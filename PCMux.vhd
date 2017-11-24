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
    Port ( jump 		: in  STD_LOGIC;
           branchJudge 	: in  STD_LOGIC;
           PCStall 		: in  STD_LOGIC;
           PC 			: in  STD_LOGIC_VECTOR(15 downto 0);
           nextPC 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCimm 		: in  STD_LOGIC_VECTOR(15 downto 0);
           ALURes 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCOut 		: sout  STD_LOGIC_VECTOR(15 downto 0)
	) ;
end PCMux;

architecture Behavioral of PCMux is
	shared variable all_controllers : STD_LOGIC_VECTOR(2 downto 0) ;
begin
	process (jump,brachJudge,PCStall,PC,nextPC,PCimm,ALURes,PCOut)
	begin
		all_controllers := branchJudge & jump & PCStall ;
		case all_controllers is
			when "000"  => PCOut <= nextPC ;
			when "001"  => PCOut <= PCimm ;
			when "010"  => PCOut <= ALURes ;
			when "011"  => PCOut <= ALURes ;
            when others => PCOut <= PC ;
        end case ; 
	end process ;

end Behavioral;

