module counter(input clk,
               input rst,
               input count,
               output[2:0] counter_out);


    reg[2:0] counter_reg;
    reg[2:0] counter_reg_in;

    wire[2:0] adder_out;


    //register
    always @(posedge clk or negedge rst)
    begin
        counter_reg <= rst ? 0 : counter_reg_in;
    end

    //Combinational
    always @(*)
    begin
        if (count)
            counter_reg_in = adder_out;
        else
            counter_reg_in = counter_reg;
    end

    assign adder_out = counter_reg + 1;



    //
    // always @(posedge clk or negedge rst)
    // begin
    //     if (rst)
    //     begin
    //        counter_reg <= 0;
    //     end
    //     else if(count)
    //     begin
    //         counter_reg <= counter_reg + 1;
    //     end
    //     else
    //     begin
    //         counter_reg <= counter_reg;
    //     end
    // end


endmodule
