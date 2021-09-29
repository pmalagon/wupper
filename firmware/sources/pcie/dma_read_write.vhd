
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class dma_read_write
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! dma_read_write contains the actual DMA state machines, it processes the descriptors
--! and reads from and writes to the PC memory if there is data in the fifo.
--! 
--! 
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Wupper: PCIe Gen3 and Gen4 DMA Core for Xilinx FPGAs
--! 
--! Copyright (C) 2021 Nikhef, Amsterdam (f.schreuder@nikhef.nl)
--! 
--! Licensed under the Apache License, Version 2.0 (the "License");
--! you may not use this file except in compliance with the License.
--! You may obtain a copy of the License at
--! 
--!         http://www.apache.org/licenses/LICENSE-2.0
--! 
--! Unless required by applicable law or agreed to in writing, software
--! distributed under the License is distributed on an "AS IS" BASIS,
--! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--! See the License for the specific language governing permissions and
--! limitations under the License.
-- 
--! @brief ieee



library ieee, UNISIM;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;-- @suppress "Deprecated package"
use ieee.std_logic_1164.all;
use work.pcie_package.all;
Library xpm;
use xpm.vcomponents.all;

entity dma_read_write is
  generic(
    NUMBER_OF_DESCRIPTORS : integer := 2;
    DATA_WIDTH            : integer := 256
    );
  port (
    clk                     : in     std_logic;
    dma_descriptors         : in     dma_descriptors_type(0 to (NUMBER_OF_DESCRIPTORS-1));
    dma_soft_reset          : in     std_logic;
    dma_status              : out    dma_statuses_type(0 to (NUMBER_OF_DESCRIPTORS-1));
    fromHostFifoIndex       : out    integer range 0 to 0;
    fromHostFifo_din        : out    std_logic_vector(DATA_WIDTH-1 downto 0);
    fromHostFifo_prog_full  : in     std_logic;
    fromHostFifo_we         : out    std_logic;
    m_axis_r_rq             : in     axis_r_type;
    m_axis_rq               : out    axis_type;
    reset                   : in     std_logic;
    s_axis_r_rc             : out    axis_r_type;
    s_axis_rc               : in     axis_type;
    toHostFifoIndex         : out    integer range 0 to NUMBER_OF_DESCRIPTORS-2;
    toHostFifo_dout         : in     std_logic_vector(DATA_WIDTH-1 downto 0);
    toHostFifo_empty_thresh : out    slv12_array(0 to NUMBER_OF_DESCRIPTORS-2);
    toHostFifo_prog_empty   : in     std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
    toHostFifo_re           : out    std_logic);
end entity dma_read_write;



