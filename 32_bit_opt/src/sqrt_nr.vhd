--------------------------------------------------------------------------------
--                             ControlUnit
-- All rights reserved 
-- Authors: Raul Murillo (2024)
--------------------------------------------------------------------------------
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X Y Cin
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity ControlUnit is
   port (
         -- clk & reset
         clk          : in  std_logic;
         rst          : in  std_logic;
         -- control entrada
         start        : in  std_logic;
         -- control salida
         done         : out std_logic;
         -- interfaz ruta de datos
         stat_n       : in  std_logic;
         stat_z       : in  std_logic;
         -- stat_nonzero : in  std_logic;
         ctrl_load    : out std_logic;
         ctrl_op      : out std_logic;
         ctrl_done    : out std_logic         
         );
end entity;

architecture arch of ControlUnit is
   
   -- Type for the FSM states
   type state_type is (idle, op);
   -- State registers
   signal state_reg, state_next : state_type;
   signal int_done  : std_logic;

begin

-------------------------------------------------------------------------------
-- * process registered                                                    --
-------------------------------------------------------------------------------

   P_REGISTERED : process (clk,rst) is
   begin
      if (rst = '1') then
         state_reg <= idle;
      elsif rising_edge(clk) then
         state_reg <= state_next;
      end if;
   end process P_REGISTERED;


-------------------------------------------------------------------------------
-- * proceso maquina de estados                                              --
-------------------------------------------------------------------------------

   P_MAQUINA : process (state_reg, start, stat_n, stat_z) is
   begin
      case state_reg is
         when idle =>
            if (start = '1') then
               state_next <= op;
            else
               state_next <= idle;
            end if;
         when op =>
            if (stat_z = '1') then -- early stop. zero remainder
               state_next <= idle;
            elsif (stat_n = '1') then
               state_next <= idle;
            else
               state_next <= op;
            end if;
         -- when rounding =>
         --    state_next <= idle;
         when others =>
            state_next <= idle;
      end case;
   end process P_MAQUINA;

-------------------------------------------------------------------------------
-- * proceso combinacional salidas                                           --
-------------------------------------------------------------------------------

P_SALIDA : process (state_reg) is
   begin
      case state_reg is
         --  when idle =>
         --    ctrl_load <= '1';
         --    ctrl_op   <= '0';
         --    int_done  <= '0';
         when op =>
            ctrl_load <= '0';
            ctrl_op   <= '1';
            int_done  <= '0';
         -- when rounding =>
         --    ctrl_load <= '0';
         --    ctrl_op   <= '0';
         --    int_done  <= '0';
         when others => -- idle
            ctrl_load <= '1';
            ctrl_op   <= '0';
            int_done  <= '1';
      end case;
   end process P_SALIDA;

   -- FSM_DONE : process (clk,rst) is
   -- begin
   --    if (rst = '1') then
   --       done <= '0';
   --    elsif rising_edge(clk) then
   --       done <= int_done;
   --    end if;
   -- end process FSM_DONE;

   done <= int_done;
   ctrl_done <= int_done;

end architecture;


--------------------------------------------------------------------------------
--                             DataPath
-- All rights reserved 
-- Authors: Raul Murillo (2024)
--------------------------------------------------------------------------------
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X Y Cin
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- use ieee.math_real.all; -- for ceil function
library std;
use std.textio.all;
library work;

entity DataPath is
   generic (
      n : positive; -- 1 integer bit, n-1 fraction bits -> n-1 iterations
      iter_len : positive -- bit length of the iterations counter, log2(n-1)
   );
   port (
         clk            : in  std_logic;
         rst            : in  std_logic;
         -- -- Inputs
         -- r_reg : in  std_logic_vector(8 downto 0);
         -- q_reg : in  std_logic_vector(7 downto 0);
         -- real_q_reg : in  std_logic_vector(7 downto 0);
         -- pow_2_reg : in  std_logic_vector(8 downto 0);
         -- z_reg : in  std_logic;
         -- -- Outputs
         -- r_next : out  std_logic_vector(8 downto 0);
         -- q_next : out  std_logic_vector(7 downto 0);
         -- real_q_next : out  std_logic_vector(7 downto 0);
         -- pow_2_next: out std_logic_vector(8 downto 0);
         -- z_next : out  std_logic
         ----
         r : in  std_logic_vector(n downto 0);
         iters : in  std_logic_vector(iter_len-1 downto 0);
         -- Control signals
         ctrl_load      : in  std_logic;
         ctrl_op        : in  std_logic;
         ctrl_done      : in  std_logic;
         stat_n         : out std_logic;
         stat_z         : out std_logic;
         -- stat_nonzero   : out std_logic;
         root : out std_logic_vector(n-1 downto 0)
         );
