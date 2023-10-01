module CC( clk, rst_n, in_valid, mode, xi, yi, out_valid, xo, yo );

input    clk, rst_n, in_valid;
input  [1:0]   mode;
input  signed  [7:0]  xi, yi;

output reg          out_valid;
output reg signed [7:0]   xo, yo;

reg [1:0]Mode;
reg [2:0] c_state , n_state;
reg signed[7:0] x [3:0];
reg signed[7:0] y [3:0];

parameter   Load1     = 3'd0,
            Load2     = 3'd1,
            Load3     = 3'd2,
            Load4     = 3'd3,
            Caculate  = 3'd4,
            Out       = 3'd5;

parameter   Trape     = 2'd0,
            Circle    = 2'd1,
            Area      = 2'd2;


reg  signed [8:0] start;
reg signed[8:0] mul_a , mul_b ,mul_c , mul_d , mul_e , mul_f , mul_g , mul_h;
wire signed [16:0] ans1 , ans2 , ans3 , ans4;

assign   ans1 = mul_a * mul_b ;
assign   ans2 = mul_c * mul_d ;
assign   ans3 = mul_e * mul_f ;
assign   ans4 = mul_g * mul_h ;

wire line_L ;
wire line_R;
wire slope ;

assign slope = (x[0] >= x[2] )? 1:  0;
assign line_R = (ans1 <= ans2)? 1 : 0; // line_R == 1 mean  left side of line_R (on the)=
assign line_L = (ans3 <= ans4)? 1 : 0; // line_L == 1 mean  left side of line_L (on the)
/* =================================================================  Trape */

always @(posedge clk or negedge rst_n) begin // FSM
    if(!rst_n)
        c_state <= Load1;
    else
        c_state <= n_state;
end

wire done ;
assign done = (xo == ( x[1] - 1 ) && yo == y[1]  && Mode == Trape) ||  Mode == Circle || Mode == Area;

always @(*) begin // next state logic
    n_state = c_state;
    case(c_state)
        Load1 :
            if(in_valid)
                n_state = Load2 ;
        Load2 :
            n_state = Load3 ;
        Load3 :
            n_state = Load4 ;
        Load4 :
            n_state = Caculate ;
        Caculate :
            n_state = Out ;
        Out   :
            if(done)
                n_state = Load1 ;
    endcase
end
/* =================================================================  Circle */

reg [8:0] Pos1,Pos2,Pos3,Pos4;
reg [8:0] appr1,appr2;
reg [7:0] A;
reg [5:0] B;
always@(*) begin
    Pos1 = x[1]-x[0];
    Pos2 = y[0]-y[1];
    Pos3 = x[2]- xi ;
    Pos4 = y[2]- yi ;

    Pos1 = {9{Pos1[8]}} ^ Pos1 - Pos1[8];
    Pos2 = {9{Pos2[8]}} ^ Pos2 - Pos2[8];
    Pos3 = {9{Pos3[8]}} ^ Pos3 - Pos3[8];
    Pos4 = {9{Pos4[8]}} ^ Pos4 - Pos4[8];

    if( Pos1 > Pos2) begin
        A = Pos1;
        B = (Pos2 >> 2);
    end
    else begin
        A = Pos2;
        B = (Pos1 >> 2);
    end

    appr1 = A + B  + (B >> 1);

    if( Pos3 > Pos4) begin
        A = Pos3;
        B = (Pos4 >> 2);
    end
    else begin
        A = Pos4;
        B = (Pos3 >> 2);
    end

    appr2 = A +  B  + (B >> 1);

end

/* =================================================================  Area */
reg signed [16:0]temp;
wire signed [16:0]Total_area ;
wire signed [12:0]Circle_dis;

