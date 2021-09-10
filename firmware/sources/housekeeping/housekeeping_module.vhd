

library ieee, UNISIM;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;-- @suppress "Deprecated package"
use ieee.std_logic_1164.all;
use work.pcie_package.all;
use work.I2C.all;

entity housekeeping_module is
  generic(
    CARD_TYPE                       : integer := 710;
    ENDPOINTS                       : integer := 1 --Number of PCIe Endpoints in the design, GBT_NUM has to be multiplied by this number in some cases.
    );
  port (
    SCL                         : inout  std_logic;
    SDA                         : inout  std_logic;
    appreg_clk                  : in     std_logic;
    i2cmux_rst                  : out    std_logic;
    leds                        : out    std_logic_vector(7 downto 0);
    register_map_control        : in     register_map_control_type;
    register_map_gen_board_info : out    register_map_gen_board_info_type;
    register_map_hk_monitor     : out    register_map_hk_monitor_type;
    rst_soft                    : in     std_logic;
    rst_hw                      : in     std_logic;
    versal_sys_reset_n_out      : out    std_logic
);
end entity housekeeping_module;


architecture structure of housekeeping_module is

  signal clk                            : std_logic;
  signal cmd_ack                        : std_logic;
  signal ack_out                        : std_logic;
  signal Dout                           : std_logic_vector(7 downto 0);
  signal Din                            : std_logic_vector(7 downto 0);
  signal ack_in                         : std_logic;
  signal write                          : std_logic;
  signal read                           : std_logic;
  signal stop                           : std_logic;
  signal start                          : std_logic;
  signal ena                            : std_logic;
  signal reset                          : std_logic;
  signal reset_n                        : std_logic;
  signal I2C_nReset                     : std_logic;
  signal AUTOMATIC_CLOCK_SWITCH_ENABLED : std_logic_vector(0 downto 0);
  signal TACH_CNT                       : std_logic_vector(19 downto 0);
  signal TACH_CNT_LATCHED               : std_logic_vector(19 downto 0);
  signal TACH_FLAG                      : std_logic:='0';
  signal TACH_R                         : std_logic:='0';
  signal TACH_2R                        : std_logic:='0';
  signal TACH_3R                        : std_logic:='0';
  
  signal dna_out_data                   : std_logic_vector(95 downto 0); --IG: get the entire output vector data and assign the relevant bits only 
  signal LMK_locked                     : std_logic;



begin
  leds <= register_map_control.STATUS_LEDS;
  register_map_gen_board_info.NUMBER_OF_PCIE_ENDPOINTS <= std_logic_vector(to_unsigned(ENDPOINTS,2));
 
  
  i2c0: entity work.simple_i2c
    port map(
      clk     => clk,
      ena     => ena,
      nReset  => I2C_nReset,
      clk_cnt => "01100100",
      start   => start,
      stop    => stop,
      read    => read,
      write   => write,
      ack_in  => ack_in,
      Din     => Din,
      cmd_ack => cmd_ack,
      ack_out => ack_out,
      Dout    => Dout,
      SCL     => SCL,
      SDA     => SDA);

  i2cint0: entity work.i2c_interface
    port map(
      Din                  => Din,
      Dout                 => Dout,
      I2C_RD               => register_map_hk_monitor.I2C_RD,
      I2C_WR               => register_map_hk_monitor.I2C_WR,
      RST                  => rst_hw,
      ack_in               => ack_in,
      ack_out              => ack_out,
      appreg_clk           => appreg_clk,
      clk                  => clk,
      cmd_ack              => cmd_ack,
      ena                  => ena,
      nReset               => I2C_nReset,
      read                 => read,
      register_map_control => register_map_control,
      rst_soft             => rst_soft,
      start                => start,
      stop                 => stop,
      write                => write);




  g_HTG710: if CARD_TYPE = 710 generate
    i2cmux_rst      <= reset;
  end generate;

  g_notHTG710: if CARD_TYPE = 709 or CARD_TYPE = 105 or CARD_TYPE = 128 or CARD_TYPE = 180 generate
    i2cmux_rst      <= reset_n;
  end generate;

  
  xadc0: entity work.xadc_drp
    generic map(
      CARD_TYPE => CARD_TYPE)
    port map(
      clk40   => appreg_clk,
      reset   => reset,
      temp    => register_map_hk_monitor.FPGA_CORE_TEMP,
      vccint  => register_map_hk_monitor.FPGA_CORE_VCCINT,
      vccaux  => register_map_hk_monitor.FPGA_CORE_VCCAUX,
      vccbram => register_map_hk_monitor.FPGA_CORE_VCCBRAM);

  dna0: entity work.dna
    generic map(
      CARD_TYPE => CARD_TYPE)
    port map(
      clk40   => appreg_clk,
      reset   => reset,
      dna_out => dna_out_data); 
      register_map_hk_monitor.FPGA_DNA  <= dna_out_data(63 downto 0);

    g_180: if (CARD_TYPE = 180) generate
        component cips_bd_wrapper 
          port (
            pl0_resetn : out STD_LOGIC
          );
        end component;
    begin
    versal_cips_block0: cips_bd_wrapper 
      port map(
        pl0_resetn => versal_sys_reset_n_out
      );
    end generate g_180;

  reset <= rst_soft or rst_hw;
  reset_n <= not reset;

end architecture structure ; -- of housekeeping_module

