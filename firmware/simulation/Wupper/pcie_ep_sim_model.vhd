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
--! @version     1.1
--!
--! @brief 
--! Wrapper unit for the PCI Express core simulation model
--!
--! Notes:
--! Dec 08 2020 F. Schreuder <f.schreuder@nikhef.nl> 
--!          Initial commit
--!
--!
--! @detail
--!
--!-----------------------------------------------------------------------------
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


library uvvm_util;
context uvvm_util.uvvm_util_context;
library ieee, UNISIM;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"
use work.pcie_package.all;
use std.env.all;

entity pcie_ep_sim_model is
    generic(
        DATA_WIDTH: integer := 256;
        NUMBER_OF_DESCRIPTORS: integer := 5
        );
    port (
        cfg_fc_cpld                : out    std_logic_vector(11 downto 0);
        cfg_fc_cplh                : out    std_logic_vector(7 downto 0);
        cfg_fc_npd                 : out    std_logic_vector(11 downto 0);
        cfg_fc_nph                 : out    std_logic_vector(7 downto 0);
        cfg_fc_pd                  : out    std_logic_vector(11 downto 0);
        cfg_fc_ph                  : out    std_logic_vector(7 downto 0);
        --cfg_fc_sel                 : in     std_logic_vector(2 downto 0);
        --cfg_interrupt_msix_address : in     std_logic_vector(63 downto 0);
        --cfg_interrupt_msix_data    : in     std_logic_vector(31 downto 0);
        cfg_interrupt_msix_enable  : out    std_logic_vector(3 downto 0);
        cfg_interrupt_msix_fail    : out    std_logic;
        cfg_interrupt_msix_int     : in     std_logic;
        cfg_interrupt_msix_sent    : out    std_logic;
        cfg_mgmt_addr              : in     std_logic_vector(18 downto 0);
        --cfg_mgmt_byte_enable       : in     std_logic_vector(3 downto 0);
        cfg_mgmt_read              : in     std_logic;
        cfg_mgmt_read_data         : out    std_logic_vector(31 downto 0);
        cfg_mgmt_read_write_done   : out    std_logic;
        cfg_mgmt_write             : in     std_logic;
        --cfg_mgmt_write_data        : in     std_logic_vector(31 downto 0);
        clk                        : out    std_logic;
        m_axis_cq                  : out    axis_type;
        m_axis_r_cq                : in     axis_r_type;
        m_axis_r_rc                : in     axis_r_type;
        m_axis_rc                  : out    axis_type;
        reset                      : out    std_logic;
        s_axis_cc                  : in     axis_type;
        s_axis_r_cc                : out    axis_r_type;
        s_axis_r_rq                : out    axis_r_type;
        s_axis_rq                  : in     axis_type;
        sys_rst_n                  : in     std_logic;
        user_lnk_up                : out    std_logic);
end entity pcie_ep_sim_model;

architecture sim of pcie_ep_sim_model is

    constant DESCRIPTOR_SIZE: std_logic_vector(47 downto 0) := x"0000_0001_0000";
    constant FROMHOST_DESCRIPTOR_SIZE: std_logic_vector(47 downto 0) := x"0000_0000_1000";
    
    constant user_clk_period: time  := 4 ns;

    constant BAR0: std_logic_vector(31 downto 0) := x"BA00_0000";
    constant BAR1: std_logic_vector(31 downto 0) := x"BA10_0000";
    constant BAR2: std_logic_vector(31 downto 0) := x"BA20_0000";
    type slvD_array is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type slv2D_array is array (natural range <>) of slvD_array(0 to 127);
    
    signal ToHostMem: slv2D_array(0 to 3);
    signal FromHostMem: slvD_array(0 to 127);
    signal FromHostWrapCount : integer:= 1;
    signal ToHostWrapCount : integer:= 0;
    signal ToHostMemorySelect_s : integer range 0 to NUMBER_OF_DESCRIPTORS-2;
    signal DoCompare: std_logic;
    signal user_clk: std_logic;
    signal sysclk_gen: std_logic;
    signal wait_for_cc_tvalid: std_logic;
    signal switch_off_tohost: std_logic;
    signal do_finish_fromhost: boolean := false;
    constant TLP_SIZE_TOHOST : integer := 512;
    constant TLP_SIZE_FROMHOST : integer := 128;
    signal responding : std_logic;