assign    Total_area = temp + ans1 -ans2 + ans3 - ans4;
assign Circle_dis = ({17{temp[16]}} ^ temp - temp[16] ) -  ans4 ;
//assign    Circle_dis = (temp[16] == 0) ? temp -ans4 : -temp -  ans4 ;
always @(posedge clk ) begin // current State sequential
    case(c_state)
        Load2: begin
            if(Mode == Circle) begin
                mul_a <= xi;
                mul_b <= -y[0];
                mul_c <= x[0];
                mul_d <= yi;
            end
            else begin
                temp <= 0;
            end

        end
        Load3: begin
            if(Mode == Circle) begin

                mul_e <= x[1] - x[0];
                mul_f <= yi;
                mul_g <= y[0] - y[1];
                mul_h <= xi;
            end
            else begin

                mul_a <= x[0] ;
                mul_b <= y[1] ;
                mul_c <= x[1] ;
                mul_d <= y[0] ;

                mul_e <= x[1] ;
                mul_f <= yi   ;
                mul_g <= xi   ;
                mul_h <= y[1] ;
            end
        end
        Load4: begin
            if(Mode == Circle) begin
                temp <= ans1 + ans2 + ans3 + ans4;

                mul_g <= appr1;
                mul_h <= appr2;

            end
            else begin
                temp <= Total_area ;

                mul_a <= x[2] ;
                mul_b <= yi   ;
                mul_c <= xi   ;
                mul_d <= y[2] ;
                mul_e <= xi   ;
                mul_f <= y[0] ;
                mul_g <= x[0] ;
                mul_h <= yi ;
            end
        end
        Caculate : begin
            if(Mode == Trape) begin   // ( x_next - x[3] ) * (y[1]-y[3]) - (x[1]- x[3] ) * ( y_next  - y[3]);
                mul_a <= x[2] - x[3] + 1 ;
                mul_b <= y[1] - y[3]  ;
                mul_c <= x[1] - x[3]  ;
                mul_d <= y[2] - y[3]  ;

                if(slope)  //( start - x[2]  + 1) * (y[0]-y[2]) - (x[0]- x[2] ) * ( (yo + 1) - y[2]);
                    mul_e <= 1 ;
                else
                    mul_e <= 0 ;

                mul_f <= y[0] - y[2]  ;
                mul_g <= x[0] - x[2]  ;
                mul_h <= 1  ;
            end
        end
        Out : begin
            if(Mode == Trape) begin
                if(line_R ) begin
                    mul_a <= mul_a + 1 ;
                end
                else begin
                    if(slope)
                        mul_a <= start + 1 - x[3] ;
                    else
                        mul_a <= start + 2 - x[3] ;

                    mul_d <= mul_d + 1  ;
                end


                if(slope) begin
                    if (line_L )
                        mul_e <= mul_e + 1 ;
                end
                else begin
                    if(!line_L )
                        mul_e <= mul_e - 1 ;
                end

                if (!line_R )
                    mul_h <= mul_h + 1 ;
            end
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin // current State sequential
    if(!rst_n) begin
        out_valid <= 0;
        xo <= 0;
        yo <= 0;
    end
    else begin
        case(c_state)
            Load1 : begin
                out_valid <= 0;

                if(in_valid) begin
                    x[0] <= xi;
                    y[0] <= yi;

                    Mode <= mode;
                end
            end
            Load2: begin
                x[1] <= xi;
                y[1] <= yi;
            end
            Load3: begin
                x[2] <= xi;
                y[2] <= yi;
            end
            Load4: begin
                x[3] <= xi;
                y[3] <= yi;


            end
            Caculate: begin
                out_valid <= 1;
                case (Mode)
                    Trape : begin
                        xo <= x[2] ;
                        yo <= y[2] ;

                    end
                    Circle : begin
                        xo <= 0;

                        if (Circle_dis == 0 )
                            yo <= 2;
                        else if (Circle_dis > 0)
                            yo <= 0 ;
                        else
                            yo <= 1;

                    end
                    Area : begin
                        if(Total_area[16] == 0)
                            {xo,yo} <= (Total_area >> 1) ;
                        else
                            {xo,yo} <= (-Total_area >> 1)  ;
                    end
                endcase
            end
            Out: begin
                if(Mode == Trape)
                    out_valid <= 1;
                else
                    out_valid <= 0;

                if(line_R) begin
                    xo <=  xo + 1 ;
                end
                else begin
                    yo <= yo + 1;

                    if(slope)
                        xo <=  start; // change row
                    else
                        xo <=  start + 1;  // change row

                end
            end
        endcase
    end
end

always@(posedge clk) begin
    case(c_state)
        Caculate: begin
            if(slope)
                start <=  x[2];
            else
                start <=  x[2] -1;
        end
        Out: begin
            if(yo == y[0] - 1 ) begin
                if(slope)
                    start <= x[0] ;
                else
                    start <= x[0] - 1;
            end
            else  begin
                if(slope && line_L)
                    start <=  start + 1;

                if (!slope && !line_L)
                    start <=  start - 1;

            end
        end

    endcase
end
endmodule //    71208.246049 237
