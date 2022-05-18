module test2(input rst,input clk);

    wire[2:0] counter1;
    wire count1;


    wire[2:0] counter2;
    wire count2;

    counter a1(clk,rst,count1,counter1);

    counter a2(.clk(clk),.rst(rst),.count(count2),.counter_out(counter2));




endmodule