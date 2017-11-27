library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MemController is
	port(	PC				: in std_logic_vector(17 downto 0);
			DataAddr		: in std_logic_vector(17 downto 0);
			MemWrite		: in std_logic;
			MemRead			: in std_logic;

			IFIDFlush		: out std_logic;
			PCStall			: out std_logic;
			Addr			: out std_logic_vector(17 downto 0);
		);
end MemController;

architecture Behavioral of MemController is

begin
	process
	begin
		if(MemWrite = '1' or MemRead = '1') then
			Addr <= DataAddr;
			IFIDFlush <= '1';
			PCStall <= '1';
		else
			Addr <= PC;
		end if;
	end process;
end Behavioral