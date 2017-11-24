----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:12:39 11/20/2017 
-- Design Name: 
-- Module Name:    IF - Behavioral 
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

entity InstructionMemory is
    Port ( 
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		-- RAM2
		Ram2OE		: out STD_LOGIC;
		Ram2WE 		: out STD_LOGIC;
		Ram2EN 		: out STD_LOGIC;
		Ram2Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram2Data	: inout STD_LOGIC_VECTOR(15 downto 0);
		-- input
		PC 			: in STD_LOGIC_VECTOR(15 downto 0);
		-- output
		IR 			: out STD_LOGIC_VECTOR(15 downto 0));
end InstructionMemory;


architecture Behavioral of InstructionMemory is

component RAM2
    port ( CLK : in  STD_LOGIC;
           ADDR_IN : in  STD_LOGIC_VECTOR (17 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0); 		--op(1): 使能(使能:0, 非使能:1); op(0): 读或写 (0,1)
           DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM2_DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_OE : out  STD_LOGIC;
           RAM2_WE : out  STD_LOGIC;
           RAM2_EN : out  STD_LOGIC);
			  --rdn, wrn					--一定要关闭
end component;

component ZERO_EXTEND_18BIT
    port ( D_16BIT : in  STD_LOGIC_VECTOR (15 downto 0);
           Q_18BIT : out  STD_LOGIC_VECTOR (17 downto 0));
end component;

--signal op : std_logic_vector (1 downto 0);
signal PC_18bit : std_logic_vector (17 downto 0);

begin
	u0:ZERO_EXTEND_18BIT port map(PC, PC_18bit);
	u1:RAM2 port map(CLK, PC_18bit, "0000000000000000", "00", IR, RAM2_ADDR, RAM2_DATA, RAM2_OE, RAM2_WE, RAM2_EN);
	--												写入信号为0...,    总是读取
end Behavioral;

