module CC(
    //Input Port
    clk,
    rst_n,
	in_valid,
	mode,
    xi,
    yi,

    //Output Port
    out_valid,
	xo,
	yo
    );

input               clk, rst_n, in_valid;
input       [1:0]   mode;
input  signed   [7:0]   xi, yi;  

output reg          out_valid;
output reg  [7:0]   xo, yo;


reg [2:0] c_state , n_state;
reg signed[7:0] x [3:0];
reg signed[7:0] y [3:0]; // y_1 == y_2 , y_3 == y_4  


wire signed [16:0]a;
reg  signed [8:0]   x_next, y_next;
assign a = ( x_next - x[3] ) * (y[1]-y[3]) - (x[1]- x[3] ) * ( y_next  - y[3]);
wire line2; 
assign line2 = ( a <= 0 )? 1 : 0 ; // line2 left side or on the line
//
wire signed [16:0]a2;
reg  signed [8:0] start;
assign a2 = ( start - x[2]  ) * (y[0]-y[2]) - (x[0]- x[2] ) * ( (y_next + 1) - y[2]);
wire line1; 
assign line1 = ( a2 > 0 )? 1 : 0 ; // line1 right side 

//reg signed [7:0]Start,End;
reg       [7:0]high;
reg       [7:0]del_x;
reg       [7:0]del_y;
reg signed[16:0]slope;
reg signed[16:0]result;

always@(*)begin

    if(x[0] >= x[2])
        del_x = x[0] - x[2] ;
    else
        del_x = x[2] - x[0] ;
    del_y =   y[0] - y[2];       
    slope =  (high * del_x ) / del_y;
    if(x[0] >= x[2] )
        result = x[2] + slope;
        
    else  begin
        if(y_next != y[0] - 1  )    result = x[2] - slope - 1;
        else           result = x[2] - slope ;
    end
end


/* =================================================================  Trape */

reg signed[18:0] mul_a , mul_b; 
reg signed[8:0] mul_c , mul_d , mul_e , mul_f;//
reg signed[31:0] ans1 ;
reg signed [19:0] ans2 , ans3; 
always@(*)begin
    ans1 = mul_a * mul_b;
    ans2 = mul_c * mul_d;
    ans3 = mul_e * mul_f;
end

reg signed [16:0]temp1,temp2,temp3,temp4;
reg signed [31:0]b;

always@(*)begin
    b = ans1 -((ans2 +ans3 )*(temp3 + temp4));
end

reg [1:0]Mode;
parameter   Load1     = 3'd0,
            Load2     = 3'd2,
            Load3     = 3'd3,
            Load4     = 3'd4,
            Caculate  = 3'd5,
            Out       = 3'd6;  

parameter   Trape     = 2'd0,
            Circle    = 2'd1,
            Area      = 2'd2;

always @(posedge clk or negedge rst_n) begin // FSM
    if(!rst_n) 
        c_state <= Load1;
    else 
        c_state <= n_state;
end


wire finish ;
assign finish = (xo == ( x[1] - 1 ) && yo == y[1]  && Mode == Trape) ||  
                 Mode == Circle || Mode == Area;

always @(*) begin // next state logic
    n_state = c_state;
    case(c_state)
        Load1 : if(in_valid) n_state = Load2 ;   
        Load2 :  n_state = Load3 ;  
        Load3 :  n_state = Load4 ;
        Load4 :  n_state = Caculate ;                    
        Caculate : begin
                            n_state = Out ;
                    end
        Out   : begin
                        if(finish)
                            n_state = Load1 ;
                end                 
 
    endcase
end
reg signed[16:0]area_tmp;

