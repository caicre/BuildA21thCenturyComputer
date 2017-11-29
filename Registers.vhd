----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:45:23 11/23/2017 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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
use CpuConstant.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Registers is
    port(
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        -- control signal
        RegWrite    : in STD_LOGIC;
        -- input
        raddr1      : in STD_LOGIC_VECTOR(3 downto 0);
        raddr2      : in STD_LOGIC_VECTOR(3 downto 0);
        waddr       : in STD_LOGIC_VECTOR(3 downto 0);
        wdata       : in STD_LOGIC_VECTOR(15 downto 0);
        -- output
        reg1        : out STD_LOGIC_VECTOR(15 downto 0);
        reg2        : out STD_LOGIC_VECTOR(15 downto 0);

        showreg_r0  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r1  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r2  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r3  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r4  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r5  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r6  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_r7  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_T  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_IH  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_SP  : out STD_LOGIC_VECTOR(15 downto 0);
        showreg_RA  : out STD_LOGIC_VECTOR(15 downto 0)
    );
end Registers;

architecture Behavioral of Registers is

	shared variable r0 : std_logic_vector(15 downto 0);
	shared variable r1 : std_logic_vector(15 downto 0);
	shared variable r2 : std_logic_vector(15 downto 0);
	shared variable r3 : std_logic_vector(15 downto 0);
	shared variable r4 : std_logic_vector(15 downto 0);
	shared variable r5 : std_logic_vector(15 downto 0);
	shared variable r6 : std_logic_vector(15 downto 0);
	shared variable r7 : std_logic_vector(15 downto 0);
	shared variable T : std_logic_vector(15 downto 0);
	shared variable IH : std_logic_vector(15 downto 0);
	shared variable SP : std_logic_vector(15 downto 0);
	shared variable RA : std_logic_vector(15 downto 0);
	signal state : clockState := c0 ;
begin
    process (clk,rst) -- WRITE
    begin
    if(rst='0') then
        r0 := (others => '0');
        r1 := (others => '0');
        r2 := (others => '0');
        r3 := (others => '0');
        r4 := (others => '0');
        r5 := (others => '0');
        r6 := (others => '0');
        r7 := (others => '0');
        T  := (others => '0');
        IH := (others => '0');			
        SP := (others => '0');
        RA := (others => '0');
		  state <= c0 ;
	 elsif (clk'event and clk = '1') then
		case state is 
			when c0 => 
				state <= c1 ;
			when c1 =>
				if (RegWrite = '1') then --for now, 1 is to write
					  case waddr is
							when R0_ADDR => r0 := wdata ;
							when R1_ADDR => r1 := wdata ;
							when R2_ADDR => r2 := wdata ;
							when R3_ADDR => r3 := wdata ;
							when R4_ADDR => r4 := wdata ;
							when R5_ADDR => r5 := wdata ;
							when R6_ADDR => r6 := wdata ;
							when R7_ADDR => r7 := wdata ;
							when REG_SP => SP := wdata ;
							when REG_T  => T  := wdata ;
							when REG_IH => IH := wdata ;
							when REG_RA => RA := wdata ;
							when others => 
					  end case ;
				 end if ;
				 state <= c2 ;
			when c2 =>
				state <= c0 ;
			when others => state <= c0 ;
		end case ;
	 end if ;
    end process ;
	process (raddr1,state)
	begin
    if    (raddr1 = R0_ADDR) then 
        reg1 <= r0 ; 
    elsif (raddr1 = R1_ADDR) then
        reg1 <= r1 ;
    elsif (raddr1 = R2_ADDR) then
        reg1 <= r2 ;
    elsif (raddr1 = R3_ADDR) then
        reg1 <= r3 ;
    elsif (raddr1 = R4_ADDR) then
        reg1 <= r4 ;
    elsif (raddr1 = R5_ADDR) then
        reg1 <= r5 ;
    elsif (raddr1 = R6_ADDR) then
        reg1 <= r6 ;
    elsif (raddr1 = R7_ADDR) then
        reg1 <= r7 ;
    elsif (raddr1 = REG_SP) then
        reg1 <= SP ;     
    elsif (raddr1 = REG_IH) then
        reg1 <= IH ;
    elsif (raddr1 = REG_RA) then
        reg1 <= RA ;
    elsif (raddr1 = REG_T ) then
        reg1 <= T  ;
    end if ;
    end process ;
    process (raddr2, state)
	begin
    if    (raddr2 = R0_ADDR) then 
        reg2 <= r0 ; 
    elsif (raddr2 = R1_ADDR) then
        reg2 <= r1 ;
    elsif (raddr2 = R2_ADDR) then
        reg2 <= r2 ;
    elsif (raddr2 = R3_ADDR) then
        reg2 <= r3 ;
    elsif (raddr2 = R4_ADDR) then
        reg2 <= r4 ;
    elsif (raddr2 = R5_ADDR) then
        reg2 <= r5 ;
    elsif (raddr2 = R6_ADDR) then
        reg2 <= r6 ;
    elsif (raddr2 = R7_ADDR) then
        reg2 <= r7 ;
    elsif (raddr2 = REG_SP) then
        reg2 <= SP ;     
    elsif (raddr2 = REG_IH) then
        reg2 <= IH ;
    elsif (raddr2 = REG_RA) then
        reg2 <= RA ;
    elsif (raddr2 = REG_T ) then
        reg2 <= T  ;
    end if ;
	end process ;

    showreg_r0 <= r0 ;
    showreg_r1 <= r1 ;
    showreg_r2 <= r2 ;
    showreg_r3 <= r3 ;
    showreg_r4 <= r4 ;
    showreg_r5 <= r5 ;
    showreg_r6 <= r6 ;
    showreg_r7 <= r7 ;
    showreg_T  <= T ;
    showreg_SP <= SP ;
    showreg_RA <= RA ;
    showreg_IH <= IH ;
end Behavioral;

