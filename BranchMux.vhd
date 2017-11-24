----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:45:16 11/23/2017 
-- Design Name: 
-- Module Name:    BranchMux - Behavioral 
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

entity BranchMux is
    Port ( Branch : in  STD_LOGIC;
           BranchOp : in  STD_LOGIC_VECTOR(1 downto 0);
           ALUZero : in  STD_LOGIC;
           BranchJudge : out  STD_LOGIC);
end BranchMux;

architecture Behavioral of BranchMux is

begin
    process (Branch,BranchOp,ALUZero)
    begin
        case BranchOp is
            when "00" => BranchJudge <= Branch ;
            when "01" => BranchJudge <= ALUZero ;
            when "10" => BranchJudge <= not ALUZero ;
        end case ;
    end process ;

end Behavioral;

