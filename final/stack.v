`define C2Q 5
module LIFO (
    in,
    full,
    empty,
    clk,
    rst_n,
    wn,
    rn,
    out
);
    parameter DATA_WIDTH = 16;
    parameter STACK_DEPTH = 16;

    input [DATA_WIDTH-1:0] in;
    input clk, rst_n, wn, rn;
    output reg [DATA_WIDTH-1:0] out;
    output full, empty;

    reg [3:0] sp;
    reg [DATA_WIDTH-1:0] memory[0:STACK_DEPTH-1];
    integer i;

    assign full  = (sp == 4'b1111) ? 1 : 0;
    assign empty = (sp == 4'b0000) ? 1 : 0;

    always @(*) begin
            out = memory[sp];
    end

    always @(posedge clk or negedge rst_n) begin
          //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            for (i = 0; i < STACK_DEPTH; i = i + 1) begin
                memory[i] <= 'd0;
            end
            sp <= 1;
        end else if (wn & !full) begin
            memory[sp] <= in;
            sp <= sp + 1;
        end else if (rn & !empty) begin
            sp <= sp - 1;
        end
    end
endmodule
