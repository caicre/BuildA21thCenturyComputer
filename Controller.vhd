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
	Port(	command : in std_logic_vector(15 downto 0);
			rst : in std_logic;
			controllerOut : out std_logic_vector(30 downto 0)
			-- RegSrcA(4), RegSrcB(4), ImmSrc(3), ExtendOp(1)					30-19
			-- RegDst(4), ALUOp(4), ALUSrcB(1), ALURes(2), Jump(1)				18-7
			-- BranchOp(2), Branch(1), MemRead(1), MemWrite(1), MemToReg(1)		6-1
			-- RegWrite(1)														0
			);
end Controller;

architecture Behavioral of Controller is

begin
	process(rst, command)

	variable rx: std_logic_vector(3 downto 0) := "0000"
	variable ry: std_logic_vector(3 downto 0) := "0000"
	variable rz: std_logic_vector(3 downto 0) := "0000"

	begin
		rx(2 downto 0) := command(10 downto 8)
		ry(2 downto 0) := command(7 downto 5)
		rz(2 downto 0) := command(4 downto 2)
		if (rst = '0') then
			controllerOut <= (others => '0');
		else
			case command(15 downto 11) is
				when PRE5_ADDIU =>
					controllerOut <= (rx, "00000010", rx, "00011000", "0000001");
				when PRE5_ADDIU3 =>
					controllerOut <= (rx, ry, "1000", ry, "00011000", "0000001");
				when PRE5_ADDSP =>
					controllerOut <= (REG_SP, "00000010", REG_SP, "00011000", "0000001");
				when PRE5_ADDU =>
					controllerOut <= (rx, ry, "0000", rz, "00010000", "0000001");
				when PRE5_SUBU =>
					controllerOut <= (rx, ry, "0000", rz, "00100000", "0000001");
				when PRE5_AND =>
					controllerOut <= (rx, ry, "0000", rx, "00110000", "0000001");
				when PRE5_OR =>
					controllerOut <= (rx, ry, "0000", rx, "01000000", "0000001");
				when PRE5_SLL =>
					controllerOut <= (ry, "0000", "0111", rx, "0101", "1000", "0000001");
				when PRE5_SRA =>
					controllerOut <= (rx, ry, "0111", rx, "0110", "1000", "0000001");
				when PRE5_B =>
					controllerOut <= ("0000", "0000", "0000", "0000", "0000", "0000", "0000000");
				when PRE5_BEQZ =>
					controllerOut <= (rx, "0000", "0000", "0000", "0000", "0000", "0110000");
				when PRE5_BNEZ =>
					controllerOut <= (rx, "0000", "0000", "0000", "0000", "0000", "1010000");
				when PRE5_BTEQZ =>
					controllerOut <= (REG_T, "0000", "0000", "0000", "0000", "0000", "0110000");
				when PRE5_JALR =>
					controllerOut <= (rx, "0000", "0000", REG_RA, "0000", "0101", "0000001");
				when PRE5_JR =>
					controllerOut <= (rx, "0000", "0000", "0000", "0000", "0001", "0000000");
				when PRE5_JRRA =>
					controllerOut <= (REG_RA, "0000", "0000", "0000", "0000", "0001", "0000000");
				when PRE5_CMP =>
					controllerOut <= (rx, ry, "0000", REG_T, "1000", "0000", "0000001");
				when PRE5_SLTU =>
					controllerOut <= (rx, ry, "0000", REG_T, "1001", "0000", "0000001");
				when PRE5_LI =>
					controllerOut <= ("0000", "0000", "0011", rx, "1010", "1000", "0000001");
				when PRE5_LW =>
					controllerOut <= (rx, "0000", "0100", ry, "0001", "1000", "0001011");
				when PRE5_LW_SP =>
					controllerOut <= (REG_SP, "0000", "0010", rx, "0001", "1000", "0001011");
				when PRE5_SW =>
					controllerOut <= (rx, ry, "0100", "0000", "0001", "1000", "0000100");
				when PRE5_SW_RS =>
					controllerOut <= (REG_SP, REG_RA, "0100", "0000", "0001", "1000", "0000100");
				when PRE5_SW_SP =>
					controllerOut <= (REG_SP, rx, "0100", "0000", "0001", "1000", "0000100");
				when PRE5_MFIH =>
					controllerOut <= (REG_IH, "0000", "0000", rx, "0000", "0000", "0000001");
				when PRE5_MFPC =>
					controllerOut <= ("0000", "0000", "0000", rx, "0000", "0010", "0000001");
				when PRE5_MOVE =>
					controllerOut <= (ry, "0000", "0000", rx, "0000", "0000", "0000001");
				when PRE5_MTIH =>
					controllerOut <= (rx, "0000", "0000", REG_IH, "0000", "0000", "0000001");
				when PRE5_MTSP =>
					controllerOut <= (rx, "0000", "0000", REG_SP, "0000", "0000", "0000001");
				when PRE5_NOP =>
					controllerOut <= ("0000", "0000", "0000", "0000", "0000", "0000", "0000000");
				when others =>
					controllerOut <= ("0000", "0000", "0000", "0000", "0000", "0000", "0000000");
			end case;
		end if;
	end process;
end Behavioral;

