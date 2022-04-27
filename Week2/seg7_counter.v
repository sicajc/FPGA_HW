`timescale 1ns / 1ps

// ==  ==  == module ==  ==  ==
module seg7_counter(input clk,
                    input rst_n,
                    input btn_c,
                    output [7:0] seg7,
                    output [7:0] seg7_sel,
                    output [15:0] led);

    //Parameters
    parameter RESET = 8'b1111_1111;
    parameter ZERO  = 8'b0011_1111;
    parameter ONE   = 8'b0000_0110;
    parameter TWO   = 8'b0001_1011;
    parameter THREE = 8'b0000_1111 ;
    parameter FOUR  = 8'b0110_0110;
    parameter FIVE  = 8'b0110_1101;
    parameter SIX   = 8'b0111_1101;
    parameter SEVEN = 8'b0010_0111 ;
    parameter EIGHT = 8'b0111_1111 ;
    parameter NINE  = 8'b0110_1111;
    parameter A     = 8'b1111_0111;
    parameter B     = 8'b1111_1100;
    parameter C     = 8'b1101_1000 ;
    parameter D     = 8'b1101_1110;
    parameter E     = 8'b1111_1001;
    parameter F     = 8'b1111_0001 ;
    // ==  ==  == Register ==  ==  ==
    reg [7:0] seg7;
    reg [3:0] seg7_cnt; //4 bits
    reg [24:0] count;
    reg [15:0] led; // Add led control

    wire d_clk;

    // ==  ==  == frequency division ==  ==  ==
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count <= 0;
        else if(btn_c)
            count <= count + 1;
        else
            count <= count + 2;
    end

    assign d_clk =  count[24]; //enables slower movements , frequency would become lower

    // ==  ==  == Set the chip select signal ==  ==  ==
    assign seg7_sel = 8'b0000_0001;

    // ==  ==  == SEVEN segment display light control ==  ==  ==
    always @(posedge d_clk or negedge rst_n)begin
        if (!rst_n)
            seg7_cnt <= 'd15;
        else if (seg7_cnt == 'd0) //Once become 0 return to 15, fuck you overflow.
            seg7_cnt <= 'd15;
        else
            seg7_cnt <= seg7_cnt - 'd1;
    end

    always @(posedge d_clk or negedge rst_n)begin
        if (!rst_n)
            seg7 <= RESET;
        else begin
            case(seg7_cnt)
                0:seg7        <= ZERO;
                1:seg7        <= ONE;
                2:seg7        <= TWO;
                3:seg7        <= THREE;
                4:seg7        <= FOUR;
                5:seg7        <= FIVE;
                6:seg7        <= SIX;
                7:seg7        <= SEVEN;
                8:seg7        <= EIGHT;
                9:seg7        <= NINE;
                10:seg7       <= A;
                11:seg7       <= B;
                12:seg7       <= C;
                13:seg7       <= D;
                14:seg7       <= E;
                15:seg7       <= F;
                default: seg7 <= RESET;
            endcase
        end
    end

    // ==  ==  == LED light control ==  ==  ==
    always@(posedge d_clk or negedge rst_n)
    begin
        if (!rst_n)
            led <= 16'b1111_1111_1111_1111;
        else if (seg7_cnt == 'd0)
        begin
            led <= 16'b1111_1111_1111_1111;
        end
        else
        begin
            led[seg7_cnt] <= 1'b0;
        end
    end

endmodule
