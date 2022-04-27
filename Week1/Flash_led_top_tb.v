`timescale 1ps / 1ps
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

module flash_led_top_tb;

reg clk, rst, btn_c;
wire [15:0] led;

flash_led_top flash_led_top(
.clk(clk),
.rst_n(rst),
.btn_c(btn_c),
.led(led)
);

initial begin
    clk = 1'b0;
    rst = 1'b1;
    btn_c = 1'b0;
    #10 rst = 1'b0;
    #10 rst = 1'b1;
    #1000000000
    btn_c = 1'b1;
end

always #5 clk <= ~clk;

endmodule 