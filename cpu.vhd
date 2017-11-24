library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
		rst			: in STD_LOGIC;
		clk			: in STD_LOGIC;
		clk_50		: in STD_LOGIC;

		-- Serial Port
		dataReady	: in STD_LOGIC;
		tbre		: in STD_LOGIC;
		tsre		: in STD_LOGIC;
		rdn			: inout	STD_LOGIC;
		wrn			: inout	STD_LOGIC;

		-- RAM1 
		Ram1OE		: out STD_LOGIC;
		Ram1WE		: out STD_LOGIC;
		Ram1EN		: out STD_LOGIC;
		Ram1Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram1Data	: inout STD_LOGIC_VECTOR(15 downto 0);

		--RAM2
		Ram2OE		: out STD_LOGIC;
		Ram2WE		: out STD_LOGIC;
		Ram2EN		: out STD_LOGIC;
		Ram2Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram2Data	: inout STD_LOGIC_VECTOR(15 downto 0)

		-- Flash
	);
end cpu;

architecture behavioral of cpu is

	component Controller
		port(
			rst 		: in STD_LOGIC;
			inst		: in STD_LOGIC_VECTOR(15 downto 0);
			controlSignal: out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component ForwardingUnit
		port(
			-- control signal
			EX_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			MEM_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			-- input
			raddr1 		: in STD_LOGIC_VECTOR(3 downto 0);
			raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
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
			IDEXFlush 	: out STD_LOGIC;
		);
	end component;

	component 
	----------------------------
	--          IF            
	----------------------------
	component PCRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			PCIn 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0);
		);
	end component;

	component PCAdder
		port(
			PCIn		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component RPCAdder
		port(
			PCIn		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCMux
		port(
			-- control signal
			jump		: in STD_LOGIC;
			branchJudge	: in STD_LOGIC;
			PCStall		: in STD_LOGIC;
			--
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			nextPC		: in STD_LOGIC_VECTOR(15 downto 0);
			PCimm		: in STD_LOGIC_VECTOR(15 downto 0);
			ALURes 	    : in STD_LOGIC_VECTOR(15 downto 0);
			--
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)

		);
	end component;

	component InstructionMemory
		port(
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
			IR 			: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component IFIDRegister
		port(
			rst 		: in STD_LOGIC;
			clk 		: in STD_LOGIC;
			-- input
			IF_PC		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_IR		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_RPC		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ID_PC		: out STD_LOGIC_VECTOR(15 downto 0);
			ID_IR		: out STD_LOGIC_VECTOR(15 downto 0);
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
			ID_ALURes  	: in STD_LOGIC;
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
			ID_RPC 		: in STD_LOGIC_VECTOR(15 downto 0)
			-- output control signal
			EX_RegDst	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUOp	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUSrcB	: out STD_LOGIC;
			EX_ALURes  	: out STD_LOGIC;
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
			EX_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			src1		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALUSrcMux2
		port(
			-- control signal
			ForwardB	: in STD_LOGIC_VECTOR(1 downto 0);
			ALUSrcB		: in STD_LOGIC
			-- input
			reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			EX_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0)
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
			result 		: in STD_LOGIC_VECTOR(15 downto 0);
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ALUResult	: out STD_LOGIC_VECTOR(15 downto 0);
		);
	end component;

	component PCImmAdder
		port(
			PCIn		: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component BranchMux
		port(
			-- control signal
			ForwardA	: in STD_LOGIC_VECTOR(1 downto 0);
			Branch 		: in STD_LOGIC;
			BranchOp 	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg1 		: in STD_LOGIC_VECTOR(15 downto 0);
			EX_ALURes 	: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALURes 	: in STD_LOGIC_VECTOR(15 downto 0);
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
			EX_reg2		: in STD_LOGIC_VECTOR(15 downto 0)
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

	component DataMemory 
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MemWrite 	: in STD_LOGIC;
			MemRead 	: in STD_LOGIC;
			-- RAM1
			Ram1OE 		: out STD_LOGIC;
			Ram1WE 		: out STD_LOGIC;
			Ram1EN 		: out STD_LOGIC;
			Ram1Addr	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram1Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			addr 		: in STD_LOGIC_VECTOR(15 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			rdata 		: out STD_LOGIC_VECTOR(15 downto 0);
		);
	end component;

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
			MEM_ALURes	: in STD_LOGIC_VECTOR(15 downto 0)
			-- output control signal
			WB_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
			WB_MemToRead: out STD_LOGIC;
			WB_RegWrite : out STD_LOGIC;
			-- output
			WB_rdata 	: out STD_LOGIC_VECTOR(15 downto 0);
			WB_ALURes	: out STD_LOGIC_VECTOR(15 downto 0);
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
			result		: in STD_LOGIC_VECTOR(15 downto 0);
			-- oiutput
			wdata 		: out STD_LOGIC_VECTOR(15 downto 0);
		);
	end component;

	----------------------------
	--         signals            
	----------------------------
	-- PCRegister
	signal PC 	 		: STD_LOGIC_VECTOR(15 downto 0);
	_
	-- PCAdder
	signal PCAddOne 	: STD_LOGIC_VECTOR(15 downto 0);

	-- RPCAdder
	signal PCAddTwo 	: STD_LOGIC_VECTOR(15 downto 0);

	-- PCMux
	signal PCOut 		: STD_LOGIC_VECTOR(15 downto 0);

	-- InstructionMemory
	signal IR 			: STD_LOGIC_VECTOR(15 downto 0);

	-- IFIDRegister
	signal ID_PC 		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_IR		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_RPC		: STD_LOGIC_VECTOR(15 downto 0);

	-- Registers
	signal reg1 		: STD_LOGIC_VECTOR(15 downto 0);
	signal reg2 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ImmUnit
	signal immOut 		: STD_LOGIC_VECTOR(15 downto 0);

	-- IDEXRegister
	signal EX_RegDst	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUOp 	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUSrcB	: STD_LOGIC;
	signal EX_ALURes 	: STD_LOGIC;
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
	signal EX_RPC 		: STD_LOGIC_VECTOR(3 downto 0);

	-- ALUSrcMux1
	signal ALUSrc1 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUSrcMux2
	signal ALUSrc2 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALU
	signal result	 	: STD_LOGIC_VECTOR(15 downto 0);
	signal zero 		: STD_LOGIC;

	-- ALUResMux
	signal ALUResult	: STD_LOGIC_VECTOR(15 downto 0);

	-- PCImmAdder
	signal PCAddImm		: STD_LOGIC_VECTOR(15 downto 0);

	-- EXMEMRegister
	signal MEM_BranchOp	: STD_
