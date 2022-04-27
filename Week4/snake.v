module snake(input clk,
             input rst_n,
             input sw,
             input btn_c,
             output [2:0] seg7_sel,
             output [7:0] seg7);

    //Parameters
    parameter S0  = 'd0;
    parameter S1  = 'd1;
    parameter S2  = 'd2;
    parameter S3  = 'd3;
    parameter S4  = 'd4;
    parameter S5  = 'd5;
    parameter S6  = 'd6;
    parameter S7  = 'd7;
    parameter S8  = 'd8;
    parameter S9  = 'd9;
    parameter S10 = 'd10;
    parameter S11 = 'd11;
    parameter S12 = 'd12;
    parameter S13 = 'd13;
    parameter S14 = 'd14;
    parameter S15 = 'd15;
    parameter S16 = 'd16;
    parameter S17 = 'd17;
    parameter S18 = 'd18;
    parameter S19 = 'd19;
    parameter S20 = 'd20;
    parameter S21 = 'd21;
    parameter S22 = 'd22;
    parameter S23 = 'd23;

    // ==  ==  == Register ==  ==  ==
    reg [7:0] seg7;
    reg [3:0] seg7_cnt; //4 bits
    reg [24:0] count;
    reg [2:0] seg7_sel;
    reg [3:0] seg7_temp;
    reg [4:0] state_counter;

    wire d_clk;


    wire max_state_count_reach_flag = state_counter == 'd21 & !sw ;
    wire min_state_count_reach_flag = state_counter == 'd0 & sw ;
    wire seg7_cnt_zero_flag   = seg7_cnt == 'd0;

    // ==  ==  == frequency division ==  ==  ==
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count <= 0;
        else if (btn_c)
            count <= count + 1;
        else
            count <= count + 2;
    end

    assign d_clk = count[24] & count[23]; //enables slower movements , frequency would become lower
    assign d_clk_seg7_cnt = count[23];

    // ==  ==  == STATE COUNTER ==  ==  == //
    always @(posedge d_clk or negedge rst_n)begin
        if (!rst_n)                 //We have 21 states to enumerate
            state_counter <= 'd0;
        else if (max_state_count_reach_flag)
            state_counter <= 'd0;
        else if (min_state_count_reach_flag)
            state_counter <= 'd21;
        else if (sw)
            state_counter <= state_counter - 'd1;
        else
            state_counter <= state_counter + 'd1;
    end

    // ==  ==  == SEVEN segment display light control ==  ==  ==
    always @(posedge d_clk_seg7_cnt or negedge rst_n)begin
        if (!rst_n)                 //We have 4 displayer needs to control thus set to 4
            seg7_cnt <= 'd4;
        else if (seg7_cnt_zero_flag)
            seg7_cnt <= 'd4;
        else
            seg7_cnt <= seg7_cnt - 'd1;
    end

    always @(posedge d_clk or negedge rst_n)begin
        if (!rst_n)
        begin
            seg7_sel <= 0;
            seg7     <= 0;
        end
        else
        begin
            case(state_counter)
                S0:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b0100;
                        2:	seg7_sel <= 4'b0010;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S1:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0100;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0001;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0010;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S2:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0010;
                        1:	seg7_sel <= 4'b0001;
                        2:	seg7_sel <= 4'b0001;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0010;
                        3:seg7 <= 8'b0100_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S3:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0001;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0100;
                        3:	seg7_sel <= 4'b1000;

                        0:seg7 <= 8'b0011_1111;
                        1:seg7 <= 8'b0000_0110;
                        2:seg7 <= 8'b0101_1011;
                        3:seg7 <= 8'b0100_1111;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end

                S4:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0100;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0001;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0100_0000;
                        1:seg7 <= 8'b0100_0000;
                        2:seg7 <= 8'b0000_0010;
                        3:seg7 <= 8'b0100_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end

                S5:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b0100;
                        2:	seg7_sel <= 4'b0010;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0100_0000;
                        1:seg7 <= 8'b0100_0000;
                        2:seg7 <= 8'b0100_0000;
                        3:seg7 <= 8'b0100_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S6:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b1000;
                        2:	seg7_sel <= 4'b0100;
                        3:	seg7_sel <= 4'b0010;

                        0:seg7 <= 8'b0010_0000;
                        1:seg7 <= 8'b0100_0000;
                        2:seg7 <= 8'b0100_0000;
                        3:seg7 <= 8'b0100_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end

                S7:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b1000;
                        2:	seg7_sel <= 4'b1000;
                        3:	seg7_sel <= 4'b0100;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0010_0000;
                        2:seg7 <= 8'b0100_0000;
                        3:seg7 <= 8'b0100_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S8:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b1000;
                        2:	seg7_sel <= 4'b1000;
                        3:	seg7_sel <= 4'b0100;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0010_0000;
                        2:seg7 <= 8'b0100_0000;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S9:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0001;
                        1:	seg7_sel <= 4'b0001;
                        2:	seg7_sel <= 4'b0010;
                        3:	seg7_sel <= 4'b0100;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0010_0000;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S10:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b0100;
                        2:	seg7_sel <= 4'b0010;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S11:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0100;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0001;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0010;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S12:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0100;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0001;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0010;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S13:
                begin
                    case(seg7_cnt)
                        0,1,2,3: seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0010;
                        2:seg7 <= 8'b0000_0100;
                        3:seg7 <= 8'b0000_1000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S14:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel     <= 4'b0010;
                        1,2,3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_1000;
                        1:seg7 <= 8'b0000_0010;
                        2:seg7 <= 8'b0000_0100;
                        3:seg7 <= 8'b0000_1000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S15:
                begin
                    case(seg7_cnt)
                        0,1:	seg7_sel <= 4'b0001;
                        2:	seg7_sel   <= 4'b0010;
                        3:	seg7_sel   <= 4'b0100;

                        0:seg7 <= 8'b0000_0100;
                        1:seg7 <= 8'b0000_1000;
                        2:seg7 <= 8'b0000_1000;
                        3:seg7 <= 8'b0000_1000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S16:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b0001;
                        1:	seg7_sel <= 4'b0010;
                        2:	seg7_sel <= 4'b0100;
                        3:	seg7_sel <= 4'b1000;

                        0,1,2,3: seg7 <= 8'b0000_1000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S17:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel   <= 4'b0100;
                        1:	seg7_sel   <= 4'b0010;
                        2,3:	seg7_sel <= 4'b1000;

                        0:seg7 <= 8'b0000_1000;
                        1:seg7 <= 8'b0000_1000;
                        2:seg7 <= 8'b0000_1000;
                        3:seg7 <= 8'b0001_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S18:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel     <= 4'b0100;
                        1,2,3:	seg7_sel <= 4'b1000;

                        0:seg7 <= 8'b0000_1000;
                        1:seg7 <= 8'b0000_1000;
                        2:seg7 <= 8'b0001_0000;
                        3:seg7 <= 8'b0010_0000;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S19:
                begin
                    case(seg7_cnt)
                        0,1,2,3:	seg7_sel <= 4'b1000;

                        0:seg7 <= 8'b0000_1000;
                        1:seg7 <= 8'b0001_0000;
                        2:seg7 <= 8'b0010_0000;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S20:
                begin
                    case(seg7_cnt)
                        0,1,2:	seg7_sel <= 4'b1000;
                        3:	seg7_sel     <= 4'b0100;

                        0:seg7 <= 8'b0001_0000;
                        1:seg7 <= 8'b0010_0000;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                S21:
                begin
                    case(seg7_cnt)
                        0,1:	seg7_sel <= 4'b1000;
                        2:	seg7_sel   <= 4'b0100;
                        3:	seg7_sel   <= 4'b0010;

                        0:seg7 <= 8'b0010_0000;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
                default:
                begin
                    case(seg7_cnt)
                        0:	seg7_sel <= 4'b1000;
                        1:	seg7_sel <= 4'b0100;
                        2:	seg7_sel <= 4'b0010;
                        3:	seg7_sel <= 4'b0001;

                        0:seg7 <= 8'b0000_0001;
                        1:seg7 <= 8'b0000_0001;
                        2:seg7 <= 8'b0000_0001;
                        3:seg7 <= 8'b0000_0001;
                        default:
                        begin
                            seg7     <= 8'b1111_1111;
                            seg7_sel <= 4'b1000;
                        end
                    endcase
                end
            endcase
        end
    end


endmodule
