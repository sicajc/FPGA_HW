`define C2Q 5
module LIFObuffer (
    dataIn,

    dataOut,

    RW,

    EN,

    Rst,

    EMPTY,

    FULL,

    Clk

);

    input [15:0] dataIn;

    input RW, EN, Rst, Clk;

    output reg [15:0] dataOut;
    parameter DEPTH = 16;

    reg [15:0] stack_mem[0:DEPTH-1];

    reg [ 4:0] SP;

    output reg EMPTY, FULL;

    integer i;

    always @(posedge Clk or negedge Rst) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on

        if (~Rst) begin
            SP <= 5'd15;
            for (i = 0; i < DEPTH; i = i + 1) begin
                stack_mem[i] <= 'd0;
            end
        end else
        if (EN == 0);
        else begin
            if (~Rst == 0) begin
                if (FULL == 1'b0 && RW == 1'b0) begin
                    SP            <= SP - 5'd1;
                    stack_mem[SP] <= dataIn;
                end else if (EMPTY == 1'b0 && RW == 1'b1) begin
                    stack_mem[SP] <= 0;
                    SP <= SP + 1;
                end else;
            end else;
        end
    end

    always @(*) begin
        if (~Rst) begin
            EMPTY   = SP[4];
            dataOut = 4'h0;
        end else
        if (EN == 0);
        else begin
            if (~Rst == 0) begin
                FULL = SP ? 0 : 1;
                EMPTY = SP[4];
                dataOut = 4'hx;
                if (FULL == 1'b0 && RW == 1'b0) begin
                    FULL  = SP ? 0 : 1;
                    EMPTY = SP[4];
                end else if (EMPTY == 1'b0 && RW == 1'b1) begin
                    dataOut = stack_mem[SP];
                    FULL = SP ? 0 : 1;
                    EMPTY = SP[4];
                end else;
            end else;
        end
    end

endmodule
