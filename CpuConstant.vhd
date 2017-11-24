library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package CpuConstant is

	-- command(15 downto 11)

	constant PRE5_ADDIU: std_logic_vector(4 downto 0) := 	"01001";
	constant PRE5_ADDIU3: std_logic_vector(4 downto 0) := 	"01000";
	constant PRE5_ADDSP: std_logic_vector(4 downto 0) := 	"01100";
	constant PRE5_ADDU: std_logic_vector(4 downto 0) := 	"11100";
	constant PRE5_AND: std_logic_vector(4 downto 0) := 		"11101";

	constant PRE5_B: std_logic_vector(4 downto 0) := 		"00010";
	constant PRE5_BEQZ: std_logic_vector(4 downto 0) := 	"00100";
	constant PRE5_BNEZ: std_logic_vector(4 downto 0) := 	"00101";
	constant PRE5_BTEQZ: std_logic_vector(4 downto 0) := 	"01100";
	constant PRE5_CMP: std_logic_vector(4 downto 0) := 		"11101";

	constant PRE5_JR: std_logic_vector(4 downto 0) := 		"11101";
	constant PRE5_LI: std_logic_vector(4 downto 0) := 		"01101";
	constant PRE5_LW: std_logic_vector(4 downto 0) := 		"10011";
	constant PRE5_LW_SP: std_logic_vector(4 downto 0) := 	"10010";
	constant PRE5_MFIH: std_logic_vector(4 downto 0) := 	"11110";

	constant PRE5_MFPC: std_logic_vector(4 downto 0) := 	"11101";
	constant PRE5_MTIH: std_logic_vector(4 downto 0) := 	"11110";
	constant PRE5_MTSP: std_logic_vector(4 downto 0) := 	"01100";
	constant PRE5_NOP: std_logic_vector(4 downto 0) := 		"00001";
	constant PRE5_OR: std_logic_vector(4 downto 0) := 		"11101";

	constant PRE5_SLL: std_logic_vector(4 downto 0) := 		"00110";
	constant PRE5_SRA: std_logic_vector(4 downto 0) := 		"00110";
	constant PRE5_SUBU: std_logic_vector(4 downto 0) := 	"11100";
	constant PRE5_SW: std_logic_vector(4 downto 0) := 		"11011";
	constant PRE5_SW_SP: std_logic_vector(4 downto 0) := 	"11010";

	constant PRE5_JALR: std_logic_vector(4 downto 0) := 	"11101";
	constant PRE5_JRRA: std_logic_vector(4 downto 0) := 	"11101";
	constant PRE5_MOVE: std_logic_vector(4 downto 0) := 	"01111";
	constant PRE5_SLTU: std_logic_vector(4 downto 0) := 	"11101";
	constant PRE5_SW_RS: std_logic_vector(4 downto 0) := 	"01100";

	constant PRE5_NOP: std_logic_vector(4 downto 0) := 		"00001";

	-- RegSrcA, RegSrcB
	-- 通用寄存器的值为 0000 - 0111
		
	constant R0_ADDR: std_logic_vector(3 downto 0) := 	"0000";
	constant R1_ADDR: std_logic_vector(3 downto 0) := 	"0001";
	constant R2_ADDR: std_logic_vector(3 downto 0) := 	"0010";
	constant R3_ADDR: std_logic_vector(3 downto 0) := 	"0011";
	constant R4_ADDR: std_logic_vector(3 downto 0) := 	"0100";
	constant R5_ADDR: std_logic_vector(3 downto 0) := 	"0101";
	constant R6_ADDR: std_logic_vector(3 downto 0) := 	"0110";
	constant R7_ADDR: std_logic_vector(3 downto 0) := 	"0111";
	constant REG_SP: std_logic_vector(3 downto 0) := 	"1000";
	constant REG_T : std_logic_vector(3 downto 0) := 	"1001";
	constant REG_IH: std_logic_vector(3 downto 0) := 	"1010";
	constant REG_RA: std_logic_vector(3 downto 0) := 	"1011";

end CpuConstant;

package body CpuConstant is

end CpuConstant;