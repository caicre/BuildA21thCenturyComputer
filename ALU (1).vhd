----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:08:39 10/20/2017 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           inputSW : in  STD_LOGIC_VECTOR (15 downto 0);
           Lights1 : out  STD_LOGIC_VECTOR (6 downto 0);
           Lights2 : out  STD_LOGIC_VECTOR (6 downto 0);
           led : out  STD_LOGIC_VECTOR (15 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal inputA : STD_LOGIC_VECTOR (15 downto 0);
	signal inputB : STD_LOGIC_VECTOR (15 downto 0);
	signal operation : STD_LOGIC_VECTOR (3 downto 0);
	type state is (s0,s1,s2,s3,s4);
	signal current_state : state ;
	signal cf, zf, sf, vf : STD_LOGIC ;
	
begin
	process(clk,rst)
	variable tmp : STD_LOGIC_VECTOR(15 downto 0);
	begin
		if(rst='0')then
			current_state <= s0;
			inputA <= "0000000000000000";
			inputB <= "0000000000000000";
			operation <= "1111" ;
			cf <= '0' ;
			sf <= '0' ;
			vf <= '0' ;
			zf <= '0' ;
			
		elsif (clk='1') AND (clk'EVENT)then
			case current_state is
				when s0 =>
					operation <= "1111" ;
					cf <= '0' ;
					sf <= '0' ;
					vf <= '0' ;
					zf <= '0' ;
					inputA <= inputSW ; 
					led <= inputSW ;	
				when s1=>
					inputB <= inputSW ;
					led <= inputSW ;
				when s2=>
					operation <= inputSW(3 downto 0) ;
					led <= inputSW ;
				when s3=>
					case operation is
						when "0000" =>			--ADD: A + B
							tmp := inputA + inputB;
							if (CONV_INTEGER(tmp) < CONV_INTEGER(inputA)) then
								cf <= '1';
							end if;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							if ((tmp(15) = '1') /= (inputA(15) = '1')) AND
									  ((inputA(15) = '1') = (inputB(15) = '1')) then
								vf <= '1';
							end if;
							led <= tmp;
						when "0001" =>			--SUB: A - B
							tmp := inputA - inputB;
							if (CONV_INTEGER(inputA) < CONV_INTEGER(inputB)) then --减法的无符号溢出是这么理解吗？
								cf <= '1';
							end if;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							if ((tmp(15) = '1') /= (inputA(15) = '1')) AND
									  ((inputA(15) = '1') = (inputB(15) = '0')) then
								vf <= '1';
							end if;
							led <= tmp;
						when "0010" =>			--AND
							tmp := inputA AND inputB;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "0011" =>			--OR
							tmp := inputA OR inputB;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "0100" =>			--XOR
							tmp := inputA XOR inputB;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "0101" =>			--NOT A
							tmp := NOT inputA;
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "0110" =>			--SLL: A << B
							tmp := TO_STDLOGICVECTOR(TO_BITVECTOR(inputA) SLL CONV_INTEGER(inputB));
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "0111" =>			--SRL: A >> B 逻辑右移
							tmp := TO_STDLOGICVECTOR(TO_BITVECTOR(inputA) SRL CONV_INTEGER(inputB));
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "1000" =>			--SRA: A >> B 算术右移
							tmp := TO_STDLOGICVECTOR(TO_BITVECTOR(inputA) SRA CONV_INTEGER(inputB));
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when "1001" =>			--ROL: 循环左移
							tmp := TO_STDLOGICVECTOR(TO_BITVECTOR(inputA) ROL CONV_INTEGER(inputB));
							if (tmp = "0000000000000000") then
								zf <= '1';
							end if;
							if (tmp(15) = '1') then
								sf <= '1';
							end if;
							led <= tmp;
						when others =>			--其他情况
							inputA <= "0000000000000000";
							inputB <= "0000000000000000";
							led <= "0000000000000000";

					end case;					
					
				when s4=>
					led(3) <= cf ;
					led(2) <= zf ;
					led(1) <= sf ;
					led(0) <= vf ;
					led(15 downto 4) <= "000000000000" ;
			end case;
			case current_state is
				when s0 => current_state <= s1 ;
				when s1 => current_state <= s2 ;
				when s2 => current_state <= s3 ;
				when s3 => current_state <= s4 ;
				when others => current_state <= s0 ;
			end case ;

		end if ;
	end process ;

	process(current_state)
	begin
		case current_state is
			when s0=>
				Lights1 <= "1111110";
			when s1=>
				Lights1 <= "0110000";
			when s2=>
				Lights1 <= "1101101";
			when s3=>
				Lights1 <= "1111001";
			when s4=>
				Lights1 <= "0110011";
			when others =>
				Lights1 <= "0000000";
		end case;
	end process ;
				
	process(operation)
	begin
		case operation is
			when "0000" =>
				Lights2 <= "1111110";
			when "0001" =>
				Lights2 <= "0110000";
			when "0010" =>
				Lights2 <= "1101101";
			when "0011" =>
				Lights2 <= "1111001";
			when "0100" =>
				Lights2 <= "0110011";
			when "0101" =>
				Lights2 <= "1011011";
			when "0110" =>
				Lights2 <= "1111101";
			when "0111" =>
				Lights2 <= "0000111";
			when "1000" =>
				Lights2 <= "1111111";
			when "1001" =>
				Lights2 <= "1101111";
			when others =>
				Lights2 <= "0000000";
		end case;
	end process;

end Behavioral;