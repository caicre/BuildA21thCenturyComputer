----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:12:21 11/21/2017 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity Controller is
	Port(	inst : 		in std_logic_vector(15 downto 0);
			rst : 		in std_logic;
			RegSrcA : 	out std_logic_vector(3 downto 0);
			RegSrcB : 	out std_logic_vector(3 downto 0);
			ImmSrc : 	out std_logic_vector(2 downto 0);
			ExtendOp : 	out std_logic;
			RegDst : 	out std_logic_vector(3 downto 0);
			ALUOp : 	out std_logic_vector(3 downto 0);
			ALUSrcB : 	out std_logic;
			ALURes : 	out std_logic_vector(1 downto 0);
			Jump : 		out std_logic;
			BranchOp : 	out std_logic_vector(1 downto 0);
			Branch : 	out std_logic;
			MemRead : 	out std_logic;
			MemWrite : 	out std_logic;
			MemToReg : 	out std_logic;
			RegWrite : 	out std_logic;
			);
end Controller;

architecture Behavioral of Controller is

begin
	process(rst, inst)

	variable rx: std_logic_vector(3 downto 0) := "0000"
	variable ry: std_logic_vector(3 downto 0) := "0000"
	variable rz: std_logic_vector(3 downto 0) := "0000"

	begin
		rx(2 downto 0) := inst(10 downto 8)
		ry(2 downto 0) := inst(7 downto 5)
		rz(2 downto 0) := inst(4 downto 2)

		if (rst = '0') then
			controlerSignal <= (others => '0');
		else
			case inst(15 downto 11) is
				when PRE5_ADDIU =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "001";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_ADDIU3 =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "100";
					ExtendOp => "0";
					RegDst => ry;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_ADDSP =>
					RegSrcA => REG_SP;
					RegSrcB => REG_NO;
					ImmSrc => "001";
					ExtendOp => "0";
					RegDst => REG_SP;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_ADDU =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rz;
					ALUOp => "0001";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_SUBU =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rz;
					ALUOp => "0010";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_AND =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0011";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_OR =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0100";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_SLL =>
					RegSrcA => ry;
					RegSrcB => REG_NO;
					ImmSrc => "011";
					ExtendOp => "1";
					RegDst => rx;
					ALUOp => "0101";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_SRA =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "011";
					ExtendOp => "1";
					RegDst => rx;
					ALUOp => "0110";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_B =>
					RegSrcA => REG_NO;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_BEQZ =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "01";
					Branch => "1";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_BNEZ =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "10";
					Branch => "1";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_BTEQZ =>
					RegSrcA => REG_T;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "01";
					Branch => "1";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_JALR =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_RA;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "10";
					Jump => "1";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_JR =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "1";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_JRRA =>
					RegSrcA => REG_RA;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "1";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_CMP =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_T;
					ALUOp => "1000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_SLTU =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_T;
					ALUOp => "1001";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_LI =>
					RegSrcA => REG_NO;
					RegSrcB => REG_NO;
					ImmSrc => "001";
					ExtendOp => "1";
					RegDst => rx;
					ALUOp => "1010";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_LW =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "010";
					ExtendOp => "0";
					RegDst => ry;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "1";
					MemWrite => "0";
					MemToReg => "1";
					RegWrite => "1";
				when PRE5_LW_SP =>
					RegSrcA => REG_SP;
					RegSrcB => REG_NO;
					ImmSrc => "001";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "1";
					MemWrite => "0";
					MemToReg => "1";
					RegWrite => "1";
				when PRE5_SW =>
					RegSrcA => rx;
					RegSrcB => ry;
					ImmSrc => "010";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "1";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_SW_RS =>
					RegSrcA => REG_SP;
					RegSrcB => REG_RA;
					ImmSrc => "010";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "1";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_SW_SP =>
					RegSrcA => REG_SP;
					RegSrcB => rx;
					ImmSrc => "010";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0001";
					ALUSrcB => "1";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "1";
					MemToReg => "0";
					RegWrite => "0";
				when PRE5_MFIH =>
					RegSrcA => REG_IH;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_MFPC =>
					RegSrcA => REG_NO;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "01";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_MOVE =>
					RegSrcA => ry;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => rx;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_MTIH =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_IH;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_MTSP =>
					RegSrcA => rx;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_SP;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "1";
				when PRE5_NOP =>
					RegSrcA => REG_NO;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
				when others =>
					RegSrcA => REG_NO;
					RegSrcB => REG_NO;
					ImmSrc => "000";
					ExtendOp => "0";
					RegDst => REG_NO;
					ALUOp => "0000";
					ALUSrcB => "0";
					ALURes => "00";
					Jump => "0";
					BranchOp => "00";
					Branch => "0";
					MemRead => "0";
					MemWrite => "0";
					MemToReg => "0";
					RegWrite => "0";
			end case;
		end if;
	end process;
end Behavioral;

