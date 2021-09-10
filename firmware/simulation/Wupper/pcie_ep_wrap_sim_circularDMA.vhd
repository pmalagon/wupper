
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_ep_wrap
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
--! Wrapper unit for the PCI Express core, and the clock generator 
--!
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity pcie_ep_wrap is
  generic(
    CARD_TYPE : integer := 710;
    DEVID     : std_logic_vector(15 downto 0) := x"7038";
    DATA_WIDTH: integer := 256);
  port (
    cfg_fc_cpld                : out    std_logic_vector(11 downto 0);
    cfg_fc_cplh                : out    std_logic_vector(7 downto 0);
    cfg_fc_npd                 : out    std_logic_vector(11 downto 0);
    cfg_fc_nph                 : out    std_logic_vector(7 downto 0);
    cfg_fc_pd                  : out    std_logic_vector(11 downto 0);
    cfg_fc_ph                  : out    std_logic_vector(7 downto 0);
    cfg_fc_sel                 : in     std_logic_vector(2 downto 0);
    cfg_interrupt_msix_address : in     std_logic_vector(63 downto 0);
    cfg_interrupt_msix_data    : in     std_logic_vector(31 downto 0);
    cfg_interrupt_msix_enable  : out    std_logic_vector(3 downto 0);
    cfg_interrupt_msix_fail    : out    std_logic;
    cfg_interrupt_msix_int     : in     std_logic;
    cfg_interrupt_msix_sent    : out    std_logic;
    cfg_mgmt_addr              : in     std_logic_vector(18 downto 0);
    cfg_mgmt_byte_enable       : in     std_logic_vector(3 downto 0);
    cfg_mgmt_read              : in     std_logic;
    cfg_mgmt_read_data         : out    std_logic_vector(31 downto 0);
    cfg_mgmt_read_write_done   : out    std_logic;
    cfg_mgmt_write             : in     std_logic;
    cfg_mgmt_write_data        : in     std_logic_vector(31 downto 0);
    clk                        : out    std_logic;
    m_axis_cq                  : out    axis_type;
    m_axis_r_cq                : in     axis_r_type;
    m_axis_r_rc                : in     axis_r_type;
    m_axis_rc                  : out    axis_type;
    pci_exp_rxn                : in     std_logic_vector(7 downto 0);
    pci_exp_rxp                : in     std_logic_vector(7 downto 0);
    pci_exp_txn                : out    std_logic_vector(7 downto 0);
    pci_exp_txp                : out    std_logic_vector(7 downto 0);
    reset                      : out    std_logic;
    s_axis_cc                  : in     axis_type;
    s_axis_r_cc                : out    axis_r_type;
    s_axis_r_rq                : out    axis_r_type;
    s_axis_rq                  : in     axis_type;
    sys_clk_n                  : in     std_logic;
    sys_clk_p                  : in     std_logic;
    sys_rst_n                  : in     std_logic;
    user_lnk_up                : out    std_logic);
end entity pcie_ep_wrap;



architecture structure of pcie_ep_wrap is
  
  signal user_clk: std_logic;
  constant user_clk_period: time  := 4 ns;
      
  constant BAR0: std_logic_vector(31 downto 0) := x"BA00_8000";   
  constant BAR1: std_logic_vector(31 downto 0) := x"BA00_8001";   
  constant BAR2: std_logic_vector(31 downto 0) := x"BA00_8002";   
  type slvD_array is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ToHostMem: slvD_array(0 to 127);  
  signal FromHostMem: slvD_array(0 to 127);  
  signal compare_success : std_logic;
  signal compare_unknown : std_logic;
  signal compare_error   : std_logic;
  signal FromHostWrapCount : integer:= 1;
  signal ToHostWrapCount : integer:= 0;
  
  