architecture rtl of dma_read_write is
  constant NUMBER_OF_DESCRIPTORS_TOHOST: integer := NUMBER_OF_DESCRIPTORS -1;
  --constant NUMBER_OF_DESCRIPTORS_FROMHOST: integer := 1;

  type rw_state_type is(IDLE, START_WRITE, CONT_WRITE, START_READ, DELAY);
  signal rw_state: rw_state_type := IDLE;
  
  signal rw_state_slv: std_logic_vector(2 downto 0); -- @suppress "signal rw_state_slv is never read"
  attribute dont_touch : string;
  attribute dont_touch of rw_state_slv : signal is "true";
  
  constant IDLE_SLV                           : std_logic_vector(2 downto 0) := "000";
  constant START_WRITE_SLV                    : std_logic_vector(2 downto 0) := "001";
  constant CONT_WRITE_SLV                     : std_logic_vector(2 downto 0) := "010";
  constant START_READ_SLV                     : std_logic_vector(2 downto 0) := "100";
  constant DELAY_SLV                          : std_logic_vector(2 downto 0) := "101";
  
  type strip_state_type is(IDLE, PUSH_DATA);
  signal strip_state: strip_state_type := IDLE;
  
  signal strip_state_slv: std_logic_vector(2 downto 0); -- @suppress "signal strip_state_slv is never read"
  attribute dont_touch of strip_state_slv : signal is "true";
  
  constant PUSH_DATA_SLV                      : std_logic_vector(2 downto 0) := "001";
  signal toHostFifo_dout_pipe: std_logic_vector(127 downto 0); --pipe part of the fifo data 1 clock cycle for 256 bit alignment
  signal mem_dina_pipe: std_logic_vector(DATA_WIDTH-97 downto 0);  --pipe part of the fifo data 1 clock cycle for 256 bit alignment
  constant req_tc: std_logic_vector (2 downto 0) := "000";
  constant req_attr: std_logic_vector(2 downto 0) := "000"; --ID based ordering, Relaxed ordering, No Snoop (should be "001"?)
  signal s_axis_rc_tlast_pipe: std_logic;
  signal receive_word_count: std_logic_vector(10 downto 0);
  signal active_descriptor_s: integer range 0 to (NUMBER_OF_DESCRIPTORS-1);
  signal toHostFifoIndex_s    :   integer range 0 to NUMBER_OF_DESCRIPTORS_TOHOST-1;
  
  signal s_m_axis_rq : axis_type;
  signal evencycle_dma_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  signal dma_wait_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  signal dma_wait_pc_pointer_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  signal dma_wait_next_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  type slv64_arr is array(0 to (NUMBER_OF_DESCRIPTORS -1)) of std_logic_vector(63 downto 0);
  signal next_address_s           : slv64_arr;
  signal current_address_s           : slv64_arr;
  signal address_wrapped_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  --signal current_address: std_logic_vector(63 downto 0);
  
  signal mem_doutb : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_addra : std_logic_vector(14-f_log2(DATA_WIDTH) downto 0);
  signal mem_addrb : std_logic_vector(14-f_log2(DATA_WIDTH) downto 0);
  signal mem_dina  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_wea   : std_logic_vector(0 downto 0);
  signal mem_full  : std_logic_vector((32768/DATA_WIDTH)-1 downto 0);
  signal mem_full_p1  : std_logic_vector((32768/DATA_WIDTH)-1 downto 0);
  signal reading_mem : std_logic;
  --signal fromHostFifo_we_p0 : std_logic;
  signal clear_wait_for_4k_boundary : std_logic;
    
  signal StartSearchingAt: integer range 0 to (NUMBER_OF_DESCRIPTORS-1)*2-1;
  signal do_re_fifo: std_logic; 
  signal toHostFifo_prog_empty_s: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  signal next_address_equals_end_address: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  type IntArray_type is array(natural range <>) of integer;
  --! Alternate between a one of the ToHost descriptors (round robin) and every other turn we select the FromHost descriptor.
  constant RoundRobinLookup : IntArray_type(0 to 15) := (0,NUMBER_OF_DESCRIPTORS-1,
                                                   1,NUMBER_OF_DESCRIPTORS-1,
                                                   2,NUMBER_OF_DESCRIPTORS-1,
                                                   3,NUMBER_OF_DESCRIPTORS-1,
                                                   4,NUMBER_OF_DESCRIPTORS-1,
                                                   5,NUMBER_OF_DESCRIPTORS-1,
                                                   6,NUMBER_OF_DESCRIPTORS-1,
                                                   7,NUMBER_OF_DESCRIPTORS-1);

