--------------------------------------------------------------------------------
--                       Normalizer_ZO_14_14_14_F0_uid6
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X OZb
-- Output signals: Count R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_ZO_14_14_14_F0_uid6 is
    port (X : in  std_logic_vector(13 downto 0);
          OZb : in  std_logic;
          Count : out  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(13 downto 0)   );
end entity;

architecture arch of Normalizer_ZO_14_14_14_F0_uid6 is
signal level4 :  std_logic_vector(13 downto 0);
signal sozb :  std_logic;
signal count3 :  std_logic;
signal level3 :  std_logic_vector(13 downto 0);
signal count2 :  std_logic;
signal level2 :  std_logic_vector(13 downto 0);
signal count1 :  std_logic;
signal level1 :  std_logic_vector(13 downto 0);
signal count0 :  std_logic;
signal level0 :  std_logic_vector(13 downto 0);
signal sCount :  std_logic_vector(3 downto 0);
begin
   level4 <= X ;
   sozb<= OZb;
   count3<= '1' when level4(13 downto 6) = (13 downto 6=>sozb) else '0';
   level3<= level4(13 downto 0) when count3='0' else level4(5 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(13 downto 10) = (13 downto 10=>sozb) else '0';
   level2<= level3(13 downto 0) when count2='0' else level3(9 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2(13 downto 12) = (13 downto 12=>sozb) else '0';
   level1<= level2(13 downto 0) when count1='0' else level2(11 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1(13 downto 13) = (13 downto 13=>sozb) else '0';
   level0<= level1(13 downto 0) when count0='0' else level1(12 downto 0) & (0 downto 0 => '0');

   R <= level0;
   sCount <= count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                       PositFastDecoder_16_2_F0_uid4
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo (2021-2022)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X
-- Output signals: Sign SF Frac NZN

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity PositFastDecoder_16_2_F0_uid4 is
    port (X : in  std_logic_vector(15 downto 0);
          Sign : out  std_logic;
          SF : out  std_logic_vector(6 downto 0);
          reg_L : out std_logic_vector(3 downto 0); --
          Frac : out  std_logic_vector(10 downto 0);
          NZN : out  std_logic   );
end entity;

architecture arch of PositFastDecoder_16_2_F0_uid4 is
   component Normalizer_ZO_14_14_14_F0_uid6 is
      port ( X : in  std_logic_vector(13 downto 0);
             OZb : in  std_logic;
             Count : out  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(13 downto 0)   );
   end component;

signal sgn :  std_logic;
signal pNZN :  std_logic;
signal rc :  std_logic;
signal regPosit :  std_logic_vector(13 downto 0);
signal regLength :  std_logic_vector(3 downto 0);
signal shiftedPosit :  std_logic_vector(13 downto 0);
signal k :  std_logic_vector(4 downto 0);
signal sgnVect :  std_logic_vector(1 downto 0);
signal exp :  std_logic_vector(1 downto 0);
signal pSF :  std_logic_vector(6 downto 0);
signal pFrac :  std_logic_vector(10 downto 0);
begin
--------------------------- Start of vhdl generation ---------------------------
--------------------------- Sign bit & special cases ---------------------------
   sgn <= X(15);
   pNZN <= '0' when (X(14 downto 0) = "000000000000000") else '1';
-------------- Count leading zeros/ones of regime & shift it out --------------
   rc <= X(14);
   regPosit <= X(13 downto 0);
   RegimeCounter: Normalizer_ZO_14_14_14_F0_uid6
      port map ( OZb => rc,
                 X => regPosit,
                 Count => regLength,
                 R => shiftedPosit);
----------------- Determine the scaling factor - regime & exp -----------------
   k <= "0" & regLength when rc /= sgn else "1" & NOT(regLength);
   sgnVect <= (others => sgn);
   exp <= shiftedPosit(12 downto 11) XOR sgnVect;
   pSF <= k & exp;
------------------------------- Extract fraction -------------------------------
   pFrac <= shiftedPosit(10 downto 0);
   Sign <= sgn;
   SF <= pSF;
   Frac <= pFrac;
   NZN <= pNZN;
   --
   reg_L <= regLength;
---------------------------- End of vhdl generation ----------------------------
end architecture;

--------------------------------------------------------------------------------
--                  RightShifterSticky15_by_max_15_F0_uid38
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X S padBit
-- Output signals: R Sticky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifterSticky15_by_max_15_F0_uid38 is
    port (X : in  std_logic_vector(14 downto 0);
          S : in  std_logic_vector(3 downto 0);
          padBit : in  std_logic;
          R : out  std_logic_vector(14 downto 0);
          Sticky : out  std_logic   );
end entity;

architecture arch of RightShifterSticky15_by_max_15_F0_uid38 is
signal ps :  std_logic_vector(3 downto 0);
signal Xpadded :  std_logic_vector(14 downto 0);
signal level4 :  std_logic_vector(14 downto 0);
signal stk3 :  std_logic;
signal level3 :  std_logic_vector(14 downto 0);
signal stk2 :  std_logic;
signal level2 :  std_logic_vector(14 downto 0);
signal stk1 :  std_logic;
signal level1 :  std_logic_vector(14 downto 0);
signal stk0 :  std_logic;
signal level0 :  std_logic_vector(14 downto 0);
begin
   ps<= S;
   Xpadded <= X;
   level4<= Xpadded;
   stk3 <= '1' when (level4(7 downto 0)/="00000000" and ps(3)='1')   else '0';
   level3 <=  level4 when  ps(3)='0'    else (7 downto 0 => padBit) & level4(14 downto 8);
   stk2 <= '1' when (level3(3 downto 0)/="0000" and ps(2)='1') or stk3 ='1'   else '0';
   level2 <=  level3 when  ps(2)='0'    else (3 downto 0 => padBit) & level3(14 downto 4);
   stk1 <= '1' when (level2(1 downto 0)/="00" and ps(1)='1') or stk2 ='1'   else '0';
   level1 <=  level2 when  ps(1)='0'    else (1 downto 0 => padBit) & level2(14 downto 2);
   stk0 <= '1' when (level1(0 downto 0)/="0" and ps(0)='1') or stk1 ='1'   else '0';
   level0 <=  level1 when  ps(0)='0'    else (0 downto 0 => padBit) & level1(14 downto 1);
   R <= level0;
   Sticky <= stk0;
end architecture;

--------------------------------------------------------------------------------
--                       PositFastEncoder_16_2_F0_uid36
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo (2021-2022)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: Sign SF Frac Guard Sticky NZN
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity PositFastEncoder_16_2_F0_uid36 is
    port (Sign : in  std_logic;
          SF : in  std_logic_vector(7 downto 0);
          Frac : in  std_logic_vector(10 downto 0);
          Guard : in  std_logic;
          Sticky : in  std_logic;
          NZN : in  std_logic;
          R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of PositFastEncoder_16_2_F0_uid36 is
   component RightShifterSticky15_by_max_15_F0_uid38 is
      port ( X : in  std_logic_vector(14 downto 0);
             S : in  std_logic_vector(3 downto 0);
             padBit : in  std_logic;
             R : out  std_logic_vector(14 downto 0);
             Sticky : out  std_logic   );
   end component;

signal rc :  std_logic;
signal rcVect :  std_logic_vector(4 downto 0);
signal k :  std_logic_vector(4 downto 0);
signal sgnVect :  std_logic_vector(1 downto 0);
signal exp :  std_logic_vector(1 downto 0);
signal ovf :  std_logic;
signal regValue :  std_logic_vector(3 downto 0);
signal regNeg :  std_logic;
signal padBit :  std_logic;
signal inputShifter :  std_logic_vector(14 downto 0);
signal shiftedPosit :  std_logic_vector(14 downto 0);
signal stkBit :  std_logic;
signal unroundedPosit :  std_logic_vector(14 downto 0);
signal lsb :  std_logic;
signal rnd :  std_logic;
signal stk :  std_logic;
signal round :  std_logic;
signal roundedPosit :  std_logic_vector(14 downto 0);
signal unsignedPosit :  std_logic_vector(14 downto 0);
begin
--------------------------- Start of vhdl generation ---------------------------
----------------------------- Get value of regime -----------------------------
   rc <= SF(SF'high);
   rcVect <= (others => rc);
   k <= SF(6 downto 2) XOR rcVect;
   sgnVect <= (others => Sign);
   exp <= SF(1 downto 0) XOR sgnVect;
   -- Check for regime overflow
   ovf <= '1' when (k > "01101") else '0';
   regValue <= k(3 downto 0) when ovf = '0' else "1110";
-------------- Generate regime - shift out exponent and fraction --------------
   regNeg <= Sign XOR rc;
   padBit <= NOT(regNeg);
   inputShifter <= regNeg & exp & Frac & Guard;
   RegimeGenerator: RightShifterSticky15_by_max_15_F0_uid38
      port map ( S => regValue,
                 X => inputShifter,
                 padBit => padBit,
                 R => shiftedPosit,
                 Sticky => stkBit);
   unroundedPosit <= padBit & shiftedPosit(14 downto 1);
---------------------------- Round to nearest even ----------------------------
   lsb <= shiftedPosit(1);
   rnd <= shiftedPosit(0);
   stk <= stkBit OR Sticky;
   round <= rnd AND (lsb OR stk OR ovf);
   roundedPosit <= unroundedPosit + round;
-------------------------- Check sign & Special Cases --------------------------
   unsignedPosit <= roundedPosit when NZN = '1' else (others => '0');
   R <= Sign & unsignedPosit;
---------------------------- End of vhdl generation ----------------------------
end architecture;

--------------------------------------------------------------------------------
--                                 PositSqrt
--                          (PositSqrt_16_2_F0_uid2)
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo (2022)
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
use ieee.math_real.all; -- for ceil function
library std;
use std.textio.all;
library work;

entity PositSqrt is
    port (
         clk, rst : in std_logic;
         start : in  std_logic;
         X : in  std_logic_vector(15 downto 0);
         done: out std_logic;
         R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of PositSqrt is
   component PositFastDecoder_16_2_F0_uid4 is
      port ( X : in  std_logic_vector(15 downto 0);
             Sign : out  std_logic;
             SF : out  std_logic_vector(6 downto 0);
             reg_L : out std_logic_vector(3 downto 0);
             Frac : out  std_logic_vector(10 downto 0);
             NZN : out  std_logic   );
   end component;

   component Non_Restoring_SQRT is
      generic (
         n : positive;
         iter_len : positive
      );
      port (
         clk, rst : in std_logic;
         start : in  std_logic;
         X : in std_logic_vector(n-1 downto 0);
         iters : in  std_logic_vector(iter_len-1 downto 0);
         ready: out std_logic;
         R : out std_logic_vector(n-1 downto 0)   );
   end component;

   component PositFastEncoder_16_2_F0_uid36 is
      port ( Sign : in  std_logic;
             SF : in  std_logic_vector(7 downto 0);
             Frac : in  std_logic_vector(10 downto 0);
             Guard : in  std_logic;
             Sticky : in  std_logic;
             NZN : in  std_logic;
             R : out  std_logic_vector(15 downto 0)   );
   end component;

signal X_sgn :  std_logic;
signal X_sf :  std_logic_vector(6 downto 0);
signal X_f :  std_logic_vector(10 downto 0);
signal X_nzn :  std_logic;
signal XY_nzn :  std_logic;
signal XY_finalSgn :  std_logic;
signal odd_exp :  std_logic;
signal X_sf_1 :  std_logic_vector(7 downto 0);
signal X_sf_2 :  std_logic_vector(7 downto 0);
signal X_sf_3 :  std_logic_vector(7 downto 0);
signal sqrt_f :  std_logic_vector(13 downto 0);
signal XY_sf :  std_logic_vector(7 downto 0);
signal XY_frac :  std_logic_vector(10 downto 0);
signal grd :  std_logic;
signal stk :  std_logic;
--------------- extra signals
signal sqrt_in :  std_logic_vector(13 downto 0);
signal sqrt_ready :  std_logic;
--- Need registers for the signals in the rounding logic
signal XY_sf_reg :  std_logic_vector(7 downto 0);
signal XY_nzn_reg :  std_logic;
signal XY_finalSgn_reg :  std_logic;
signal sqrt_in_reg: std_logic_vector(13 downto 0);
signal start_reg: std_logic;
signal sqrt_f_reg :  std_logic_vector(13 downto 0);
signal ready_reg: std_logic;
signal ready: std_logic;
--- Signals for optimized module
signal reg_Len: std_logic_vector(3 downto 0);
signal iters_aux: std_logic_vector(3 downto 0);
signal iters: std_logic_vector(3 downto 0);


begin

-------------------------------------------------------------------------------
-- * registro inicial                                                        --
-------------------------------------------------------------------------------

REG_DATA_TOP : process (clk,rst) is
   begin
   if (rst = '1') then
      XY_sf_reg <= (others => '0');
      XY_nzn_reg <= '1';
      XY_finalSgn_reg <= '0';
      sqrt_in_reg <= (others => '0');
      start_reg <= '0';
      sqrt_f_reg <= (others => '0');
      ready_reg <= '0';
   elsif rising_edge(clk) then
      XY_sf_reg <= XY_sf;
      XY_nzn_reg <= XY_nzn;
      XY_finalSgn_reg <= XY_finalSgn;
      sqrt_in_reg <= sqrt_in;
      start_reg <= start;
      sqrt_f_reg <= sqrt_f;
      ready_reg <= ready;
   end if;
end process REG_DATA_TOP;


--------------------------- Start of vhdl generation ---------------------------
------------------------------- Decode X operand -------------------------------
   X_decoder: PositFastDecoder_16_2_F0_uid4
      port map ( X => X,
                 Frac => X_f,
                 NZN => X_nzn,
                 reg_L => reg_Len,
                 SF => X_sf,
                 Sign => X_sgn);
   -- Sign and Special Cases Computation
   XY_nzn <= NOT(X_sgn) AND X_nzn;
   XY_finalSgn <= X_sgn;
----------------------------- Exponent computation -----------------------------
   odd_exp <= X_sf(0);
   -- Divide exponent by 2
   X_sf_3 <= X_sf(X_sf'high) & X_sf(X_sf'high) & X_sf(6 downto 1);

   -- -- Add 1 to exponent to compensate fraction division
   -- odd_exp <= X_sf(0);
   -- X_sf_1 <= (X_sf(X_sf'high) & X_sf) + 1 when odd_exp='1' else (X_sf(X_sf'high) & X_sf) + 2;
   -- -- Divide exponent by 2
   -- X_sf_2 <= X_sf_1(X_sf_1'high) & X_sf_1(7 downto 1);
   -- -- Subtract 1 to exponent to compensate fraction multiplication
   -- X_sf_3 <= X_sf_2 - 1;
----------------------------- Sqrt of the fraction -----------------------------

sqrt_in <= ("01" & X_f & '0') when odd_exp='1' else ("001" & X_f);

-- TODO:
-- iters_aux <= "1111" - reg_Len;
-- iters <= "1100" when iters_aux > "1101" else iters_aux(3 downto 0) - 1;
iters <= "1100" - ('0' & reg_Len(3 downto 1)); -- this works

-- iters_aux <= reg_Len - odd_exp;
-- iters <= "1100" - ('0' & iters_aux(3 downto 1));


sqrt_module: Non_Restoring_SQRT
generic map (
   n => 16-2,
   iter_len => natural(ceil(log2(real(16-2-1))))
)
port map ( 
         clk => clk, 
         rst => rst,
         start => start_reg, --
         X => sqrt_in_reg, --
         iters => iters,
         ready => sqrt_ready,
         R => sqrt_f);
-- ready <= sqrt_ready; -- OR NOT(XY_nzn_reg); -- Fast forward special values. TODO: FIX
ready <= sqrt_ready;
done <= ready_reg;
----------------------------- Generate final posit -----------------------------
   XY_sf <= X_sf_3;
   XY_frac <= sqrt_f_reg(12 downto 2);
   grd <= sqrt_f_reg(1);
   stk <= sqrt_f_reg(0);
   PositEncoder: PositFastEncoder_16_2_F0_uid36
      port map ( Frac => XY_frac,
                 Guard => grd,
                 NZN => XY_nzn_reg,
                 SF => XY_sf_reg,
                 Sign => XY_finalSgn_reg,
                 Sticky => stk,
                 R => R);
---------------------------- End of vhdl generation ----------------------------
end architecture;