begin
    user_clk_proc: process
    begin
        user_clk <= '1';
        wait for user_clk_period / 2;
        user_clk <= '0';
        wait for user_clk_period / 2;
    end process;

    cfg_fc_cpld                <= (others => '0');--: out    std_logic_vector(11 downto 0);
    cfg_fc_cplh                <= (others => '0');--: out    std_logic_vector(7 downto 0);
    cfg_fc_npd                 <= (others => '0');--: out    std_logic_vector(11 downto 0);
    cfg_fc_nph                 <= (others => '0');--: out    std_logic_vector(7 downto 0);
    cfg_fc_pd                  <= (others => '0');--: out    std_logic_vector(11 downto 0);
    cfg_fc_ph                  <= (others => '0');--: out    std_logic_vector(7 downto 0);
    --cfg_fc_sel                 : in     std_logic_vector(2 downto 0);
    --cfg_interrupt_msix_address : in     std_logic_vector(63 downto 0);
    --cfg_interrupt_msix_data    : in     std_logic_vector(31 downto 0);
    cfg_interrupt_msix_enable  <= (others => '1');--: out    std_logic_vector(3 downto 0);
    cfg_interrupt_msix_fail    <= '0';--: out    std_logic;
    cfg_interrupt_msix_sent    <= cfg_interrupt_msix_int;--: out    std_logic;
    
    mgmt_proc: process(user_clk)
    begin
        if rising_edge(user_clk) then
            cfg_mgmt_read_write_done <= cfg_mgmt_read or cfg_mgmt_write;
            if cfg_mgmt_addr = "000"&x"0004" and cfg_mgmt_read = '1' then --read BAR0
              cfg_mgmt_read_data <= BAR0; --BAR0 address
            end if;
            if cfg_mgmt_addr = "000"&x"0005" and cfg_mgmt_read = '1' then --read BAR0
              cfg_mgmt_read_data <= BAR1; --BAR0 address
            end if;
            if cfg_mgmt_addr = "000"&x"0006" and cfg_mgmt_read = '1' then --read BAR0
              cfg_mgmt_read_data <= BAR2; --BAR0 address
            end if;            
        end if;
    end process;
    
    reg_write: process
        procedure w
     (RegAddr: in std_logic_vector(19 downto 0);
      BarAddr: in std_logic_vector(31 downto 0);
      Data:    in std_logic_vector(63 downto 0)) is
      variable bar_id: std_logic_vector(2 downto 0):= "000";
    begin
      wait until rising_edge(user_clk);
      m_axis_cq.tdata <= (others => '0');
      
      m_axis_cq.tdata(1 downto 0) <= "00"; --address type
      m_axis_cq.tdata(63 downto 32) <= x"0000_0000";
      m_axis_cq.tdata(31 downto 20) <= BarAddr(31 downto 20);
      m_axis_cq.tdata(19 downto 2) <= RegAddr(19 downto 2);
      
      m_axis_cq.tdata(74 downto 64) <= "00000000010";-- 2 words, 64 bit write dword_count_s;
      m_axis_cq.tdata(78 downto 75) <= "0001"; --Memory write, request_type_v
      m_axis_cq.tdata(95 downto 80)    <= x"0000";--requester_id_s
      m_axis_cq.tdata(103 downto 96)   <= x"00";--tag_s
      m_axis_cq.tdata(111 downto 104)  <= x"00";--target_function_s
      if BarAddr = BAR0 then
        bar_id := "000";
      end if;
      if BarAddr = BAR1 then
        bar_id := "001";
      end if;
      if BarAddr = BAR2 then
        bar_id := "010";
      end if;
      m_axis_cq.tdata(114 downto 112)  <= bar_id;
      m_axis_cq.tdata(120 downto 115)  <= "000000";--bar_aperture_s
      m_axis_cq.tdata(123 downto 121)  <= "000";--transaction_class_s
      m_axis_cq.tdata(126 downto 124)  <= "000";--attributes_s
      m_axis_cq.tdata(191 downto 128)  <= Data; --register_write_data_250_s
      m_axis_cq.tdata(DATA_WIDTH-1 downto 192)  <= (others => '0'); --register_write_data_250_s
      m_axis_cq.tuser(3 downto 0)      <= "1111";--first_be_s
      m_axis_cq.tuser(84 downto 0)      <= (others => '0');
      if DATA_WIDTH = 512 then
        m_axis_cq.tuser(11 downto 8)      <= "1111";--last_be_s
      else
        m_axis_cq.tuser(7 downto 4)      <= "1111";--last_be_s
      end if;
      m_axis_cq.tkeep(m_axis_cq.tkeep'high downto 0)      <= (others => '0'); --For 512bit mode
      m_axis_cq.tkeep(7 downto 0)      <= "00111111"; --64b writes, don't care about the MSB 64 bits
      m_axis_cq.tvalid                 <= '1';
      m_axis_cq.tlast                  <= '1';
      wait until rising_edge(user_clk);
      m_axis_cq.tvalid                 <= '0';
      m_axis_cq.tlast                  <= '0';
      while m_axis_r_cq.tready = '0' loop
        wait until rising_edge(user_clk);
      end loop;
           
    end w;
    begin
        wait for 1 us; --startup time
        w(REG_PC_PTR_GAP, BAR0, x"0000_0000_0000_0020"); --set pc_ptr_gap to 32
                
        w(REG_DESCRIPTOR_0,      BAR0, x"ABCD_0000_0000_0000"); --descr 0 start address
        w(REG_DESCRIPTOR_0+8,    BAR0, x"ABCD_0000_0000_0000"+(16*DATA_WIDTH)); --descr 0 end address = end address + 4096 (16 TLPs of 256 bytes)
        w(REG_DESCRIPTOR_0a+8,   BAR0, x"ABCD_0000_0000_0000"); --init PC pointer at start_address
        w(REG_DESCRIPTOR_0a,     BAR0, x"0000_0000_0000_1040"); --wrap around, ToHost, 256 bytes  
        w(REG_DESCRIPTOR_1,      BAR0, x"DEF8_0000_0000_0000"); --descr 1 start address
        w(REG_DESCRIPTOR_1+8,    BAR0, x"DEF8_0000_0000_0000"+(16*DATA_WIDTH)); --descr 1 end address = end address + 4096 (16 TLPs of 256 bytes)
        w(REG_DESCRIPTOR_1a+8,   BAR0, x"DEF8_0000_0000_0000"); --init PC pointer at start_address
        w(REG_DESCRIPTOR_1a,     BAR0, x"0000_0000_0000_1800"+(DATA_WIDTH/32)); --wrap around, FromHost, 32 or 64 bytes 
        w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_0003"); --Enable both descriptors  
        --wait for 1 us;
        --w(REG_DESCRIPTOR_1a+8  , BAR0, x"DEF8_0000_0000_0020"); --increment PC pointer with 1 TLP
        --wait for 1 us;
        --w(REG_DESCRIPTOR_1a+8  , BAR0, x"DEF8_0000_0000_0060"); --increment PC pointer with 2 TLPs
        --wait for 1 us;
        --w(REG_DESCRIPTOR_1a+8  , BAR0, x"DEF8_0000_0000_0020"); --Wrap around to 0x20
        
        --wait for 1 us;
        --w(REG_DESCRIPTOR_0a+8,   BAR0, x"ABCD_0000_0000_0800"); --Icrement ToHost pc_pointer with 8 TLPs (half way the buffer)
        --w(REG_DESCRIPTOR_1a+8,   BAR0, x"DEF8_0000_0000_0800"); --Also start reading FromHost
        

        for round in 0 to 4 loop
          if round = 4 then
          
            wait for 100 ns;
            w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_0000"); --Disable both descriptors  
            wait for 100 ns;
            w(REG_FIFO_FLUSH, BAR0, x"0000_0000_0000_0001"); --Flush the fifo's we are switching to single shot FromHost
            wait for 500 ns;  
            w(REG_DESCRIPTOR_1a,     BAR0, x"0000_0000_0000_0800"+(DATA_WIDTH/32)); --single shot, FromHost, 32 or 64 bytes
            wait for 500 ns;
            w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_0003"); --Enable both descriptors
              
                                        
          end if;
              
          for i in 0 to 15 loop
            w(REG_DESCRIPTOR_0a+8,   BAR0, x"ABCD_0000_0000_0000"+(i*DATA_WIDTH)); --Wrap ToHost pc_pointer
            wait for 100 ns;
            if round < 4 then
              for j in 0 to (2048/DATA_WIDTH)-1 loop
                w(REG_DESCRIPTOR_1a+8,   BAR0, x"DEF8_0000_0000_0000"+(i*DATA_WIDTH)+(j*(DATA_WIDTH/8)));
                wait for 100 ns; 
              end loop;
            end if;
          end loop;  
          w(REG_DESCRIPTOR_1a+8,   BAR0, x"DEF8_0000_0000_0000"); --wrap to start_address;
                          
        end loop;                
        wait for 1 us;
        --wait;
        
    end process;
    s_axis_r_cc.tready <= '1';
    
    g_FromHostMem: for i in 0 to 127 generate
     g_256: if DATA_WIDTH = 256 generate
        FromHostMem(i) <= 
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32));
      end generate;
      g_512: if DATA_WIDTH = 512 generate
        FromHostMem(i) <= 
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32))&
        std_logic_vector(to_unsigned(i, 32))&std_logic_vector(to_unsigned(FromHostWrapCount, 32));
      end generate;
    end generate;
    
    response_proc: process(user_clk)
        variable ToHost_tlp_busy: std_logic := '0';
        variable address: std_logic_vector(63 downto 0);
        variable dword_count: std_logic_vector(10 downto 0);
        variable request_type: std_logic_vector(3 downto 0); --"0001" for write, "0000" for read.
        variable ToHost_pipe_data: std_logic_vector(DATA_WIDTH-129 downto 0);
        variable TLPsToSend: integer range 0 to 65536:= 0;
        variable FromHostIndex: integer range 0 to 127;
        variable ToHostIndex: integer range 0 to 127;
        variable FromHost_pipe_data: std_logic_vector(95 downto 0);
        variable TlpIndex: integer range 0 to 127:= 0;
    begin
        if rising_edge(user_clk) then
            if s_axis_rq.tvalid = '1' then
                if ToHost_tlp_busy = '0' then --first word, decode everything from header.
                    address := s_axis_rq.tdata(63 downto 2) & "00";
                    dword_count := s_axis_rq.tdata(74 downto 64);
                    request_type := s_axis_rq.tdata(78 downto 75);
                    ToHost_pipe_data := s_axis_rq.tdata(DATA_WIDTH-1 downto 128);
                    if request_type = "0000" then 
                        FromHostIndex := to_integer(unsigned(address(10 + (DATA_WIDTH/256) downto 4 + (DATA_WIDTH/256))));
                        if FromHostIndex = 127 then
                          FromHostWrapCount <= FromHostWrapCount + 1;
                        end if;
                        TLPsToSend := TLPsToSend + 1;
                    end if;
                    if request_type = "0001" then 
                        ToHostIndex := to_integer(unsigned(address(10 + (DATA_WIDTH/256) downto 4 + (DATA_WIDTH/256))));
                        if ToHostIndex = 0 then
                          ToHostWrapCount <= ToHostWrapCount + 1;
                          for i in 0 to 127 loop
                            ToHostMem(i) <= (others => 'U');
                          end loop;
                        end if;
                                                
                    end if;
                    ToHost_tlp_busy := '1';
                else
                    ToHostMem(ToHostIndex) <=  s_axis_rq.tdata(127 downto 0) & ToHost_pipe_data; --write the TLP in the host memory.
                    ToHost_pipe_data := s_axis_rq.tdata(DATA_WIDTH-1 downto 128);
                    ToHostIndex := ToHostIndex + 1;
                end if;
                if s_axis_rq.tlast = '1' then
                    ToHost_tlp_busy := '0';
                end if;
            end if;
            if(m_axis_r_rc.tready = '1') then
                m_axis_rc.tvalid <= '0';
                m_axis_rc.tdata <= (others => '0');
                m_axis_rc.tuser <= (others => '0');
                m_axis_rc.tkeep <= (others => '0');
                if TLPsToSend > 0 and TlpIndex = 0 then
                    m_axis_rc.tdata(DATA_WIDTH-1 downto 96) <= FromHostMem(FromHostIndex)(DATA_WIDTH-97 downto 0);
                    FromHost_pipe_data := FromHostMem(FromHostIndex)(DATA_WIDTH-1 downto DATA_WIDTH-96);
                    m_axis_rc.tdata(42 downto 32) <= dword_count;
                    m_axis_rc.tvalid <= '1';
                    TlpIndex := to_integer(unsigned(dword_count(10 downto (2+(DATA_WIDTH/256)))));
                    FromHostIndex := FromHostIndex + 1;            
                    m_axis_rc.tlast <= '0';
                    TLPsToSend := TLPsToSend - 1 ;
                    m_axis_rc.tkeep <= (others => '1');
                elsif TlpIndex > 0 then
                    m_axis_rc.tdata(95 downto 0) <= FromHost_pipe_data;
                    m_axis_rc.tvalid <= '1';
                    if(TlpIndex > 1) then
                        m_axis_rc.tdata(DATA_WIDTH-1 downto 96) <= FromHostMem(FromHostIndex)(DATA_WIDTH-97 downto 0);
                        FromHost_pipe_data := FromHostMem(FromHostIndex)(DATA_WIDTH-1 downto DATA_WIDTH-96);
                        m_axis_rc.tlast <= '0';
                        m_axis_rc.tkeep <= (others => '1');
                        FromHostIndex := FromHostIndex + 1;
                    else
                        m_axis_rc.tdata(DATA_WIDTH-1 downto 96) <= (others => '0');
                        m_axis_rc.tlast <= '1';
			m_axis_rc.tkeep <= (others => '0');
                        m_axis_rc.tkeep(7 downto 0) <= x"07";
                    end if;
                    TlpIndex := TlpIndex - 1;
                          
                end if;
            end if;
        end if;
    end process;
                  
    
    compare_proc: process(ToHostMem, FromHostMem)
    begin
      compare_unknown <= '0';
      compare_error <= '0';
      compare_success <= '1';
                    
      for i in 0 to 127 loop
        if ToHostMem(i) /= FromHostMem(i) and ToHostWrapCount = FromHostWrapCount then
          compare_success <= '0';
          if ToHostMem(i) = (ToHostMem(i)'range => 'U') or FromHostMem(i) = (FromHostMem(i)'range => 'U') then
            compare_unknown <= '1';
          else
            compare_error <= '1';
            report "At index: " & integer'image(i) severity warning;
            report "ToHost: " & integer'image(to_integer(unsigned(ToHostMem(i)(7 downto 0)))) severity warning;
            report "FromHost: " & integer'image(to_integer(unsigned(FromHostMem(i)(7 downto 0)))) severity warning;
            assert false;
          end if; 
        end if;
      end loop;
    end process;
    
    --m_axis_r_rc                : in     axis_r_type;
    --m_axis_rc                  : out    axis_type;
    s_axis_r_rq.tready <= '1';
    --s_axis_rq                  : in     axis_type;
    
    pci_exp_txn         <= (others => '0');--       : out    std_logic_vector(7 downto 0);
    pci_exp_txp         <= (others => '0');--       : out    std_logic_vector(7 downto 0);
    user_lnk_up   <= '1';--             : out    std_logic

   
    reset <= not sys_rst_n;
    clk   <= user_clk;

end architecture structure ; -- of pcie_ep_wrap

