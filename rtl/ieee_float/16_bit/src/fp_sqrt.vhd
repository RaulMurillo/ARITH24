--------------------------------------------------------------------------------
--                             ControlUnit
-- All rights reserved 
-- Authors: Raul Murillo (2024)
--------------------------------------------------------------------------------
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X start
-- Input control signals: clk rst
-- Output signals: R done

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPSqrt is
    port (
         clk, rst : in std_logic;
         start : in  std_logic;
         X : in  std_logic_vector(15 downto 0);
         done: out std_logic;
         R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of FPSqrt is
   component InputIEEE is
      port (X : in  std_logic_vector(15 downto 0);
            R : out  std_logic_vector(5+10+2 downto 0)   );
   end component;

   component FP_Non_Restoring_SQRT is
      port (
         clk, rst : in std_logic;
         start : in  std_logic;
         X : in std_logic_vector(5+10+2 downto 0);
         ready: out std_logic;
         R : out std_logic_vector(5+10+2 downto 0)   );
   end component;

   component OutputIEEE is
      port (X : in  std_logic_vector(5+10+2 downto 0);
            R : out  std_logic_vector(15 downto 0)   );
   end component;

signal X_in, X_in_reg std_logic_vector(5+10+2 downto 0);
signal R_out, R_out_reg std_logic_vector(5+10+2 downto 0);
signal start_reg std_logic;
signal ready_reg std_logic;

begin

-------------------------------------------------------------------------------
-- * initial register                                                        --
-------------------------------------------------------------------------------

REG_DATA_TOP : process (clk,rst) is
   begin
   if (rst = '1') then
      X_in_reg <= (others => '0');
      R_out_reg <= (others => '0');
      start_reg <= '0';
      ready_reg <= '0';
   elsif rising_edge(clk) then
      X_in_reg <= X_in;
      R_out_reg <= R_out;
      start_reg <= start;
      ready_reg <= ready;
   end if;
end process REG_DATA_TOP;

------------------------------- Decode X operand -------------------------------
   X_decoder: InputIEEE
      port map ( X => X,
                 R => X_in);

----------------------------- Sqrt of the fraction -----------------------------
    sqrt_module: FP_Non_Restoring_SQRT
    port map ( 
            clk => clk, 
            rst => rst,
            start => start_reg,
            X => X_in_reg,
            ready => sqrt_ready,
            R => R_out);

    ready <= sqrt_ready;
    done <= ready_reg;

------------------------------- Round the result -------------------------------
   round_mod: OutputIEEE
      port map ( X => R_out_reg,
                 R => R);
---------------------------- End of vhdl generation ----------------------------

end architecture;