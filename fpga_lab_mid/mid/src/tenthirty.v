module tenthirty(
           input clk, // FPGA Clock
           input rst_n, //negedge reset
           input btn_m, //bottom middle
           input btn_r, //bottom right
           output reg [7:0] seg7_sel,
           output reg [7:0] seg7,   //segment right
           output reg [7:0] seg7_l, //segment left
           output reg [2:0] led // led[0] : player win, led[1] : dealer win, led[2] : done
       );

//================================================================
//   PARAMETER
//================================================================
localparam  IDLE                    = 4'd0 ;
localparam  DEAL                    = 4'd1 ;
localparam  DRAW                    = 4'd2 ;
localparam  SHOW_DOWN               = 4'd3 ;
localparam  WAIT_NEXT_ROUND         = 4'd4 ;
localparam  WAIT_LUT_DEAL_PLAYER    = 4'd7 ;
localparam  WAIT_LUT_DEAL_HOUSE     = 4'd12;
localparam  WAIT_LUT_DEAL_DRAW      = 4'd8 ;
localparam  WAIT_LUT_DRAW           = 4'd9 ;
localparam  EXCEPTIONS              = 4'd10 ;
localparam  DONE = 4'd11;

localparam  PLAYERS_TURN    = 1'b0;
localparam  HOUSE_TURN      = 1'b1;

localparam  PLAYER_WIN      = 1'b1;
localparam  HOUSE_WIN       = 1'b0;


//7-Segment display Signals
localparam SEG_RESET          = 8'b0000_0001;
localparam SEG_ZERO           = 8'b0011_1111;
localparam SEG_ONE            = 8'b0000_0110;
localparam SEG_TWO            = 8'b0101_1011;
localparam SEG_THREE          = 8'b0100_1111;
localparam SEG_FOUR           = 8'b0110_0110;
localparam SEG_FIVE           = 8'b0110_1101;
localparam SEG_SIX            = 8'b0111_1101;
localparam SEG_SEVEN          = 8'b0010_0111;
localparam SEG_EIGHT          = 8'b0111_1111;
localparam SEG_NINE           = 8'b0110_1111;
localparam SEG_TEN            = 8'b0011_1111;
localparam SEG_HALF_POINT     = 8'b1000_0000;

localparam  J = 'd11 ;
localparam  Q = 'd12 ;
localparam  K = 'd13 ;


localparam LED_PLAYER_WINS = 3'b010;
localparam LED_HOUSE_WINS  = 3'b001;
localparam LED_DONE        = 3'b100;

localparam HALF_POINT_VALUE = 5'b00001;


//================================================================
//   Frequency division Sys Clk -> 7seg clk and module clk
//================================================================
reg [24:0] counter;
wire dis_clk; //seg display d_clk, frequency faster than d_clk
wire d_clk  ; //division d_clk

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

assign d_clk = counter[23];
assign dis_clk = counter[15];

// assign d_clk = counter[5];
// assign dis_clk = counter[2];

//================================================================
//   One pulse generator
//================================================================

reg btn_m_press_flag;
reg btn_ri_press_flag;

wire btn_m_pulse;
wire btn_r_pulse;

