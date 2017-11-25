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
    port(
      -- control signal
      EX_ALUSrcB  : in STD_LOGIC;
      MEM_RegDst  : in STD_LOGIC_VECTOR(3 downto 0);
      WB_RegDst : in STD_LOGIC_VECTOR(3 downto 0);
      -- input
      EX_raddr1   : in STD_LOGIC_VECTOR(3 downto 0);
      EX_raddr2   : in STD_LOGIC_VECTOR(3 downto 0);
      -- output
      ForwardA  : out STD_LOGIC_VECTOR(1 downto 0);
      ForwardB  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is

begin
    process(EX_raddr1,EX_raddr2,MEM_RegDst,EXMEM_RegWrite,WB_RegDst,MEMWB_RegWrite)
    begin 
        if (EX_raddr1 = MEM_RegDst) then
            ForwardA <= "01" ;
        elsif (EX_raddr1 = WB_RegDst) then
            ForwardA <= "10" ;
        else ForwardA <= "00" ;
        end if ;
        
        if (EX_ALUSrcB = '1') then
            ForwardB <= "00" ;
        elsif (EX_raddr2 = MEM_RegDst) then
            ForwardB <= "01" ;
        elsif (EX_raddr2 = WB_RegDst) then
            ForwardB <= "10" ;
        else ForwardB <= "00" ;
        end if ;
	end process ;
        

end Behavioral;

