----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:38:33 11/19/2017 
-- Design Name: 
-- Module Name:    EXE_MEM - Behavioral 
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

entity EXMEMRegister is
port(
	clk			: in STD_LOGIC;
	rst			: in STD_LOGIC;
	-- input control signal
	EX_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
	EX_Branch	: in STD_LOGIC;
	EX_MemRead	: in STD_LOGIC;
	EX_MemWrite	: in STD_LOGIC;
	EX_MemToRead: in STD_LOGIC;
	EX_RegWrite	: in STD_LOGIC;
	-- input
	EX_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
	EX_rdata2	: in STD_LOGIC_VECTOR(15 downto 0);
	EX_waddr		: in STD_LOGIC_VECTOR(3 downto 0);
	-- output control signal
	MEM_BranchOp:	out STD_LOGIC_VECTOR(1 downto 0);
	MEM_Branch	:	out STD_LOGIC;
	MEM_MemRead	:	out STD_LOGIC;
	MEM_MemWrite:	out STD_LOGIC;
	MEM_MemToRead:	out STD_LOGIC;
	MEM_RegWrite:	out STD_LOGIC;
	-- output
	MEM_ALURes	: out STD_LOGIC_VECTOR(15 downto 0);
	MEM_rdata2	: out STD_LOGIC_VECTOR(15 downto 0);
	MEM_waddr	: out STD_LOGIC_VECTOR(3 downto 0));
end EXMEMRegister;


architecture Behavioral of EXMEMRegister is

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

component LATCH_2BIT
	port(CLK: in STD_LOGIC;
			 D : in  STD_LOGIC_VECTOR (1 downto 0);
          Q : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component LATCH_1BIT
	port(CLK: in STD_LOGIC;
			D: in STD_LOGIC;
			Q: out STD_LOGIC);
end component;

begin
	u0:LATCH_2BIT port map(clk, EX_BranchOp, MEM_BranchOp);
	u2:LATCH_1BIT port map(clk, EX_Branch, MEM_Branch);
	u3:LATCH_1BIT port map(clk, EX_MemRead, MEM_MemRead);
	u4:LATCH_1BIT port map(clk, EX_MemWrite, MEM_MemWrite);
	u5:LATCH_1BIT port map(clk, EX_MemToRead, MEM_MemToRead);
	u6:LATCH_1BIT port map(clk, EX_RegWrite, MEM_RegWrite);
	u7:LATCH_16BIT port map(clk, EX_ALURes, MEM_ALURes);
	u8:LATCH_16BIT port map(clk, EX_rdata2, MEM_rdata2);
	u9:LATCH_4BIT port map(clk, EX_waddr, MEM_waddr);
	
end Behavioral;