library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is 
	port(
		src1		: in STD_LOGIC_VECTOR(15 downto 0);
		src2		: in STD_LOGIC_VECTOR(15 downto 0);
		ALUOp		: in STD_LOGIC_VECTOR(3 downto 0);

		result 		: out STD_LOGIC_VECTOR(15 downto 0);
		zero 		: out STD_LOGIC
	);
end component;

architecture Behavioral of ALU is 
	shared variable tmp		: STD_LOGIC_VECTOR(15 downto 0);
	shared variable num0	: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
begin
	process(src1, src2, ALUop)
	begin
		case ALUUp is
			when "0000" => -- src1, branch
				result <= src1;
				if (src1 = num0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
			when "0001" => -- +
				result <= src1 + src2;
				zero <= '0';
			when "0010" => -- -
				result <= src1 - src2;
				zero <= '0';
			when "0011" => -- and
				result <= src1 AND src2;
				zero <= '0';
			when "0100" => -- or
				result <= src1 OR src2;
				zero <= '0';
			when "0101" => -- sll
				tmp := src1(15 downto 0);
				if (src2 = num0) then
					result(15 downto 0) <= to_stdLogicvector(to_bitvector(tmp) sll 8);
				else
					result <= to_stdLogicvector(to_bitvector(src1) sll conv_integer(src2));
				end if;
				zero <= '0';
			when "0110" => -- sra
				tmp := src1(15 downto 0);
				if (Bsrc = num0) then 
					result(15 downto 0) <= to_stdlogicvector(to_bitvector(tmp) sra 8);
				else 
					result <= to_stdlogicvector(to_bitvector(src1) sra conv_integer(src2));
				end if;
				zero <= '0';
			when "0111" => -- cmp
				if (src1 == src2) then
					result <= "0000000000000000";
				else
					result <= "0000000000000001";
				end if;
				zero <= '0';
			when "1000" => -- sltu
				if (src1 < src2)
					result <= "0000000000000000";
				else
					result <= "0000000000000001";
				end if;
				zero <= '0';
			when "1001" => -- li, src2
				result <= src2;
				zero <= '0';
			when others =>
				result <= "0000000000000000";
				zero <= '0';
		end case;
	end process;
end Behavioral;
 