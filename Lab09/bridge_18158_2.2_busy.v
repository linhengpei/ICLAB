module bridge(input clk, INF.bridge_inf inf);

typedef enum logic [3:0]{
            Idle,
            Read_data,
            Read_address,
            Expire_check,
            Add3,
            Overflow_check,
            Add2,
            Add1,
            Sub1,
            Sub2,
            Quan_check,
            Write_address,
            Write_data,
            Write_respond
        } state_t;

state_t c_state;

logic [11:0] oper1,oper2 ;
logic [12:0] add_result ;
logic [10:0] sub_result ;
always_comb begin
    add_result = oper1 + oper2 ;
    sub_result = oper1[11:2] - oper2[9:2];
end

always_ff @(posedge clk )begin
    case(c_state)
        Read_data: begin
            oper1 <=  inf.R_DATA[63:52] ;
            oper2 <=  inf.C_data_w [61:50] ;
        end
        Add1: begin
            oper1 <=  inf.W_DATA[51:40] ; 
            oper2 <=  inf.C_data_w [49:38] ;
        end
        Add2: begin
            oper1 <=  inf.W_DATA[31:20] ;
            oper2 <=  inf.C_data_w [37:26] ;
        end
        Add3: begin
            oper1 <=  inf.W_DATA[19: 8] ;
            oper2 <=  inf.C_data_w [25:14] ;
        end
        Expire_check: begin
            oper1 <=  inf.W_DATA[51:40] ;
            oper2 <=  inf.C_data_w [49:38];
        end
        Sub1: begin
            oper1 <=  inf.W_DATA[31:20] ;
            oper2 <=  inf.C_data_w[37:26];
        end
        Sub2: begin
            oper1 <=  inf.W_DATA[19:8] ;
            oper2 <=  inf.C_data_w [25:14];
        end
    endcase
end
always_comb begin
    if(c_state == Read_address)
        inf.AR_VALID = 1;
    else
        inf.AR_VALID = 0;
end
always_comb begin
    if(c_state == Read_data)
        inf.R_READY = 1;
    else
        inf.R_READY = 0;
end
always_comb begin
    if(c_state == Write_address)
        inf.AW_VALID = 1;
    else
        inf.AW_VALID = 0;
end
always_comb begin
    if(c_state == Write_data)
        inf.W_VALID = 1;
    else
        inf.W_VALID = 0;
end
always_comb begin
    if(c_state == Write_respond)
        inf.B_READY = 1;
    else
        inf.B_READY = 0;
end
logic [7:0]C_addr;
always_ff @( posedge clk or negedge inf.rst_n )
    if (!inf.rst_n)
        C_addr <= 0 ;
    else
        C_addr <= inf.C_addr;
always_comb begin
    inf.AR_ADDR[15:0] = {5'b00000 , C_addr , 3'd0};
    inf.AW_ADDR[15:0] = {5'b00000 , C_addr , 3'd0} ;
    if(!inf.rst_n)begin
        inf.AR_ADDR[16] = 0;
        inf.AW_ADDR[16] = 0;
    end
    else begin
        inf.AR_ADDR[16] = 1;
        inf.AW_ADDR[16] = 1;
    end
