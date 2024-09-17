module tenthirty(
    input clk,
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
parameter [2:0] stop = 3'b000, begining = 3'b001, hit = 3'b010, compare = 3'b011, done = 3'b100;

reg [24:0] count; 
wire dis_clk; //seg display clk, frequency faster than d_clk
wire d_clk  ; //division clk

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count <= 0;
    end
    else begin
        count <= count + 1;
    end
end

assign d_clk = count[5];
assign dis_clk = count[10];

//================================================================
//   REG/WIRE
//================================================================
//store segment display situation
reg [7:0] seg7_temp[0:7]; 
reg [7:0] seg7_temp1;
//display counter
reg [2:0] dis_cnt;
//LUT IO
reg  pip;
wire [3:0] number;
/*
Please write your reg/wire here.
*/
reg [3:0] current_total;
reg [3:0] player_total;
reg [3:0] dealer_total;
reg [7:0] seg7_number;
reg [7:0] seg7_total;
reg press_m;
reg press_r;
wire btn_m_pulse;
wire btn_r_pulse;
reg [1:0] CS, NS;
reg [3:0] number_temp;
integer cards, turn, j, k, round; // turn:判斷在player or dealer j,k for迴圈計數器

//轉為單一脈衝
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        press_m <= 0;
        press_r <= 0;
    end
    else begin
        press_m <= btn_m;
        press_r <= btn_r;
    end
end

assign btn_m_pulse = {btn_m,press_m}==2'b10 ? 1 : 0;
assign btn_r_pulse = {btn_r,press_r}==2'b10 ? 1 : 0;

//================================================================
//   FSM
//================================================================
always@(posedge dis_clk or negedge rst_n)begin
    if(!rst_n)begin
        cards <= 1;
        turn <= 0;
        round <= 0;
        number_temp <= 0;
        player_total <= 0;
        dealer_total <= 0;
        led <= 3'b000;
        CS <= stop;
    end
    else
    CS <= NS;
end

always@(CS)begin
    case(CS)
    stop :begin
        seg7_temp1 <= 0;
        led <= 3'b000;
        seg7_total <= 0;
        current_total <= 0;
        seg7_number <= 0;
        if(btn_m_pulse)begin
            pip <= btn_m_pulse;
            number_temp <= number;
            NS <= begining;
        end
        else begin
            NS <= stop;
        end
        end
    begining :begin
        cards <= 1;
        seg7_number[0] <= (number_temp < 11) ? number_temp : 11;
        current_total <= (number_temp < 11) ? 2 * number_temp : 1;
        number_temp <= 0;
        NS <= hit;
        end
    hit :begin
        pip <= btn_m_pulse;
        number_temp <= number;
        if(number_temp == 10)begin // 抽到十
            seg7_number[cards] <= 10;
            current_total <= current_total + 20;
            number_temp <= 0;
        end
        else if(number_temp == 11 || number_temp == 12 || number_temp == 13)begin // 抽到大於十
            seg7_number[cards] <= 11;
            current_total <= current_total + 1;
            number_temp <= 0;
        end
        else begin  // 抽到小於十
            seg7_number[cards] <= number_temp[0];
            current_total <= current_total + 2 * number_temp[0];
            number_temp <= 0; 
        end
        cards = cards + 1;
        seg7_total[0] <= (current_total % 2 == 0) ? 0 : 11; //total 轉為七段顯示器
        seg7_total[1] <= (current_total / 2);
        seg7_total[2] <= (current_total / 20);

        if(btn_m_pulse && current_total < 22 && cards < 5)begin // 合法叫牌
            NS <= hit;
        end
        else if(current_total > 21 && turn == 0)begin // player點數爆了
            seg7_total <= 0;
            seg7_number <= 0;
            player_total <= current_total;
            cards = 1;
            turn = 1;
            current_total <= 0;
            NS <= begining;
        end
        else if(current_total > 21 && turn == 1)begin // dealer點數爆了
            seg7_total <= 0;
            seg7_number <= 0;
            dealer_total <= current_total;
            cards = 1;
            turn = 0;
            current_total <= 0;
            NS <= compare;
        end
        else if((btn_r_pulse && turn == 0) || (cards == 5 && turn == 0))begin // plaer round over
            seg7_total <= 0;
            seg7_number <= 0;
            cards = 1;
            turn = 1;
            player_total <= current_total;
            current_total <= 0;
            NS <= stop;
        end
        else if((btn_r_pulse && turn == 1) || (cards == 5 && turn == 1))begin // dealer round over
            seg7_total <= 0;
            seg7_number <= 0;
            cards = 1;
            turn = 0;
            dealer_total <= current_total;
            current_total <= 0;
            NS <= compare;
        end
        end
    compare :begin
        if(player_total < 22 && dealer_total < 22)begin
        led <= (player_total > dealer_total) ? 3'b101 : 3'b011; // compare two result
        end
        else if(player_total > 21)begin //玩家點數爆了
            led <= 3'b011;
        end
        else if(dealer_total > 21)begin //dealer點數爆了
            led <= 3'b101;
        end
        seg7_temp1[3] <= 0; //compare顯示player,dealer各自大小
        seg7_temp1[4] <= 0;
        seg7_temp1[0] <= (player_total % 2 == 0) ? 0 : 11;
        seg7_temp1[1] <= (player_total / 2);
        seg7_temp1[2] <= (player_total / 20);
        seg7_temp1[5] <= (dealer_total % 2 == 0) ? 0 : 11;
        seg7_temp1[6] <= (dealer_total / 2);
        seg7_temp1[7] <= (dealer_total / 20);
        if(round < 4 && btn_r_pulse)begin // 尚未四輪
            player_total <= 0;
            dealer_total <= 0;
            NS <= stop;
            round <= round + 1;
        end
        else if(round == 4 && btn_r_pulse)begin //四輪結束
            player_total <= 0;
            dealer_total <= 0;
            round <= 0;
            NS <= done;
        end
        end
    done :begin
        NS <= done;
        end
    endcase
end

//pip 

//Please write your LUT pip signal here.


//seg7_temp
always@(posedge d_clk or negedge rst_n)begin
    if(!rst_n)begin
        seg7_temp1 <= 0;
    end
    else begin
        for(j = 0; j < 5; j = j + 1)begin
            seg7_temp1[j] <= seg7_number[j];
        end
        for(k = 5; k < 8; k = k + 1)begin
            seg7_temp1[k] <= seg7_total[k-5];
        end
    end
end

always@(posedge d_clk or negedge rst_n)begin
    if(!rst_n)begin
        seg7_temp1[0] <= 1'b1;
        seg7_temp1[1] <= 1'b0;
        seg7_temp1[2] <= 1'b0;
        seg7_temp1[3] <= 1'b0;
        seg7_temp1[4] <= 1'b0;
        seg7_temp1[5] <= 1'b0;
        seg7_temp1[6] <= 1'b0;
        seg7_temp1[7] <= 1'b0;
    end
    else begin
        case(seg7_temp1[dis_cnt])
        0 : seg7_temp[dis_clk] <= 8'b00000001; //represent the begining state
        1 : seg7_temp[dis_clk]  <= 8'b00000110;
        2 : seg7_temp[dis_clk]  <= 8'b01011011;
        3 : seg7_temp[dis_clk]  <= 8'b01001111;
        4 : seg7_temp[dis_clk]  <= 8'b01100110;
        5 : seg7_temp[dis_clk]  <= 8'b01101101;
        6 : seg7_temp[dis_clk]  <= 8'b01111101;
        7 : seg7_temp[dis_clk]  <= 8'b00000111;
        8 : seg7_temp[dis_clk]  <= 8'b01111111;
        9 : seg7_temp[dis_clk]  <= 8'b01101111;
        10 : seg7_temp[dis_clk]  <= 8'b00111111; //represent 0
        11 : seg7_temp[dis_clk]  <= 8'b10000000; //represent half point
        endcase
    end
end
//================================================================
//   LED
//================================================================


//#################### Don't revise the code below ############################## 

//================================================================
//   SEGMENT
//================================================================

//display counter 
always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        dis_cnt <= 0;
    end
    else begin
        dis_cnt <= (dis_cnt >= 7) ? 0 : (dis_cnt + 1);
    end
end

always@(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7 <= 8'b0000_0001;
    end 
    else begin
        if(!dis_cnt[2]) begin
            seg7 <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7_l <= 8'b0000_0001;
    end 
    else begin
        if(dis_cnt[2]) begin
            seg7_l <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg7_sel <= 8'b11111111;
    end
    else begin
        case(dis_cnt)
            0 : seg7_sel <= 8'b00000001;
            1 : seg7_sel <= 8'b00000010;
            2 : seg7_sel <= 8'b00000100;
            3 : seg7_sel <= 8'b00001000;
            4 : seg7_sel <= 8'b00010000;
            5 : seg7_sel <= 8'b00100000;
            6 : seg7_sel <= 8'b01000000;
            7 : seg7_sel <= 8'b10000000;
            default : seg7_sel <= 8'b11111111;
        endcase
    end
end

//================================================================
//   LUT
//================================================================

LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));

endmodule 