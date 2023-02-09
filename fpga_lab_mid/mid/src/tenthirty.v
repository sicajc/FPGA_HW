module tenthirty(
           input clk,
           input rst_n, //negedge reset
           input btn_m, //bottom middle
           input btn_r, //bottom right
           output reg [7:0] seg7_sel,
           output reg [7:0] seg7,   //segment right
           output reg [7:0] seg7_l, //segment left
           output reg [2:0] led // led[0] : dealer win, led[1] : player win, led[2] : done
       );

//================================================================
//   PARAMETER
//================================================================
localparam  IDLE            = 4'd0 ;
localparam  DEAL            = 4'd1 ;
localparam  DRAW            = 4'd2 ;
localparam  SHOW_DOWN       = 4'd3 ;
localparam  WAIT_NEXT_ROUND = 4'd4 ;
localparam  WAIT_LUT        = 4'd5 ;
localparam  EXCEPTIONS      = 4'd6 ;

localparam  PLAYERS_TURN    = 1'b0;
localparam  HOUSE_TURN      = 1'b0;

localparam  PLAYER_WIN      = 1'b1;
localparam  HOUSE_WIN       = 1'b0;


//7-Segment display Signals
localparam SEG_RESET = 8'b1111_1111;
localparam SEG_ONE   = 8'b0000_0110;
localparam SEG_TWO   = 8'b0001_1011;
localparam SEG_THREE = 8'b0000_1111 ;
localparam SEG_FOUR  = 8'b0110_0110;
localparam SEG_FIVE  = 8'b0110_1101;
localparam SEG_SIX   = 8'b0111_1101;
localparam SEG_SEVEN = 8'b0010_0111 ;
localparam SEG_EIGHT = 8'b0111_1111 ;
localparam SEG_NINE  = 8'b0110_1111;
localparam SEG_TEN  = 8'b0011_1111;
localparam SEG_HALF_POINT     = 8'b1111_0111;


localparam LED_PLAYER_WINS = 16'b0000_0010_0000_0000;
localparam LED_HOUSE_WINS  = 16'b0000_0001_0000_0000;
localparam LED_DONE        = 16'b0000_0100_0000_0000;

localparam HALF_POINT_VALUE = 5'b00001;


//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter;
wire dis_clk; //seg display clk, frequency faster than d_clk
wire d_clk  ; //division clk

//====== frequency division ======
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        counter <= 0;
    end
    else
    begin
        counter <= counter + 1;
    end
end

//================================================================
//   REG/WIRE
//================================================================
//store segment display situation
reg [7:0] seg7_temp[0:7];
//display counter
reg [2:0] dis_cnt;
//LUT IO
reg  pip;
wire [3:0] number;
//State registers
reg[3:0] currentState;
reg[3:0] nextState;

reg[1:0] gameResultState;
reg[1:0] gameResultState_next;

reg[1:0] turnState_cur;
reg[1:0] turnState_next;

reg[3:0] playerCards_rf[0:4];
reg[3:0] houseCards_rf[0:4];

reg[7:0] playerPoints_ff;
reg[7:0] housePoints_ff;

reg[4:0] currentCard_cnt;

reg[4:0] card_value;// zero-th bit used to store half point.

//================================================================
//   CONTROL SIGNALS
//================================================================
wire state_IDLE            =  currentState == IDLE              ;
wire state_DEAL            =  currentState == DEAL              ;
wire state_DRAW            =  currentState == DRAW              ;
wire state_SHOW_DOWN       =  currentState == SHOW_DOWN         ;
wire state_WAIT_NEXT_ROUND =  currentState == WAIT_NEXT_ROUND   ;
wire state_WAIT_LUT        =  currentState == WAIT_LUT          ;
wire state_EXCEPTIONS      =  currentState == EXCEPTIONS        ;

wire state_PLAYERS_TURN    =  turnState_cur == PLAYERS_TURN      ;
wire state_HOUSE_TURN      =  turnState_cur == HOUSE_TURN        ;

wire state_PLAYER_WIN      =  gameResultState == PLAYER_WIN        ;
wire state_HOUSE_WIN       =  gameResultState == HOUSE_WIN         ;


wire Start_game         ;
wire Deal_Cards         ;
wire Finish_dealing_First_card;
wire Busted;
wire DrawCards;
wire RoundEnds;
wire GameEnds ;
wire Finish_drawing;

//================================================================
//   FSM
//================================================================
// Main FSM
always @(posedge d_clk or negedge rst_n )
begin
    if(~rst_n)
    begin
        currentState <= IDLE;
    end
    else
    begin
        currentState <= nextState;
    end
end

always @(*)
begin
    case(currentState)
        IDLE:
        begin
            nextState  = Start_game ? DEAL : IDLE;
        end
        DEAL:
        begin
            nextState  = Deal_Cards ? (Finish_dealing_First_card ? PLAYER_DRAW : WAIT_LUT) : DEAL;
        end
        DRAW:
        begin
            if(DrawCards)
            begin
                if(state_HOUSE_TURN)
                begin
                    nextState = Busted ? WAIT_NEXT_ROUND : (Finish_drawing ? SHOW_DOWN : WAIT_LUT )
                    end
                else if (state_PLAYERS_TURN)
                begin
                    nextState = Busted ? WAIT_NEXT_ROUND : (Finish_drawing ? DRAW : WAIT_LUT );
                end
                else
                begin
                    nextState = DRAW;
                end
            end
            else
            begin
                nextState = DRAW;
            end
        end
        WAIT_LUT:
        begin
            nextState  = DEAL;
        end
        SHOW_DOWN:
        begin
            nextState = RoundEnds ? WAIT_NEXT_ROUND : SHOW_DOWN;
        end
        WAIT_NEXT_ROUND:
        begin
            nextState = GameEnds ? DONE : IDLE;
        end
        default:
        begin
            nextState = EXCEPTIONS;
        end
    endcase