end
/*
 output C_out_valid, C_data_r, 
		       AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY
*/
assign inf.C_data_r[63:3] = 61'b0;
assign inf.W_DATA[39:36] = 4'b0;
assign inf.W_DATA[7:5] = 3'b0;
logic No_ing_flag , Overflow_flag , Exp_flag ;
always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        c_state <= Idle;
        inf.C_out_valid <= 0;
        inf.C_data_r[2:0] <= 0;
        //inf.W_DATA <= 0;
        {inf.W_DATA[63:40],inf.W_DATA[35:8] ,inf.W_DATA[4:0]  } <= 0 ;
    end
    else begin
        case(c_state)
            Idle: begin
                No_ing_flag <= 0 ;
                inf.C_out_valid <= 0;
                inf.C_data_r[2:0] <= 0;

                if(inf.C_in_valid) begin
                    c_state <= Read_address;
                end
            end
            Read_address: begin
                if(inf.AR_READY) begin
                    c_state <= Read_data;
                end
            end
            Read_data: begin
                {inf.W_DATA[63:40],inf.W_DATA[35:8] ,inf.W_DATA[4:0]  } <= {inf.R_DATA[63:40],inf.R_DATA[35:8] ,inf.R_DATA[4:0] } ;//inf.R_DATA; // save in W_DATA

                Exp_flag <= inf.C_data_w[8:5] < inf.R_DATA[35:32] ||  ( inf.C_data_w[8:5] == inf.R_DATA[35:32] &&  inf.C_data_w[4:0] <= inf.R_DATA[4:0] ) ;
                if(inf.R_VALID) begin    
                    if(inf.C_data_w[62] )begin // Supply
                        c_state <= Add1;
                    end    
                    else begin   
                        c_state <= Expire_check;
                    end    
                end
            end
            Add1: begin
                Overflow_flag <= add_result[12];
                if(add_result [12]) begin
                    inf.W_DATA[63:52] <= 4095; 
                end
                else begin
                    inf.W_DATA[63:52] <= add_result;
                end

                inf.W_DATA[35:32] <= inf.C_data_w[8:5] ;
                inf.W_DATA[ 4: 0] <= inf.C_data_w[4:0] ; // change date
                c_state <= Add2;
            end
            Add2: begin
                if(add_result [12]) begin
                    inf.W_DATA[51:40] <= 4095;
                    Overflow_flag <= 1;
                end
                else
                    inf.W_DATA[51:40] <= add_result;
                c_state <= Add3;
            end
            Add3: begin
                if(add_result [12]) begin
                    inf.W_DATA[31:20] <= 4095;
                    Overflow_flag <= 1;
                end
                else
                    inf.W_DATA[31:20] <= add_result;
                c_state <= Overflow_check;
            end

            Overflow_check: begin
                inf.C_data_r[2] <= 1 ; // busy
                if( Overflow_flag ||  add_result[12]) begin
                    inf.C_data_r[1:0] <= 2'b11 ; // img_OF
                end

                if( add_result [12])
                    inf.W_DATA[19: 8] <= 4095;
                else
                    inf.W_DATA[19: 8] <=  add_result;
    
                inf.C_out_valid <= 1;
                c_state <= Write_address;
            end
            Expire_check: begin
                inf.W_DATA[63:54] <= sub_result;
                No_ing_flag <= No_ing_flag || sub_result[10];

                if(  Exp_flag ) begin// inf.C_data_w[8:5] < inf.W_DATA[35:32] || ( inf.C_data_w[8:5] == inf.W_DATA[35:32] &&  inf.C_data_w[4:0] <= inf.W_DATA[4:0] ) ) begin
                    if(inf.C_data_w[63] == 1'b0) begin // make
                        c_state <= Sub1; //c_state <= Quan_check;
                    end
                    else begin
                        inf.C_out_valid <= 1;
                        c_state <= Idle;    //check normal
                    end
                end
                else begin // expire
                    inf.C_out_valid <= 1;
                    inf.C_data_r[1:0] <= 1 ; //No_Exp;

                    c_state <= Idle;
                end
            end
            Sub1: begin
                inf.W_DATA[51:42]  <= sub_result;
                No_ing_flag <= No_ing_flag || sub_result[10];

                c_state <= Sub2;
            end
            Sub2: begin
                inf.W_DATA[31:22] <= sub_result;
                No_ing_flag <= No_ing_flag || sub_result[10];

                c_state <= Quan_check;
            end
            Quan_check: begin
                inf.C_out_valid <= 1;
                inf.W_DATA[19:10] <= sub_result ;
                if(  No_ing_flag || sub_result[10]) begin //not enought
                    inf.C_data_r[2:0] <= 3'b010 ; // No_Ing ;
                    c_state <= Idle;
                end
                else begin
                    inf.C_data_r[2:0] <= 3'b100 ; // busy
                    c_state <= Write_address;
                end
            end
            Write_address : begin
                inf.C_out_valid <= 0;
                if(inf.AW_READY) begin
                    c_state <= Write_data;
                end
            end
            Write_data : begin
                if(inf.W_READY) begin
                    c_state <= Write_respond;
                end
            end
            Write_respond : begin
                if(inf.B_VALID) begin
                    c_state <= Idle;
                end
            end
        endcase
    end
end

endmodule // 20414  2.4
          // 21233  2.3
          // 20417  2.2
