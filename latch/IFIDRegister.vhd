----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:17:33 11/19/2017 
-- Design Name: 
-- Module Name:    IF_ID - Behavioral 
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

entity IFIDRegister is
    Port ( 
		rst 		: in STD_LOGIC;
		clk 		: in STD_LOGIC;
		-- control signal
		IFIDStall	: in STD_LOGIC;
		-- input
		IF_PC		: in STD_LOGIC_VECTOR(15 downto 0);
		IF_inst		: in STD_LOGIC_VECTOR(15 downto 0);
		IF_RPC		: in STD_LOGIC_VECTOR(15 downto 0);
		IFIDStall 	: in STD_LOGIC;
		-- output
		ID_PC		: out STD_LOGIC_VECTOR(15 downto 0);
		ID_inst		: out STD_LOGIC_VECTOR(15 downto 0);
		ID_RPC		: out STD_LOGIC_VECTOR(15 downto 0)
	);
end IFIDRegister;

architecture Behavioral of IFIDRegister is

begin
	process(clk, rst)
	begin
		if(rst = '0') then
			ID_PC <= (others => '0');
			ID_inst <= (others => '0');
			ID_RPC <= (others => '0');
		elsif(clk'event and clk='1') then
			if(IFIDStall = '1') then
				null;
			else
				ID_PC <= IF_PC;
				ID_inst <= IF_inst;
				ID_RPC <= IF_RPC;
			end if;
		end if;
	end process;
end Behavioral;

