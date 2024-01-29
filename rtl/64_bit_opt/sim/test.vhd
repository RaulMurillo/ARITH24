--------------------------------------------------------------------------------
--                        TestBench_PositSqrt
-- VHDL generated for Kintex7 @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Cristian Klein, Nicolas Brunie (2007-2010)
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
    component PositSqrt is
        port ( X : in  std_logic_vector(DataWidth-1 downto 0);
                R : out  std_logic_vector(DataWidth-1 downto 0)   );
    end component;
signal X :  std_logic_vector(DataWidth-1 downto 0);
signal R :  std_logic_vector(DataWidth-1 downto 0);
signal clk :  std_logic;
signal rst :  std_logic;

    -- FP compare function (found vs. real)
    function fp_equal(a : std_logic_vector; b : std_logic_vector) return boolean is
    begin
        if b(b'high downto b'high-1) = "01" then
            return a = b;
        elsif b(b'high downto b'high-1) = "11" then
            return (a(a'high downto a'high-1)=b(b'high downto b'high-1));
        else
            return a(a'high downto a'high-2) = b(b'high downto b'high-2);
        end if;
    end;



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




    -- test isZero
    function iszero(a : std_logic_vector) return boolean is
    begin
        return  a = (a'high downto 0 => '0');
    end;


    -- FP IEEE compare function (found vs. real)
    function fp_equal_ieee(a : std_logic_vector; b : std_logic_vector; we : integer; wf : integer) return boolean is
    begin
        if a(wf+we downto wf) = b(wf+we downto wf) and b(we+wf-1 downto wf) = (we downto 1 => '1') then
            if iszero(b(wf-1 downto 0)) then return  iszero(a(wf-1 downto 0));
            else return not iszero(a(wf - 1 downto 0));
            end if;
        else
            return a(a'high downto 0) = b(b'high downto 0);
        end if;
    end;
begin

    test: PositSqrt
        port map ( X => X,
                    R => R);

    -- Ticking clock signal
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Reading the input from a file 
    process
        variable inline : line; 
        variable counter : integer := 1;
        variable errorCounter : integer := 0;
        variable possibilityNumber : integer := 0;
        variable localErrorCounter : integer := 0;
        variable tmpChar : character;
        file inputsFile : text is "./test.input"; 
        variable V_X : bit_vector(DataWidth-1 downto 0);
        variable V_R : bit_vector(DataWidth-1 downto 0);
    begin
        -- Send reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        while not endfile(inputsFile) loop
            -- positionning inputs
            readline(inputsFile,inline);
            read(inline ,V_X);
            read(inline,tmpChar);
            X <= to_stdlogicvector(V_X);
            -- readline(inputsFile,inline);
            read(inline ,V_R);
            wait for 10 ns;
        end loop;
        wait for 10000 ns; -- wait for simulation to finish
    end process;
    -- verifying the corresponding output
    process
        variable inline : line; 
        variable counter : integer := 1;
        variable errorCounter : integer := 0;
        -- variable possibilityNumber : integer := 1;
        variable tmpChar : character;
        file inputsFile : text is "./test.input"; 
        variable outline : line; 
        file outputsFile : text open write_mode is "output_test.txt";
        variable V_X : bit_vector(DataWidth-1 downto 0);
        variable V_R : bit_vector(DataWidth-1 downto 0);
    begin
            wait for 10 ns;
        wait for 2 ns; -- no pipeline here
        while not endfile(inputsFile) loop
            -- positionning inputs
            readline(inputsFile,inline);
            read(inline ,V_X);
            read(inline,tmpChar);
            read(inline ,V_R);
            if not (R= to_stdlogicvector(V_R)) then 
                errorCounter := errorCounter + 1;
                -- assert false report("Line " & integer'image(counter) & " of input file, incorrect output for R: " & lf & "  expected value: " & str(to_stdlogicvector(V_R)) & lf & "          result: " & str(R)) ;
                write(outline, V_X, right, DataWidth);      -- inpùt
                write(outline, V_R, right, DataWidth+1);    -- expected value
                write(outline, str(R), right, DataWidth+1); -- obtained result
                writeline(outputsFile, outline);
            end if;
            wait for 10 ns; -- wait for pipeline to flush
            -- counter := counter + 2;
            counter := counter + 1;
        end loop;
        report (integer'image(errorCounter) & " error(s) encoutered.");
        report "End of simulation" severity note;
        
        -- Testing complete
        --report "simulation finished successfully" severity FAILURE;
        finish;
    end process;

end architecture;
