----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:40:42 11/23/2017 
-- Design Name: 
-- Module Name:    ForwardingUnit - Behavioral 
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

entity ForwardingUnit is
    Port ( reg1             : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
           reg2             : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
           IDEX_ALUSrcB     : in STD_LOGIC ;
           EXMEM_RegWrite   : in  STD_LOGIC;
           EXMEM_RegDst     : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
           MEMWB_RegWrite   : in  STD_LOGIC;
           MEMWB_RegDst     : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
           ForwardA         : out  STD_LOGIC_VECTOR(1 DOWNTO 0);
           ForwardB         : out  STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is

begin
    process(reg1,reg2,EXMEM_RegDst,EXMEM_RegWrite,MEMWB_RegDst,MEMWB_RegWrite)
    begin 
        if (reg1 = EXMEM_RegDst) then
            ForwardA <= "01" ;
        elsif (reg1 = MEMWB_RegDst) then
            ForwardA <= "10" ;
        else ForwardA <= "00" ;
        end if ;
        
        if (IDEX_ALUSrcB = '1') then
            ForwardB <= "00" ;
        elsif (reg2 = EXMEM_RegDst) then
            ForwardB <= "01" ;
        elsif (reg2 = MEMWB_RegDst) then
            ForwardB <= "10" ;
        else ForwardB <= "00" ;
        end if ;
	end process ;
        

end Behavioral;

