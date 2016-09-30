
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class application
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)<br>
--!              Oussama el Kharraz Alami<br>
--!
--!
--! @date        05/10/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! This example application fills the downfifo (PCIe -> PC) with pseudo random data by using
--! a LFSR and multiplies the data from upfifo (PC -> PCIe) back to the downfifo. The size
--! of the randomdata is 256 bits. The DMA core will take care of the data and writes it into PC memory
--! according to the DMA descriptors.
--! 
--! @detail
--! We are discarding any DMA data sent by the PC, otherwise a second fifo could be connected to these ports: <br>
--! fifo_din <br>
--! fifo_we <br>
--! fifo_full <br>
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

entity application is
  generic(
    NUMBER_OF_INTERRUPTS : integer := 8;
    CARD_TYPE            : integer := 709);
  port (
    appreg_clk           : in     std_logic;
    upfifo_din           : in     std_logic_vector(255 downto 0);
    downfifo_dout        : out    std_logic_vector(255 downto 0);
    downfifo_prog_empty  : out    std_logic;
    downfifo_empty_thresh: in     std_logic_vector(6 downto 0);
    upfifo_prog_full     : out    std_logic;
    fifo_rd_clk          : in     std_logic;
    downfifo_re          : in     std_logic;
    upfifo_we            : in     std_logic;
    fifo_wr_clk          : in     std_logic;
    flush_fifo           : in     std_logic;
    interrupt_call       : out    std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
    leds                 : out    std_logic_vector(7 downto 0);
    pll_locked           : in     std_logic;
    register_map_control : in     register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd
    register_map_monitor : out    register_map_monitor_type; --! contains all status (read only) signals from the application. The record members are described in pcie_package.vhd
    reset_hard           : in     std_logic;
    reset_soft           : in     std_logic);
end entity application;

architecture rtl of application is

COMPONENT xadc_drp
generic(
    CARD_TYPE : integer := 711
    );
port(
    clk40 : in std_logic;
    reset : in std_logic;
    temp  : out std_logic_vector(11 downto 0);
    vccint   : out std_logic_vector(11 downto 0);
    vccaux   : out std_logic_vector(11 downto 0);
    vccbram  : out std_logic_vector(11 downto 0)
    );
END COMPONENT;

