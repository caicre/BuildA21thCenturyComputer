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
		EX_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
		EX_MemRead	: in STD_LOGIC;
		EX_MemWrite	: in STD_LOGIC;
		EX_MemToRead: in STD_LOGIC;
		EX_RegWrite	: in STD_LOGIC;
		-- input
		EX_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
		EX_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
		-- output control signal
		MEM_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
		MEM_MemRead	:	out STD_LOGIC;
		MEM_MemWrite:	out STD_LOGIC;
		MEM_MemToRead:	out STD_LOGIC;
		MEM_RegWrite:	out STD_LOGIC;
		-- output
		MEM_ALURes	: out STD_LOGIC_VECTOR(15 downto 0);
		MEM_reg2	: out STD_LOGIC_VECTOR(15 downto 0)
	);
end EXMEMRegister;


architecture Behavioral of EXMEMRegister is

begin
	process(clk, rst)
	begin
		if(rst = '0') then
			MEM_RegDst <= (others => '0');
			MEM_MemRead <= '0';
			MEM_MemWrite <= '0';
			MEM_MemToRead <= '0';
			MEM_RegWrite <= '0';
			MEM_ALURes <= (others => '0');
			MEM_reg2 <= (others => '0');
		elsif(clk'event and clk='1') then
			MEM_RegDst <= EX_RegDst;
			MEM_MemRead <= EX_MemRead;
			MEM_MemWrite <= EX_MemWrite;
			MEM_MemToRead <= EX_MemToRead;
			MEM_RegWrite <= EX_RegWrite;
			MEM_ALURes <= EX_ALURes;
			MEM_reg2 <= EX_reg2;
		end if;
	end process;
end Behavioral;