end entity;

architecture arch of DataPath is

-- ** constant declaration
   -- constant C_LEN : natural := natural(ceil(log2(real(n-1))));
   -- iter_len

   constant C_ZERO : std_logic_vector((iter_len-1) downto 0) := std_logic_vector(to_unsigned(0,iter_len));
   constant C_ITER : std_logic_vector((iter_len-1) downto 0) := std_logic_vector(to_unsigned(n-2,iter_len));
   -- constant C_ITER : std_logic_vector(2 downto 0) := "110";
   -- need as many iterations as fraction bits (n-1 downto 0).
   -- The conversion to two's complement is done on the fly


   -- ** signal declaration
   signal r_reg, r_next : std_logic_vector(n downto 0);
   signal q_reg, q_next : std_logic_vector(n-1 downto 0);
   signal real_q_reg, real_q_next : std_logic_vector(n-1 downto 0);
   signal pow_2_reg : std_logic_vector(n downto 0);
   signal pow_2_next : std_logic_vector(n downto 0);
   signal z_reg, z_next : std_logic;

   signal sign_r :  std_logic;
   signal two_r :  std_logic_vector(n downto 0);
   signal two_q :  std_logic_vector(n downto 0);
   signal cond :  std_logic;
   signal n_aux :  std_logic_vector(n downto 0);
   signal rem_z :  std_logic;

   signal int_n   : std_logic_vector((iter_len-1) downto 0);
   signal root_tmp : std_logic_vector(n-1 downto 0);

begin

   -- Iteration i-th

   sign_r <= r_reg(n);
   two_r <= r_reg(n-1 downto 0) & '0';
   pow_2_next <= '0' & pow_2_reg(n downto 1);
   cond <= sign_r OR z_reg;
   q_next <= (q_reg OR pow_2_reg(n-1 downto 0)) when cond='0' else q_reg;
   ----------------------------------------------
   -- NOTE: Why 2Q_i must do OR with 2^-i?
   -- Both real_q and two_q must be in two's complement, 
   -- so we need to replace the '-1' bits.
   -- This is a workaround to avoid the use of two vectors,
   -- one for the positive values and another for the negative bits of q.
   -- Maybe handling the '1's and '-1's in different vectors improve 
   -- readability. Also, neet to check the performance/synthesis.
   real_q_next <= ((q_next(n-2 downto 0) & '0') OR ('0' & pow_2_reg(n-2 downto 0))) when z_reg='0' else real_q_reg;
   two_q <= ('0' & q_reg(n-2 downto 0) & '0') OR ('0' & pow_2_reg(n-2 downto 0) & '0');
   ----------------------------------------------

   n_aux <= (two_q + pow_2_next) when sign_r='0' else
            (two_q - pow_2_next);
   r_next <= two_r - (two_q + pow_2_next) when sign_r='0' else
   two_r + (two_q - pow_2_next);
   rem_z <= '1' when r_next = 0 else '0';
   z_next <= rem_z OR z_reg;
   
-------------------------------------------------------------------------------
-- * comparaciones                                                           --
-------------------------------------------------------------------------------

stat_n <= '1' when (int_n = C_ZERO) else '0';
stat_z <= z_next;
-- stat_z <= '0';

-- stat_nonzero <= '1' when int_b(0) = '1' else '0';

-------------------------------------------------------------------------------
-- * registro inicial                                                        --
-------------------------------------------------------------------------------

   REG_DATA : process (clk,rst) is
      begin
      if (rst = '1') then
            r_reg <= (others => '0');
            q_reg <= (others => '0');
            real_q_reg <= (others => '0');
            pow_2_reg <= (others => '0');
            z_reg <= '0';
      elsif rising_edge(clk) then
         if (ctrl_load = '1') then
            r_reg <= r;
            q_reg <= (others => '0');
            real_q_reg <= (others => '0');
            pow_2_reg(n-2 downto 0) <= (others => '0');
            pow_2_reg(n downto n-1) <= "01";--"010...0";
            z_reg <= '0';
         else
            r_reg <= r_next;
            q_reg <= q_next;
            real_q_reg <= real_q_next;
            pow_2_reg <= pow_2_next;
            z_reg <= z_next;
         end if;
      end if;
   end process REG_DATA;

-------------------------------------------------------------------------------
-- * iteration counter                                                       --
-------------------------------------------------------------------------------

   ITER_COUNT : process (clk,rst) is
   begin
      if (rst = '1') then
      int_n <= (others => '0');
      elsif rising_edge(clk) then
      if (ctrl_load = '1') then
         int_n <= iters;
      else
         if (ctrl_op = '1') then
            int_n <= int_n - 1;
         else
            int_n <= int_n;
         end if;
      end if;
      end if;
   end process ITER_COUNT;