COMPONENT fifo_256x256
  PORT (
    rst                : IN    STD_LOGIC;
--    wr_clk             : IN    STD_LOGIC;
--    rd_clk             : IN    STD_LOGIC;
    clk                : IN    STD_LOGIC;
    din                : IN    STD_LOGIC_VECTOR(255 DOWNTO 0);
    wr_en              : IN    STD_LOGIC;
    rd_en              : IN    STD_LOGIC;
    --prog_empty_thresh  : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
    prog_empty_thresh  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dout               : OUT   STD_LOGIC_VECTOR(255 DOWNTO 0);
    full               : OUT   STD_LOGIC;
    empty              : OUT   STD_LOGIC;
    prog_full          : OUT   STD_LOGIC;
    prog_empty         : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_256x512
  PORT (
    rst                : IN    STD_LOGIC;
    clk                : IN    STD_LOGIC;
    din                : IN    STD_LOGIC_VECTOR(255 DOWNTO 0);
    wr_en              : IN    STD_LOGIC;
    rd_en              : IN    STD_LOGIC;
    dout               : OUT   STD_LOGIC_VECTOR(255 DOWNTO 0);
    full               : OUT   STD_LOGIC;
    empty              : OUT   STD_LOGIC;
    almost_full        : OUT   STD_LOGIC;
    prog_full          : OUT   STD_LOGIC

  );
END COMPONENT;

COMPONENT LFSR
  PORT (
    clk               : in     STD_LOGIC;
    load_seed         : in     STD_LOGIC_VECTOR (0   downto 0);
    enable	          : in     STD_LOGIC;
    rndmdata          : out    STD_LOGIC_VECTOR (255 downto 0);
    seed              : in     STD_LOGIC_VECTOR (255 downto 0)
);
END COMPONENT;
  
COMPONENT multiplier
    PORT (
      clk  : IN  STD_LOGIC;
      A    : IN  STD_LOGIC_VECTOR(63  DOWNTO 0);
      B    : IN  STD_LOGIC_VECTOR(63  DOWNTO 0);
      SCLR : IN  STD_LOGIC;
      P    : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END COMPONENT;

  signal register_map_monitor_s  :  register_map_monitor_type;
  signal register_map_control_s  :  register_map_control_type;
  
  attribute dont_touch : string;
  --attribute dont_touch of register_map_monitor_s : signal is "true";
  attribute dont_touch of register_map_control_s : signal is "true";
  
  --! This signal below is for PCIe -> PC. 
  signal s_downfifo_we          : std_logic;
  signal s_downfifo_full        : std_logic;
  signal s_downfifo_din         : std_logic_vector(255 downto 0);
  signal s_downfifo_prog_full   : std_logic;
  
   --! This signal below is for PC-> PCIe.
   signal s_upfifo_re           : std_logic;
   signal s_upfifo_empty        : std_logic;
--   signal s_fifo_empty_thresh   : std_logic_vector(  9 downto 0);
   signal s_upfifo_dout         : std_logic_vector(255 downto 0);
   signal reset                 : std_logic;
   signal s_flush_fifo          : std_logic;
   
  --! These signals belong to the multipliers
  signal mul0_A                 :std_logic_vector(63  downto 0);
  signal mul0_B                 :std_logic_vector(63  downto 0);
  signal mul0_P                 :std_logic_vector(127 downto 0);
  signal mul1_A                 :std_logic_vector(63  downto 0);
  signal mul1_B                 :std_logic_vector(63  downto 0);
  signal mul1_P                 :std_logic_vector(127 downto 0);
  signal mul_out                :std_logic_vector(255 downto 0);
  signal mul_sclr               : std_logic;
  
 
 --! These signals belong to the LFSR
  signal lfsr_enable            :std_logic;
  signal lfsr_load_seed_latch   :std_logic;
  signal lfsr_data              :std_logic_vector(255 downto 0);
  
 --! This signal start the write process
  signal start_write            :std_logic;
  
  --! Enable application enable 
    signal enable_app_write     :std_logic;
    signal start_lfsr           :std_logic;
    signal start_mul            :std_logic;
  
  --! for xadc
  signal reset_n: std_logic;
  signal vp_in: std_logic;
  signal vn_in: std_logic;
  
  
  signal APP_MUX        : std_logic;
  signal LFSR_LOAD_SEED : std_logic;
  signal APP_ENABLE     : std_logic_vector(1 downto 0);
  signal LFSR_SEED      : std_logic_vector(255 downto 0);
  
begin

  reset <= reset_hard or reset_soft;
  reset_n <= not reset;

  register_map_monitor                  <= register_map_monitor_s;
  register_map_monitor_s.PLL_LOCK(0)    <= pll_locked;
  register_map_control_s                <= register_map_control;
  leds                                  <= register_map_control_s.STATUS_LEDS(7 downto 0);
  
  
   xadc : xadc_drp
    GENERIC MAP (
      CARD_TYPE => CARD_TYPE)
    PORT MAP (
      clk40 => appreg_clk, 
      reset => reset, 
      temp  => register_map_monitor_s.CORE_TEMPERATURE, 
      vccint  => register_map_monitor_s.VCCINT,
      vccaux  => register_map_monitor_s.VCCAUX,
      vccbram => register_map_monitor_s.VCCBRAM
    ); 
  
  s_flush_fifo <= flush_fifo or reset;
  
  --! Instantiation of the fifo (PCIe => PC)
  downfifo : fifo_256x256
  PORT MAP (
    clk               => fifo_rd_clk,
    rst               => s_flush_fifo,
    din               => s_downfifo_din,
    wr_en             => s_downfifo_we,
    rd_en             => downfifo_re,
    dout              => downfifo_dout,
    full              => s_downfifo_full,
    empty             => open,
    prog_full         => s_downfifo_prog_full, 
    prog_empty        => downfifo_prog_empty,
    prog_empty_thresh => "0"&downfifo_empty_thresh
    
  );



--! Instantiation of the fifo (PC => PCIe) 
  upfifo : fifo_256x512
  PORT MAP (
    clk              =>            fifo_wr_clk,
    rst              =>            s_flush_fifo,
    din              =>            upfifo_din,
    wr_en            =>            upfifo_we,
    rd_en            =>            s_upfifo_re,
    dout             =>            s_upfifo_dout,
    full             =>            open,
    almost_full      =>            open,
    empty            =>            s_upfifo_empty,
    prog_full        =>            upfifo_prog_full 
    
  );

  
  LFSR1 : LFSR
    PORT MAP(
      clk               => fifo_rd_clk,
      load_seed(0)      => LFSR_LOAD_SEED,
      enable            => lfsr_enable,
      rndmdata          => lfsr_data,
      seed              => LFSR_SEED
  );
  
  mul0 : multiplier
    PORT MAP (
      CLK           => fifo_rd_clk,
      A             => mul0_A,
      B             => mul0_B,
      SCLR          => mul_sclr,
      P             => mul0_P
    );
    
  mul1 : multiplier
  PORT MAP (
        CLK         => fifo_rd_clk,
        A           => mul1_A,
        B           => mul1_B,
        SCLR          => mul_sclr,
        P           => mul1_P
      );
      
      
  process(fifo_rd_clk, reset, s_downfifo_prog_full )
    variable s_upfifo_re_pipe : std_logic_vector(18 downto 0);
  begin
      if(rising_edge(fifo_rd_clk)) then
          if (APP_MUX = '0') then    
              if (s_downfifo_prog_full = '0' and start_lfsr = '1') then
              -- Write data from fifo to PC
                 s_downfifo_we <= '1';
              else
                 s_downfifo_we <= '0';
              end if;
              s_downfifo_din <= lfsr_data; 
           else
               s_downfifo_din <= mul_out;
               if(s_upfifo_re_pipe(18) = '1') then
                  s_downfifo_we <= '1';
               else
                  s_downfifo_we <= '0';
               end if;          
           end if;
           s_upfifo_re_pipe := s_upfifo_re_pipe(17 downto 0) & s_upfifo_re;
       end if;           
   end process;
   

regsync: process(fifo_rd_clk)
     variable APP_MUX_P1, APP_MUX_P2 : std_logic;
     variable LFSR_LOAD_SEED_P1, LFSR_LOAD_SEED_P2 : std_logic;
     variable APP_ENABLE_P1, APP_ENABLE_P2 : std_logic_vector(1 downto 0);
     variable LFSR_SEED_P1, LFSR_SEED_P2 : std_logic_vector(255 downto 0);
     
   begin
     APP_MUX           <= APP_MUX_P2;
     LFSR_LOAD_SEED    <= LFSR_LOAD_SEED_P2;
     APP_ENABLE        <= APP_ENABLE_P2;
     LFSR_SEED         <= LFSR_SEED_P2;
   
     APP_MUX_P2        := APP_MUX_P1;
     LFSR_LOAD_SEED_P2 := LFSR_LOAD_SEED_P1;
     APP_ENABLE_P2     := APP_ENABLE_P1;
     LFSR_SEED_P2      := LFSR_SEED_P1;
   
     APP_MUX_P1        := register_map_control_s.APP_MUX(0);
     LFSR_LOAD_SEED_P1 := register_map_control_s.LFSR_LOAD_SEED(0);
     APP_ENABLE_P1     := register_map_control_s.APP_ENABLE;
     LFSR_SEED_P1      := register_map_control_s.LFSR_SEED;
   end process;

    --process(APP_MUX, s_downfifo_prog_full ,s_upfifo_empty)
    --   begin
    --       if (APP_MUX = '0') then    
    --           if (s_downfifo_prog_full = '0' ) then
    --           -- Enable LFSR for random data
    --             lfsr_enable <= '1';
    --           else
    --             lfsr_enable <= '0';
    --           end if;
    --           s_upfifo_re <= '0'; 
    --        else
    --           --if (s_upfifo_empty = '0' and s_downfifo_full = '0') then
    --           if (s_upfifo_empty = '0' and (s_downfifo_prog_full = '0' and start_mul = '1')) then       
    --              s_upfifo_re <= '1';  
    --           else
    --              s_upfifo_re <= '0'; 
    --           end if;
    --           lfsr_enable <= '0';  
    --        end if;       
    --end process;
    
    s_upfifo_re <= (APP_MUX and (not s_upfifo_empty)) and ((not s_downfifo_prog_full) and start_mul);
    lfsr_enable <= (not APP_MUX) and (not s_downfifo_prog_full);
    
    
    process(fifo_rd_clk, reset )
        variable lfsr_load_seed_p1: std_logic;
        begin
            if(reset ='1') then
                lfsr_load_seed_latch <= '0';
            elsif(rising_edge(fifo_rd_clk)) then
                if(lfsr_load_seed_p1 = '1' and LFSR_LOAD_SEED = '0') then
                    lfsr_load_seed_latch <= '1';
                else
                    lfsr_load_seed_latch <= lfsr_load_seed_latch;
                end if;    
                lfsr_load_seed_p1 := LFSR_LOAD_SEED; 
            end if;
    end process;
        
   start_lfsr <= '1' when ( lfsr_load_seed_latch = '1') and (APP_ENABLE(0) ='1') else '0';
   start_mul  <= APP_ENABLE(1);
   mul_sclr   <= not start_mul;     

  -- mulitpliers
   mul0_A                         <= s_upfifo_dout  (63  downto 0)   ;
   mul0_B                         <= s_upfifo_dout  (127 downto 64 ) ;
   mul_out (127 downto 0)         <= mul0_P                          ;

   
   mul1_A                        <= s_upfifo_dout  (191 downto 128)  ;
   mul1_B                        <= s_upfifo_dout  (255 downto 192)  ;
   mul_out (255 downto 128)      <= mul1_P                           ;

  
  g0: if(NUMBER_OF_INTERRUPTS>4) generate
    interrupt_call(4 downto 4) <= register_map_control_s.INT_TEST_2;
    g1: if(NUMBER_OF_INTERRUPTS>5) generate
      interrupt_call(5 downto 5) <= register_map_control_s.INT_TEST_3;
      interrupt_call(NUMBER_OF_INTERRUPTS-1 downto 6) <= (others => '0');
    end generate;
  end generate;
  
  
end architecture rtl ; -- of application

