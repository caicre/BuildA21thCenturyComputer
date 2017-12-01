----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:45:15 11/26/2017 
-- Design Name: 
-- Module Name:    MemoryUnit - Behavioral 
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

entity MemoryUnit is
	port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MemWrite : in STD_LOGIC;		--'1':д
			MemRead 	: in STD_LOGIC;		--'1':��
			-- RAM1								--Ϊ����(BF00~BF03)
			Ram1_OE 		: out STD_LOGIC;
			Ram1_WE 		: out STD_LOGIC;
			Ram1_EN 		: out STD_LOGIC;
			Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			addr 		: in STD_LOGIC_VECTOR(15 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			rdata 		: out STD_LOGIC_VECTOR(15 downto 0);
			
			-- RAM2								--��س���(0000~3FFF), �û�����(4000~FFFF), ϵͳ����(8000~BEFF), �û�����(C000~FFFF)
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
			
			--����
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC;
			
			--FLASH								--��س���
			FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
			FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
			FLASH_BYTE	: out STD_LOGIC := '1';		--flash����ģʽ, ����'1'
			FLASH_VPEN	: out STD_LOGIC := '1';		--flashд����, ����'1'
			FLASH_RP		: out STD_LOGIC := '1';		--'1'��ʾflash����, ����'1'
			FLASH_CE		: out STD_LOGIC := '0';		--flashʹ��
			FLASH_OE		: out STD_LOGIC := '1';		--flash��ʹ��, '0'��Ч, ÿ�ζ�������ֵ'1'
			FLASH_WE		: out STD_LOGIC := '1';		--flashдʹ��
			
			--output
			FLASH_FINISH: out STD_LOGIC := '0'		--'0':δ���	'1':��ɶ���س���RAM2
																--��Ҫת��������, Ҫ��PC?IF?ͣ��
				);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
signal rflag : std_logic := '0';		--rflag='1'����Ѵ��������ߣ�ram1_data���ø��裬���ڽ�ʡ״̬�Ŀ���

--flash
signal flash_state : state;
signal flash_finished : std_logic := '0';
signal current_addr : std_logic_vector(15 downto 0) := (others => '0');
shared variable cnt : integer := 0;	--����ԭ����Ƶ�ʽ���Ϊ�ʺ�FLASH��Ƶ��

