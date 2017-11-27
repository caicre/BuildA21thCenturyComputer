library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
		rst			: in STD_LOGIC;
		clk			: in STD_LOGIC;

		-- Serial Port
		dataReady	: in STD_LOGIC;
		tbre		: in STD_LOGIC;
		tsre		: in STD_LOGIC;
		rdn			: inout	STD_LOGIC;
		wrn			: inout	STD_LOGIC;

		-- RAM1 
		Ram1_OE		: out STD_LOGIC;
		Ram1_WE		: out STD_LOGIC;
		Ram1_EN		: out STD_LOGIC;
		Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);

		--RAM2
		Ram2_OE		: out STD_LOGIC;
		Ram2_WE		: out STD_LOGIC;
		Ram2_EN		: out STD_LOGIC;
		Ram2_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0) ;
		
		--LED
		led			: out STD_LOGIC_VECTOR(15 downto 0) ;
		showclk		: out STD_LOGIC_VECTOR(3 downto 0)
		
	);
end cpu;

architecture Behavioral of cpu is

	component Clock
		port(
			rst	: in STD_LOGIC;
			clk 	: in STD_LOGIC;
			clk0	: out STD_LOGIC;
			clk1 	: out STD_LOGIC;
			clk2	: out STD_LOGIC;
			clk3 	: out STD_LOGIC
		);
	end component;

	component Controller
		port(
			rst 		: in STD_LOGIC;
			inst		: in STD_LOGIC_VECTOR(15 downto 0);
			--
			RegSrcA		: out STD_LOGIC_VECTOR(3 downto 0);
			RegSrcB		: out STD_LOGIC_VECTOR(3 downto 0);
			ImmSrc 		: out STD_LOGIC_VECTOR(2 downto 0);
			ExtendOp 	: out STD_LOGIC;
			RegDst 		: out STD_LOGIC_VECTOR(3 downto 0);
			ALUOp 		: out STD_LOGIC_VECTOR(3 downto 0);
			ALUSrcB 	: out STD_LOGIC;
			ALURes 		: out STD_LOGIC_VECTOR(1 downto 0);
			Jump 		: out STD_LOGIC;
			BranchOp 	: out STD_LOGIC_VECTOR(1 downto 0);
			Branch 		: out STD_LOGIC;
			MemRead 	: out STD_LOGIC;
			MemWrite 	: out STD_LOGIC;
			MemToReg 	: out STD_LOGIC;
			RegWrite 	: out STD_LOGIC
		);
	end component;

	component ForwardingUnit
		port(
			-- control signal
			EX_ALUSrcB	: in STD_LOGIC;
			MEM_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			WB_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			-- input
			EX_raddr1 	: in STD_LOGIC_VECTOR(3 downto 0);
			EX_raddr2 	: in STD_LOGIC_VECTOR(3 downto 0);
			-- output
			ForwardA	: out STD_LOGIC_VECTOR(1 downto 0);
			ForwardB 	: out STD_LOGIC_VECTOR(1 downto 0)
		);
	end component;

	component HazardDetectionUnit
		port(
			-- control signal
			EX_MemRead 	: in STD_LOGIC;
			EX_RegDst	:in STD_LOGIC_VECTOR(3 downto 0);
			-- input
			raddr1 		: in STD_LOGIC_VECTOR(3 downto 0);
			raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
			-- output
			PCStall		: out STD_LOGIC;
			IFIDStall 	: out STD_LOGIC;
			IDEXFlush 	: out STD_LOGIC
		);
	end component;

	component MemoryUnit is
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;		

			-- input control signal
			MemWrite 	: in STD_LOGIC;		--'1':�
			MemRead 	: in STD_LOGIC;		--'1':�
			
			-- RAM1							--为串�BF00~BF03)
			Ram1_OE 	: out STD_LOGIC;
			Ram1_WE 	: out STD_LOGIC;
			Ram1_EN 	: out STD_LOGIC;
			Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			addr 		: in STD_LOGIC_VECTOR(15 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			rdata 		: out STD_LOGIC_VECTOR(15 downto 0);	
				
			-- RAM2								--¼à¿Ø³ÌÐò(0000~3FFF), ÓÃ»§³ÌÐò(4000~FFFF), ÏµÍ³Êý¾Ý(8000~BEFF), ÓÃ»§Êý¾Ý(C000~FFFF)
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
				
			--´®¿Ú
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC
			
		);
	end component;

	--component 
	----------------------------
	--          IF            
	----------------------------
	component PCRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			PCIn 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCAdder
		port(
			PC 		: in STD_LOGIC_VECTOR(15 downto 0);
			NPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component RPCAdder
		port(
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCMux
		port(
			-- control signal
			Jump		: in STD_LOGIC;
			BranchJudge	: in STD_LOGIC;
			PCStall		: in STD_LOGIC;
			--
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			NPC			: in STD_LOGIC_VECTOR(15 downto 0);
			PCAddImm	: in STD_LOGIC_VECTOR(15 downto 0);
			reg1 	    : in STD_LOGIC_VECTOR(15 downto 0);
			--
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)

		);
	end component;

	component IFIDRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input
			IF_PC		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_inst		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_RPC		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ID_PC		: out STD_LOGIC_VECTOR(15 downto 0);
			ID_inst		: out STD_LOGIC_VECTOR(15 downto 0);
			ID_RPC		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          ID            
	----------------------------
	component Registers
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- control signal
			RegWrite 	: in STD_LOGIC;
			-- input
			raddr1		: in STD_LOGIC_VECTOR(3 downto 0);
			raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
			waddr 		: in STD_LOGIC_VECTOR(3 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			reg1 		: out STD_LOGIC_VECTOR(15 downto 0);
			reg2 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ImmUnit
		port(
			-- control signal
			ImmSrc		: in STD_LOGIC_VECTOR(2 downto 0);
			ExtendOp	: in STD_LOGIC;
			--
			inst 		: in STD_LOGIC_VECTOR(15 downto 0);
			--
			immOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component IDEXRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			ID_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_ALUOp	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_ALUSrcB	: in STD_LOGIC;
			ID_ALURes  	: in STD_LOGIC_VECTOR(1 downto 0);
			ID_Jump		: in STD_LOGIC;
			ID_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
			ID_Branch 	: in STD_LOGIC;
			ID_MemRead	: in STD_LOGIC;
			ID_MemWrite	: in STD_LOGIC;
			ID_MemToRead: in STD_LOGIC;
			ID_RegWrite : in STD_LOGIC;
			-- input
			ID_PC 		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_reg1		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_raddr1	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_raddr2	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_imm		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			EX_RegDst	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUOp	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUSrcB	: out STD_LOGIC;
			EX_ALURes  	: out STD_LOGIC_VECTOR(1 downto 0);
			EX_Jump		: out STD_LOGIC;
			EX_BranchOp	: out STD_LOGIC_VECTOR(1 downto 0);
			EX_Branch 	: out STD_LOGIC;
			EX_MemRead	: out STD_LOGIC;
			EX_MemWrite	: out STD_LOGIC;
			EX_MemToRead: out STD_LOGIC;
			EX_RegWrite : out STD_LOGIC;
			-- output
			EX_PC 		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_reg1		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_reg2		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_raddr1	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_raddr2	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_imm		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          EX            
	----------------------------
	component ALUSrcMux1
		port(
			-- control signal
			ForwardA	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg1		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			src1		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALUSrcMux2
		port(
			-- control signal
			ForwardB	: in STD_LOGIC_VECTOR(1 downto 0);
			ALUSrcB		: in STD_LOGIC ;
			-- input
			reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0) ;
			-- output
			src2		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALU
		port(
			-- input
			src1		: in STD_LOGIC_VECTOR(15 downto 0);
			src2		: in STD_LOGIC_VECTOR(15 downto 0);
			ALUOp		: in STD_LOGIC_VECTOR(3 downto 0);
			-- output
			result		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALUResMux
		port(
			-- control signal
			ALURes 		: in STD_LOGIC_VECTOR(1 downto 0);
			-- input 
			ALUResult 	: in STD_LOGIC_VECTOR(15 downto 0);
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ALUMuxResult: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCImmAdder
		port(
			PCIn		: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component BranchUnit
		port(
			-- control signal
			ForwardA	: in STD_LOGIC_VECTOR(1 downto 0);
			Branch 		: in STD_LOGIC;
			BranchOp 	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg1 		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes 	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALURes 	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			BranchJudge : out STD_LOGIC
		);
	end component;

	component EXMEMRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			EX_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
			EX_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
			EX_Branch 	: in STD_LOGIC;
			EX_MemRead	: in STD_LOGIC;
			EX_MemWrite	: in STD_LOGIC;
			EX_MemToRead: in STD_LOGIC;
			EX_RegWrite : in STD_LOGIC;
			-- input
			EX_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			EX_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			MEM_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
			MEM_BranchOp: out STD_LOGIC_VECTOR(1 downto 0);
			MEM_Branch 	: out STD_LOGIC;
			MEM_MemRead	: out STD_LOGIC;
			MEM_MemWrite: out STD_LOGIC;
			MEM_MemToRead: out STD_LOGIC;
			MEM_RegWrite: out STD_LOGIC;
			-- output
			MEM_ALURes	: out STD_LOGIC_VECTOR(15 downto 0);
			MEM_reg2	: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          MEM            
	----------------------------

	component MEMWBRegister 
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MEM_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
			MEM_MemToRead: in STD_LOGIC;
			MEM_RegWrite: in STD_LOGIC;
			-- input
			MEM_rdata 	: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			WB_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
			WB_MemToRead: out STD_LOGIC;
			WB_RegWrite : out STD_LOGIC;
			-- output
			WB_rdata 	: out STD_LOGIC_VECTOR(15 downto 0);
			WB_ALURes	: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          WB            
	----------------------------
	component WriteDataMux
		port(
			-- control signal
			MemToReg: in STD_LOGIC;
			-- input
			rdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			-- oiutput
			wdata 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	----------------------------
	--         signals            
	----------------------------
	-- Clock
	signal clk0 		: STD_LOGIC;
	signal clk1 		: STD_LOGIC;
	signal clk2 		: STD_LOGIC;
	signal clk3 		: STD_LOGIC;

	-- Controller
	signal RegSrcA		: STD_LOGIC_VECTOR(3 downto 0);
	signal RegSrcB		: STD_LOGIC_VECTOR(3 downto 0);
	signal ImmSrc 		: STD_LOGIC_VECTOR(2 downto 0);
	signal ExtendOp 	: STD_LOGIC;
	signal RegDst 		: STD_LOGIC_VECTOR(3 downto 0);
	signal ALUOp 		: STD_LOGIC_VECTOR(3 downto 0);
	signal ALUSrcB 	: STD_LOGIC;
	signal ALURes 		: STD_LOGIC_VECTOR(1 downto 0);
	signal Jump 		: STD_LOGIC;
	signal BranchOp 	: STD_LOGIC_VECTOR(1 downto 0);
	signal Branch 		: STD_LOGIC;
	signal MemRead 		: STD_LOGIC;
	signal MemWrite 	: STD_LOGIC;
	signal MemToReg 	: STD_LOGIC;
	signal RegWrite 	: STD_LOGIC;

	-- ForwardingUnit
	signal ForwardA		: STD_LOGIC_VECTOR(1 downto 0);
	signal ForwardB 	: STD_LOGIC_VECTOR(1 downto 0);

	-- HazardDetectionUnit
	signal PCStall 		: STD_LOGIC;
	signal IFIDStall	: STD_LOGIC;
	signal IDEXFlush	: STD_LOGIC;

	-- MemoryUnit
	signal rdata 		: STD_LOGIC_VECTOR(15 downto 0);
	signal IF_inst 		: STD_LOGIC_VECTOR(15 downto 0) ;

	-- PCRegister
	signal IF_PC 	 	: STD_LOGIC_VECTOR(15 downto 0);
	
	-- PCAdder
	signal IF_NPC 		 : STD_LOGIC_VECTOR(15 downto 0);

	-- RPCAdder
	signal IF_RPC 		 : STD_LOGIC_VECTOR(15 downto 0);

	-- PCMux
	signal PCMuxOut 	: STD_LOGIC_VECTOR(15 downto 0);

	-- IFIDRegister
	signal ID_PC 		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_inst		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_RPC		: STD_LOGIC_VECTOR(15 downto 0);

	-- Registers
	signal ID_reg1 		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_reg2 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ImmUnit
	signal ID_immOut 		: STD_LOGIC_VECTOR(15 downto 0);
--ID_
	-- IDEXRegister
	signal EX_RegDst	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUOp 	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUSrcB	: STD_LOGIC;
	signal EX_ALURes 	: STD_LOGIC_VECTOR(1 downto 0);
	signal EX_Jump 		: STD_LOGIC;
	signal EX_BranchOp	: STD_LOGIC_VECTOR(1 downto 0);
	signal EX_Branch 	: STD_LOGIC;
	signal EX_MemRead 	: STD_LOGIC;
	signal EX_MemWrite	: STD_LOGIC;
	signal EX_MemToRead : STD_LOGIC;
	signal EX_RegWrite  : STD_LOGIC;
	signal EX_PC 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_reg1 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_reg2 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_raddr1 	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_raddr2	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_imm 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_inst 	: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_RPC 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUSrcMux1
	signal ALUSrc1 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUSrcMux2
	signal ALUSrc2 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALU
	signal ALUResult	: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUResMux
	signal ALUMuxResult	: STD_LOGIC_VECTOR(15 downto 0);

	-- PCImmAdder
	signal EX_PCAddImm	: STD_LOGIC_VECTOR(15 downto 0);

	-- BranchUnit
	signal EX_BranchJudge: STD_LOGIC;

	-- EXMEMRegister
	signal MEM_RegDst 	: STD_LOGIC_VECTOR(3 downto 0);
	signal MEM_BranchOp	: STD_LOGIC_VECTOR(1 downto 0);
	signal MEM_Branch 	: STD_LOGIC;
	signal MEM_MemRead 	: STD_LOGIC;
	signal MEM_MemWrite : STD_LOGIC;
	signal MEM_MemToRead: STD_LOGIC;
	signal MEM_RegWrite : STD_LOGIC;
	signal MEM_ALURes 	: STD_LOGIC_VECTOR(15 downto 0);
	signal MEM_reg2 	: STD_LOGIC_VECTOR(15 downto 0);

	-- MEMWBRegister
	signal WB_RegDst	: STD_LOGIC_VECTOR(3 downto 0);
	signal WB_MemToRead : STD_LOGIC;
	signal WB_RegWrite 	: STD_LOGIC;
	signal WB_rdata 	: STD_LOGIC_VECTOR(15 downto 0);
	signal WB_ALURes 	: STD_LOGIC_VECTOR(15 downto 0);

	-- WriteDataMux
	signal WB_wdata 	: STD_LOGIC_VECTOR(15 downto 0);

	signal show1 : std_logic ;
	signal show2 : std_logic ;
	signal show3 : std_logic ;

begin

	u0 : Clock
	port map(
		rst 		=> rst,
		clk 		=> clk,
		clk0 		=> clk0,
		clk1 		=> clk1,
		clk2 		=> clk2,
		clk3 		=> clk3
	);
	
	u1 : Controller
	port map(
		rst 		=> rst,
		inst 		=> EX_inst,
		RegSrcA		=> RegSrcA,
		RegSrcB 	=> RegSrcB,
		ImmSrc		=> ImmSrc,
		ExtendOp 	=> ExtendOp,
		RegDst 		=> RegDst,
		ALUOp 		=> ALUOp,
		ALUSrcB 	=> ALUSrcB,
		ALURes 		=> ALURes,
		Jump 		=> Jump,
		BranchOp 	=> BranchOp,
		Branch 		=> Branch,
		MemRead 	=> MemRead,
		MemWrite 	=> MemWrite,
		MemToReg 	=> MemToReg,
		RegWrite 	=> RegWrite
	); 

	u2 : ForwardingUnit
	port map(
		EX_ALUSrcB	=> EX_ALUSrcB,
		MEM_RegDst	=> EX_RegDst,
		WB_RegDst	=> MEM_RegDst,
		EX_raddr1 	=> EX_raddr1,
		EX_raddr2	=> EX_raddr2,
		ForwardA	=> ForwardA,
		ForwardB	=> ForwardB
	);

	u3 : HazardDetectionUnit
	port map(
		EX_MemRead 	=> EX_MemRead,
		EX_RegDst 	=> EX_RegDst,
		raddr1 		=> EX_raddr1,
		raddr2 		=> EX_raddr2,
		PCStall 	=> PCStall,
		IFIDStall 	=> IFIDStall,
		IDEXFlush 	=> IDEXFlush
	);

	u30 : MemoryUnit
	port map(
		clk 		=> clk0,
		rst 		=> rst,
		MemWrite 	=> MEM_MemWrite,
		MemRead 	=> MEM_MemRead,
		Ram1_OE 	=> Ram1_OE,
		Ram1_WE 	=> Ram1_WE,
		Ram1_EN 	=> Ram1_EN,
		Ram1_Addr 	=> Ram1_Addr,
		Ram1_Data 	=> Ram1_Data,
		addr 		=> MEM_ALURes,
		wdata 		=> MEM_reg2,
		rdata 		=> rdata, --HERE was MEM_rdata
		Ram2_OE 	=> Ram2_OE,
		Ram2_WE 	=> Ram2_WE,
		Ram2_EN 	=> Ram2_EN,	
		Ram2_Addr 	=> Ram2_Addr,
		Ram2_Data 	=> Ram2_Data,
		PC 			=> IF_PC,
		inst 		=> IF_inst, --HERE was IF_inst, not right
		data_ready 	=> dataReady, 
		tbre 		=> tbre,
		tsre 		=> tsre,
		wrn 		=> wrn,
		rdn 		=> rdn
	);

	u4 : PCRegister
	port map(
		clk 		=> clk1,
		rst 		=> rst,
		PCIn 		=> PCMuxOut,
		PCOut 		=> IF_PC
	);

	u5 : PCAdder
	port map(
		PC			=> IF_PC,
		NPC 		=> IF_NPC
	);

	u6 : RPCAdder
	port map(
		PC 			=> IF_PC,
		RPC 		=> IF_RPC
	);

	u7 : PCMux
	port map(
		Jump 		=> EX_Jump,
		BranchJudge => EX_BranchJudge,
		PCStall		=> PCStall,
		PC 			=> IF_PC,
		NPC 		=> IF_NPC,
		PCAddImm 	=> EX_PCAddImm,
		reg1 		=> EX_reg1,
		PCOut 		=> PCMuxOut
	);

	u9 : IFIDRegister
	port map(
		clk 		=> clk1,
		rst 		=> rst,
		IF_PC 	=> IF_NPC,
		IF_inst 	=> IF_inst,
		IF_RPC	=> IF_RPC,
		ID_PC		=> ID_PC,
		ID_inst	=> ID_inst,
		ID_RPC 	=> ID_RPC
	);

	u10 : Registers
	port map(
		clk 		=> clk2,
		rst 		=> rst,
		RegWrite 	=> WB_RegWrite,
		raddr1 		=> RegSrcA,
		raddr2 		=> RegSrcB,
		waddr 		=> WB_RegDst,
		wdata 		=> WB_wdata,
		reg1 		=> ID_reg1, 
		reg2 		=> ID_reg2
	);

	u11 : ImmUnit
	port map(
		ImmSrc 		=> ImmSrc,
		ExtendOp 	=> ExtendOp,
		inst 		=> ID_inst,
		immOut 		=> ID_immOut
	);

	u12 : IDEXRegister
	port map(
		clk 		=> clk1,
		rst 		=> rst,
		ID_RegDst 	=> RegDst,
		ID_ALUOp 	=> ALUOp,
		ID_ALUSrcB 	=> ALUSrcB,
		ID_ALURes 	=> ALURes,
		ID_Jump 	=> Jump,
		ID_BranchOp => BranchOp,
		ID_Branch 	=> Branch,
		ID_MemRead 	=> MemRead,
		ID_MemWrite => MemWrite,
		ID_MemToRead=> MemToReg,
		ID_RegWrite	=> RegWrite,
		ID_PC 		=> ID_PC,
		ID_reg1		=> ID_reg1,
		ID_reg2 	=> ID_reg2,
		ID_raddr1 	=> RegSrcA, 
		ID_raddr2	=> RegSrcB, 
		ID_imm 		=> ID_immOut,
		ID_RPC 		=> ID_RPC,
		EX_RegDst	=> EX_RegDst,
		EX_ALUOp 	=> EX_ALUOp,
		EX_ALUSrcB  => EX_ALUSrcB,
		EX_ALURes	=> EX_ALURes,
		EX_Jump 	=> EX_Jump,
		EX_BranchOp => EX_BranchOp,
		EX_Branch 	=> EX_Branch,
		EX_MemRead 	=> EX_MemRead,
		EX_MemToRead=> EX_MemToRead,
		EX_RegWrite => EX_RegWrite,
		EX_MemWrite => Ex_MemWrite,
		EX_PC 		=> EX_PC,
		EX_reg1 	=> EX_reg1,
		EX_reg2 	=> EX_reg2,
		EX_raddr1 	=> EX_raddr1,
		EX_raddr2 	=> EX_raddr2,
		EX_imm 		=> EX_imm,
		EX_RPC 		=> EX_RPC
	);

	u13 : ALUSrcMux1
	port map(
		ForwardA	=> ForwardA,
		reg1 		=> EX_reg1,
		MEM_ALURes	=> MEM_ALURes,
		WB_ALURes 	=> WB_wdata,
		src1		=> ALUSrc1
	);

	u14 : ALUSrcMux2
	port map(
		ForwardB 	=> ForwardB,
		ALUSrcB 	=> EX_ALUSrcB,
		reg2 		=> EX_reg2,
		MEM_ALURes 	=> MEM_ALURes,
		WB_ALURes 	=> WB_ALURes,
		imm 		=> EX_imm,
		src2 		=> ALUSrc2
	);

	u15 : ALU
	port map(
		src1 		=> ALUSrc1,
		src2 		=> ALUSrc2,
		ALUOp 		=> EX_ALUOp,
		result 		=> ALUResult
	);

	u16 : ALUResMux
	port map(
		ALURes 		=> EX_ALURes,
		ALUResult 	=> ALUResult,
		PC 			=> EX_PC,
		RPC 		=> EX_RPC,
		ALUMuxResult=> ALUMuxResult
	);

	u17 : PCImmAdder
	port map(
		PCIn		=> EX_PC,
		imm 		=> EX_imm,
		PCOut 		=> EX_PCAddImm
	);

	u18 : BranchUnit
	port map(
		ForwardA 	=> ForwardA,
		Branch 		=> EX_Branch,
		BranchOp 	=> EX_BranchOp,
		reg1 		=> EX_reg1,
		MEM_ALURes 	=> MEM_ALURes,
		WB_ALURes	=> WB_ALURes,
		BranchJudge => EX_BranchJudge
	);

	u19 : EXMEMRegister
	port map(
		clk 		=> clk1,
		rst 		=> rst,
		EX_RegDst 	=> EX_RegDst,
		EX_BranchOp => EX_BranchOp,
		EX_Branch 	=> EX_Branch,
		EX_MemRead 	=> EX_MemRead,
		EX_MemWrite => EX_MemWrite,
		EX_MemToRead=> EX_MemToRead,
		EX_RegWrite => EX_RegWrite,
		EX_ALURes 	=> ALUMuxResult,
		EX_reg2 	=> EX_reg2,
		MEM_RegDst 	=> MEM_RegDst,
		MEM_BranchOp=> MEM_BranchOp,
		MEM_Branch  => MEM_Branch,
		MEM_MemRead => MEM_MemRead,
		MEM_MemWrite=> MEM_MemWrite,
		MEM_MemToRead=>MEM_MemToRead,
		MEM_RegWrite=> MEM_RegWrite,
		MEM_ALURes	=> MEM_ALURes,
		MEM_reg2 	=> MEM_reg2
	);

	u21 : MEMWBRegister
	port map(
		clk 		=> clk1,
		rst 		=> rst,
		MEM_RegDst  => MEM_RegDst,
		MEM_MemToRead=>MEM_MemToRead,
		MEM_RegWrite=> MEM_RegWrite,
		MEM_rdata	=> rdata,
		MEM_ALURes 	=> MEM_ALURes,
		WB_RegDst	=> WB_RegDst,
		WB_MemToRead=> WB_MemToRead,
		WB_RegWrite => WB_RegWrite,
		WB_rdata 	=> WB_rdata,
		WB_ALURes	=> WB_ALURes
	);

	u22 : WriteDataMux
	port map(
		MemToReg 	=> WB_MemToRead,
		rdata 		=> WB_rdata,
		ALUresult 	=> WB_ALURes,
		wdata 		=> WB_wdata
	);
	
	process (IF_inst)
	begin
--		led(15 downto 8) <= IF_inst(15 downto 8) ;
--		led(7 downto 0) <= IF_NPC(7 downto 0) ;
		led <= IF_NPC ;
	end process ;
	
	process (clk0,PCStall,EX_BranchJudge,EX_Jump)
	begin
		showclk(0) <= clk0 ;
		showclk(1) <= PCStall ;
		showclk(2) <= EX_BranchJudge ;
		showclk(3) <= EX_Jump ;

	end process ;
	
	
end Behavioral;