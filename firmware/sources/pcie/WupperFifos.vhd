



library ieee, UNISIM, XPM;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use XPM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;-- @suppress "Deprecated package"
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity WupperFifos is
  generic(
    NUMBER_OF_DESCRIPTORS : integer := 3;
    DATA_WIDTH            : integer := 256);
  port (
    --fromHostFifoIndex                   : in     integer range 0 to 0;
    fromHostFifo_din                    : in     std_logic_vector(DATA_WIDTH-1 downto 0);
    fromHostFifo_dout                   : out    std_logic_vector(DATA_WIDTH-1 downto 0);
    fromHostFifo_empty                  : out    std_logic;
    fromHostFifo_pfull_threshold_assert : in     std_logic_vector(8 downto 0);
    fromHostFifo_pfull_threshold_negate : in     std_logic_vector(8 downto 0);
    fromHostFifo_prog_full              : out    std_logic;
    fromHostFifo_rd_clk                 : in     std_logic;
    fromHostFifo_rd_en                  : in     std_logic;
    fromHostFifo_rst                    : in     std_logic;
    fromHostFifo_we                     : in     std_logic;
    fromHostFifo_wr_clk                 : in     std_logic;
    toHostFifoIndex                     : in     integer range 0 to NUMBER_OF_DESCRIPTORS-2;
    toHostFifo_din                      : in     slv_array(0 to NUMBER_OF_DESCRIPTORS-2);
    toHostFifo_dout                     : out    std_logic_vector(DATA_WIDTH-1 downto 0);
    toHostFifo_empty_thresh             : in     slv12_array(0 to NUMBER_OF_DESCRIPTORS-2);
    toHostFifo_pfull_threshold_assert   : in     std_logic_vector(11 downto 0);
    toHostFifo_pfull_threshold_negate   : in     std_logic_vector(11 downto 0);
    toHostFifo_prog_empty               : out    std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
    toHostFifo_prog_full                : out    std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
    toHostFifo_rd_clk                   : in     std_logic;
    toHostFifo_re                       : in     std_logic;
    toHostFifo_rst                      : in     std_logic;
    toHostFifo_wr_clk                   : in     std_logic;
    toHostFifo_wr_data_count            : out    slv12_array(0 to NUMBER_OF_DESCRIPTORS-2);
    toHostFifo_wr_en                    : in     std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0));
end entity WupperFifos;



architecture rtl of WupperFifos is
    function f_log2 (constant x : positive) return natural is
        variable i : natural;
    begin
        i := 0;
        while (2**i < x) and i < 31 loop
            i := i + 1;
        end loop;
        return i;
    end function;

  signal toHostFifoIndex_p1           : integer range 0 to NUMBER_OF_DESCRIPTORS-2;
  signal toHostFifo_dout_array        : slv_array(0 to NUMBER_OF_DESCRIPTORS-2);
  signal toHostFifo_re_array          : std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
  constant FROMHOSTFIFO_DEPTH : integer := 512;
  --! If we have multiple descriptors ToHost (take one off for FromHost direction) we have more FIFOs, let's make them less deep.
  constant TOHOSTFIFO_DEPTH : integer := 4096/(NUMBER_OF_DESCRIPTORS-1);
  signal fromHostFifo_wr_data_count : std_logic_vector(f_log2(FROMHOSTFIFO_DEPTH)-1 downto 0);
  signal fromHostFifo_we_i: std_logic;
  signal fromHostFifo_rd_en_i: std_logic;
  signal toHostFifo_pfull_threshold_assert_s : std_logic_vector(12 downto 0);
  signal toHostFifo_pfull_threshold_negate_s : std_logic_vector(12 downto 0);
  type slv13_array is array(natural range <>) of std_logic_vector(12 downto 0);
  signal toHostFifo_wr_data_count_array_s : slv13_array(0 to NUMBER_OF_DESCRIPTORS-2);
  signal fromHostFifo_rst_sync, toHostFifo_rst_sync: std_logic;
