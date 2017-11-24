----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:45:23 11/23/2017 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use CpuConstant.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Registers is
    Port ( clk      : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           raddr1   : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
           raddr2   : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
           waddr    : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
           wdata    : in  STD_LOGIC_VECTOR (15 DOWNTO 0);
           reg1     : out  STD_LOGIC_VECTOR (15 DOWNTO 0);
           reg2     : out  STD_LOGIC_VECTOR (15 DOWNTO 0);
           RegWrite : in  STD_LOGIC);
end Registers;

architecture Behavioral of Registers is

	signal r0 : std_logic_vector(15 downto 0);
	signal r1 : std_logic_vector(15 downto 0);
	signal r2 : std_logic_vector(15 downto 0);
	signal r3 : std_logic_vector(15 downto 0);
	signal r4 : std_logic_vector(15 downto 0);
	signal r5 : std_logic_vector(15 downto 0);
	signal r6 : std_logic_vector(15 downto 0);
	signal r7 : std_logic_vector(15 downto 0);
	signal T : std_logic_vector(15 downto 0);
	signal IH : std_logic_vector(15 downto 0);
	signal SP : std_logic_vector(15 downto 0);
	signal RA : std_logic_vector(15 downto 0);
	signal state : std_logic_vector(1 downto 0) ; --PROBLEM ABOUT T = n*T0
	
begin
    process (clk,rst) -- WRITE
    begin
    if(rst='0') then
        r0 <= (others => '0');
        r1 <= (others => '0');
        r2 <= (others => '0');
        r3 <= (others => '0');
        r4 <= (others => '0');
        r5 <= (others => '0');
        r6 <= (others => '0');
        r7 <= (others => '0');
        T  <= (others => '0');
        IH <= (others => '0');			
        SP <= (others => '0');
        RA <= (others => '0');
        state <= "00";
    elsif (clk'event and clk = '1') then -- WHICH SIGNAL?
        case state is
            when "00" => state <= "01" ;
            when "01" => state <= "10" ;
            when "10" => 
                if (RegWrite = '1') then --for now, 1 is to write
                    case waddr is
                        when R0_ADDR => r0 <= wdata ;
                        when R1_ADDR => r1 <= wdata ;
                        when R2_ADDR => r2 <= wdata ;
                        when R3_ADDR => r3 <= wdata ;
                        when R4_ADDR => r4 <= wdata ;
                        when R5_ADDR => r5 <= wdata ;
                        when R6_ADDR => r5 <= wdata ;
                        when R7_ADDR => r7 <= wdata ;
                        when REG_SP => SP <= wdata ;
                        when REG_T  => T  <= wdata ;
                        when REG_IH => IH <= wdata ;
                        when REG_RA => RA <= wdata ;
                    end case ;
                end if ;
                state <= "00" ;
        end case ;
    end if ;
    end process ;

    process (raddr1,raddr2,r0,r1,r2,r3,r4,r5,r6,r7,SP,T,IH,RA) -- CHANGE
    begin
        case raddr1 is
            when R0_ADDR => reg1 <= r0 ;
            when R1_ADDR => reg1 <= r1 ;
            when R2_ADDR => reg1 <= r2 ;
            when R3_ADDR => reg1 <= r3 ;
            when R4_ADDR => reg1 <= r4 ;
            when R5_ADDR => reg1 <= r5 ;
            when R6_ADDR => reg1 <= r6 ;
            when R7_ADDR => reg1 <= r7 ;
            when REG_SP => reg1 <= SP ;
            when REG_IH => reg1 <= IH ;
            when REG_T  => reg1 <= T ;
            when REG_RA => reg1 <= RA ;
        end case ;
        case raddr2 is
            when R0_ADDR => reg2 <= r0 ;
            when R1_ADDR => reg2 <= r1 ;
            when R2_ADDR => reg2 <= r2 ;
            when R3_ADDR => reg2 <= r3 ;
            when R4_ADDR => reg2 <= r4 ;
            when R5_ADDR => reg2 <= r5 ;
            when R6_ADDR => reg2 <= r6 ;
            when R7_ADDR => reg2 <= r7 ;
            when REG_SP => reg2 <= SP ;
            when REG_IH => reg2 <= IH ;
            when REG_T  => reg2 <= T ;
            when REG_RA => reg2 <= RA ;
        end case ;
    
    end process ;

end Behavioral;

