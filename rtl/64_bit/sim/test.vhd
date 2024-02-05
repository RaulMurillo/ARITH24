--------------------------------------------------------------------------------
--                        A simple Counter
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
    port ( clk,rst : in  std_logic;
             count : out  std_logic_vector (4 downto 0));
end counter;

architecture Behavioral of counter is

signal temp: std_logic_vector(4 downto 0):=(others => '0');

begin
    process (clk,rst)
    begin
        if (rst = '1')then
            temp <= (others => '0');
        elsif(rising_edge(clk))then
            temp <= temp+1;
        end if;
    end process;

    count<=temp;
end Behavioral;

--------------------------------------------------------------------------------
--                        TestBench_PositSqrt
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
library work;
use std.env.finish;

entity TestBench_PositSqrt is
end entity;

architecture behavorial of TestBench_PositSqrt is
constant DataWidth : integer := 64;
constant INPUT_FILE_NAME : string := "./input.txt"; -- Specify the input file name
constant OUTPUT_FILE_NAME : string := "./output.txt"; -- Specify the input file name

    component PositSqrt is
        port ( 
                clk, rst : in std_logic;
                start : in  std_logic;
                X : in  std_logic_vector(DataWidth-1 downto 0);
                done: out  std_logic;
                R : out  std_logic_vector(DataWidth-1 downto 0)   );
    end component;
    
    component counter is
        port ( 
                clk, rst : in std_logic;
                count : out  std_logic_vector(4 downto 0)   );
    end component;

constant CLK_PERIOD : time := 10 ns;
signal X :  std_logic_vector(DataWidth-1 downto 0);
signal R :  std_logic_vector(DataWidth-1 downto 0);
signal clk  : std_logic := '0';
signal rst :  std_logic;
signal count_rst :  std_logic := '1';
signal start :  std_logic;
signal done :  std_logic;
signal count :  std_logic_vector(4 downto 0);

    -- converts std_logic into a character
    function chr(sl: std_logic) return character is
        variable c: character;
    begin
        case sl is
            when 'U' => c:= 'U';
            when 'X' => c:= 'X';
            when '0' => c:= '0';
            when '1' => c:= '1';
            when 'Z' => c:= 'Z';
            when 'W' => c:= 'W';
            when 'L' => c:= 'L';
            when 'H' => c:= 'H';
            when '-' => c:= '-';
        end case;
        return c;
    end chr;
    -- converts bit to std_logic (1 to 1)
    function to_stdlogic(b : bit) return std_logic is
        variable sl : std_logic;
    begin
        case b is 
            when '0' => sl := '0';
            when '1' => sl := '1';
        end case;
        return sl;
    end to_stdlogic;
    -- converts std_logic into a string (1 to 1)
    function str(sl: std_logic) return string is
    variable s: string(1 to 1);
    begin
        s(1) := chr(sl);
        return s;
    end str;
    -- converts std_logic_vector into a string (binary base)
    -- (this also takes care of the fact that the range of
    --  a string is natural while a std_logic_vector may
    --  have an integer range)
    function str(slv: std_logic_vector) return string is
        variable result : string (1 to slv'length);
        variable r : integer;
    begin
        r := 1;
        for i in slv'range loop
            result(r) := chr(slv(i));
            r := r + 1;
        end loop;
        return result;
    end str;



begin    

    test: PositSqrt
        port map ( 
                clk => clk, 
                rst => rst,
                start => start,
                X => X,
                done => done,
                R => R);
    counter_module: counter
        port map ( 
                clk => clk, 
                rst => count_rst,
                count => count);

    -- Reset and clock
    clk <= not clk after CLK_PERIOD/2;
    -- rst <= '1', '0' after CLK_PERIOD/2;


    -- Reading the input from a file 
    process
        procedure async_reset is
        begin
            wait until rising_edge(clk);
            wait for CLK_PERIOD / 4;
            rst <= '1';
            -- count_rst <= '1';
            wait for CLK_PERIOD / 2;
            rst <= '0';
            -- count_rst <= '0';
        end procedure async_reset;

        variable inline : line; 
        variable counter : integer := 1;
        variable errorCounter : integer := 0;
        variable possibilityNumber : integer := 0;
        variable localErrorCounter : integer := 0;
        variable tmpChar : character;
        file inputsFile : text is INPUT_FILE_NAME;
        variable V_X : bit_vector(DataWidth-1 downto 0);
        variable V_R : bit_vector(DataWidth-1 downto 0);
        variable outline : line; 
        file outputsFile : text open write_mode is OUTPUT_FILE_NAME;
    begin
        while not endfile(inputsFile) loop
            -- Reset the circuit.
            async_reset;
            -- positioning inputs
            readline(inputsFile,inline);
            read(inline ,V_X);
            read(inline,tmpChar);
            read(inline ,V_R);
            -- Assign values to circuit inputs.
            -- count_rst <= '1';
            wait until rising_edge(clk);
            X <= to_stdlogicvector(V_X);
            start <= '1';
            counter := 0;
            count_rst <= '1';
            wait until rising_edge(clk);
            -- TODO: Remove values from circuit inputs. 
            -- Need to assert that the circuit is robust to input switching (others => '0')
            -- X <= (others => '0');
            count_rst <= '0';   -- start counting cycles
            start <= '0';
            wait until (done = '1');
            wait for CLK_PERIOD / 2; -- need to wait a little bit to catch results in the next cycle
            
            -- write(outline, counter, left, 4);
            write(outline, to_integer(unsigned(count)), left, 4+1);
            if not (R= to_stdlogicvector(V_R)) then 
                errorCounter := errorCounter + 1;
                -- assert false report("Line " & integer'image(counter) & " of input file, incorrect output for R: " & lf & "  expected value: " & str(to_stdlogicvector(V_R)) & lf & "          result: " & str(R)) ;
                write(outline, V_X, right, DataWidth);      -- input
                write(outline, V_R, right, DataWidth+1);    -- expected value
                write(outline, str(R), right, DataWidth+1); -- obtained result
                end if;
                writeline(outputsFile, outline);
            -- wait for CLK_PERIOD / 2; -- wait for pipeline to flush
            -- counter := counter + 2;
            -- end if;
            counter := counter + 1;
        end loop;
        report (integer'image(errorCounter) & " error(s) encoutered.");
        report "End of simulation" severity note;
        
        -- Testing complete
        --report "simulation finished successfully" severity FAILURE;
        finish;
    end process;

end architecture;