begin
	process(clk, rst)
	begin
		if(rst = '0') then
			Ram1_EN <= '1';
			Ram1_OE <= '1';
			Ram1_WE <= '1';
			Ram2_OE <= '1';
			Ram2_WE <= '1';
			wrn <= '1';
			rdn <= '1';
			rflag <= '0';
			
			Ram1_Addr <= (others => '0');
			Ram2_Addr <= (others => '0');
			
			rdata <= (others => '0');
			inst <= (others => '0');
			
			mem_state <= s0;
			flash_state <= s0;
			
			current_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then
			if(flash_finished = '1') then
				FLASH_BYTE <= '1';
				FLASH_VPEN <= '1';
				FLASH_RP <= '1';
				FLASH_CE <= '1';
				Ram1_EN <= '1';
				Ram1_OE <= '1';
				Ram1_WE <= '1';
				Ram1_Addr(17 downto 0) <= (others => '0');
				Ram2_EN <= '0';
				Ram2_OE <= '1';
				Ram2_WE <= '1';
				Ram2_Addr(17 downto 16) <= "00";
				wrn <= '1';
				rdn <= '1';
				
				case mem_state is
					when s0 =>												--׼����ָ��
					--	if PCKeep = '0' then
					--		Ram2_Addr(15 downto 0) <= PCMuxOut;
					--	elsif PCKeep ='1' then
					--		Ram2_(15 downto 0) <= PCOut;
					--	end if;
						wrn <= '1';
						rdn <= '1';
						Ram2_OE <= '0';
						Ram2_Addr(15 downto 0) <= PC;
						Ram2_Data <= (others => 'Z');
						mem_state <= s1;
					when s1 =>												--��ָ��, ׼����д�ڴ�/����
						Ram2_OE <= '1';
						inst <= Ram2_Data;
						if(MemWrite = '1') then
							rflag <= '0';
							if(addr = x"BF00") then	--׼��д��������
								Ram1_data(7 downto 0) <= wdata(7 downto 0);
								wrn <= '0';
							else					--׼��д�ڴ�
								Ram2_Addr(15 downto 0) <= addr;
								Ram2_Data <= wdata;
								Ram2_WE <= '0';
							end if;
						elsif(MemRead = '1') then
							if(addr = x"BF01") then --׼��������״̬
								rdata(15 downto 2) <= (others => '0');
								rdata(1) <= data_ready;
								rdata(0) <= tsre and tbre;
								if(rflag = '0') then --������״̬ʱ��ζ�Ž���������Ҫ��/д��������
									Ram1_Data <= (others => 'Z');--��Ԥ�Ȱ�ram1_data��Ϊ����
									rflag <= '1'; --���������Ҫ�������ֱ�Ӱ�rdn��'0'��ʡһ��״̬��Ҫд����rflag='0'��������д���ڵ�����
								end if;
							elsif (addr = x"BF00") then	--׼������������
								rflag <= '0';
								rdn <= '0';
							else						--׼�����ڴ�
								Ram2_Data <= (others => 'Z');
								Ram2_Addr(15 downto 0) <= addr;
								Ram2_OE <= '0';
							end if;
						end if;
						mem_state <= s2;
						
					when s2 =>
						if(MemWrite = '1') then			
							if(addr = x"BF00") then		--д��������
								wrn <= '1';
							else						--д�ڴ�
								Ram2_WE <= '1';
							end if; 
						elsif(MemRead = '1') then
							if (addr = x"BF01") then	--������״̬���Ѷ�����
								null;
							elsif(addr = x"BF00") then	--����������
								rdn <= '1';
								rdata(15 downto 8) <= (others => '0');
								rdata(7 downto 0) <= Ram1_Data(7 downto 0);
							else						--���ڴ�
								Ram2_OE <= '1';
								rdata <= Ram2_Data;
							end if;
						end if;
						mem_state <= s0;
					when others =>
						mem_state <= s0;
				end case;
			else
				if( cnt >= 1000) then
					cnt := 0;
					
					case flash_state is
						when s0 =>		--WE��0
							Ram2_EN <= '0';
							Ram2_WE <= '0';
							Ram2_OE <= '1';
							wrn <= '1';
							rdn <= '1';
							FLASH_WE <= '0';
							FLASH_OE <= '1';
							
							FLASH_BYTE <= '1';
							FLASH_VPEN <= '1';
							FLASH_RP <= '1';
							FLASH_CE <= '0';
							
							flash_state <= s1;
							
						when s1 =>		--��Ϊ��ģʽ
							FLASH_DATA <= x"00FF";
							flash_state <= s2;
							
						when s2 =>
							FLASH_WE <= '1';
							flash_state <= s3;
							
						when s3 =>		--׼����ȡ
							FLASH_ADDR <= "000000" & current_addr & '0';	--����������ģʽ��ֻ�õ�22~1, �������6λ(22~17)Ϊblock��ַ, ֮��(16~1)Ϊblock�ڵĵ�ַ.
																			--������ֻ�õ�һ��block
							FLASH_DATA <= (others => 'Z');
							FLASH_OE <= '0';
							flash_state <= s4;
							
						when s4 =>		--��ȡ���, ׼��д�뵽�ڴ�
							FLASH_OE <= '1';	
							Ram2_WE <= '0';
							Ram2_Addr <= "00" & current_addr;
							--Ram2_AddrOutput <= "00" & current_addr;	--����
							Ram2_Data <= FLASH_DATA;
							flash_state <= s5;
						
						when s5 =>		--д�뵽�ڴ�
							Ram2_WE <= '1';
							current_addr <= current_addr + '1';
							flash_state <= s0;
						
							
						when others =>
							flash_state <= s0;
					end case;
					
					if (current_addr > x"0249") then		--�����ַ��ʱkernel.bin�ĳ��ȶ��ı�??
						flash_finished <= '1';
					end if;
				else
					if (cnt < 1000) then
						cnt := cnt + 1;
					end if;
				end if;	--cnt
			end if; --flash_finished
		end if;	--rst and clk's raise
	end process;
	
	FLASH_FINISH <= flash_finished;
	
end Behavioral;