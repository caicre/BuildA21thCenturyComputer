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
			MemWrite : in STD_LOGIC;		--'1':写
			MemRead 	: in STD_LOGIC;		--'1':读
			IsMem		: in STD_LOGIC;		--'0': 只有IF操作 '1': 只有MEM操作(IF,ID,EX要停顿)
			
			-- RAM1								--为串口(BF00~BF03)
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
			
			-- RAM2								--监控程序(0000~3FFF), 用户程序(4000~FFFF), 系统数据(8000~BEFF), 用户数据(C000~FFFF)
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
			
			--串口
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC;
			
			--FLASH								--监控程序
			FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
			FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
			FLASH_BYTE	: out STD_LOGIC := '1';		--flash操作模式, 常置'1'
			FLASH_VPEN	: out STD_LOGIC := '1';		--flash写保护, 常置'1'
			FLASH_RP		: out STD_LOGIC := '1';		--'1'表示flash工作, 常置'1'
			FLASH_CE		: out STD_LOGIC := '0';		--flash使能
			FLASH_OE		: out STD_LOGIC := '1';		--flash读使能, '0'有效, 每次都操作后值'1'
			FLASH_WE		: out STD_LOGIC := '1';		--flash写使能
			
			--output
			FLASH_FINISH: out STD_LOGIC := '0'		--'0':未完成	'1':完成读监控程序到RAM2
																--这要转给控制器, 要把PC?IF?停顿
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
--signal rflag : std_logic := '0';		--rflag='1'代表把串口数据线（ram1_data）置高阻，用于节省状态的控制

shared variable Ram_Addr : std_logic_vector(15 downto 0) := (others => '0');	--随IF或MEM而改变的输入信号
shared variable Ram_Data : std_logic_vector(15 downto 0) := (others => '0');	--随IF或MEM而改变的输入信号

--flash
signal flash_state : state;
signal flash_finished : std_logic := '0';
signal current_addr : std_logic_vector(15 downto 0) := (others => '0');
shared variable cnt : integer := 0;	--用于原来的频率降低为适合FLASH的频率

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
			--rflag <= '0';
			
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
				
				if(IsMem = '1') then			--若MEM, 输入信号为addr, wdata
					Ram_Addr := addr;
					Ram_Data := wdata;
				else								--若IF, 输入信号为PC
					Ram_Addr := PC;
			--		if PCKeep = '0' then		--PCMUX, 这个应该在哪里实现????
			--			ram2_addr(15 downto 0) <= PCMuxOut;
			--		elsif PCKeep = '1' then
			--			ram2_addr(15 downto 0) <= PCOut;
			--		end if;
				end if;
				
				if(MemWrite = '1') then	--RAM2/串口写入
					
					case mem_state is
						when s0 =>
							if(Ram_Addr = x"BF00") then --串口准备写入
								wrn <= '0';
								--Ram1_Addr(15 downto 0) <= Ram_Addr;
								Ram1_Data(7 downto 0) <= Ram_Data(7 downto 0);
							else								 --RAM2准备写入
								wrn <= '1';
								rdn <= '1';
								Ram2_WE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= Ram_Data;
							end if;
							mem_state <= s1;
						
						when s1 =>
							if(Ram_Addr = x"BF00") then --串口写入
								wrn <= '1';
							else								 --RAM2写入
								Ram2_WE <= '1';
							end if;
							mem_state <= s0;
						
						when others =>
							mem_state <= s0;
					end case;
					
				elsif(MemRead = '1') then --RAM2/串口读取
					case mem_state is
						when s0 =>
							if(Ram_Addr = x"BF01") then --准备读串口状态
								rdata(15 downto 2) <= (others => '0');
								rdata(1) <= data_ready;
								rdata(0) <= tsre and tbre;
								--if(rflag = '0') then --读串口状态时意味着接下来可能要读/写串口数据
								Ram1_Data <= (others => 'Z');--故预先把ram1_data置为高阻
								--	rflag <= '1'; --如果接下来要读，则可直接把rdn置'0'，省一个状态；要写，则rflag='0'，正常走写串口的流程
								--end if;
								
							elsif(Ram_Addr = x"BF00") then --准备读串口数据
								--rflag <= '0';
								rdn <= '0';
								--在这里不加Ram1_Data<= 'Z...'的原因是此赋值是rdn<='1'和一起的, 而不是rdn<='0', 所以准备读串口时要完成此赋值
								
							else 									 --准备读RAM2
								wrn <= '1';
								rdn <= '1';
								Ram2_OE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= (others => 'Z');							
							end if;
							mem_state <= s1;
						
						when s1 =>
							if(Ram_Addr = x"BF01") then		--读串口状态(已读)
								null;
							elsif(Ram_Addr = x"BF00") then	--读串口数据
								rdn <= '1';
								rdata(15 downto 8) <= (others => '0');
								rdata(7 downto 0) <= Ram1_Data(7 downto 0);
							else										--读内存
								Ram2_OE <= '1';
								if(IsMem = '1') then	--若MEM, 输出信号为rdata
									rdata <= Ram2_Data;
								else						--若IF, 输出信号为inst
									inst <= Ram2_Data;
								end if;
							end if;	
							mem_state <= s0;
							
						when others =>
							mem_state <= s0;
					end case;
					
				end if; --RAM2写/读
			else
				if( cnt >= 1000) then
					cnt := 0;
					
					case flash_state is
						when s0 =>		--WE置0
							Ram2_EN <= '0';
							Ram2_WE <= '0';
							Ram2_OE <= '1';
							--wrn <= '1';
							--rdn <= '1';
							FLASH_WE <= '0';
							FLASH_OE <= '1';
							
							FLASH_BYTE <= '1';
							FLASH_VPEN <= '1';
							FLASH_RP <= '1';
							FLASH_CE <= '0';
							
							flash_state <= s1;
							
						when s1 =>		--置为读模式
							FLASH_DATA <= x"00FF";
							flash_state <= s2;
							
						when s2 =>
							FLASH_WE <= '1';
							flash_state <= s3;
							
						when s3 =>		--准备读取
							FLASH_ADDR <= "000000" & current_addr & '0';	--这是由于字模式中只用到22~1, 其中最高6位(22~17)为block地址, 之后(16~1)为block内的地址.
																			--我们是只用第一个block
							FLASH_DATA <= (others => 'Z');
							FLASH_OE <= '0';
							flash_state <= s4;
							
						when s4 =>		--读取完毕, 准备写入到内存
							FLASH_OE <= '1';	
							Ram2_WE <= '0';
							Ram2_Addr <= "00" & current_addr;
							--Ram2_AddrOutput <= "00" & current_addr;	--调试
							Ram2_Data <= FLASH_DATA;
							flash_state <= s5;
						
						when s5 =>		--写入到内存
							Ram2_WE <= '1';
							current_addr <= current_addr + '1';
							flash_state <= s0;
						
							
						when others =>
							flash_state <= s0;
					end case;
					
					if (current_addr > x"0249") then		--这个地址随时kernel.bin的长度而改变??
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