begin
    user_clk_proc: process
    begin
        sysclk_gen <= '1';
        wait for user_clk_period / 2;
        sysclk_gen <= '0';
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
        variable RegData: std_logic_vector(63 downto 0);
        variable pc_pointer_FromHost, last_pc_pointer_FromHost: std_logic_vector(11 downto 0);
        constant pc_pointer_FromHost_msb: std_logic_vector(63 downto 12):= x"DEF8_0000_0000_0";
        variable tohost_switched_off : std_logic;
        variable fromhost_wraps: integer;
        procedure w(RegAddr: in std_logic_vector(19 downto 0);
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
            m_axis_cq.tuser(84 downto 0)      <= (others => '0');
            m_axis_cq.tuser(3 downto 0)      <= "1111";--first_be_s
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
            while m_axis_r_cq.tready = '0' loop
                wait until rising_edge(user_clk);
            end loop;
            m_axis_cq.tvalid                 <= '0';
            m_axis_cq.tlast                  <= '0';

        end w;
        procedure r(RegAddr: in std_logic_vector(19 downto 0);
                    BarAddr: in std_logic_vector(31 downto 0);
                    DataOut: out std_logic_vector(63 downto 0)
                    ) is
            variable bar_id: std_logic_vector(2 downto 0):= "000";
            variable timeout: integer;
        begin
            wait until rising_edge(user_clk);
            while m_axis_r_cq.tready = '0' loop
                wait until rising_edge(user_clk);
                timeout := timeout + 1;
                if timeout = 100 then
                    report "Timeout waiting for tready" severity error;
                    std.env.stop;
                    exit;
                end if;
            end loop;
            --wait until rising_edge(user_clk);
            m_axis_cq.tdata <= (others => '0');

            m_axis_cq.tdata(1 downto 0) <= "00"; --address type
            m_axis_cq.tdata(63 downto 32) <= x"0000_0000";
            m_axis_cq.tdata(31 downto 20) <= BarAddr(31 downto 20);
            m_axis_cq.tdata(19 downto 2) <= RegAddr(19 downto 2);

            m_axis_cq.tdata(74 downto 64) <= "00000000010";-- 2 words, 64 bit read dword_count_s;
            m_axis_cq.tdata(78 downto 75) <= "0000"; --Memory read, request_type_v
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
            m_axis_cq.tdata(191 downto 128)  <= (others => '0'); --register_write_data_250_s
            m_axis_cq.tdata(DATA_WIDTH-1 downto 192)  <= (others => '0'); --register_write_data_250_s
            m_axis_cq.tuser(84 downto 0)      <= (others => '0');
            m_axis_cq.tuser(3 downto 0)      <= "1111";--first_be_s
            if DATA_WIDTH = 512 then
                m_axis_cq.tuser(11 downto 8)      <= "1111";--last_be_s
            else
                m_axis_cq.tuser(7 downto 4)      <= "1111";--last_be_s
            end if;
            m_axis_cq.tkeep(m_axis_cq.tkeep'high downto 0)      <= (others => '0'); --For 512bit mode
            m_axis_cq.tkeep(7 downto 0)      <= "00001111"; --no payload
            m_axis_cq.tvalid                 <= '1';
            m_axis_cq.tlast                  <= '1';
            --wait until rising_edge(user_clk);
            timeout := 0;
            wait_for_cc_tvalid <= '1';
            while s_axis_cc.tvalid = '0' loop
                wait for user_clk_period/2;
                timeout := timeout + 1;
                if timeout = 100 then
                    report "Timeout waiting for tvalid" severity error;
                    std.env.stop;
                    exit;
                end if;
            end loop;
            wait_for_cc_tvalid <= '0';
            while m_axis_r_cq.tready = '0' loop
                wait until rising_edge(user_clk);
                timeout := timeout + 1;
                if timeout = 100 then
                    report "Timeout waiting for tready" severity error;
                    std.env.stop;
                    exit;
                end if;
            end loop;
            m_axis_cq.tvalid                 <= '0';
            m_axis_cq.tlast                  <= '0';
            timeout := 0;
            DataOut := s_axis_cc.tdata(96+63 downto 96);
        end r;

    begin
        report_global_ctrl(VOID);
        report_msg_id_panel(VOID);
        enable_log_msg(ALL_MESSAGES);
        pc_pointer_FromHost := x"000";
        last_pc_pointer_FromHost := x"000";
        tohost_switched_off := '0';
        fromhost_wraps := 0;
        
        wait for 18 us; --startup time
        w(REG_PC_PTR_GAP, BAR0, x"0000_0000_0000_0100"); --set pc_ptr_gap 
        for i in 0 to NUMBER_OF_DESCRIPTORS-2 loop
            w(REG_DESCRIPTOR_0+i*32,      BAR0, x"AA"&std_logic_vector(to_unsigned(i,8))&x"0000_0000_0000"); --descr 0 start address
            w(REG_DESCRIPTOR_0+i*32+8,    BAR0, x"AA"&std_logic_vector(to_unsigned(i,8))&DESCRIPTOR_SIZE); --descr 0 end address
            w(REG_DESCRIPTOR_0a+i*32+8,   BAR0, x"AA"&std_logic_vector(to_unsigned(i,8))&x"0000_0000_0000"); --init PC pointer at start_address
            w(REG_DESCRIPTOR_0a+i*32,     BAR0, x"0000_0000_0000_1000"+TLP_SIZE_TOHOST/4); --wrap around, ToHost, 512 bytes  
        end loop;
        
        w(REG_DESCRIPTOR_0+((NUMBER_OF_DESCRIPTORS-1)*32),      BAR0, x"DEF8_0000_0000_0000"); --descr N start address
        w(REG_DESCRIPTOR_0+8+(NUMBER_OF_DESCRIPTORS-1)*32,   BAR0, x"DEF8"&FROMHOST_DESCRIPTOR_SIZE); --set to end_address
        w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32)+8,   BAR0, pc_pointer_FromHost_msb&pc_pointer_FromHost); --init PC pointer at start_address like felixcore seems to do
        --w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32)+8,   BAR0, x"DEF8"&"00"&(DESCRIPTOR_SIZE(DESCRIPTOR_SIZE'high downto 2))); --init PC pointer at 1/4 end_address
        w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32),     BAR0, x"0000_0000_0000_1800"+TLP_SIZE_FROMHOST/4); --wrap around, FromHost, 32 or 64 bytes
        w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_0010"); --Enable only FromHost descriptor
        w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_00FF"); --Enable all 8 descriptors
        --! ---- Removed this check, now going completely circular
        --!   wait for 1 us; --See what FromHost current_address does with pc_pointer at start_address.
        --!   r(REG_STATUS_0+(NUMBER_OF_DESCRIPTORS-1)*16, BAR0,RegData);
        --!   check_value(RegData, x"DEF8_0000_0000_0000", "FromHost current_address should stay nicely at start_address", C_SCOPE);
        --!   --Increment FromHost descriptor by a single TLP
        --!   w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32)+8,   BAR0, x"DEF8_0000_0000_0020"); --init PC pointer at start_address like felixcore seems to do
        --!   wait for 1 us;
        --!   r(REG_STATUS_0+(NUMBER_OF_DESCRIPTORS-1)*16, BAR0,RegData);
        --!   check_value(RegData, x"DEF8_0000_0000_0020", "FromHost current_address should stay nicely at start_address+32", C_SCOPE);
        --!   w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32)+8,   BAR0, x"DEF8_0000_0000_0060"); --init PC pointer at start_address like felixcore seems to do
        --!   wait for 1 us;
        --!   r(REG_STATUS_0+(NUMBER_OF_DESCRIPTORS-1)*16, BAR0, RegData);
        --!   check_value(RegData, x"DEF8_0000_0000_0060", "FromHost current_address should stay nicely at start_address+32", C_SCOPE);
        --!   w(REG_DESCRIPTOR_0a+((NUMBER_OF_DESCRIPTORS-1)*32)+8,   BAR0, x"DEF8"&"00"&(DESCRIPTOR_SIZE(DESCRIPTOR_SIZE'high downto 2))); --init PC pointer at 1/4 end_address
        --! ----  Removed this check, now going completely circular
        --loop
        --    r(REG_DESCRIPTOR_ENABLE, BAR0);
        --    RegData := s_axis_cc.tdata(96+63 downto 96);
        --    if(RegData(NUMBER_OF_DESCRIPTORS-1) = '0') then
        --        report "FromHost descriptor done, re-enabling";
        --        w(REG_DESCRIPTOR_ENABLE, BAR0, x"0000_0000_0000_0010"); --Enable only FromHost descriptor
        --    end if;
        --    
        --end loop;
        loop
            --Wrap ToHost descriptors
            if switch_off_tohost = '0' then
                for i in 0 to NUMBER_OF_DESCRIPTORS-2 loop
                    r(REG_STATUS_0+i*16, BAR0, RegData);
                    report "current address for desc "&to_string(i)&": "&to_hstring(RegData);
                    if(RegData(47 downto 0) = DESCRIPTOR_SIZE-TLP_SIZE_TOHOST or
                       RegData(47 downto 0) = x"0000_0000_0000") then
                        w(REG_DESCRIPTOR_0a+8+i*32,   BAR0, x"AA"&std_logic_vector(to_unsigned(i,8))&DESCRIPTOR_SIZE-TLP_SIZE_TOHOST); --set pc pointer to end_address
                        w(REG_DESCRIPTOR_0a+8+i*32,   BAR0, x"AA"&std_logic_vector(to_unsigned(i,8))&x"0000_0000_0000"); --Wrap ToHost pc_pointer
                    end if;
                end loop;
            else
                if tohost_switched_off = '0' then
                    RegData := (others => '0');
                    RegData(NUMBER_OF_DESCRIPTORS-1) := '1';
                    w(REG_DESCRIPTOR_ENABLE, BAR0, RegData); --Enable only FromHost descriptor
                end if;
                tohost_switched_off := '1';
            end if;
            --read FromHost current address.
            r(REG_STATUS_0+(NUMBER_OF_DESCRIPTORS-1)*16, BAR0, RegData);
            report "current address for desc "&to_string(NUMBER_OF_DESCRIPTORS-1)&": "&to_hstring(RegData);
            if(RegData = pc_pointer_FromHost_msb&pc_pointer_FromHost) then
                last_pc_pointer_FromHost := pc_pointer_FromHost;
                pc_pointer_FromHost := pc_pointer_FromHost+TLP_SIZE_FROMHOST;
                report "Incrementing FromHost PC pointer to "&to_hstring(pc_pointer_FromHost);
                w(REG_DESCRIPTOR_0a+8+(NUMBER_OF_DESCRIPTORS-1)*32,   BAR0, pc_pointer_FromHost_msb&pc_pointer_FromHost); --Wrap ToHost pc_pointer
                if pc_pointer_FromHost = x"000" then
                    fromhost_wraps := fromhost_wraps + 1;
                end if;
                if fromhost_wraps = 20 then
                    do_finish_fromhost <= true;
                end if;
            elsif(RegData = pc_pointer_FromHost_msb&last_pc_pointer_FromHost) then
                report "current address still needs to update, not incrementing";
            else
                error("Illegal FromHost address, was: "&to_hstring(RegData(11 downto 0))&" Expected: "
                                                 &to_hstring(pc_pointer_FromHost)&" or: "
                                                 &to_hstring(last_pc_pointer_FromHost));
            end if;
            wait for 0 ns;
        end loop;
        

    end process;
    s_axis_r_cc.tready <= '1';

    g_FromHostMem: for i in 0 to 127 generate
        g_256: if DATA_WIDTH = 256 generate
            FromHostMem(i) <= 
                std_logic_vector(to_unsigned(i, 32))&x"AAAAAA"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"BBBBBB"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"CCCCCC"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"DDDDDD"&std_logic_vector(to_unsigned(FromHostWrapCount, 8));
        end generate;
        g_512: if DATA_WIDTH = 512 generate
            FromHostMem(i) <= 
                std_logic_vector(to_unsigned(i, 32))&x"AAAAAA"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"BBBBBB"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"CCCCCC"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"DDDDDD"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"EEEEEE"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"FFFFFF"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"ABABAB"&std_logic_vector(to_unsigned(FromHostWrapCount, 8))&
                std_logic_vector(to_unsigned(i, 32))&x"CDCDCD"&std_logic_vector(to_unsigned(FromHostWrapCount, 8));
        end generate;
    end generate;

    response_proc: process(user_clk, sys_rst_n)
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
        variable ToHostMemorySelect: integer range 0 to 3;
        variable IncreaseFromHostWrapCount: boolean;
    begin
        if sys_rst_n = '0' then
            responding <= '0';
            IncreaseFromHostWrapCount := false;
        elsif rising_edge(user_clk) then
            DoCompare <= '0';
            if s_axis_rq.tvalid = '1' and s_axis_r_rq.tready = '1' then 
                if ToHost_tlp_busy = '0' then --first word, decode everything from header.
                    address := s_axis_rq.tdata(63 downto 2) & "00";
                    check_value(address(47 downto 16), x"0000_0000", ERROR, "Request address bits 47..16 must be 0", C_SCOPE);
                    if(address(63 downto 52) = x"AA0") then
                        ToHostMemorySelect := to_integer(unsigned(address(51 downto 48)));
                    end if;
                    dword_count := s_axis_rq.tdata(74 downto 64);
                    request_type := s_axis_rq.tdata(78 downto 75);
                    ToHost_pipe_data := s_axis_rq.tdata(DATA_WIDTH-1 downto 128);
                    if request_type = "0000" then
                        FromHostIndex := to_integer(unsigned(address(10 + (DATA_WIDTH/256) downto 4 + (DATA_WIDTH/256))));
                        TLPsToSend := TLPsToSend + 1;
                        if FromHostIndex = 128 - (to_integer(unsigned(dword_count))/8)then
                            IncreaseFromHostWrapCount := true;
                        end if;
                        
                    end if;
                    if request_type = "0001" then
                        ToHostIndex := to_integer(unsigned(address(10 + (DATA_WIDTH/256) downto 4 + (DATA_WIDTH/256))));
                        if ToHostIndex = 0 then
                            ToHostWrapCount <= ToHostWrapCount + 1;
                            for i in 0 to 127 loop
                                ToHostMem(ToHostMemorySelect)(i) <= (others => 'U');
                            end loop;
                        end if;

                    end if;
                    ToHost_tlp_busy := '1';
                else
                    ToHostMem(ToHostMemorySelect)(ToHostIndex) <=  s_axis_rq.tdata(127 downto 0) & ToHost_pipe_data; --write the TLP in the host memory.
                    ToHost_pipe_data := s_axis_rq.tdata(DATA_WIDTH-1 downto 128);
                    if ToHostIndex < 127 then
                        ToHostIndex := ToHostIndex + 1;
                    else
                        DoCompare <= '1';
                        ToHostMemorySelect_s <= ToHostMemorySelect;
                    end if;
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
                    m_axis_rc.tdata(11 downto 0) <= address(11 downto 0);
                    m_axis_rc.tvalid <= '1';
                    TlpIndex := to_integer(unsigned(dword_count(10 downto (2+(DATA_WIDTH/256)))));
                    if(FromHostIndex < 127) then
                        FromHostIndex := FromHostIndex + 1;
                    end if;
                    m_axis_rc.tlast <= '0';
                    TLPsToSend := TLPsToSend - 1 ;
                    m_axis_rc.tkeep <= (others => '1');
                    responding <= '1';
                elsif TlpIndex > 0 then
                    m_axis_rc.tdata(95 downto 0) <= FromHost_pipe_data;
                    m_axis_rc.tvalid <= '1';
                    if(TlpIndex > 1) then
                        m_axis_rc.tdata(DATA_WIDTH-1 downto 96) <= FromHostMem(FromHostIndex)(DATA_WIDTH-97 downto 0);
                        FromHost_pipe_data := FromHostMem(FromHostIndex)(DATA_WIDTH-1 downto DATA_WIDTH-96);
                        m_axis_rc.tlast <= '0';
                        m_axis_rc.tkeep <= (others => '1');
                        if(FromHostIndex < 127 and dword_count > (DATA_WIDTH/32)) then
                            FromHostIndex := FromHostIndex + 1;
                        end if;
                    else
                        if IncreaseFromHostWrapCount then
                            FromHostWrapCount <= FromHostWrapCount + 1;
                            IncreaseFromHostWrapCount := false;
                        end if;
                        m_axis_rc.tdata(DATA_WIDTH-1 downto 96) <= (others => '0');
                        m_axis_rc.tlast <= '1';
                        m_axis_rc.tkeep <= (others => '0');
                        m_axis_rc.tkeep(7 downto 0) <= x"07";
                        responding <= '0';
                    end if;
                    TlpIndex := TlpIndex - 1;

                end if;
            end if;
        end if;
    end process;
              
compare_proc: process(ToHostMem, ToHostMemorySelect_s, DoCompare, do_finish_fromhost)
    type slv32_array is array(0 to NUMBER_OF_DESCRIPTORS-2) of std_logic_vector(31 downto 0);
    variable cnt: slv32_array:=(others => (others => '0'));
    variable compare_value: std_logic_vector(DATA_WIDTH-1 downto 0);
    constant FINAL_CNT_VAL: std_logic_vector(31 downto 0) := x"0000_8000";
    variable do_finish_tohost: boolean := false;
begin
    switch_off_tohost <= '0';
    if DoCompare = '1' and do_finish_tohost = false then
        for i in 0 to 127 loop
            compare_value :=
              std_logic_vector(to_unsigned(ToHostMemorySelect_s,8))&
              x"dd_dddd"&cnt(ToHostMemorySelect_s)&
              x"cccc_cccc"&cnt(ToHostMemorySelect_s)&
              x"bbbb_bbbb"&cnt(ToHostMemorySelect_s)&
              x"aaaa_aaaa"&cnt(ToHostMemorySelect_s);
            assert ToHostMem(ToHostMemorySelect_s)(i) = compare_value report "Memory: "&to_string(ToHostMemorySelect_s)&" index: "&to_string(i)&" expected:"&
                to_hstring(compare_value) & " value: " & to_hstring(ToHostMem(ToHostMemorySelect_s)(i)) severity error;
            check_value(ToHostMem(ToHostMemorySelect_s)(i), compare_value,ERROR, "Check counter value in ToHost memory", C_SCOPE);
            cnt(ToHostMemorySelect_s) := cnt(ToHostMemorySelect_s) + 1;
        end loop;
        do_finish_tohost := true;
        for i in 0 to NUMBER_OF_DESCRIPTORS-2 loop
            if cnt(i) < FINAL_CNT_VAL then
                do_finish_tohost := false;
            end if;
        end loop;
    end if;
    if(do_finish_tohost) then
        switch_off_tohost <= '1';
    end if;
    if(do_finish_tohost and do_finish_fromhost) then
      report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
      log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

      -- Finish the simulation
      std.env.stop;
    end if;
end process;



tready_proc: process(user_clk)
    variable rnd: std_logic_vector(9 downto 0);
begin
    if rising_edge(user_clk) then
        rnd := random(10);
        if rnd < 256 then
            s_axis_r_rq.tready <= '0';
        else
            s_axis_r_rq.tready <= not responding;
        end if;
    end if;
    
end process;
    
    user_lnk_up   <= '1';--             : out    std_logic
    reset <= not sys_rst_n;
    clk   <= sysclk_gen;
    user_clk <= sysclk_gen;
    
        
end sim;
