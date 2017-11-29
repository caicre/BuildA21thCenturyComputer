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
			IsMem		: in STD_LOGIC;		--'0': ֻ��IF���� '1': ֻ��MEM����(IF,ID,EXҪͣ��)
			
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
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
signal rflag : std_logic := '0';		--rflag='1'����Ѵ��������ߣ�ram1_data���ø��裬���ڽ�ʡ״̬�Ŀ���

shared variable Ram_Addr : std_logic_vector(15 downto 0) := (others => '0');	--��IF��MEM���ı�������ź�
shared variable Ram_Data : std_logic_vector(15 downto 0) := (others => '0');	--��IF��MEM���ı�������ź�

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
			
			current_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then
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
				
				if(IsMem = '1') then			--��MEM, �����ź�Ϊaddr, wdata
					Ram_Addr := addr;
					Ram_Data := wdata;
				else								--��IF, �����ź�ΪPC
					Ram_Addr := PC;
			--		if PCKeep = '0' then		--PCMUX, ���Ӧ��������ʵ��????
			--			ram2_addr(15 downto 0) <= PCMuxOut;
			--		elsif PCKeep = '1' then
			--			ram2_addr(15 downto 0) <= PCOut;
			--		end if;
				end if;
				
				if(MemWrite = '1') then	--RAM2/����д��
					
					case mem_state is
						when s0 =>
							if(Ram_Addr = x"BF00") then --����׼��д��
								rflag <= '0';		--???
								wrn <= '0';
								--Ram1_Addr(15 downto 0) <= Ram_Addr;
								Ram1_Data(7 downto 0) <= Ram_Data(7 downto 0);
							else								 --RAM2׼��д��
								wrn <= '1';
								rdn <= '1';
								Ram2_WE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= Ram_Data;
							end if;
							mem_state <= s1;
						
						when s1 =>
							if(Ram_Addr = x"BF00") then --����д��
								wrn <= '1';
							else								 --RAM2д��
								Ram2_WE <= '1';
							end if;
							mem_state <= s0;
						
						when others =>
							mem_state <= s0;
					end case;
					
				elsif(MemRead = '1') then --RAM2/���ڶ�ȡ
					case mem_state is
						when s0 =>
							if(Ram_Addr = x"BF01") then --׼��������״̬
								rdata(15 downto 2) <= (others => '0');
								rdata(1) <= data_ready;
								rdata(0) <= tsre and tbre;
								if(rflag = '0') then --������״̬ʱ��ζ�Ž���������Ҫ��/д��������
								Ram1_Data <= (others => 'Z');--��Ԥ�Ȱ�ram1_data��Ϊ����
									rflag <= '1'; --���������Ҫ�������ֱ�Ӱ�rdn��'0'��ʡһ��״̬��Ҫд����rflag='0'��������д���ڵ�����
								end if;
								
							elsif(Ram_Addr = x"BF00") then --׼������������
								rflag <= '0';
								rdn <= '0';
								--�����ﲻ��Ram1_Data<= 'Z...'��ԭ���Ǵ˸�ֵ��rdn<='1'��һ���, ������rdn<='0', ����׼��������ʱҪ��ɴ˸�ֵ
								
							else 									 --׼����RAM2
								wrn <= '1';
								rdn <= '1';
								Ram2_OE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= (others => 'Z');							
							end if;
							mem_state <= s1;
						
						when s1 =>
							if(Ram_Addr = x"BF01") then		--������״̬(�Ѷ�)
								null;
							elsif(Ram_Addr = x"BF00") then	--����������
								rdn <= '1';
								rdata(15 downto 8) <= (others => '0');
								rdata(7 downto 0) <= Ram1_Data(7 downto 0);
							else										--���ڴ�
								Ram2_OE <= '1';
								if(IsMem = '1') then	--��MEM, ����ź�Ϊrdata
									rdata <= Ram2_Data;
								else						--��IF, ����ź�Ϊinst
									inst <= Ram2_Data;
								end if;
							end if;	
							mem_state <= s0;
							
						when others =>
							mem_state <= s0;
					end case;
					
				end if; --RAM2д/��
			else
		end if;	--rst and clk's raise
	end process;
	
end Behavioral;