always @(posedge clk ) begin // current State sequential 
    case(c_state)
        Load2:begin
                if(Mode == Circle)begin
                    mul_a <= (x[0] - xi);
                    mul_b <= y[0];
                    mul_c <= (yi - y[0]);
                    mul_d <= x[0];
                    mul_e <= (xi - x[0]);
                    mul_f <= (xi - x[0]);
                end
                else begin
                    mul_a <= x[0] ;
                    mul_b <= yi   ;
                    mul_c <= xi   ;
                    mul_d <= y[0] ;
                end

                end 
        Load3:begin
                    if(Mode == Circle)begin
                        temp1 <= ans1;
                        temp2 <= ans2;
                        temp3 <= ans3;

                        mul_a <= (x[1] - x[0]);
                        mul_b <= yi;
                        mul_c <= (y[0] - y[1]);
                        mul_d <= xi;
                        mul_e <= (y[0] - y[1]);
                        mul_f <= (y[0] - y[1]);
                    end
                    else begin
                        area_tmp <= ans1 -ans2;

                        mul_a <= x[1] ;
                        mul_b <= yi   ;
                        mul_c <= xi   ;
                        mul_d <= y[1] ;

                    end
                end 
        Load4:begin
                    if(Mode == Circle)begin
                    temp4 <= ans3;
                        mul_a <= temp1 + temp2 + ans1 + ans2 ;
                        mul_b <= temp1 + temp2 + ans1 + ans2 ; // line formula
                        mul_c <= (xi - x[2]);
                        mul_d <= (xi - x[2]);
                        mul_e <= (yi - y[2]);
                        mul_f <= (yi - y[2]);
                    end
                    else begin
                        area_tmp <= area_tmp + ans1 -ans2;

                        mul_a <= x[2] ;
                        mul_b <= yi   ;
                        mul_c <= xi   ;
                        mul_d <= y[2] ;
                    end
                end   
    endcase
end


always @(posedge clk or negedge rst_n) begin // current State sequential 
    if(!rst_n)begin 
        out_valid <= 0;
        xo <= 0;
        yo <= 0;

        high <= 0;
    end 
    else begin
        case(c_state)
            Load1 : begin
                        out_valid <= 0;
                        
                        if(in_valid)begin
                            x[0] <= xi;
                            y[0] <= yi;

                            Mode <= mode;
                        end
                   end         
            Load2:begin             

                        x[1] <= xi;
                        y[1] <= yi;
                   end 
            Load3:begin
                        x[2] <= xi;
                        y[2] <= yi;
                   end 
            Load4:begin
                        x[3] <= xi;
                        y[3] <= yi;
                   end               
            Caculate:begin
                        out_valid <= 1;
                        case (Mode)                           
                            Trape : begin
                                        xo <= x[2] ;
                                        yo <= y[2] ;  

                                        x_next <= x[2]+1 ;
                                        y_next <= y[2] ; 
                                        start <= x[2];
                                        high <= 1;              
                                    end
                            Circle : begin
                                        xo <= 0;
                                        
                                        if (b > 0) yo <= 0 ;
                                        else if (b == 0) yo <= 2;
                                        else  yo <= 1;
                                    end
                            Area : begin
                                        if((area_tmp + ans1 -ans2 + x[3] * y[0] - x[0] * y[3]) > 0)
                                            {xo,yo} <= ((area_tmp + ans1 -ans2 + x[3] * y[0] - x[0] * y[3]) >> 1) ;
                                        else  
                                            {xo,yo} <= (-(area_tmp + ans1 -ans2 + x[3] * y[0] - x[0] * y[3]) >> 1)  ;                       
                                    end
                        endcase
                    end
            Out:begin 
                    out_valid <= 0;              
                    if(Mode == Trape)begin
                        out_valid <= 1;
                        if(line2)begin
                            xo <=  x_next ;  
                            x_next  <=  x_next + 1;                                                                            
                        end  
                        else begin
                            yo <= yo + 1;  
                            y_next <=  y_next + 1 ; 
                            high <= high + 1;
                            
                            xo <=  result;
                            x_next <=  result + 1 ;  // change row          
                        end   
                    end     
                end                
        endcase
    end
end
always@(posedge clk)begin
        case(c_state)        
            Caculate:begin     
                        start <= x[2];  
                    end
            Out:begin                    
                    if(x[0] >= x[2])begin
                        if (a < 0)
                            start <=  start + 1;
                    end 
                    else begin
                        if(line1 == 0)
                            start <=  start - 1;
                    end      
                end             

        endcase
    end
endmodule // 198260.095590 237