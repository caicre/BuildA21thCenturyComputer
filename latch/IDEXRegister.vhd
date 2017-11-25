----------------------------------------------------------------------------------
--需要添加WB, MEM, EXE的控制信号
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:26:32 11/19/2017 
-- Design Name: 
-- Module Name:    ID_EXE - Behavioral 
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
entity IDEXRegister is
	port(
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		-- input control signal
		ID_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_ALUOp	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_ALUSrcB	: in STD_LOGIC;
		ID_ALURes  	: in STD_LOGIC_VECTOR(1 downto 0);
		ID_Jump		: in STD_LOGIC;
		ID_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
		ID_Branch 	: in STD_LOGIC;
		ID_MemRead	: in STD_LOGIC;
		ID_MemWrite	: in STD_LOGIC;
		ID_MemToRead: in STD_LOGIC;
		ID_RegWrite : in STD_LOGIC;
		-- input
		ID_PC 		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_reg1		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_raddr1	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_raddr2	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_imm		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
		-- output control signal
		EX_RegDst	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_ALUOp	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_ALUSrcB	: out STD_LOGIC;
		EX_ALURes  	: out STD_LOGIC_VECTOR(1 downto 0);
		EX_Jump		: out STD_LOGIC;
		EX_BranchOp	: out STD_LOGIC_VECTOR(1 downto 0);
		EX_Branch 	: out STD_LOGIC;
		EX_MemRead	: out STD_LOGIC;
		EX_MemWrite	: out STD_LOGIC;
		EX_MemToRead: out STD_LOGIC;
		EX_RegWrite : out STD_LOGIC;
		-- output
		EX_PC 		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_reg1		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_reg2		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_raddr1	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_raddr2	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_imm		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
	);
end IDEXRegister;


architecture Behavioral of IDEXRegister is

component LATCH_16BIT
	port(CLK: in STD_LOGIC;
			 D : in  STD_LOGIC_VECTOR (15 downto 0);
          Q : out  STD_LOGIC_VECTOR (15 downto 0)) ;
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
	u0:LATCH_4BIT port map(CLK, ID_RegDst, EX_RegDst);
	u1:LATCH_4BIT port map(CLK, ID_ALUOp, EX_ALUOp);
	u2:LATCH_1BIT port map(CLK, ID_ALUSrcB, EX_ALUSrcB);
	u3:LATCH_2BIT port map(CLK, ID_ALURes, EX_ALURes);
	u4:LATCH_1BIT port map(CLK, ID_Jump, EX_Jump);
	u5:LATCH_2BIT port map(CLK, ID_BranchOp, EX_BranchOp);
	u6:LATCH_1BIT port map(CLK, ID_Branch, EX_Branch);
	u7:LATCH_1BIT port map(CLK, ID_MemRead, EX_MemRead);
	u8:LATCH_1BIT port map(CLK, ID_MemWrite, EX_MemWrite);
	u9:LATCH_1BIT port map(CLK, ID_MemToRead, EX_MemToRead);
	u10:LATCH_1BIT port map(CLK, ID_RegWrite, EX_RegWrite);
	u11:LATCH_16BIT port map(CLK, ID_PC, EX_PC);
	u12:LATCH_16BIT port map(CLK, ID_reg1, EX_reg1);
	u13:LATCH_16BIT port map(CLK, ID_reg2, EX_reg2);
	u14:LATCH_4BIT port map(CLK, ID_raddr1, EX_raddr1);
	u15:LATCH_4BIT port map(CLK, ID_raddr2, EX_raddr2);
	u16:LATCH_16BIT port map(CLK, ID_imm, EX_imm);
	u17:LATCH_16BIT port map(CLK, ID_RPC, EX_RPC);
end Behavioral;

