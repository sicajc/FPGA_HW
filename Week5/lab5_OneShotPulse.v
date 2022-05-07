`define CYCLE 140000

module lab5(
	input clk,
	input rst_n,
	input btn_u,
	input btn_lw,
	input btn_lft,
	input btn_ri,
	output reg [7:0] seg7,
	output reg [3:0] seg7_sel
);
	//Add input buttons for more input options, then we can change the constraint file so that the button would be binded to these inputs
	reg [20:0] count;
	wire d_clk;

	// reg btn_c_press_flag; //????
	reg btn_u_press_flag;
	reg btn_lw_press_flag;
	reg btn_lft_press_flag;
	reg btn_ri_press_flag;

	// wire btn_c_pulse; // ?桐???
	wire btn_u_pulse;
	wire btn_lw_pulse;
	wire btn_lft_pulse;
	wire btn_ri_pulse;


	reg signed[8:0] total_value; //Used to store the total value so far, remember we must put the value into seg7 temp before we want to display them
	//reg [7:0] press_count; //??甈⊥閮??

	reg signed [7:0] seg7_temp[0:3]; //Used to store the value for seg7 to display
	reg [1:0] seg7_count; // Used to display seg7 in a fast speed.

	parameter MINUS = 10 ;

	// ?日
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			count <= 0;
		end
		else begin
			if(count >= `CYCLE)
				count <= 0;
			else
				count <= count + 1;
		end
	end
	assign d_clk = count >= (`CYCLE/2) ? 1 : 0;  // ??銝挾憿舐內?函???

	// 頧 ?銝????One pulse shot generator for btns
	always @(posedge clk or negedge rst_n)begin
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

	// 閮????活??
	// always @(posedge clk or negedge rst_n)begin
	// 	if(!rst_n)begin
	// 		press_count <= 0;
	// 	end
	// 	else begin
	// 		if(btn_c_pulse)
	// 			press_count <= press_count + 1;
	// 		else
	// 			press_count <= press_count;
	// 	end
	// end

	//Calulate the total value added so far
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			total_value <= 0;
		end
		else
		begin
			if(btn_u_pulse)
				total_value <= total_value + 'd10;
			else if(btn_lw_pulse)
				total_value <= total_value - 'd10;
			else if(btn_ri_pulse)
				total_value <= total_value + 'd1;
			else if(btn_lft_pulse)
				total_value <= total_value - 'd1;
			else
				total_value <= total_value;
		end
	end

	// 撠?憯活?貉??詨頧?脖?
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_temp[0] <= 0;
			seg7_temp[1] <= 0;
			seg7_temp[2] <= 0;
			seg7_temp[3] <= 0;
		end
		else if(total_value >= 0)
		begin
			seg7_temp[3] <= total_value / 1000;
			seg7_temp[2] <= ( total_value % 1000) / 100;
			seg7_temp[1] <= ( total_value % 100) / 10;
			seg7_temp[0] <= total_value % 10;
		end
		else
		begin
			seg7_temp[3] <= MINUS;
			seg7_temp[2] <= (total_value % 1000) / 100;
			seg7_temp[1] <= (total_value % 100) / 10;
			seg7_temp[0] <= total_value % 10;
		end
	end

	//憿舐內?潔?畾菟＊蝷箏
	always @(posedge d_clk or negedge rst_n)begin
		if(!rst_n)begin
			seg7_count <= 0;
		end
		else begin
			seg7_count <= seg7_count + 1;
		end
	end
	always @(posedge d_clk or negedge rst_n)begin
		if(!rst_n)
		begin
			seg7_sel <= 4'b1111;
			seg7 <= 8'b0011_1111;
		end
		else begin
			case(seg7_count)
				0:	seg7_sel <= 4'b0001;
				1:	seg7_sel <= 4'b0010;
				2:	seg7_sel <= 4'b0100;
				3:	seg7_sel <= 4'b1000;
			endcase
			case(seg7_temp[seg7_count])
				0:seg7 <= 8'b0011_1111;
                1:seg7 <= 8'b0000_0110;
                2:seg7 <= 8'b0101_1011;
                3:seg7 <= 8'b0100_1111;
                4:seg7 <= 8'b0110_0110;
                5:seg7 <= 8'b0110_1101;
                6:seg7 <= 8'b0111_1101;
                7:seg7 <= 8'b0000_0111;
                8:seg7 <= 8'b0111_1111;
                9:seg7 <= 8'b0110_1111;
				MINUS: seg7 <= 8'b0100_0000;
			endcase
		end
	end

endmodule