-------------------------------------------------------------------------------
-- * salida                                                                  --
-------------------------------------------------------------------------------

   -- DONE : process (clk,rst) is
   --    begin
   --    if (rst = '1') then
   --       root <= (others => '0');
   --    elsif rising_edge(clk) then
   --       if (ctrl_load = '1') then
   --          root <= (others => '0');
   --       else
   --          if (ctrl_done = '1') then
   --             root <= root_tmp;
   --          end if;
   --       end if;
   --    end if;
   --    end process DONE;

   -- Convert the result to two's complement representation
   -- root_tmp <= q_next(6 downto 0) & '1' when z_reg='0' else real_q_next;
   -- root <= q_next(6 downto 0) & '1' when z_reg='0' else real_q_next;
   root_tmp <= q_next(n-2 downto 0) & '1' when z_next='0' else real_q_next;
   root <= q_next(n-2 downto 0) & '1' when z_next='0' else real_q_next;

end architecture;


--------------------------------------------------------------------------------
--                        Non_Restoring_SQRT
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Raul Murillo
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
-- use ieee.math_real.all; -- for ceil function
use std.textio.all;
library work;

-- entity Non_Restoring_SQRT with n-bit input and output
entity Non_Restoring_SQRT is
   generic (
      n : positive; -- 1 integer bit, n-1 fraction bits -> n-1 iterations
      iter_len : positive -- bit length of the iterations counter, log2(n-1)
   );
   port (
      clk, rst : in std_logic;
      -- input control
      start : in  std_logic;
      X : in std_logic_vector(n-1 downto 0);
      iters : in  std_logic_vector(iter_len-1 downto 0);
      R : out std_logic_vector(n-1 downto 0);
      -- output control
      ready : out std_logic
   );
end entity Non_Restoring_SQRT;

architecture arch of Non_Restoring_SQRT is

   component DataPath is
      generic (
         n : positive; -- 1 integer bit, n-1 fraction bits -> n-1 iterations
         iter_len : positive -- bit length of the iterations counter, log2(n-1)
      );
      port (
            clk            : in  std_logic;
            rst            : in  std_logic;
            r : in  std_logic_vector(n downto 0);
            iters : in  std_logic_vector(iter_len-1 downto 0);
            -- Control signals
            ctrl_load      : in  std_logic;
            ctrl_op        : in  std_logic;
            ctrl_done      : in  std_logic;
            stat_n         : out std_logic;
            stat_z         : out std_logic;
            -- stat_nonzero   : out std_logic;
            root : out std_logic_vector(n-1 downto 0)
            );
   end component;

   component ControlUnit is
      port (
            -- clk & reset
            clk          : in  std_logic;
            rst          : in  std_logic;
            -- control entrada
            start        : in  std_logic;
            -- control salida
            done         : out std_logic;
            -- interfaz ruta de datos
            stat_n       : in  std_logic;
            stat_z       : in  std_logic;
            -- stat_nonzero : in  std_logic;
            ctrl_load    : out std_logic;
            ctrl_op      : out std_logic;
            ctrl_done    : out std_logic         
            );
   end component;

signal ctrl_load      : std_logic;
signal ctrl_op        : std_logic;
signal ctrl_done      : std_logic;
signal stat_n         : std_logic;
signal stat_z         : std_logic;
signal remainder :  std_logic_vector(n downto 0);


begin

-------------------------------------------------------------------------------
-- * unidad de control                                                       --
-------------------------------------------------------------------------------

   UC : ControlUnit
      port map (
      clk          => clk,
      rst          => rst,
      start        => start,
      done         => ready,
      stat_n       => stat_n,
      stat_z       => stat_z,
      -- stat_nonzero => open,
      ctrl_load    => ctrl_load,
      ctrl_op      => ctrl_op,
      ctrl_done    => ctrl_done
      );

-------------------------------------------------------------------------------
-- * ruta de datos                                                           --
-------------------------------------------------------------------------------

   DP: DataPath
      generic map (
         n => n,
         iter_len => iter_len
      )
      port map (
      clk            => clk,
      rst            => rst,
      r              => remainder,
      iters          => iters,
      ctrl_load      => ctrl_load,
      ctrl_op        => ctrl_op,
      ctrl_done      => ctrl_done,
      stat_n         => stat_n,
      stat_z         => stat_z,
      -- stat_nonzero   => stat_nonzero,
      root => R
      );

   remainder <= '0' & X;

end architecture;