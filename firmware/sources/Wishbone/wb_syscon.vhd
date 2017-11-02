----------------------------------------------------------------------
-- Module name:     SYC0001a.VHD
--
-- Description:     A simple WISHBONE SYSCON for FPGA.  For more infor-
--                  mation, please refer to the WISHBONE Public Domain
--                  Library Technical Reference Manual.
--
-- History:         Project complete:           SEP 20, 2001
--                                              WD Peterson
--                                              Silicore Corporation
--
-- Release:         Notice is hereby given that this document is not
--                  copyrighted, and has been placed into the public
--                  domain.  It may be freely copied and distributed
--                  by any means.
--
-- Disclaimer:      In no event shall Silicore Corporation be liable
--                  for incidental, consequential, indirect or special
--                  damages resulting from the use of this file.  The
--                  user assumes all responsibility for its use.
--
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Load the IEEE 1164 library and make it visible.
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------------
-- Entity declaration.
----------------------------------------------------------------------

entity wb_syscon is
    port(
            -- WISHBONE Interface

            CLK_O:  out std_logic;
            RST_O:  out std_logic;


            -- NON-WISHBONE Signals

            EXTCLK: in  std_logic;   
            EXTRST: in  std_logic
         );

end wb_syscon;


----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture wb_syscon of wb_syscon IS

    
begin

  CLK_O <= EXTCLK;
  RST_O <= EXTRST;


end architecture wb_syscon;