begin
  toHostFifo_pfull_threshold_assert_s(11 downto 0) <= toHostFifo_pfull_threshold_assert(11 downto 0);
  toHostFifo_pfull_threshold_negate_s(11 downto 0) <= toHostFifo_pfull_threshold_negate(11 downto 0);

  fromHostFifo_we_i <= fromHostFifo_we;
  fromHostFifo_rd_en_i <= fromHostFifo_rd_en;
  
  xpm_cdc_sync_fromHostFifo_rst_inst : xpm_cdc_sync_rst
   generic map (
      DEST_SYNC_FF => 2,
      INIT => 1,
      INIT_SYNC_FF => 0,
      SIM_ASSERT_CHK => 0
   )
   port map (
      dest_rst => fromHostFifo_rst_sync,
      dest_clk => fromHostFifo_wr_clk,
      src_rst => fromHostFifo_rst
   );
   
  xpm_cdc_sync_toHostFifo_rst_inst : xpm_cdc_sync_rst
   generic map (
      DEST_SYNC_FF => 2,
      INIT => 1,
      INIT_SYNC_FF => 0,
      SIM_ASSERT_CHK => 0
   )
   port map (
      dest_rst => toHostFifo_rst_sync,
      dest_clk => toHostFifo_wr_clk,
      src_rst => toHostFifo_rst
   );
  
  fromHostFifo0 : xpm_fifo_async
    generic map (
    FIFO_MEMORY_TYPE => "block", --string; "auto", "block", or "distributed";
    FIFO_WRITE_DEPTH => FROMHOSTFIFO_DEPTH, --positive integer
--    CASCADE_HEIGHT => 0,
    RELATED_CLOCKS => 0, --positive integer; 0 or 1
    WRITE_DATA_WIDTH => DATA_WIDTH, --positive integer
    READ_MODE => "std", --string; "std" or "fwft";
    FIFO_READ_LATENCY => 1, --positive integer
    FULL_RESET_VALUE => 1, --positive integer; 0 or 1;
    USE_ADV_FEATURES => "0004", -- String
    READ_DATA_WIDTH => DATA_WIDTH, --positive integer
    CDC_SYNC_STAGES => 2, --positive integer
    WR_DATA_COUNT_WIDTH => f_log2(FROMHOSTFIFO_DEPTH), --positive integer
    PROG_FULL_THRESH => FROMHOSTFIFO_DEPTH-10, --positive integer
    RD_DATA_COUNT_WIDTH => f_log2(FROMHOSTFIFO_DEPTH), --positive integer
    PROG_EMPTY_THRESH => 10, --positive integer
    DOUT_RESET_VALUE => "0", --string
    ECC_MODE => "no_ecc", --string; "no_ecc" or "en_ecc";
    --SIM_ASSERT_CHK => 0,
    WAKEUP_TIME => 2 --positive integer; 0 or 2;
    )
    port map (
    sleep => '0',
    rst => fromHostFifo_rst_sync,
    wr_clk => fromHostFifo_wr_clk,
    wr_en => fromHostFifo_we_i,
    din => fromHostFifo_din,
    full => open,
    prog_full => open,
    wr_data_count => fromHostFifo_wr_data_count,
    overflow => open,
    wr_rst_busy => open,
    almost_full => open,
    wr_ack => open,
    rd_clk => fromHostFifo_rd_clk,
    rd_en => fromHostFifo_rd_en_i,
    dout => fromHostFifo_dout,
    empty => fromHostFifo_empty,
    prog_empty => open,
    rd_data_count => open,
    underflow => open,
    rd_rst_busy => open,
    almost_empty => open,
    data_valid => open,
    injectsbiterr => '0',
    injectdbiterr => '0',
    sbiterr => open,
    dbiterr => open      
    );


  fromhost_prog_full_proc: process(fromHostFifo_wr_clk)
  begin
    if rising_edge(fromHostFifo_wr_clk) then
        if fromHostFifo_wr_data_count >= fromHostFifo_pfull_threshold_assert then
            fromHostFifo_prog_full <= '1';
        elsif fromHostFifo_wr_data_count <= fromHostFifo_pfull_threshold_negate then
            fromHostFifo_prog_full <= '0';
        end if;
    end if;
  end process;



  mux1: process (toHostFifoIndex_p1, toHostFifoIndex, toHostFifo_re,
    toHostFifo_dout_array)
  begin
      toHostFifo_dout                         <= toHostFifo_dout_array(toHostFifoIndex_p1);
      toHostFifo_re_array <= (others => '0');
      toHostFifo_re_array(toHostFifoIndex)    <= toHostFifo_re;
  end process mux1 ;

  index_pipe_proc: process (toHostFifo_rd_clk)
  begin
      if rising_edge(toHostFifo_rd_clk) then
          toHostFifoIndex_p1 <= toHostFifoIndex;
      end if;
  end process index_pipe_proc ;

  g_tohost: for i in 0 to NUMBER_OF_DESCRIPTORS-2 generate
      signal toHostFifo_wr_en_pipe : std_logic;
      signal toHostFifo_din_pipe   : std_logic_vector(DATA_WIDTH-1 downto 0);
      signal toHostFifo_wr_data_count_s : std_logic_vector(f_log2(TOHOSTFIFO_DEPTH) downto 0);
      signal toHostFifo_rd_data_count_s : std_logic_vector(f_log2(TOHOSTFIFO_DEPTH) downto 0);
      signal toHostFifo_prog_full_s: std_logic;
      signal toHostFifo_prog_empty_s: std_logic;
      signal wr_rst_busy : std_logic;
  begin
  
  toHostFifo0 : xpm_fifo_async
    generic map ( 
    FIFO_MEMORY_TYPE => "block", --string; "auto", "block", or "distributed";
    FIFO_WRITE_DEPTH => TOHOSTFIFO_DEPTH, --positive integer
    --CASCADE_HEIGHT => 0,
    RELATED_CLOCKS => 0, --positive integer; 0 or 1
    WRITE_DATA_WIDTH => DATA_WIDTH, --positive integer
    READ_MODE => "std", --string; "std" or "fwft";
    FIFO_READ_LATENCY => 1, --positive integer
    FULL_RESET_VALUE => 1, --positive integer; 0 or 1;
    USE_ADV_FEATURES => "0404", -- String
    READ_DATA_WIDTH => DATA_WIDTH, --positive integer
    CDC_SYNC_STAGES => 2, --positive integer
    WR_DATA_COUNT_WIDTH => f_log2(TOHOSTFIFO_DEPTH)+1, --positive integer
    PROG_FULL_THRESH => TOHOSTFIFO_DEPTH-10, --positive integer
    RD_DATA_COUNT_WIDTH => f_log2(TOHOSTFIFO_DEPTH)+1, --positive integer
    PROG_EMPTY_THRESH => 10, --positive integer
    DOUT_RESET_VALUE => "0", --string
    ECC_MODE => "no_ecc", --string; "no_ecc" or "en_ecc";
    --SIM_ASSERT_CHK => 0,
    WAKEUP_TIME => 2 --positive integer; 0 or 2;
    )
    port map (
    sleep => '0',
    rst => toHostFifo_rst_sync,
    wr_clk => toHostFifo_wr_clk,
    wr_en => toHostFifo_wr_en_pipe,
    din => toHostFifo_din_pipe,
    full => open,
    prog_full => open,
    wr_data_count => toHostFifo_wr_data_count_s,
    overflow => open,
    wr_rst_busy => wr_rst_busy,
    almost_full => open,
    wr_ack => open,
    rd_clk => toHostFifo_rd_clk,
    rd_en => toHostFifo_re_array(i),
    dout => toHostFifo_dout_array(i),
    empty => open,
    prog_empty => open,
    rd_data_count => toHostFifo_rd_data_count_s,
    underflow => open,
    rd_rst_busy => open,
    almost_empty => open,
    data_valid => open,
    injectsbiterr => '0',
    injectdbiterr => '0',
    sbiterr => open,
    dbiterr => open      
    );
    
  tohost_prog_full_proc: process(toHostFifo_wr_clk)
  begin
    if rising_edge(toHostFifo_wr_clk) then
        if toHostFifo_wr_data_count_s >= toHostFifo_pfull_threshold_assert_s(f_log2(TOHOSTFIFO_DEPTH) downto 0) then
            toHostFifo_prog_full_s <= '1';
        elsif toHostFifo_wr_data_count_s <= toHostFifo_pfull_threshold_negate_s(f_log2(TOHOSTFIFO_DEPTH) downto 0) then
            toHostFifo_prog_full_s <= wr_rst_busy;
        end if;
    end if;
  end process;
  
  toHostFifo_prog_full(i) <= toHostFifo_prog_full_s;
  
  tohost_prog_empty_proc: process(toHostFifo_rd_clk)
  begin
    if rising_edge(toHostFifo_rd_clk) then
        if toHostFifo_rd_data_count_s <= toHostFifo_empty_thresh(i)(f_log2(TOHOSTFIFO_DEPTH)-1 downto 0) then
            toHostFifo_prog_empty_s <= '1';
        else
            toHostFifo_prog_empty_s <= '0';
        end if;
    end if;
  end process;
  
  toHostFifo_prog_empty(i) <= toHostFifo_prog_empty_s;
  
  toHostFifo_wr_data_count_array_s(i)(12 downto f_log2(TOHOSTFIFO_DEPTH)) <= (others => '0');  
  toHostFifo_wr_data_count_array_s(i)(f_log2(TOHOSTFIFO_DEPTH)-1 downto 0) <= toHostFifo_wr_data_count_s(f_log2(TOHOSTFIFO_DEPTH)-1 downto 0);
  toHostFifo_wr_data_count(i) <= toHostFifo_wr_data_count_array_s(i)(11 downto 0);
      
      pipe0: process (toHostFifo_wr_clk) is
      begin
          if rising_edge(toHostFifo_wr_clk) then
              toHostFifo_din_pipe <= toHostFifo_din(i);
              toHostFifo_wr_en_pipe <= toHostFifo_wr_en(i);
          end if;
      end process pipe0 ;
  end generate g_tohost;




end architecture rtl ; -- of WupperFifos

