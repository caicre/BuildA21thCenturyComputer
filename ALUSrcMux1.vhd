----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:21:59 11/23/2017 
-- Design Name: 
-- Module Name:    ALUSrcMux1 - Behavioral 
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

entity ALUSrcMux1 is
    Port ( ForwardA     : in  STD_LOGIC_VECTOR(1  downto 0);
           reg1         : in  STD_LOGIC_VECTOR(15 downto 0);
           EX_ALURes    : in  STD_LOGIC_VECTOR(15 downto 0);
           MEM_ALURes   : in  STD_LOGIC_VECTOR(15 downto 0);
           src1         : out STD_LOGIC_VECTOR(15 downto 0));
end ALUSrcMux1;

architecture Behavioral of ALUSrcMux1 is

begin
    process (ForwardA, reg1, EX_ALURes, MEM_ALURes, src1)
    begin 
        case ForwardA is
            when "00" => src1 <= reg1 ;
            when "01" => src1 <= EX_ALURes ;
            when "10" => src1 <= MEM_ALURes ;
        end case ;
    end process ;
end Behavioral;

