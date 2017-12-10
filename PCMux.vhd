----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:55:05 11/23/2017 
-- Design Name: 
-- Module Name:    PCMux - Behavioral 
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

entity PCMux is
    Port ( Jump 		: in  STD_LOGIC;
           branchJudge 	: in  STD_LOGIC;
           PCStall 		: in  STD_LOGIC;
           PC 			: in  STD_LOGIC_VECTOR(15 downto 0);
           NPC 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCAddImm 		: in  STD_LOGIC_VECTOR(15 downto 0);
           reg1 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCOut 		: out  STD_LOGIC_VECTOR(15 downto 0);
			  
			  FLASH_FINISH: in STD_LOGIC
	) ;
end PCMux;

architecture Behavioral of PCMux is
begin
<<<<<<< HEAD
	PCOut <= (others => '0') when FLASH_FINISH = '0' else
				PCAddImm when (PCStall = '0' and Jump = '0' and branchJudge = '1') else
				PC when PCStall = '1' else
				reg1 when (PCStall = '0' and Jump = '1') else 
				NPC ;
=======
	process(Jump, branchJudge, PCStall, PC, NPC, PCAddImm, reg1, FLASH_FINISH)
	begin
		if (FLASH_FINISH = '1') then
			if(PCStall = '0' and Jump = '0' and branchJudge = '1') then
				PCOut <= PCAddImm;
			elsif(PCStall = '1') then
				PCOut <= PC;
			elsif(PCStall = '0' and Jump = '1') then
				PCOut <= reg1;
			else
				PCOut <= NPC;
			end if;
--			PCOut <= PCAddImm when (PCStall = '0' and Jump = '0' and branchJudge = '1') else
--						PC when PCStall = '1' else
--						reg1 when (PCStall = '0' and Jump = '1') else 
--						NPC ;
		else
			PCOut <= (others => '0');
		end if;
	end process;
>>>>>>> 799e6cf0a4a6e85ec5e8bebcb629207b39b6b1f0
end Behavioral;

