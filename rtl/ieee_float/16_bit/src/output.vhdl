--------------------------------------------------------------------------------
--                                 OutputIEEE
--                         (OutputIEEE_5_10_to_5_10)
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: F. Ferrandi  (2009-2012)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity OutputIEEE is
    port (X : in  std_logic_vector(5+10+2 downto 0);
          R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of OutputIEEE is
signal fracX :  std_logic_vector(9 downto 0);
signal exnX :  std_logic_vector(1 downto 0);
signal expX :  std_logic_vector(4 downto 0);
signal sX :  std_logic;
signal expZero :  std_logic;
signal fracR :  std_logic_vector(9 downto 0);
signal expR :  std_logic_vector(4 downto 0);
begin
   fracX  <= X(9 downto 0);
   exnX  <= X(17 downto 16);
   expX  <= X(14 downto 10);
   sX  <= X(15) when (exnX = "01" or exnX = "10" or exnX = "00") else '0';
   expZero  <= '1' when expX = (4 downto 0 => '0') else '0';
   -- since we have one more exponent value than IEEE (field 0...0, value emin-1),
   -- we can represent subnormal numbers whose mantissa field begins with a 1
   fracR <= 
      "0000000000" when (exnX = "00") else
      '1' & fracX(9 downto 1) & "" when (expZero = '1' and exnX = "01") else
      fracX  & "" when (exnX = "01") else 
      "000000000" & exnX(0);
   expR <=  
      (4 downto 0 => '0') when (exnX = "00") else
      expX when (exnX = "01") else 
      (4 downto 0 => '1');
   R <= sX & expR & fracR; 
end architecture;