end

//Deciding whose turn
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        turnState_cur <= PLAYER_DRAW;
    end
    else
    begin
        turnState_cur <= turnState_next;
    end
end

always @(*)
begin
    if(Finish_drawing)
    begin
        turnState_next = HOUSE_TURN;
    end
    else
    begin
        turnState_next = turnState_cur;
    end

end

//Game Final result
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        gameResultState <= HOUSE_WIN;
    end
    else
    begin
        gameResultState <= gameResultState_next;
    end
end

always @(*)
begin
    if(state_PLAYERS_TURN && state_DRAW)
    begin
        gameResultState_next = Busted ? HOUSE_WIN  : gameResultState;
    end
    else if(state_HOUSE_TURN && state_DRAW)
    begin
        gameResultState_next = Busted ? PLAYER_WIN : gameResultState;
    end
    else if(state_SHOW_DOWN)
    begin
        gameResultState_next = (housePoints_ff >= playerPoints_ff) ? HOUSE_WIN : PLAYER_WIN;
    end
end


//================================================================
//   DESIGN
//================================================================
integer i;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        currentCard_cnt <= 'd0;
    end
    else if(turnState_cur != turnState_next)
    begin
        currentCard_cnt <= 'd0;
    end
    else if(state_WAIT_LUT)
    begin
        currentCard_cnt <= currentCard_cnt + 1;
    end
    else
    begin
        currentCard_cnt <= currentCard_cnt;
    end
end

always @(posedge clk or negedge rst_n)
begin: House_Cards
    if(~rst_n)
    begin
        for(i=0;i<5;i=i+1)
        begin
            houseCards_rf[i] <= 'd0;
        end
    end
    else if(state_WAIT_LUT && state_HOUSE_TURN)
    begin
        houseCards_rf[currentCard_cnt] <= number;
    end
    else
    begin
        for(i=0;i<5;i=i+1)
        begin
            houseCards_rf[i] <= houseCards_rf[i];
        end
    end
end

always @(posedge clk or negedge rst_n)
begin: Player_Cards
    if(~rst_n)
    begin
        for(i=0;i<5;i=i+1)
        begin
            playerCards_rf[i] <= 'd0;
        end
    end
    else if(state_WAIT_LUT && state_PLAYERS_TURN)
    begin
        playerCards_rf[currentCard_cnt] <= number;
    end
    else
    begin
        for(i=0;i<5;i=i+1)
        begin
            playerCards_rf[i] <= playerCards_rf[i];
        end
    end
end

always @(posedge clk or negedge rst_n)
begin: PlayerPoint
    if(~rst_n)
    begin
        playerPoints_ff <= 'd0;
    end
    else if(state_WAIT_LUT && state_PLAYERS_TURN)
    begin
        playerPoints_ff <= playerPoints_ff + card_value;
    end
    else if(state_WAIT_NEXT_ROUND && RoundEnds)
    begin
        playerPoints_ff <= 'd0;
    end
    else
    begin
        playerPoints_ff <= playerPoints_ff;
    end
end

always @(posedge clk or rst_n)
begin: HousePoints
    if(~rst_n)
    begin
        housePoints_ff <= 'd0;
    end
    else if(state_WAIT_LUT && state_HOUSE_TURN)
    begin
        housePoints_ff <= housePoints_ff + card_value;
    end
    else if(state_WAIT_NEXT_ROUND && RoundEnds)
    begin
        housePoints_ff <= 'd0;
    end
    else
    begin
        housePoints_ff <= housePoints_ff;
    end
end

always @(*)
begin
    case(number)
        J,Q,K:
        begin
            card_value = HALF_POINT_VALUE;
        end
        default:
        begin
            card_value = {number,1'b0};
        end
    endcase
end
//seg7_temp
/*
Please write your design here.
*/

//================================================================
//   SEGMENT
//================================================================

//display counter
always@(posedge dis_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        dis_cnt <= 0;
    end
    else
    begin
        dis_cnt <= (dis_cnt >= 7) ? 0 : (dis_cnt + 1);
    end
end

always @(posedge dis_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        seg7 <= 8'b0000_0001;
    end
    else
    begin
        if(!dis_cnt[2])
        begin
            seg7 <= seg7_temp[dis_cnt];
        end
    end
end

always @(posedge dis_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        seg7_l <= 8'b0000_0001;
    end
    else
    begin
        if(dis_cnt[2])
        begin
            seg7_l <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        seg7_sel <= 8'b11111111;
    end
    else
    begin
        case(dis_cnt)
            0 :
                seg7_sel <= 8'b00000001;
            1 :
                seg7_sel <= 8'b00000010;
            2 :
                seg7_sel <= 8'b00000100;
            3 :
                seg7_sel <= 8'b00001000;
            4 :
                seg7_sel <= 8'b00010000;
            5 :
                seg7_sel <= 8'b00100000;
            6 :
                seg7_sel <= 8'b01000000;
            7 :
                seg7_sel <= 8'b10000000;
            default :
                seg7_sel <= 8'b11111111;
        endcase
    end
end

//================================================================
//   LED
//================================================================

//================================================================
//   LUT
//================================================================

LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));


endmodule
