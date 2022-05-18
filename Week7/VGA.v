`define CYCLE 140000
module VGA(
           input rst_n,
           input clk,    //100MHz
           input btn_u,
           input btn_lw,
           input btn_lft,
           input btn_ri,
           output VGA_HS,    //Horizontal synchronize signal
           output VGA_VS,    //Vertical synchronize signal
           output [3:0] VGA_R,    //Signal RED
           output [3:0] VGA_G,    //Signal Green
           output [3:0] VGA_B     //Signal Blue
       );
//PIXEL_WIDTH
parameter PIXEL_WIDTH= 40 ;

//Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

//Vertical Parameter
parameter V_FRONT = 10;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_ACT   = 480;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

//SNAKE STATES
parameter UP = 'd0 ;
parameter DOWN = 'd1 ;
parameter RIGHT = 'd2 ;
parameter LEFT =  'd3;


//Add input buttons for more input options, then we can change the constraint file so that the button would be binded to these inputs
reg [20:0] count;
reg[1:0] count_vga;
wire d_clk;

// reg btn_c_press_flag; //按壓旗號
reg btn_u_press_flag;
reg btn_lw_press_flag;
reg btn_lft_press_flag;
reg btn_ri_press_flag;

// wire btn_c_pulse; // 單一脈衝
wire btn_u_pulse;
wire btn_lw_pulse;
wire btn_lft_pulse;
wire btn_ri_pulse;

//state registers
reg[2:0] current_state,next_state;

wire clk_25;    //25MHz clk


reg [9:0] H_cnt;
reg [9:0] V_cnt;
reg vga_hs;    //register for horizontal synchronize signal
reg vga_vs;    //register for vertical synchronize signal
reg [9:0] X;    //from 1~640
reg [8:0] Y;    //from 1~480

assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

reg [11:0] VGA_RGB;

assign VGA_R = VGA_RGB[11:8];
assign VGA_G = VGA_RGB[7:4];
assign VGA_B = VGA_RGB[3:0];

//100MHz -> 25MHz
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        count_vga <= 0;
    else
        count_vga <= count_vga + 1;
end
assign clk_25 = count[1];

//Horizontal counter
always@(posedge clk_25 or negedge rst_n)
begin    //count 0~800
    H_cnt <= (!rst_n)? H_TOTAL : (H_cnt < H_TOTAL)?  H_cnt+1'b1 : 10'd0;
end

//Vertical counter
always@(posedge VGA_HS or negedge rst_n)
begin    //count 0~525
    V_cnt <= (!rst_n)? V_TOTAL : (V_cnt < V_TOTAL)?  V_cnt+1'b1 : 10'd0;
end

//Horizontal Generator: Refer to the pixel clock
always@(posedge clk_25 or negedge rst_n)
begin
    if(!rst_n)
    begin
        vga_hs <= 1;
        X      <= 0;
    end
    else
    begin
        //Horizontal Sync
        if(H_cnt<=H_SYNC)    //Sync pulse start
            vga_hs <= 1'b0;    //horizontal synchronize pulse
        else
            vga_hs <= 1'b1;
        //Current X
        if( (H_cnt>=H_SYNC+H_BACK) && (H_cnt<=H_TOTAL-H_FRONT) )
            X <= X + 1;
        else
            X <= 0;
    end
end

//Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS or negedge rst_n)
begin
    if(!rst_n)
    begin
        vga_vs <= 1;
        Y      <= 0;
    end
    else
    begin
        //Vertical Sync
        if (V_cnt<=V_SYNC)    //Sync pulse start
            vga_vs <= 0;
        else
            vga_vs <= 1;
        //Current Y
        if( (V_cnt>=V_SYNC+V_BACK) && (V_cnt<=V_TOTAL-V_FRONT) )
            Y <= Y + 1;
        else
            Y <= 0;
    end
end


// 除頻
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        count <= 0;
    end
    else
    begin
        count <= count + 1;
    end
end

assign d_clk = count[19];
assign snake_clk = count[20];


// 轉為 「單一脈衝」 One pulse shot generator for btns
always @(posedge d_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        // btn_c_press_flag <= 0;
        btn_u_press_flag <= 0;
        btn_lw_press_flag <= 0;
        btn_lft_press_flag <= 0;
        btn_ri_press_flag <= 0;
    end
    else
    begin
        // btn_c_press_flag <= btn_c;
        btn_u_press_flag <= btn_u;
        btn_lw_press_flag <= btn_lw;
        btn_lft_press_flag <= btn_lft;
        btn_ri_press_flag <= btn_ri;
    end
end

// assign btn_c_pulse = {btn_c,btn_c_press_flag} == 2'b10 ? 1 : 0;
assign btn_u_pulse = {btn_u,btn_u_press_flag} == 2'b10 ? 1 : 0;
assign btn_lw_pulse = {btn_lw,btn_lw_press_flag} == 2'b10 ? 1 : 0;
assign btn_lft_pulse = {btn_lft,btn_lft_press_flag} == 2'b10 ? 1 : 0;
assign btn_ri_pulse = {btn_ri,btn_ri_press_flag} == 2'b10 ? 1 : 0;

reg[4:0] apple_reg [0:1];
reg[4:0] snake_pos_reg [0:4][0:1];
reg[3:0] snake_length_reg;

//SNAKE MAIN CTR
always @(posedge snake_clk or negedge rst_n)
begin
    current_state <= !rst_n ? UP : next_state;
end

always @(*)
begin
    case(current_state)
        UP:
        begin
            case({btn_u_pulse,btn_lw_pulse,btn_lft_pulse,btn_ri_pulse})
                4'b0010:
                begin
                    next_state = LEFT;
                end
                4'b0001:
                begin
                    next_state = RIGHT;
                end
                default:
                begin
                    next_state = UP;
                end
            endcase
        end
        DOWN:
        begin
            case({btn_u_pulse,btn_lw_pulse,btn_lft_pulse,btn_ri_pulse})
                4'b0010:
                begin
                    next_state = LEFT;
                end
                4'b0001:
                begin
                    next_state = RIGHT;
                end
                default:
                begin
                    next_state = DOWN;
                end
            endcase
        end
        RIGHT:
        begin
            case({btn_u_pulse,btn_lw_pulse,btn_lft_pulse,btn_ri_pulse})
                4'b1000:
                begin
                    next_state = UP;
                end
                4'b0100:
                begin
                    next_state = DOWN;
                end
                default:
                begin
                    next_state = RIGHT;
                end
            endcase
        end
        LEFT:
        begin
            case({btn_u_pulse,btn_lw_pulse,btn_lft_pulse,btn_ri_pulse})
                4'b1000:
                begin
                    next_state = UP;
                end
                4'b0100:
                begin
                    next_state = DOWN;
                end
                default:
                begin
                    next_state = LEFT;
                end

            endcase
        end
        default:
        begin
            next_state = current_state;
        end
    endcase
end

//snake_length_reg
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        snake_length_reg <= 'd0;
    end
    else
    begin // if we got the apple, length ++




    end
end

//snake_pos_reg
integer  i;
integer  j;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin//(x,y)
        {snake_pos_reg[0][1],snake_pos_reg[0][0]} <={5'd5 ,5'd5 };
        {snake_pos_reg[1][1],snake_pos_reg[1][0]} <={5'd5 ,5'd6 };
        {snake_pos_reg[2][1],snake_pos_reg[2][0]} <={5'd5 ,5'd7 };
        {snake_pos_reg[3][1],snake_pos_reg[3][0]} <={5'd5 ,5'd8 };
        {snake_pos_reg[4][1],snake_pos_reg[4][0]} <={5'd5 ,5'd9 };
    end
    else
    begin
        case(current_state)





        endcase
    end
end



//VGA DISPLAY
always@(*)
begin
    if( (X >= 1) && (X <= 80) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'h000;
    else if( (X >= 81) && (X <= 160) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'h00f;
    else if( (X >= 161) && (X <= 240) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'h0f0;
    else if( (X >= 241) && (X <= 320) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'h0ff;
    else if( (X >= 321) && (X <= 400) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'hf00;
    else if( (X >= 401) && (X <= 480) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'hf0f;
    else if( (X >= 481) && (X <= 560) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'hff0;
    else if( (X >= 561) && (X <= 640) && (Y > 0) && (Y <= 480) )
        VGA_RGB = 12'hfff;
    else
        VGA_RGB = 12'h000;
end

endmodule
