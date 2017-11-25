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
    port(
        -- control signal
        ForwardA    : in STD_LOGIC_VECTOR(1 downto 0);
        Branch      : in STD_LOGIC;
        BranchOp    : in STD_LOGIC_VECTOR(1 downto 0);
        -- input
        reg1        : in STD_LOGIC_VECTOR(15 downto 0);
        MEM_ALURes  : in STD_LOGIC_VECTOR(15 downto 0);
        WB_ALURes   : in STD_LOGIC_VECTOR(15 downto 0);
        -- output
        BranchJudge : out STD_LOGIC
    );
end BranchMux;

architecture Behavioral of BranchMux is

begin
    process (Branch,BranchOp,ALUZero)
        variable reg        : STD_LOGIC_VECTOR(15 downto 0);
        variable zero       : STD_LOGIC_VECTOR(15 downto 0) := others => 0;
    begin
        if (Branch = '1') then
            case ForwardA is
                when "00" => reg := reg1;
                when "01" => reg := MEM_ALURes;
                when "10" => reg := WB_ALURes;
            end case;
            case BranchOp is
                when "00" => BranchJudge <= '1';
                when "01" => 
                    if (reg = zero) then 
                        BranchJudge <= '1';
                    else 
                        BranchJudge <= '0';
                    end if;
                when "10" =>
                    if (reg != zero) then
                        BranchJudge <= '1';
                    else 
                        BranchJudge <= '0';
                    end if;
            end case ;
        else 
            BranchJudge <= '0';
        end if;
    end process ;

end Behavioral;

