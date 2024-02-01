--------------------------------------------------------------------------------
-- Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
--
-- This   document  contains  proprietary information  which   is        
-- protected by  copyright. All rights  are reserved.  This notice       
-- refers to original work by Efinix, Inc. which may be derivitive       
-- of other work distributed under license of the authors.  In the       
-- case of derivative work, nothing in this notice overrides the         
-- original author's license agreement.  Where applicable, the           
-- original license agreement is included in it's original               
-- unmodified form immediately below this header.                        
--                                                                       
-- WARRANTY DISCLAIMER.                                                  
--     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
--     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
--     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
--     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
--     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
--     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
--     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
--                                                                       
-- LIMITATION OF LIABILITY.                                              
--     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
--     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
--     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
--     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
--     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
--     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
--     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
--     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
--     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
--     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
--     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
--     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
--     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
--     APPLY TO LICENSEE.                                                
--
--------------------------------------------------------------------------------
------------- Begin Cut here for COMPONENT Declaration ------
COMPONENT jtag2spi is
PORT (
rstn : in std_logic;
clkin : in std_logic;
miso : in std_logic;
sclk : out std_logic;
nss : out std_logic;
mosi : out std_logic;
jtag_inst1_CAPTURE : in std_logic;
jtag_inst1_DRCK : in std_logic;
jtag_inst1_RESET : in std_logic;
jtag_inst1_RUNTEST : in std_logic;
jtag_inst1_SEL : in std_logic;
jtag_inst1_SHIFT : in std_logic;
jtag_inst1_TCK : in std_logic;
jtag_inst1_TDI : in std_logic;
jtag_inst1_TMS : in std_logic;
jtag_inst1_UPDATE : in std_logic;
jtag_inst1_TDO : out std_logic;
wp_n : out std_logic;
hold_n : out std_logic;
osc_inst1_ENA : out std_logic);
END COMPONENT;
---------------------- End COMPONENT Declaration ------------

------------- Begin Cut here for INSTANTIATION Template -----
u_jtag2spi : jtag2spi
PORT MAP (
rstn => rstn,
clkin => clkin,
miso => miso,
sclk => sclk,
nss => nss,
mosi => mosi,
jtag_inst1_CAPTURE => jtag_inst1_CAPTURE,
jtag_inst1_DRCK => jtag_inst1_DRCK,
jtag_inst1_RESET => jtag_inst1_RESET,
jtag_inst1_RUNTEST => jtag_inst1_RUNTEST,
jtag_inst1_SEL => jtag_inst1_SEL,
jtag_inst1_SHIFT => jtag_inst1_SHIFT,
jtag_inst1_TCK => jtag_inst1_TCK,
jtag_inst1_TDI => jtag_inst1_TDI,
jtag_inst1_TMS => jtag_inst1_TMS,
jtag_inst1_UPDATE => jtag_inst1_UPDATE,
jtag_inst1_TDO => jtag_inst1_TDO,
wp_n => wp_n,
hold_n => hold_n,
osc_inst1_ENA => osc_inst1_ENA);
------------------------ End INSTANTIATION Template ---------
