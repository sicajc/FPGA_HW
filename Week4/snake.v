module lab_4(input clk,
             input rst_n,
             input sw,
             input btn_c,
             output reg [3:0] seg7_sel,
             output reg [7:0] seg7);
    reg [24:0] count;
    wire dis_clk,d_clk;
    reg [7:0] seg7_temp [0:3]; //We have 4 parts to illuminate, so we need 4 slots to store the right value
    reg [3:0] seg7_cnt; // Counter enables the use of fast illumination
    reg [1:0] dis_cnt; //The display counter used to reach different states for the snakes, we have 21 states.

    // Clk counter for frequency divider
    always @(posedge clk or negedge rst_n)begin
        if (!rst_n)
        begin
            count <= 0;
        end
        else
        begin
            count <= count + 1;
        end
    end

    assign dis_clk = count[17];
    assign d_clk   = !btn_c ? count[23] : count[22];

    //Used to display different snake pattern
    always @(posedge d_clk or negedge rst_n)
    begin
        if (!rst_n)begin
            seg7_cnt <= 0;
        end
        else if ((seg7_cnt == 'd21) && (!sw))
        begin
            seg7_cnt <= 0;
        end
            else if ((seg7_cnt == 'd0) && sw)
            begin
            seg7_cnt <= 'd21;
            end
            else if (sw)
            begin
            seg7_cnt <= seg7_cnt - 'd1;
            end
        else
        begin
            seg7_cnt <= seg7_cnt + 'd1;
        end
    end

    // Output Contral,we must save the value into seg7_temp first, otherwise it would not be loaded
    always @(posedge d_clk or negedge rst_n)begin
        if (!rst_n)
        begin
            seg7_temp[0] <= 8'b0000_0001;
            seg7_temp[1] <= 8'b0000_0001;
            seg7_temp[2] <= 8'b0000_0001;
            seg7_temp[3] <= 8'b0000_0001;
        end
        else
        begin
            case(seg7_cnt)
                0:
                begin
                    seg7_temp[3] <= 8'b0000_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0001;
                end
                1:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0011;
                end
                2:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0100_0011;
                end
                3:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0100_0000; seg7_temp[0] <= 8'b0100_0011;
                end
                4:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0100_0000; seg7_temp[1] <= 8'b0100_0000; seg7_temp[0] <= 8'b0100_0010;
                end
                5:
                begin
                    seg7_temp[3] <= 8'b0100_0000;seg7_temp[2] <= 8'b0100_0000; seg7_temp[1] <= 8'b0100_0000; seg7_temp[0] <= 8'b0100_0100;
                end
                6:
                begin
                    seg7_temp[3] <= 8'b0110_0000;seg7_temp[2] <= 8'b0100_0000; seg7_temp[1] <= 8'b0100_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                7:
                begin
                    seg7_temp[3] <= 8'b0110_0001;seg7_temp[2] <= 8'b0100_0000; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                8:
                begin
                    seg7_temp[3] <= 8'b0110_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                9:
                begin
                    seg7_temp[3] <= 8'b0010_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0000;
                end
                10:
                begin
                    seg7_temp[3] <= 8'b0000_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0001;
                end
                11:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0011;
                end
                12:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0111;
                end
                13
                :begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_1111;
                end
                14:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0000_1000; seg7_temp[0] <= 8'b0000_0111;
                end
                15:
                begin
                    seg7_temp[3] <= 8'b0000_0000;seg7_temp[2] <= 8'b0000_1000; seg7_temp[1] <= 8'b0000_1000; seg7_temp[0] <= 8'b0000_1100;
                end
                16:
                begin
                    seg7_temp[3] <= 8'b0000_1000;seg7_temp[2] <= 8'b0000_1000; seg7_temp[1] <= 8'b0000_1000; seg7_temp[0] <= 8'b0000_1000;
                end
                17:
                begin
                    seg7_temp[3] <= 8'b0001_1000;seg7_temp[2] <= 8'b0000_1000; seg7_temp[1] <= 8'b0000_1000; seg7_temp[0] <= 8'b0000_0000;
                end
                18:
                begin
                    seg7_temp[3] <= 8'b0011_1000;seg7_temp[2] <= 8'b0000_1000; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                19:
                begin
                    seg7_temp[3] <= 8'b0011_1001;seg7_temp[2] <= 8'b0000_0000; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                20:
                begin
                    seg7_temp[3] <= 8'b0011_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0000; seg7_temp[0] <= 8'b0000_0000;
                end
                21:
                begin
                    seg7_temp[3] <= 8'b0010_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0000;
                end
                default:
                begin
                    seg7_temp[3] <= 8'b0010_0001;seg7_temp[2] <= 8'b0000_0001; seg7_temp[1] <= 8'b0000_0001; seg7_temp[0] <= 8'b0000_0000;
                end
            endcase
        end
    end

    // Display used to display the seg7 with fast illumination
    always @(posedge dis_clk or negedge rst_n)begin
        if (!rst_n)
        begin
            dis_cnt <= 0;
        end
        else
        begin
            if (dis_cnt == 'd4)
                dis_cnt <= 0;
            else
                dis_cnt <= dis_cnt + 1;
        end
    end

    always @(posedge dis_clk or negedge rst_n)begin
        if (!rst_n)
        begin
            seg7_sel <= 4'b1111;
            seg7     <= 8'b0000_0001;
        end
        else
        begin
            case(dis_cnt)
                0:seg7_sel <= 4'b0001;
                1:seg7_sel <= 4'b0010;
                2:seg7_sel <= 4'b0100;
                3:seg7_sel <= 4'b1000;
            endcase
            seg7 <= seg7_temp[dis_cnt];
        end
    end

endmodule