begin

  toHostFifoIndex <= toHostFifoIndex_s;
  fromHostFifoIndex <= 0; --constant for now, keep it to 1 fromHost descriptor.

  m_axis_rq <= s_m_axis_rq;

  s_m_axis_rq.tuser <= (others => '0');

  re_proc: process(rw_state,  m_axis_r_rq, dma_descriptors, active_descriptor_s, dma_wait_s, do_re_fifo, toHostFifo_prog_empty_s)
  begin
    if rw_state = IDLE then
        toHostFifo_re <= '0';
        if((toHostFifo_prog_empty_s(active_descriptor_s) = '0') and (m_axis_r_rq.tready = '1')) then
          if((dma_descriptors(active_descriptor_s).enable = '1') and dma_wait_s(active_descriptor_s) = '0') then
            toHostFifo_re <= m_axis_r_rq.tready;
          end if;
        end if;
    else
      toHostFifo_re <= do_re_fifo and m_axis_r_rq.tready;
    end if;
  end process;
  
  thresh: process(dma_descriptors)
    variable wc: std_logic_vector(10 downto 0);
    variable th: std_logic_vector(7 downto 0);
  begin
    for i in 0 to NUMBER_OF_DESCRIPTORS-2 loop
        wc := dma_descriptors(i).dword_count-1; --32b words
        if DATA_WIDTH = 256 then
            th := wc(10 downto 3); --256b fifo data width
        else
            th := "0"&wc(10 downto 4); --512b fifo data width
        end if;
        toHostFifo_empty_thresh(i) <= "0000"&th;
    end loop;
  end process;
  
  toHostFifo_prog_empty_s <= '1'&toHostFifo_prog_empty;
  
  add_header: process(clk)
    variable ToHostWriteCount: std_logic_vector(7 downto 0); --Supports max 128x256 or Supports max 64x512, max 4096byte TLP
    variable next_active_descriptor_v: integer range 0 to (NUMBER_OF_DESCRIPTORS-1);
    --variable read_idle_counter: integer range 0 to 255;
    --variable dma_wait_v : std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
    --variable evencycle_dma_v: std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
    variable start_transfer : std_logic := '0';
    variable advance_address, advance_address_p1 : std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
    variable wait_for_4k_boundary : std_logic;
    variable searchIndex : integer range 0 to (NUMBER_OF_DESCRIPTORS*2)-1;
    variable current_address_equals_pc_pointer : std_logic_vector(NUMBER_OF_DESCRIPTORS-1 downto 0);
  
  begin
    if(rising_edge(clk)) then
      if(reset = '1') or (dma_soft_reset = '1') then
        do_re_fifo <= '0';
        rw_state <= IDLE;
        ToHostWriteCount := x"00";
        evencycle_dma_s <= (others => '0');
        active_descriptor_s <= 0;
        wait_for_4k_boundary := '0';
        toHostFifoIndex_s <= 0;
        StartSearchingAt <= 0;
        dma_wait_next_s <= (others => '0');
        address_wrapped_s <= (others => '0'); 
      else
        --defaults:
        active_descriptor_s <= active_descriptor_s;
        
        --If FromHost descriptor is disabled, clear wait_for_4k_boundary
        if (dma_descriptors(NUMBER_OF_DESCRIPTORS-1).enable='0') then
          wait_for_4k_boundary := '0';
        end if;
        
        searchIndex := RoundRobinLookup(StartSearchingAt);
        next_active_descriptor_v := active_descriptor_s;
        if((searchIndex /= active_descriptor_s) and (dma_descriptors(searchIndex).enable='1') and dma_wait_s(searchIndex) = '0') then
          if(dma_descriptors(searchIndex).read_not_write = '0') then
              if (toHostFifo_prog_empty_s(searchIndex) = '0') then
                  next_active_descriptor_v := searchIndex; --find another active descriptor, else just continue with the current descriptor. 0 has priority above 1 and so on.
              end if;
          end if;
          if(((dma_descriptors(searchIndex).read_not_write = '1') and (fromHostFifo_prog_full = '0'))) then
            next_active_descriptor_v := searchIndex; --find another active descriptor, else just continue with the current descriptor. 0 has priority above 1 and so on.
          end if;
        end if;
          
        if(m_axis_r_rq.tready = '1') then
            do_re_fifo <= '0';
            toHostFifo_dout_pipe  <= toHostFifo_dout(DATA_WIDTH-1 downto DATA_WIDTH-128);
            advance_address := (others => '0');
            case(rw_state) is
              when IDLE =>
                if StartSearchingAt = (NUMBER_OF_DESCRIPTORS-1)*2-1 then
                  StartSearchingAt <= 0;
                else
                  StartSearchingAt <= StartSearchingAt + 1;
                end if;
                start_transfer := '0';
                active_descriptor_s <= next_active_descriptor_v;
                m_axis_rq.state <= IDLE_SLV;
                s_m_axis_rq.tvalid  <= '0';
                if(next_active_descriptor_v < NUMBER_OF_DESCRIPTORS_TOHOST) then
                    toHostFifoIndex_s <= next_active_descriptor_v;
                end if;
                rw_state_slv <= IDLE_SLV;
                if DATA_WIDTH = 256 then
                    ToHostWriteCount := dma_descriptors(active_descriptor_s).dword_count(10 downto 3); --256 cycles in a TLP, ex header
                    if dma_descriptors(active_descriptor_s).dword_count(2 downto 0) /= "000" then
                        ToHostWriteCount := ToHostWriteCount + 1;
                    end if;
                else
                    ToHostWriteCount := "0"&dma_descriptors(active_descriptor_s).dword_count(10 downto 4); --512 cycles in a TLP, ex header
                    if dma_descriptors(active_descriptor_s).dword_count(3 downto 0) /= "0000" then
                        ToHostWriteCount := ToHostWriteCount + 1;
                    end if;
                end if;
                if dma_descriptors(active_descriptor_s).enable = '1' then
                  if (dma_wait_s(active_descriptor_s) = '0') then
                    if(((dma_descriptors(active_descriptor_s).read_not_write = '0') and (toHostFifo_prog_empty_s(active_descriptor_s) = '0'))) then
                      rw_state <= START_WRITE;
                      start_transfer := '1';
                      if ToHostWriteCount > 1 then
                        do_re_fifo <= '1';
                      end if;
                    end if;
                    if(((dma_descriptors(active_descriptor_s).read_not_write = '1') and (fromHostFifo_prog_full = '0')) and (wait_for_4k_boundary = '0')) then
                      rw_state <= START_READ;
                      start_transfer := '1';
                    end if;
                    if start_transfer = '1' then
                      active_descriptor_s <= active_descriptor_s;
                      toHostFifoIndex_s <= toHostFifoIndex_s;
                    end if;
                  end if;
                end if;  
              when START_WRITE =>
                  m_axis_rq.state <= START_WRITE_SLV;
                                      -----DW 7-4
                  s_m_axis_rq.tdata(DATA_WIDTH-1 downto 0)  <= toHostFifo_dout(DATA_WIDTH-129 downto 0) & --128 bits data
                                      -----DW 3
                                      '0'&       --31 - 1 bit reserved          127
                                      req_attr & --30-28 3 bits Attr            124-126
                                      req_tc &   -- 27-25 3- bits           121-123
                                      '0'&       -- 24 req_id enable            120
                                      x"0000" &  --xcompleter_id_bus,    -- 23-16 Completer Bus number - selected if Compl ID    = 1  104-119
                                                 --completer_id_dev_func, --15-8 Compl Dev / Func no - sel if Compl ID = 1
                                      x"00" &    -- 7-0 Client Tag  96-103
                                      --DW 2    
                                      x"0000" &  --req_rid,       -- 31-16 Requester ID - 16 bits    80-95
                                      '0' &      -- poisoned request 1'b0,          -- 15 Rsvd      79
                                      "0001" &   -- memory WRITE request            75-78
                                      dma_descriptors(active_descriptor_s).dword_count &  -- 10-0 DWord Count 0 - IO Write completions -64-74
                                      --DW 1-0
                                      current_address_s(active_descriptor_s)(63 downto 2) & "00";  --62 bit word address address + 2 bit Address type (0, untranslated)
                  if ToHostWriteCount >2 then
                    do_re_fifo <= '1';
                  end if;
                  ToHostWriteCount := ToHostWriteCount - 1;
                  s_m_axis_rq.tkeep <= (others => '1');
                  rw_state <= CONT_WRITE;
                  s_m_axis_rq.tlast <= '0';
                  s_m_axis_rq.tvalid <= '1';
                  advance_address(active_descriptor_s) := '1';
                  active_descriptor_s <= next_active_descriptor_v;
              when CONT_WRITE  =>
                  m_axis_rq.state <= CONT_WRITE_SLV;
                  rw_state <= CONT_WRITE; --default
                  s_m_axis_rq.tdata(DATA_WIDTH-1 downto 0)  <= toHostFifo_dout(DATA_WIDTH-129 downto 0) & --DATAWIDTH-129 bits data
                                    toHostFifo_dout_pipe; --128 bits data from last clock cycle
                  if ToHostWriteCount /= 0 then
                    if ToHostWriteCount > 2 then
                      do_re_fifo <= '1';
                    end if;
                    s_m_axis_rq.tlast <= '0';
                    s_m_axis_rq.tkeep  <= (others => '1');
                  else
                    s_m_axis_rq.tlast <= '1';
                    rw_state <= IDLE;
                    
                                
                    s_m_axis_rq.tkeep <= (others => '0'); --for 16 bit tkeep
                    s_m_axis_rq.tkeep(7 downto 0) <= x"0F";
                    if(active_descriptor_s < NUMBER_OF_DESCRIPTORS_TOHOST) then
                        toHostFifoIndex_s <= active_descriptor_s;
                    end if;
                  end if;
                  ToHostWriteCount := ToHostWriteCount - 1;             
                  s_m_axis_rq.tvalid <= '1';
              when START_READ  =>
                  m_axis_rq.state <= START_READ_SLV;
                                      -----DW 7-4
                  s_m_axis_rq.tdata(DATA_WIDTH-1 downto 128) <= (others => '0');
                  s_m_axis_rq.tdata(127 downto 0)  <= 
                                      -----DW 3
                                      '0' &      --31 - 1 bit reserved
                                      req_attr & --30-28 3 bits Attr
                                      req_tc &   -- 27-25 3- bits
                                      '0' &      -- 24 req_id enable
                                      x"0000" &  --xcompleter_id_bus,    -- 23-16 Completer Bus number - selected if Compl ID    = 1
                                                 --completer_id_dev_func, --15-8 Compl Dev / Func no - sel if Compl ID = 1
                                      x"00" &    -- 7-0 Client Tag
                                      --DW 2
                                      x"0000" &  --req_rid,       -- 31-16 Requester ID - 16 bits
                                      '0' &      -- poisoned request 1'b0,          -- 15 Rsvd
                                      "0000" &   -- memory READ request
                                      dma_descriptors(active_descriptor_s).dword_count&  -- 10-0 DWord Count 0 - IO Write completions
                                      --DW 1-0
                                      current_address_s(active_descriptor_s)(63 downto 2)&"00"; --62 bit word address address + 2 bit Address type (0, untranslated)
                  s_m_axis_rq.tlast <= '1';
                  rw_state <= DELAY;
                  if(next_active_descriptor_v < NUMBER_OF_DESCRIPTORS_TOHOST) then
                      toHostFifoIndex_s <= next_active_descriptor_v;
                  end if;
                  advance_address(active_descriptor_s) := '1';
                  active_descriptor_s <= next_active_descriptor_v;
                              
                  s_m_axis_rq.tkeep  <= (others => '0'); --for 16 bit tkeep 
                  s_m_axis_rq.tkeep(7 downto 0)  <= x"0F";
                  s_m_axis_rq.tvalid <= '1';

              when DELAY =>
                  m_axis_rq.state <= DELAY_SLV;
                  s_m_axis_rq.tvalid <= '0';
                  rw_state <= IDLE;
              when others =>
                  m_axis_rq.state <= "111";
                  rw_state <= IDLE;
            end case;
            
            dma_wait_s <= (others => '0');
            dma_wait_pc_pointer_s <= (others => '0');
            for i in 0 to NUMBER_OF_DESCRIPTORS-1 loop
                address_wrapped_s(i) <= '0'; 
                if advance_address_p1(i) = '1'  then
                    current_address_s(i) <= next_address_s(i);
                    next_address_s(i) <= (next_address_s(i) + (dma_descriptors(i).dword_count&"00"));
                
                    if(next_address_s(i)=dma_descriptors(i).pc_pointer) and dma_descriptors(i).enable = '1' then
                        current_address_equals_pc_pointer(i) := '1';
                    else
                        current_address_equals_pc_pointer(i) := '0';
                    end if;
                else --if dma_descriptors(i).pc_pointer_updated = '1' then
                    if(current_address_s(i)=dma_descriptors(i).pc_pointer) and dma_descriptors(i).enable = '1' then
                        current_address_equals_pc_pointer(i) := '1';
                    else
                        current_address_equals_pc_pointer(i) := '0';
                    end if;
                end if;
                if (dma_descriptors(i).enable = '0' ) then
                    evencycle_dma_s(i) <= '0';
                end if;
                if(dma_descriptors(i).wrap_around = '1' and dma_descriptors(i).enable = '1' and (evencycle_dma_s(i) xor dma_descriptors(i).read_not_write) /= dma_descriptors(i).evencycle_pc) then
                    if(current_address_equals_pc_pointer(i) = '1') then
                        dma_wait_s(i) <= '1'; --the PC is not ready to accept data, so we have to wait. dma_wait will clear the enable flag of the descriptors towards dma_read_write
                        dma_wait_pc_pointer_s(i) <= '1'; --same as dma_wait, but only for the pc_pointer case. Helper signal to see if we are allowed to wrap around
                    end if;
                end if;
                if advance_address_p1(i) = '1' or dma_descriptors(i).wrap_around = '1' then
                    if next_address_s(i) = dma_descriptors(i).end_address and dma_descriptors(i).enable = '1' then
                        next_address_equals_end_address(i) <= '1';
                        dma_wait_s(i) <= '1';--dma_descriptors(i).wrap_around; --give dma_control one extra clock cycle to disable it.
                    else
                        next_address_equals_end_address(i) <= '0';
                    end if;
                end if;
                if next_address_equals_end_address(i) = '1' and dma_wait_pc_pointer_s(i) = '0' then
                    next_address_s(i) <= dma_descriptors(i).start_address;
                    next_address_equals_end_address(i) <= '0';
                    evencycle_dma_s(i) <= (not evencycle_dma_s(i)) and dma_descriptors(i).wrap_around;
                    address_wrapped_s(i) <= '1'; --tell dma_control that we wrapped around
                    dma_wait_s(i) <= '1';--dma_descriptors(i).wrap_around; --give dma_control one extra clock cycle to disable it.
                    dma_wait_next_s(i) <= dma_descriptors(i).wrap_around;
                end if;
                if advance_address_p1(i) = '1' and next_address_s(i)(11 downto 0) = x"000" and dma_descriptors(i).read_not_write = '1' and dma_descriptors(i).enable = '1' then
                    wait_for_4k_boundary := '1';
                end if;
            end loop;
            advance_address_p1 := advance_address;
            if dma_wait_next_s /= (dma_wait_next_s'range => '0') then
                dma_wait_s <= dma_wait_s or dma_wait_next_s; --This will set dma_wait_s high for two clocks using this mechanism.
                dma_wait_next_s <= (others => '0');
            end if;
        end if; --tready
        
        for i in 0 to NUMBER_OF_DESCRIPTORS-1 loop
            if dma_descriptors(i).enable = '0' then
                current_address_s(i) <= dma_descriptors(i).start_address;
                next_address_s(i) <= (dma_descriptors(i).start_address + (dma_descriptors(i).dword_count&"00"));
                current_address_equals_pc_pointer(i) := '1'; --In case the pc_pointer is still at start_address, 
                                                          --we may be too late for the comparison, 
                                                          --so initialize it to 1 before enabling, 
                                                          --See Carlos comment from 8-3-2021 on FLX-1442
            end if;
        end loop; 
        if clear_wait_for_4k_boundary = '1' then
            wait_for_4k_boundary := '0';
        end if;
      end if; --clk
    end if; --reset
  end process;

  g0: for i in 0 to (NUMBER_OF_DESCRIPTORS-1) generate
    dma_status(i).evencycle_dma <= evencycle_dma_s(i);
    dma_status(i).current_address <= current_address_s(i);
    dma_status(i).address_wrapped <= address_wrapped_s(i);
  end generate;
   

  s_axis_r_rc.tready <= '1';  --not fromHostFifo_prog_full;

  strip_hdr: process(clk)
    --variable receive_word_count_v: std_logic_vector(10 downto 0);
  begin
    if(rising_edge(clk)) then
      if(reset = '1') or (dma_soft_reset = '1') then
        strip_state <= IDLE;
        mem_wea <= "0";
        mem_full <= (others => '0');
        mem_addra <= (others => '0');
        mem_addrb <= (others => '0');
        fromHostFifo_we <= '0';
      else
        --defaults:
        strip_state <= IDLE;
        mem_wea <= "0";
        s_axis_rc_tlast_pipe <= s_axis_rc.tlast;
        --s_axis_rc_tvalid_pipe <= s_axis_rc.tvalid;
        receive_word_count <= receive_word_count;
        case (strip_state) is
          when IDLE =>
            strip_state_slv <= IDLE_SLV;
            strip_state <= IDLE;  --stay in idle if no data with a valid tag is found
            if(s_axis_rc.tvalid = '1') then
              mem_dina_pipe <= s_axis_rc.tdata(DATA_WIDTH-1 downto 96); --pipeline 160 bits of data
              receive_word_count <= s_axis_rc.tdata(42 downto 32);
              
              mem_addra <= s_axis_rc.tdata(11 downto f_log2(DATA_WIDTH)-3);
              
              strip_state <= PUSH_DATA;
            end if;
          when PUSH_DATA =>
            strip_state_slv <= PUSH_DATA_SLV;
            strip_state <= PUSH_DATA;
            if((s_axis_rc.tvalid='1' or s_axis_rc_tlast_pipe = '1')) then
              mem_wea <= "1";
              
              if mem_wea = "1" then
                mem_addra <= mem_addra+1;
              end if;
            
              mem_dina_pipe <= s_axis_rc.tdata(DATA_WIDTH-1 downto 96); --pipeline 160 bits of data
              mem_dina <= s_axis_rc.tdata(95 downto 0) & mem_dina_pipe;
              if(receive_word_count <= (DATA_WIDTH/32) or (s_axis_rc_tlast_pipe = '1')) then
                receive_word_count <= (others => '0');
                strip_state <= IDLE;
              else
                receive_word_count <= receive_word_count - (DATA_WIDTH/32);
              end if;
            else
              mem_dina_pipe <= mem_dina_pipe;
            end if;
        end case;
        
        if mem_wea = "1" then
            mem_full(to_integer(unsigned(mem_addra))) <= '1';
        end if;
        --! Read out memory and write into fromHostFifo
        clear_wait_for_4k_boundary <= '0';
        fromHostFifo_we <= '0';
        mem_full_p1 <= mem_full;
        if reading_mem = '0' then --We are not in the process of dumping the complete memory into the fifo, start at 0
            if(mem_full_p1(0) = '1') then
                mem_addrb <= mem_addrb + 1;
                reading_mem <= '1';
                fromHostFifo_we <= '1'; --we will write the fifo in the next cycle, when the ram is read out.
                mem_full(0) <= '0';
            end if;
        else
            if(mem_full_p1(to_integer(unsigned(mem_addrb))) = '1') then
                if(mem_addrb /= (mem_addrb'range => '1')) then
                    mem_addrb <= mem_addrb + 1;
                else
                    reading_mem <= '0';
                    mem_addrb <= (others => '0');
                    clear_wait_for_4k_boundary <= '1';
                end if;
                fromHostFifo_we <= '1'; --we will write the fifo in the next cycle, when the ram is read out.
                mem_full(to_integer(unsigned(mem_addrb))) <= '0';
            else
                if mem_full(0) = '1' then --if address 0 is written, go back immediately
                    reading_mem <= '0';
                    mem_addrb <= (others => '0');
                    clear_wait_for_4k_boundary <= '1';
                end if;
            end if;
        end if;
        

      end if; --clk
    end if; --reset
  end process;
  
  
  fromHostFifo_din <= mem_doutb;

   rc_interface_mem : xpm_memory_sdpram
   generic map ( -- @suppress "Generic map uses default values. Missing optional actuals: USE_EMBEDDED_CONSTRAINT, CASCADE_HEIGHT, SIM_ASSERT_CHK, RST_MODE_A, RST_MODE_B" -- @suppress "Generic map uses default values. Missing optional actuals: USE_MEM_INIT_MMI, USE_EMBEDDED_CONSTRAINT, CASCADE_HEIGHT, SIM_ASSERT_CHK, WRITE_PROTECT, RST_MODE_A, RST_MODE_B"
      ADDR_WIDTH_A => 15-f_log2(DATA_WIDTH),
      ADDR_WIDTH_B => 15-f_log2(DATA_WIDTH),
      AUTO_SLEEP_TIME => 0,
      BYTE_WRITE_WIDTH_A => DATA_WIDTH,
      --CASCADE_HEIGHT => 0,
      CLOCKING_MODE => "common_clock",
      ECC_MODE => "no_ecc",
      MEMORY_INIT_FILE => "none",
      MEMORY_INIT_PARAM => "0",
      MEMORY_OPTIMIZATION => "true",
      MEMORY_PRIMITIVE => "auto",
      MEMORY_SIZE => 32768,
      MESSAGE_CONTROL => 0,
      READ_DATA_WIDTH_B => DATA_WIDTH,
      READ_LATENCY_B => 1,
      READ_RESET_VALUE_B => "0",
      --RST_MODE_A => "SYNC",
      --RST_MODE_B => "SYNC",
      --SIM_ASSERT_CHK => 0,
      --USE_EMBEDDED_CONSTRAINT => 0,
      USE_MEM_INIT => 1,
      WAKEUP_TIME => "disable_sleep",
      WRITE_DATA_WIDTH_A => DATA_WIDTH,
      WRITE_MODE_B => "no_change"
   )
   port map (
      sleep => '0',
      clka => clk,
      ena => '1',
      wea => mem_wea,
      addra => mem_addra,
      dina => mem_dina,
      injectsbiterra => '0',
      injectdbiterra => '0',
      clkb => clk,
      rstb => reset,
      enb => '1',
      regceb => '1',
      addrb => mem_addrb,
      doutb => mem_doutb,
      sbiterrb => open,
      dbiterrb => open
   );
end architecture rtl ; -- of dma_read_write