always @(posedge d_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        // btn_c_press_flag <= 0;
        btn_m_press_flag <= 0;
        btn_ri_press_flag <= 0;
    end
    else
    begin
        // btn_c_press_flag <= btn_c;
        btn_m_press_flag <= btn_m;
        btn_ri_press_flag <= btn_r;
    end
end

// assign btn_c_pulse = {btn_c,btn_c_press_flag} == 2'b10 ? 1 : 0;
assign btn_m_pulse = {btn_m,btn_m_press_flag} == 2'b10 ? 1 : 0;
assign btn_r_pulse = {btn_r,btn_ri_press_flag} == 2'b10 ? 1 : 0;


//================================================================
//   REG/WIRE
//================================================================
integer i;

//store segment display situation
reg [7:0] seg7_temp[0:7]; // 7 slots to display.

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

// Player, House INFOS
reg[3:0] playerCards_rf[0:4];
reg[3:0] houseCards_rf[0:4];

reg[7:0] playerPoints_ff;
reg[7:0] housePoints_ff;

reg[4:0] currentCard_cnt;
reg[7:0] card_value;// zero-th bit used to store half point.


reg[3:0] round_cnt;

reg [2:0] dis_cnt;

reg busted_ff;

//================================================================
//   CONTROL SIGNALS
//================================================================
// State indicators
wire state_IDLE                 =  currentState == IDLE              ;
wire state_DEAL                 =  currentState == DEAL              ;
wire state_DRAW                 =  currentState == DRAW              ;
wire state_SHOW_DOWN            =  currentState == SHOW_DOWN         ;
wire state_WAIT_NEXT_ROUND      =  currentState == WAIT_NEXT_ROUND   ;
wire state_WAIT_LUT_DEAL_PLAYER = currentState == WAIT_LUT_DEAL_PLAYER ;
wire state_WAIT_LUT_DEAL_HOUSE  = currentState == WAIT_LUT_DEAL_HOUSE;
wire state_WAIT_LUT_DRAW        =  currentState == WAIT_LUT_DRAW     ;
wire state_EXCEPTIONS           =  currentState == EXCEPTIONS        ;
wire state_DONE                 =  currentState == DONE ;

wire state_PLAYERS_TURN         =  turnState_cur == PLAYERS_TURN      ;
wire state_HOUSE_TURN           =  turnState_cur == HOUSE_TURN        ;

wire state_PLAYER_WIN           =  gameResultState == PLAYER_WIN        ;
wire state_HOUSE_WIN            =  gameResultState == HOUSE_WIN         ;

//Control signals
wire Start_game = state_IDLE && btn_m_pulse;

wire Deal_Cards = state_DEAL && btn_m_pulse;

wire Busted = ((playerPoints_ff[7:1] > 7'd10) || (housePoints_ff[7:1] > 7'd10)) && state_DRAW ;

wire Finish_drawing = state_DRAW && btn_r_pulse;

wire DrawCards = state_DRAW && btn_m_pulse;

wire RoundEnds = (state_SHOW_DOWN || state_WAIT_NEXT_ROUND) && btn_r_pulse;

wire GameEnds  = (round_cnt == 'd4) && state_WAIT_NEXT_ROUND && btn_r_pulse;

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
            nextState  = WAIT_LUT_DEAL_PLAYER;
        end
        WAIT_LUT_DEAL_PLAYER:
        begin
            nextState  = WAIT_LUT_DEAL_HOUSE;
        end
        WAIT_LUT_DEAL_HOUSE:
        begin
            nextState  = DRAW;
        end
        DRAW:
        begin
            if(Busted)
            begin
                nextState = SHOW_DOWN;
            end
            else if(Finish_drawing)
            begin
                if(state_HOUSE_TURN)
                begin
                    nextState = SHOW_DOWN;
                end
                else
                begin
                    nextState = DRAW;
                end
            end
            else if(DrawCards)
            begin
                nextState = WAIT_LUT_DRAW;
            end
            else
            begin
                nextState = DRAW;
            end
        end
        WAIT_LUT_DRAW:
        begin
            nextState  = DRAW;
        end
        SHOW_DOWN:
        begin
            nextState = RoundEnds ? WAIT_NEXT_ROUND : SHOW_DOWN;
        end
        WAIT_NEXT_ROUND:
        begin
            nextState = RoundEnds ? DONE : IDLE;
        end
        DONE:
        begin
            nextState = DONE;
        end
        default:
        begin
            nextState = EXCEPTIONS;
        end
    endcase
end

//Deciding whose turn
always @(posedge d_clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        turnState_cur <= PLAYERS_TURN;
    end
    else if(state_WAIT_NEXT_ROUND)
    begin
        turnState_cur <= PLAYERS_TURN;
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
always @(posedge d_clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        gameResultState <= HOUSE_WIN;
    end
    else if(RoundEnds)
    begin
        gameResultState <= HOUSE_WIN;
    end
    else
    begin
        gameResultState <= gameResultState_next;
    end
end

//Current round game result
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
    else if(state_SHOW_DOWN & !busted_ff)
    begin
        gameResultState_next = (housePoints_ff >= playerPoints_ff) ? HOUSE_WIN : PLAYER_WIN;
    end
    else
    begin
        gameResultState_next = gameResultState;
    end
end

always @(posedge d_clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        round_cnt <= 'd0;
    end
    else if(RoundEnds)
    begin
        round_cnt <= round_cnt + 1;
    end
    else
    begin
        round_cnt <= round_cnt;
    end
end

always @(posedge d_clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        busted_ff <= 1'd0;
    end
    else if(RoundEnds)
    begin
        busted_ff <= 1'd0;
    end
    else if(state_DRAW && Busted)
    begin
        busted_ff <= 1'd1;
    end
    else
    begin
        busted_ff <= busted_ff;
    end
end

//================================================================
//   DESIGN
//================================================================
always @(posedge d_clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        currentCard_cnt <= 'd0;
    end
    else if(RoundEnds || Start_game)
    begin
        currentCard_cnt <= 'd0;
    end
    else if(turnState_cur != turnState_next)
    begin
        currentCard_cnt <= 'd1;
    end
    else if(state_WAIT_LUT_DRAW || state_WAIT_LUT_DEAL_HOUSE)
    begin
        currentCard_cnt <= currentCard_cnt + 1;
    end
    else
    begin
        currentCard_cnt <= currentCard_cnt;
    end
end

always @(posedge d_clk or negedge rst_n)
begin: House_Cards
    if(~rst_n)
    begin
        for(i=0;i<5;i=i+1)
        begin
            houseCards_rf[i] <= 'd0;
        end
    end
    else if(RoundEnds || Start_game)
    begin
        for(i=0;i<5;i=i+1)
        begin
            houseCards_rf[i] <= 'd0;
        end
    end
    else if( state_WAIT_LUT_DEAL_HOUSE || (state_WAIT_LUT_DRAW && state_HOUSE_TURN))
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

always @(posedge d_clk or negedge rst_n)
begin: Player_Cards
    if(~rst_n)
    begin
        for(i=0;i<5;i=i+1)
        begin
            playerCards_rf[i] <= 'd0;
        end
    end
    else if(RoundEnds || Start_game)
    begin
        for(i=0;i<5;i=i+1)
        begin
            playerCards_rf[i] <= 'd0;
        end
    end
    else if((state_WAIT_LUT_DEAL_PLAYER) || (state_WAIT_LUT_DRAW && state_PLAYERS_TURN))
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

always @(posedge d_clk or negedge rst_n)
begin: PlayerPoint
    if(~rst_n)
    begin
        playerPoints_ff <= 'd0;
    end
    else if(RoundEnds || Start_game)
    begin
        playerPoints_ff <= 'd0;
    end
    else if((state_WAIT_LUT_DRAW && state_PLAYERS_TURN || state_WAIT_LUT_DEAL_PLAYER))
    begin
        playerPoints_ff <= playerPoints_ff + card_value;
    end
    else
    begin
        playerPoints_ff <= playerPoints_ff;
    end
end

always @(posedge d_clk or negedge rst_n)
begin: HousePoints
    if(~rst_n)
    begin
        housePoints_ff <= 'd0;
    end
    else if(RoundEnds || Start_game)
    begin
        housePoints_ff <= 'd0;
    end
    else if((state_WAIT_LUT_DRAW & state_HOUSE_TURN || state_WAIT_LUT_DEAL_HOUSE))
    begin
        housePoints_ff <= housePoints_ff + card_value;
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

//================================================================
//   SEVEN SEGMENT CTR
//================================================================
// ==  ==  == SEVEN segment display light control ==  ==  ==

wire[7:0] player_digit_temp[0:2];
assign player_digit_temp[0] = playerPoints_ff[0];
assign player_digit_temp[1] = playerPoints_ff[7:1] % 10;//INTEGER PARTS
assign player_digit_temp[2] = playerPoints_ff[7:1] / 10;

wire[7:0] house_digit_temp[0:2];
assign house_digit_temp[0] = housePoints_ff[0];
assign house_digit_temp[1] = housePoints_ff[7:1] % 10;//INTEGER PARTS
assign house_digit_temp[2] = housePoints_ff[7:1] / 10;

always @(posedge dis_clk or negedge rst_n )
begin
    if(~rst_n)
    begin
        for(i=0;i<8;i=i+1)
        begin
            seg7_temp[i] <= SEG_RESET;
        end
    end
    else if(RoundEnds || Start_game)
    begin
        for(i=0;i<8;i=i+1)
        begin
            seg7_temp[i] <= SEG_RESET;
        end
    end
    else if(state_DRAW && state_PLAYERS_TURN)
    begin
        for(i=0;i<5;i=i+1)
        begin
            case(playerCards_rf[i])
                'd0:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
                'd1:
                begin
                    seg7_temp[i] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i] <= SEG_NINE;
                end
                'd10:
                begin
                    seg7_temp[i] <= SEG_TEN;
                end
                J,Q,K:
                begin
                    seg7_temp[i] <= SEG_HALF_POINT;
                end
                default:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
            endcase
        end

        seg7_temp[5] <= player_digit_temp[0] ? SEG_HALF_POINT : SEG_RESET;

        for(i=1;i<3;i=i+1)
        begin
            case(player_digit_temp[i])
                'd0:
                begin
                    seg7_temp[i+5] <= SEG_ZERO;
                end
                'd1:
                begin
                    seg7_temp[i+5] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i+5] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i+5] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i+5] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i+5] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i+5] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i+5] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i+5] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i+5] <= SEG_NINE;
                end
                'd10:
                begin
                    seg7_temp[i+5] <= SEG_TEN;
                end
                default:
                begin
                    seg7_temp[i+5] <= SEG_RESET;
                end
            endcase
        end
    end
    else if(state_DRAW && state_HOUSE_TURN)
    begin
        for(i=0;i<5;i=i+1)
        begin
            case(houseCards_rf[i])
                'd0:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
                'd1:
                begin
                    seg7_temp[i] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i] <= SEG_NINE;
                end
                'd10:
                begin
                    seg7_temp[i] <= SEG_TEN;
                end
                J,Q,K:
                begin
                    seg7_temp[i] <= SEG_HALF_POINT;
                end
                default:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
            endcase
        end

        seg7_temp[5] <= house_digit_temp[0] ? SEG_HALF_POINT : SEG_RESET;

        for(i=1;i<3;i=i+1)
        begin
            case(house_digit_temp[i])
                'd0:
                begin
                    seg7_temp[i+5] <= SEG_ZERO;
                end
                'd1:
                begin
                    seg7_temp[i+5] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i+5] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i+5] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i+5] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i+5] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i+5] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i+5] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i+5] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i+5] <= SEG_NINE;
                end
                default:
                begin
                    seg7_temp[i+5] <= SEG_RESET;
                end
            endcase
        end
    end
    else if(state_SHOW_DOWN)
    begin
        //Player cards value
        for(i=0;i<3;i=i+1)
        begin
            case(player_digit_temp[i])
                'd0:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
                'd1:
                begin
                    seg7_temp[i] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i] <= SEG_NINE;
                end
                default:
                begin
                    seg7_temp[i] <= SEG_RESET;
                end
            endcase
        end

        seg7_temp[5] <= house_digit_temp[0] ? SEG_HALF_POINT : SEG_RESET;

        //House Cards value
        for(i=1;i<3;i=i+1)
        begin
            case(house_digit_temp[i])
                'd0:
                begin
                    seg7_temp[i+5] <= SEG_HALF_POINT;
                end
                'd1:
                begin
                    seg7_temp[i+5] <= SEG_ONE;
                end
                'd2:
                begin
                    seg7_temp[i+5] <= SEG_TWO;
                end
                'd3:
                begin
                    seg7_temp[i+5] <= SEG_THREE;
                end
                'd4:
                begin
                    seg7_temp[i+5] <= SEG_FOUR;
                end
                'd5:
                begin
                    seg7_temp[i+5] <= SEG_FIVE;
                end
                'd6:
                begin
                    seg7_temp[i+5] <= SEG_SIX;
                end
                'd7:
                begin
                    seg7_temp[i+5] <= SEG_SEVEN;
                end
                'd8:
                begin
                    seg7_temp[i+5] <= SEG_EIGHT;
                end
                'd9:
                begin
                    seg7_temp[i+5] <= SEG_NINE;
                end
                'd10:
                begin
                    seg7_temp[i+5] <= SEG_TEN;
                end
                default:
                begin
                    seg7_temp[i+5] <= SEG_RESET;
                end
            endcase
        end
    end
    else
    begin
        for(i=0;i<8;i=i+1)
        begin
            seg7_temp[i] <= seg7_temp[i];
        end
    end
end

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
always@(posedge dis_clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        led <= 3'b000;
    end
    else if(RoundEnds)
    begin
        led <= 3'b000;
    end
    else if (state_SHOW_DOWN)
    begin
        if(state_PLAYER_WIN)
        begin
            led <= 3'b001;
        end
        else
        begin
            led <= 3'b010;
        end
    end
    else if(state_DONE)
    begin
        led <= 3'b100;
    end
    else
    begin
        led <= led;
    end
end

//================================================================
//   LUT
//================================================================
always @(*)
begin
    if(~rst_n)
    begin
        pip = 1'b0;
    end
    else if(state_DRAW && DrawCards)
    begin
        pip = 1'b1;
    end
    else if(state_DEAL||state_WAIT_LUT_DEAL_PLAYER)
    begin
        pip = 1'b1;
    end
    else
    begin
        pip = 1'b0;
    end
end

LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));


endmodule
