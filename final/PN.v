// 2023 FPGA
// FIANL : Polish Notation(PN)
//
// -----------------------------------------------------------------------------
// ©Communication IC & Signal Processing Lab 716
// -----------------------------------------------------------------------------
// Author : HSUAN-YU LIN
// File   : PN.v
// Create : 2023-02-27 13:19:54
// Revise : 2023-02-27 13:19:54
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`define C2Q 5
module PN(
	input clk,
	input rst_n,
	input [1:0] mode,
	input operator,
	input [2:0] in,
	input in_valid,
	output out_valid,
	output signed [31:0] out
    );

//================================================================
//   PARAMETER/INTEGER
//================================================================
//integer
integer i;
parameter 	WORD = 4;
localparam  CNT_LEN = 4;
//================================================================
//   States
//================================================================
//======================
//   L1 MAIN FSM
//======================
localparam IDLE = 'd0;
localparam RD_DATA= 'd1 ;
localparam EVALUATION= 'd2 ;
localparam SORT = 'd3;
localparam DONE ='d4 ;


//======================
//   MODES
//======================
localparam POSTFIX_BURST    = 'd0 ;
localparam POSTFIX			= 'd1 ;
localparam PREFIX_BURST     = 'd2 ;
localparam PREFIX           = 'd3 ;

//======================
//   STACK FSM
//======================
localparam DET_TYPE 			= 'd0 ;
localparam PERFORM_OP_POP1	    = 'd1 ;
localparam PERFORM_OP_POP2      = 'd2 ;
localparam PERFORM_OP_PUSH  	= 'd3 ;
localparam PERFORM_CALCULATION  = 'd4 ;

//================================================================
//   REG/WIRE
//================================================================
reg[WORD-1:0] alu_ff;
reg[WORD-1:0] data_buf[0:15];
reg[CNT_LEN-1:0] strLen_cnt;
reg[CNT_LEN-1:0] buf_index_cnt;
reg[CNT_LEN-1:0] done_cnt;

//======================
//   FSM
//======================
reg[2:0] currentState,nextState;
reg[2:0] stackCTR;
reg[2:0] modeState;


//======================
//   STACK
//======================
wire push;
wire pop;

//======================
//   state indicators
//======================
wire    state_IDLE				= currentState == IDLE;
wire    state_RD_DATA			= currentState == RD_DATA;
wire    state_EVALUATION		= currentState == EVALUATION;
wire    state_SORT				= currentState == SORT;
wire    state_DONE				= currentState == DONE;


wire  	mode_POSTFIX_BURST		= modeState == POSTFIX_BURST;
wire  	mode_POSTFIX			= modeState == POSTFIX;
wire  	mode_PREFIX_BURST		= modeState == PREFIX_BURST;
wire  	mode_PREFIX     		= modeState == PREFIX;

wire    stack_DET_TYPE          = stackCTR == DET_TYPE;
wire    stack_POP1				= stackCTR == PERFORM_OP_POP1;
wire    stack_POP2				= stackCTR == PERFORM_OP_POP2;
wire    stack_PUSH				= stackCTR == PERFORM_OP_PUSH;
wire    stack_CALCULATION       = stackCTR == PERFORM_CALCULATION;

//================================================================
//   Design
//================================================================
//======================
//   FSM
//======================
//MAIN FSM
always @(posedge clk or posedge reset) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (reset) begin
            currentState <= IDLE;
        end else begin
            currentState <= nextState;
        end
    end

always @(*) begin
    case (currentState)
        IDLE: begin
			if(in_valid)
			begin
				nextState = RD_DATA;
			end
			else
			begin
				nextState = IDLE;
			end
        end
        RD_DATA: begin
			if(!in_valid)
			begin
				nextState = EVALUATION;
			end
			else
			begin
				nextState = RD_DATA;
			end
        end
        EVALUATION: begin
			if(evaluation_done_f)
			begin
				nextState = SORT;
			end
			else
			begin
				nextState = EVALUATION;
			end
        end
        DONE: begin
			if(in_valid)
			begin
				nextState = IDLE;
			end
			else if(timed_out_f)
			begin
				nextState = IDLE;
			end
			else
			begin
				nextState = DONE;
			end
        end
        default: begin
				nextState = IDLE;
        end
    endcase
end

//MODE
always @(posedge clk or negedge rst_n) begin
	//synopsys_translate_off
    #`C2Q;
    //synopsys_translate_on
    if (reset) begin
        modeState <= POSTFIX;
    end else if (state_RD_DATA || state_IDLE)begin
		case(mode)
		'd0:		modeState <= PREFIX_BURST;
		'd1:		modeState <= POSTFIX_BURST;
		'd2:		modeState <= PREFIX;
		'd3:		modeState <= POSTFIX;
		default:	modeState <= PREFIX;
		endcase
    end
	else begin
		modeState <= modeState;
	end
end

//Stack control
always @(posedge clk or negedge rst_n) begin
	//synopsys_translate_off
    #`C2Q;
    //synopsys_translate_on
    if (reset) begin
        stackCTR <= DET_TYPE;
	end
    else begin
		case(stackCTR)
		DET_TYPE:begin
			case({is_operand_f,is_operator_f})
			2'b10:	stackCTR  <= PERFORM_OP_PUSH;
			2'b01:  stackCTR  <= PERFORM_OP_POP1;
			default:stackCTR  <= DET_TYPE;
			endcase
		end
		PERFORM_OP_PUSH:begin
			stackCTR <= DET_TYPE;
		end
		PERFORM_OP_POP1:begin
			stackCTR <= PERFORM_OP_POP1;
		end
		PERFORM_OP_POP2:begin
			stackCTR <= PERFORM_CALCULATION;
		end
		PERFORM_CALCULATION:begin
			stackCTR <= DET_TYPE;
		end
		default:begin
			stackCTR <= DET_TYPE;
		end
		endcase
	end
end






endmodule