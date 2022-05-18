module VGA(
           input 				rst_n,
           input          		clk,      // 100 MHz
           input 				btn_c,
           output         		VGA_HS,        // Horizontal synchronize signal
           output         		VGA_VS,        // Vertical synchronize signal
           output		[3:0]	VGA_R,	// Signal RED
           output		[3:0]	VGA_G,	// Signal Green
           output		[3:0]	VGA_B	// Signal Blue
       );
// Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

// Vertical Parameter
parameter V_FRONT = 10;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_ACT   = 480;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

wire 		clk_25;		// 25MHz clk
reg [1:0]	count;

reg [9:0] 	H_cnt;
reg [9:0] 	V_cnt;
reg       	vga_hs;		// register for horizontal synchronize signal
reg       	vga_vs;		// register for vertical synchronize signal
reg [9:0] 	X;			// from 1~640
reg [8:0] 	Y;			// from 1~480

assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

reg [11:0]	VGA_RGB;

// ���W   100 MHz -> 25MHz
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end
assign clk_25 = count[1];

// Horizontal counter
always@(posedge clk_25, negedge rst_n)
begin // count 0~800
    H_cnt <= (!rst_n)? H_TOTAL : (H_cnt < H_TOTAL)?  H_cnt+1'b1 : 10'd0;
end
// vertical counter
always@(posedge VGA_HS, negedge rst_n)
begin // count 0~525
    V_cnt <= (!rst_n)? V_TOTAL : (V_cnt < V_TOTAL)?  V_cnt+1'b1 : 10'd0;
end
// Horizontal Generator: Refer to the pixel clock
always@(posedge clk_25, negedge rst_n)
begin
    if(!rst_n)
    begin
        vga_hs <= 1;
        X      <= 0;
    end
    else
    begin
        // Horizontal Sync
        if( H_cnt <= H_SYNC ) //Sync pulse start
            vga_hs <= 1'b0;// horizontal synchronize pulse
        else
            vga_hs <= 1'b1;
        // Current X
        if( H_cnt >= (H_SYNC + H_BACK) && H_cnt <= (H_ACT + H_SYNC + H_BACK) )
            X <= (X + 1);
        else
            X <= 0;
    end
end
// Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS, negedge rst_n)
begin
    if(!rst_n)
    begin
        vga_vs <= 1;
        Y      <= 0;
    end
    else
    begin
        // Vertical Sync
        if ( V_cnt <= V_SYNC ) //Sync pulse start
            vga_vs <= 0;
        else
            vga_vs <= 1;
        // Current Y
        if( V_cnt >= V_SYNC + V_BACK && V_cnt <= V_SYNC + V_BACK + V_ACT )
            Y <= (Y + 1);
        else
            Y <= 0;
    end
end

//House and btn_c
always@(*)
begin
    if(btn_c)
    begin
        // if( (X >= 1) && (X <= 80) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'h000;
        // else if( (X >= 81) && (X <= 160) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'h00f;
        // else if( (X >= 161) && (X <= 240) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'h0f0;
        // else if( (X >= 241) && (X <= 320) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'h0ff;
        // else if( (X >= 321) && (X <= 400) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'hf00;
        // else if( (X >= 401) && (X <= 480) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'hf0f;
        // else if( (X >= 481) && (X <= 560) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'hff0;
        // else if( (X >= 561) && (X <= 640) && (Y > 0) && (Y <= 480) )
        //     VGA_RGB = 12'hfff;
        if( ( (X-340)*(X-340) + (Y-400)*(Y-400) ) <=64 )
            VGA_RGB = 12'h100;
        else if( (X >= 270) && (X <= 370) && (Y > 320) && (Y <= 480) )
            VGA_RGB = 12'h110;
        else if( (X >= 220) && (X <= 420) && (Y > 200) && (Y <= 480) )
            VGA_RGB = 12'h001;
        else if( (X >= 220) && (X <= 320) && (Y >= -2*X + 640 ) )
            VGA_RGB = 12'h010;
        else if( (X >= 320) && (X <= 420) && (Y >=  2*X - 640) )
            VGA_RGB = 12'h010;
        else
            VGA_RGB = 12'h000;
    end
    else
    begin //Student ID
        begin
            if( (X >=10) && (X <=210) && (Y >=10) && (Y<=60))
                VGA_RGB = 12'hff0;
            else if( (X >=10) && (X <=60) && (Y >=60) && (Y<=420))
                VGA_RGB = 12'hff0;
            else if( (X >=160) && (X <=210) && (Y >=60) && (Y<=420))
                VGA_RGB = 12'hff0;
            else if( (X >=10) && (X <=210) && (Y >=420) && (Y<=470))
                VGA_RGB = 12'hff0;
            else if( (X >=220) && (X <=320) && (Y >=10) && (Y<=470))
                VGA_RGB = 12'h0ff;
            else if( (X >=430) && (X <=630) && (Y >=10) && (Y<=60))
                VGA_RGB = 12'hf0f;
            else if( (X >=480) && (X <=580) && (Y >=215) && (Y<=265))
                VGA_RGB = 12'hf0f;
            else if( (X >=430) && (X <=630) && (Y >=420) && (Y<=470))
                VGA_RGB = 12'hf0f;
            else if( (X >=430) && (X <=480)&& (Y >=60) && (Y<=420))
                VGA_RGB = 12'hf0f;
            else if( (X >=580) && (X <=630) && (Y >=60) && (Y<=470))
                VGA_RGB = 12'hf0f;
            else
                VGA_RGB = 12'h000;
        end
    end
end

assign VGA_R = VGA_RGB[11:8];
assign VGA_G = VGA_RGB[7:4];
assign VGA_B = VGA_RGB[3:0];

endmodule
