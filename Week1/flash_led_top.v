`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCHU EE Lab716
// Engineer:
//
// Module Name: flash_led_top
// Project Name:
// Target Devices:
// Versions: 1.0
// Tool Versions: Vivado 2018.2
//////////////////////////////////////////////////////////////////////////////////

// ==  ==  == module ==  ==  ==
module flash_led_top(input clk,
                     input rst_n,
                     input btn_c,
                     output [15:0] led);

    // ==  ==  == Register ==  ==  ==
    reg [15:0] led;
    reg [24:0] count;

    wire d_clk;

    parameter S0 = 16'b1000_0001_1000_0001;
    parameter S1 = 16'b0100_0010_0100_0010;
    parameter S2 = 16'b0010_0100_0010_0100;
    parameter S3 = 16'b0001_1000_0001_1000;

    // ==  ==  == frequency division ==  ==  ==
    //counter
    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count <= 0;
        else
            count <= count + 1;
    end

    assign d_clk =  count[23]; //Modify s.t instead of bit 23 high,  bit 10 high too
    //Frequency too high would lead to implementation error
    // ==  ==  == LED light control ==  ==  ==
    always@(posedge d_clk or negedge rst_n) begin
        if (!rst_n)
            led <= S0;
        else
        begin
            case(btn_c) //btn_c determine whether button pushed
                0 : //Right shift
                begin
                    case(led)
                        S0:
                        begin
                            led <= S1;
                        end
                        S1:
                        begin
                            led <= S2;
                        end
                        S2:
                        begin
                            led <= S3;
                        end
                        S3:
                        begin
                            led <= S0;
                        end
                        default:
                        led <= led;
                    endcase
                end
                1 : //Left shift
                begin
                    case(led)
                        S0:
                        begin
                            led <= S3;
                        end
                        S1:
                        begin
                            led <= S0;
                        end
                        S2:
                        begin
                            led <= S1;
                        end
                        S3:
                        begin
                            led <= S2;
                        end
                        default:
                        led <= led;
                    endcase
                end
            endcase
        end
    end

    // ==  ==  == end module ==  ==  ==
endmodule
