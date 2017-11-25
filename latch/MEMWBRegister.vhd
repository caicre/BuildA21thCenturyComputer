----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:44:12 11/19/2017 
-- Design Name: 
-- Module Name:    MEM_WB - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEMWBRegister is
    Port ( 
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		-- input control signal
		MEM_MemToRead: in STD_LOGIC;
		MEM_RegWrite: in STD_LOGIC;
		-- input
		MEM_rdata 	: in STD_LOGIC_VECTOR(15 downto 0);
		MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
		MEM_waddr	: in STD_LOGIC_VECTOR(3 downto 0);
		-- output control signal
		WB_MemToRead: out STD_LOGIC;
		WB_RegWrite : out STD_LOGIC;
		-- output
		WB_rdata 	: out STD_LOGIC_VECTOR(15 downto 0);
		WB_ALURes	: out STD_LOGIC_VECTOR(15 downto 0);
	);
end MEMWBRegister;


architecture Behavioral of MEMWBRegister is

component LATCH_16BIT
	port(CLK: in STD_LOGIC;
			 D : in  STD_LOGIC_VECTOR (15 downto 0);
          Q : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component LATCH_4BIT
	port(CLK: in STD_LOGIC;
			 D : in  STD_LOGIC_VECTOR (3 downto 0);
          Q : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

component LATCH_1BIT
	port(CLK: in STD_LOGIC;
			D: in STD_LOGIC;
			Q: out STD_LOGIC);
end component;

begin
	u0:LATCH_1BIT port map(CLK, MEM_MEMToRead, WB_MemToRead);
	u1:LATCH_1BIT port map(CLK, MEM_RegWrite, WB_RegWrite);
	u2:LATCH_16BIT port map(CLK, MEM_rdata, WB_rdata);
	u3:LATCH_16BIT port map(CLK, MEM_ALURes, WB_ALURes);
end Behavioral;

