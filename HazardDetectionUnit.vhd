----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:18:03 11/24/2017 
-- Design Name: 
-- Module Name:    HazardDetectionUnit - Behavioral 
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

entity HazardDetectionUnit is
	port(
		-- control signal
		EX_MemRead 	: in STD_LOGIC;
		EX_RegDst	:in STD_LOGIC_VECTOR(3 downto 0);
		-- input
		raddr1 		: in STD_LOGIC_VECTOR(3 downto 0);
		raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
		MEM_PCStall : in STD_LOGIC;
		-- output
		PCStall		: out STD_LOGIC;
		IFIDStall 	: out STD_LOGIC;
		IDEXFlush 	: out STD_LOGIC);
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is

begin
	process(EX_MemRead, EX_RegDst, raddr1, raddr2)
	begin
		if (EX_MemRead = '1') then
			--if(raddr1 = "1111" and raddr2 = "1111") then	--����Ϊʲô?
			--	PCStall <= '0';
			--	IFIDStall <= '0';
			--	IDEXFlush <= '0';
			--els
			if(EX_RegDst = raddr1 or EX_RegDst = raddr2) then
				PCStall <= '1';
				IFIDStall <= '1';
				IDEXFlush <= '1';
			elsif(MEM_PCStall) then
				PCStall <= '1';
				IFIDStall <= '0';
				IDEXFlush <= '0';
			else
				PCStall <= '0';
				IFIDStall <= '0';
				IDEXFlush <= '0';
			end if;
		else
			PCStall <= '0';
			IFIDStall <= '0';
			IDEXFlush <= '0';
		end if;
	end process;

end Behavioral;

