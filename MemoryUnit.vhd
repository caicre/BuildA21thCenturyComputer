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
			rdn			: out STD_LOGIC
				);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
--signal rflag : std_logic := '0';		--rflag='1'代表把串口数据线（ram1_data）置高阻，用于节省状态的控制

--flash
signal flash_state : state;
signal flash_finished : std_logic := '0';
signal current_addr : std_logic_vector(15 downto 0) := (others => '0');
shared variable cnt : integer := 0;	--用于原来的频率降低为适合FLASH的频率

signal rflag : std_logic := '0';		--rflag='1'代表把串口数据线（ram1_data）置高阻，用于节省状态的控制

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
					when s0 =>												--准备读指令
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
					when s1 =>												--读指令, 准备读写内存/串口
						Ram2_OE <= '1';
						inst <= Ram2_Data;
						if(MemWrite = '1') then
							rflag <= '0';
							if(addr = x"BF00") then	--准备写串口数据
								Ram1_data(7 downto 0) <= wdata(7 downto 0);
								wrn <= '0';
							else					--准备写内存
								Ram2_Addr(15 downto 0) <= addr;
								Ram2_Data <= wdata;
								Ram2_WE <= '0';
							end if;
						elsif(MemRead = '1') then
							if(addr = x"BF01") then --准备读串口状态
								rdata(15 downto 2) <= (others => '0');
								rdata(1) <= data_ready;
								rdata(0) <= tsre and tbre;
								if(rflag = '0') then --读串口状态时意味着接下来可能要读/写串口数据
									Ram1_Data <= (others => 'Z');--故预先把ram1_data置为高阻
									rflag <= '1'; --如果接下来要读，则可直接把rdn置'0'，省一个状态；要写，则rflag='0'，正常走写串口的流程
								end if;
							elsif (addr = x"BF00") then	--准备读串口数据
								rflag <= '0';
								rdn <= '0';
							else						--准备读内存
								Ram2_Data <= (others => 'Z');
								Ram2_Addr(15 downto 0) <= addr;
								Ram2_OE <= '0';
							end if;
						end if;
						mem_state <= s2;
						
					when s2 =>
						if(MemWrite = '1') then			
							if(addr = x"BF00") then		--写串口数据
								wrn <= '1';
							else						--写内存
								Ram2_WE <= '1';
							end if; 
						elsif(MemRead = '1') then
							if (addr = x"BF01") then	--读串口状态（已读出）
								null;
							elsif(addr = x"BF00") then	--读串口数据
								rdn <= '1';
								rdata(15 downto 8) <= (others => '0');
								rdata(7 downto 0) <= Ram1_Data(7 downto 0);
							else						--读内存
								Ram2_OE <= '1';
								rdata <= Ram2_Data;
							end if;
						end if;
						mem_state <= s0;
					when others =>
						mem_state <= s0;
				end case;
		end if;	--rst and clk's raise
	end process;
end Behavioral;