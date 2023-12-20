module CAD (
           clk,
           rst_n,
           in_valid,
           in_valid2,
           mode,
           matrix,
           matrix_size,
           matrix_idx,
           out_valid,
           out_value
       );

input        clk, rst_n, in_valid,in_valid2;
input  [1:0]  matrix_size;
input  [7:0]  matrix;
input  [3:0]  matrix_idx;
input         mode;
output   reg  out_valid;
output   reg  out_value;

reg [6:0] kernel_addr;
reg [39:0] kernel_data_in;
wire [39:0] kernel_data_out;
reg  kernel_WEB;
reg  kernel_CS;
KERNEL kernel_sram(.A0(kernel_addr[0]), .A1(kernel_addr[1]), .A2(kernel_addr[2]), .A3(kernel_addr[3]), .A4(kernel_addr[4]), .A5(kernel_addr[5]), .A6(kernel_addr[6]),
                   .DO0 (kernel_data_out[0]) ,  .DO1(kernel_data_out[1]) ,  .DO2(kernel_data_out[2]) ,  .DO3(kernel_data_out[3]) ,  .DO4(kernel_data_out[4]) ,  .DO5(kernel_data_out[5]) ,  .DO6(kernel_data_out[6]) ,  .DO7(kernel_data_out[7]) ,
                   .DO8 (kernel_data_out[8]) ,  .DO9(kernel_data_out[9]) , .DO10(kernel_data_out[10]), .DO11(kernel_data_out[11]), .DO12(kernel_data_out[12]), .DO13(kernel_data_out[13]), .DO14(kernel_data_out[14]), .DO15(kernel_data_out[15]),
                   .DO16(kernel_data_out[16]), .DO17(kernel_data_out[17]), .DO18(kernel_data_out[18]), .DO19(kernel_data_out[19]), .DO20(kernel_data_out[20]), .DO21(kernel_data_out[21]), .DO22(kernel_data_out[22]), .DO23(kernel_data_out[23]),
                   .DO24(kernel_data_out[24]), .DO25(kernel_data_out[25]), .DO26(kernel_data_out[26]), .DO27(kernel_data_out[27]), .DO28(kernel_data_out[28]), .DO29(kernel_data_out[29]), .DO30(kernel_data_out[30]), .DO31(kernel_data_out[31]),
                   .DO32(kernel_data_out[32]), .DO33(kernel_data_out[33]), .DO34(kernel_data_out[34]), .DO35(kernel_data_out[35]), .DO36(kernel_data_out[36]), .DO37(kernel_data_out[37]), .DO38(kernel_data_out[38]), .DO39(kernel_data_out[39]),
                   .DI0 (kernel_data_in[0]) ,  .DI1(kernel_data_in[1]) ,  .DI2(kernel_data_in[2]) ,  .DI3(kernel_data_in[3]) ,  .DI4(kernel_data_in[4]) ,  .DI5(kernel_data_in[5]) ,  .DI6(kernel_data_in[6]) ,  .DI7(kernel_data_in[7]) ,
                   .DI8 (kernel_data_in[8]) ,  .DI9(kernel_data_in[9]) , .DI10(kernel_data_in[10]), .DI11(kernel_data_in[11]), .DI12(kernel_data_in[12]), .DI13(kernel_data_in[13]), .DI14(kernel_data_in[14]), .DI15(kernel_data_in[15]),
                   .DI16(kernel_data_in[16]), .DI17(kernel_data_in[17]), .DI18(kernel_data_in[18]), .DI19(kernel_data_in[19]), .DI20(kernel_data_in[20]), .DI21(kernel_data_in[21]), .DI22(kernel_data_in[22]), .DI23(kernel_data_in[23]),
                   .DI24(kernel_data_in[24]), .DI25(kernel_data_in[25]), .DI26(kernel_data_in[26]), .DI27(kernel_data_in[27]), .DI28(kernel_data_in[28]), .DI29(kernel_data_in[29]), .DI30(kernel_data_in[30]), .DI31(kernel_data_in[31]),
                   .DI32(kernel_data_in[32]), .DI33(kernel_data_in[33]), .DI34(kernel_data_in[34]), .DI35(kernel_data_in[35]), .DI36(kernel_data_in[36]), .DI37(kernel_data_in[37]), .DI38(kernel_data_in[38]), .DI39(kernel_data_in[39]),
                   .CK(clk) , .WEB(kernel_WEB) , .OE(1'b1) , .CS(kernel_CS)); // 80 word * 40 bits

reg  [10:0] image_addr;
reg  [63:0] image_data_in;
wire [63:0] image_data_out;
reg  image_WEB;
IMAGE image_sram(.A0(image_addr[0]), .A1(image_addr[1]), .A2(image_addr[2]), .A3(image_addr[3]), .A4(image_addr[4]), .A5(image_addr[5]), .A6(image_addr[6]), .A7(image_addr[7]), .A8(image_addr[8]), .A9(image_addr[9]), .A10(image_addr[10]),
                 .DO0 (image_data_out[0]) ,  .DO1(image_data_out[1]) ,  .DO2(image_data_out[2]) ,  .DO3(image_data_out[3]) ,  .DO4(image_data_out[4]) ,  .DO5(image_data_out[5]) ,  .DO6(image_data_out[6]) ,  .DO7(image_data_out[7]) ,
                 .DO8 (image_data_out[8]) ,  .DO9(image_data_out[9]) , .DO10(image_data_out[10]), .DO11(image_data_out[11]), .DO12(image_data_out[12]), .DO13(image_data_out[13]), .DO14(image_data_out[14]), .DO15(image_data_out[15]),
                 .DO16(image_data_out[16]), .DO17(image_data_out[17]), .DO18(image_data_out[18]), .DO19(image_data_out[19]), .DO20(image_data_out[20]), .DO21(image_data_out[21]), .DO22(image_data_out[22]), .DO23(image_data_out[23]),
                 .DO24(image_data_out[24]), .DO25(image_data_out[25]), .DO26(image_data_out[26]), .DO27(image_data_out[27]), .DO28(image_data_out[28]), .DO29(image_data_out[29]), .DO30(image_data_out[30]), .DO31(image_data_out[31]),
                 .DO32(image_data_out[32]), .DO33(image_data_out[33]), .DO34(image_data_out[34]), .DO35(image_data_out[35]), .DO36(image_data_out[36]), .DO37(image_data_out[37]), .DO38(image_data_out[38]), .DO39(image_data_out[39]),
                 .DO40(image_data_out[40]), .DO41(image_data_out[41]), .DO42(image_data_out[42]), .DO43(image_data_out[43]), .DO44(image_data_out[44]), .DO45(image_data_out[45]), .DO46(image_data_out[46]), .DO47(image_data_out[47]),
                 .DO48(image_data_out[48]), .DO49(image_data_out[49]), .DO50(image_data_out[50]), .DO51(image_data_out[51]), .DO52(image_data_out[52]), .DO53(image_data_out[53]), .DO54(image_data_out[54]), .DO55(image_data_out[55]),
                 .DO56(image_data_out[56]), .DO57(image_data_out[57]), .DO58(image_data_out[58]), .DO59(image_data_out[59]), .DO60(image_data_out[60]), .DO61(image_data_out[61]), .DO62(image_data_out[62]), .DO63(image_data_out[63]),
                 .DI0 (image_data_in[0]) ,  .DI1(image_data_in[1]) ,  .DI2(image_data_in[2]) ,  .DI3(image_data_in[3]) ,  .DI4(image_data_in[4]) ,  .DI5(image_data_in[5]) ,  .DI6(image_data_in[6]) ,  .DI7(image_data_in[7]) ,
                 .DI8 (image_data_in[8]) ,  .DI9(image_data_in[9]) , .DI10(image_data_in[10]), .DI11(image_data_in[11]), .DI12(image_data_in[12]), .DI13(image_data_in[13]), .DI14(image_data_in[14]), .DI15(image_data_in[15]),
                 .DI16(image_data_in[16]), .DI17(image_data_in[17]), .DI18(image_data_in[18]), .DI19(image_data_in[19]), .DI20(image_data_in[20]), .DI21(image_data_in[21]), .DI22(image_data_in[22]), .DI23(image_data_in[23]),
                 .DI24(image_data_in[24]), .DI25(image_data_in[25]), .DI26(image_data_in[26]), .DI27(image_data_in[27]), .DI28(image_data_in[28]), .DI29(image_data_in[29]), .DI30(image_data_in[30]), .DI31(image_data_in[31]),
                 .DI32(image_data_in[32]), .DI33(image_data_in[33]), .DI34(image_data_in[34]), .DI35(image_data_in[35]), .DI36(image_data_in[36]), .DI37(image_data_in[37]), .DI38(image_data_in[38]), .DI39(image_data_in[39]),
                 .DI40(image_data_in[40]), .DI41(image_data_in[41]), .DI42(image_data_in[42]), .DI43(image_data_in[43]), .DI44(image_data_in[44]), .DI45(image_data_in[45]), .DI46(image_data_in[46]), .DI47(image_data_in[47]),
                 .DI48(image_data_in[48]), .DI49(image_data_in[49]), .DI50(image_data_in[50]), .DI51(image_data_in[51]), .DI52(image_data_in[52]), .DI53(image_data_in[53]), .DI54(image_data_in[54]), .DI55(image_data_in[55]),
                 .DI56(image_data_in[56]), .DI57(image_data_in[57]), .DI58(image_data_in[58]), .DI59(image_data_in[59]), .DI60(image_data_in[60]), .DI61(image_data_in[61]), .DI62(image_data_in[62]), .DI63(image_data_in[63]),
                 .CK(clk), .WEB(image_WEB), .OE(1'b1), .CS(1'b1)); // 2048 words * 64 bits

reg signed  [7:0] mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61 ;
reg signed  [7:0] mul_12 , mul_22 , mul_32 , mul_42 , mul_52 , mul_62 , mul_72 , mul_82 , mul_92 , mul_102 ;
wire signed[15:0] mul_result1 , mul_result2 , mul_result3 , mul_result4 , mul_result5 ;
wire signed[15:0] mul_result6 , mul_result7 , mul_result8 , mul_result9 , mul_result10 ;
wire signed[15:0] mul_result11 , mul_result12 , mul_result13 , mul_result14 , mul_result15 ;
wire signed[15:0] mul_result16 , mul_result17 , mul_result18 , mul_result19 , mul_result20 ;
assign mul_result1 = mul_11 * mul_12 ;
assign mul_result2 = mul_21 * mul_22 ;
assign mul_result3 = mul_31 * mul_32 ;
assign mul_result4 = mul_41 * mul_42 ;
assign mul_result5 = mul_51 * mul_52 ;

assign mul_result6  = mul_21 * mul_12 ;
assign mul_result7  = mul_31 * mul_22 ;
assign mul_result8  = mul_41 * mul_32 ;
assign mul_result9  = mul_51 * mul_42 ;
assign mul_result10 = mul_61 * mul_52 ;

assign mul_result11 = mul_11 * mul_62 ;
assign mul_result12 = mul_21 * mul_72 ;
assign mul_result13 = mul_31 * mul_82 ;
assign mul_result14 = mul_41 * mul_92 ;
assign mul_result15 = mul_51 * mul_102 ;

assign mul_result16 = mul_21 * mul_62 ;
assign mul_result17 = mul_31 * mul_72 ;
assign mul_result18 = mul_41 * mul_82 ;
assign mul_result19 = mul_51 * mul_92 ;
assign mul_result20 = mul_61 * mul_102 ;

reg signed  [19:0] con_result1 , con_result2 , con_result3 ,  con_result4;
wire signed [19:0] add_result1 , add_result2 , add_result3 , add_result4;
reg signed  [19:0] out_temp;
assign add_result1 = (mul_result1 + mul_result2 )+ (mul_result3 + mul_result4 )+ ( mul_result5 + con_result1);
assign add_result2 = (mul_result6 + mul_result7 )+ (mul_result8 + mul_result9 )+  (mul_result10 + con_result2);
assign add_result3 = (mul_result11 + mul_result12) + (mul_result13 + mul_result14 )+ (mul_result15 + con_result3);
assign add_result4 = (mul_result16 + mul_result17) + (mul_result18 + mul_result19 )+ (mul_result20 + con_result4);


reg [4:0] c_state;
reg [1:0] size_temp ;
reg       mode_temp ;
reg [3:0] image_idx ;
reg [3:0] kernel_idx ;

reg [4:0] out_cnt ;
reg [2:0] load_cnt;
reg [2:0] conve_cnt;
reg signed [5:0] decon_cnt;
reg [4:0] valid_cnt;

wire image_finish;
assign image_finish = ( ( (size_temp == 0) && (image_addr ==  127) ) ||
                        ( (size_temp == 1) && (image_addr ==  511) ) ||
                        ( (size_temp == 2) && (image_addr == 2047) )) ;

reg [5:0] x ;
reg signed [6:0] y ;
reg [2:0] kernel_cnt ;
reg [1:0] right_shift ;

reg [6:0]kernel_addr_reg;
reg [10:0]image_addr_reg;

always @(*) begin // kernel_addr comb
    case(c_state)
        2,3:
            kernel_addr = kernel_addr_reg;
        4:
            kernel_addr = matrix_idx * 5  ;
        default:
            kernel_addr = kernel_idx * 5  + kernel_cnt ;
    endcase
end

always @(*) begin // image_addr comb
    case(c_state)
        1,2:
            image_addr = image_addr_reg;
        default: begin
            case(size_temp)  // save image_index
                0:
                    image_addr = {image_idx , 3'd0} + y  ;
                1:
                    image_addr = {image_idx , 5'd0} + 2 * y  + right_shift;
                2,3:
                    image_addr = {image_idx , 7'd0} + 4 * y +  right_shift ;
            endcase
        end
    endcase
end

///////////////////
reg next_row ;
reg mode0_finish;
reg [11:0]last_address;

always@(*) begin
    case(size_temp)
        0: begin
            next_row = (x == 2);
            //last_address = {(image_idx) , 3'b0} + 4;
            last_address = {(image_idx) , 3'b100} ;
            mode0_finish = (image_addr == last_address);
        end
        1: begin
            next_row = (x == 10);
            last_address = {(image_idx) , 5'b11000};
            //last_address = {(image_idx) , 5'b0} + 24;
            mode0_finish = (image_addr == last_address);
        end
        2,3: begin
            next_row = (x == 26);
            last_address = {(image_idx) , 7'b1110000} ;
            //last_address = {(image_idx) , 7'b0} + 112;
            mode0_finish = (image_addr == last_address);
        end
    endcase
end
/////////// mode 0

reg [5:0] last_address2;
reg mode1_finish;
reg out_image;
always@(*) begin
    case(size_temp)
        0: begin
            last_address2 = 11 ;
            mode1_finish = (y == 8);
        end
        1: begin
            last_address2 = 19 ;
            mode1_finish = (y == 16);
        end
        2,3: begin
            last_address2 = 35 ;
            mode1_finish = (y == 32);
        end
    endcase

    out_image = decon_cnt < 0 || decon_cnt > last_address2 - 4;
end
/////////// mode 1



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        c_state <= 0;
        size_temp  <= 0;
        image_idx  <= 0;
        kernel_idx <= 0;

        image_addr_reg <= 0;
        image_WEB <= 1; //read

        kernel_addr_reg <= -1;
        kernel_WEB  <= 1; //read
        kernel_CS <= 0; //stand by

        x <= 0;
        y <= 0;
        kernel_cnt <= 0;
        right_shift <= 0;

        con_result1 <= 0;
        con_result2 <= 0;
        con_result3 <= 0;
        con_result4 <= 0;

        conve_cnt <= 0;
        decon_cnt <= 0;
        valid_cnt <= 0;
        load_cnt <= 1;
    end
    else begin
        case(c_state)
            0: begin
                valid_cnt <= 0;
                if(in_valid) begin
                    image_data_in[63:56] <= matrix ;
                    size_temp <= matrix_size;

                    c_state <= c_state + 1 ;
                end
            end
            1: begin //  Load_image
                image_WEB <= 1;  //Read
                load_cnt <= load_cnt + 1;
                case(load_cnt)
                    0:  begin
                        image_addr_reg <=  image_addr_reg + 1;
                        image_data_in[63:56] <= matrix ;
                    end
                    1:
                        image_data_in[55:48] <= matrix ;
                    2:
                        image_data_in[47:40] <= matrix ;
                    3:
                        image_data_in[39:32] <= matrix ;
                    4:
                        image_data_in[31:24] <= matrix ;
                    5:
                        image_data_in[23:16] <= matrix ;
                    6:
                        image_data_in[15: 8] <= matrix ;
                    7: begin
                        image_data_in[ 7: 0] <= matrix ;
                        image_WEB <= 0;  //Write

                        if(image_finish)
                            c_state <= c_state + 1;
                    end
                endcase
            end

            2: begin //Load kernel
                image_WEB <= 1;  //Read
                kernel_WEB  <= 1; //read

                case(load_cnt)
                    0:
                        kernel_data_in[39:32] <= matrix ;
                    1:
                        kernel_data_in[31:24] <= matrix ;
                    2:
                        kernel_data_in[23:16] <= matrix ;
                    3:
                        kernel_data_in[15: 8] <= matrix ;
                    4: begin
                        kernel_data_in[ 7: 0] <= matrix ;
                        kernel_WEB <= 0;  //Write
                        kernel_CS  <= 1;

                        kernel_addr_reg <=  kernel_addr_reg + 1;

                        if(kernel_addr_reg == 78)
                            c_state <= c_state + 1;
                    end
                endcase

                if( load_cnt == 4)
                    load_cnt <= 0;
                else
                    load_cnt <=  load_cnt + 1;
            end

            3: begin //in_valid2 - 1
                kernel_WEB  <= 1; //read
                if(in_valid2) begin
                    mode_temp <= mode;
                    image_idx <= matrix_idx;
                    valid_cnt <= valid_cnt + 1;
                    c_state <= c_state + 1 ;
                end
            end
            4: begin //in_valid2 - 2
                if(mode_temp == 0) begin// Convelution
                    c_state <= c_state + 1;
                    y <= y + 1;
                    kernel_cnt <= kernel_cnt + 1;
                end
                else  begin             // Deconvelution;
                    c_state <= 14;
                end

                kernel_idx <= matrix_idx;
            end
            5: begin  // 5 ~ 8 first output
                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[63:16];
                {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52} <=  kernel_data_out;

                y <= y + 1;
                kernel_cnt <= kernel_cnt + 1;

                c_state <= c_state + 1;
            end
            6: begin
                con_result1 <= add_result1;
                con_result2 <= add_result2;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[63:16];
                {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}         <=  kernel_data_out;
                {mul_62 , mul_72 , mul_82 , mul_92 ,  mul_102}        <=  {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}  ;

                y <= y + 1;
                kernel_cnt <= kernel_cnt + 1;

                c_state <= c_state + 1;
            end
            7: begin
                con_result1 <= add_result1;
                con_result2 <= add_result2;
                con_result3 <= add_result3;
                con_result4 <= add_result4;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[63:16];
                {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}         <=  kernel_data_out;
                {mul_62 , mul_72 , mul_82 , mul_92 ,  mul_102}        <=  {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}  ;

                if(conve_cnt == 3) begin
                    y <= 0;
                    kernel_cnt <= 0;
                    c_state <= c_state + 1;
                    conve_cnt <= 0;
                end
                else begin
                    if(y < 5)
                        y <= y + 1;
                    if(kernel_cnt < 4)
                        kernel_cnt <= kernel_cnt + 1;
                    conve_cnt <= conve_cnt + 1;
                end

            end
            8: begin
                con_result1 <= 0 ;
                con_result2 <= 0 ;
                con_result3 <= 0 ;
                con_result4 <= 0 ;
                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  0 ;
                {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}         <=  0 ;
                {mul_62 , mul_72 , mul_82 , mul_92 ,  mul_102}        <=  0 ;

                x <= 2;
                right_shift <= right_shift + 1;

                c_state <= c_state + 1;
            end

            9: begin  // 9 ~    : CONVELUTION
                con_result3 <= add_result3;
                con_result4 <= add_result4;


                {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}  <=  kernel_data_out;
                {mul_62 , mul_72 , mul_82 , mul_92 ,  mul_102} <=  {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}  ;

                case(x[2:0])
                    0:
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[63:16];
                    1:
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[55: 8];
                    2:
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  image_data_out[47: 0];
                    3:
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 }         <=  image_data_out[39: 0];
                    4:
                        {mul_11 , mul_21 , mul_31 , mul_41 }                  <=  image_data_out[31: 0];
                    5:
                        {mul_11 , mul_21 , mul_31 }                           <=  image_data_out[23: 0];
                    6:
                        {mul_11 , mul_21 }                                    <=  image_data_out[15: 0];
                    7:
                        {mul_11}                                              <=  image_data_out[ 7: 0];
                endcase

                if(conve_cnt < 4) begin
                    kernel_cnt <= kernel_cnt + 1;
                end

                if(conve_cnt < 5) begin
                    y <= y + 1;
                end

                if(conve_cnt == 6) begin
                    conve_cnt <= 0 ;
                    c_state <= c_state + 2 ;
                end
                else begin
                    right_shift <= right_shift - 1;
                    con_result1 <= add_result1;
                    con_result2 <= add_result2;

                    conve_cnt <= conve_cnt + 1;
                    c_state <= c_state + 1;
                end
            end

            10: begin
                case(x[2:0])
                    3:
                        {mul_61}                                         <=  image_data_out[63:56];
                    4:
                        {mul_51 , mul_61}                                <=  image_data_out[63:48];
                    5:
                        {mul_41 , mul_51 , mul_61}                       <=  image_data_out[63:40];
                    6:
                        {mul_31 , mul_41 , mul_51 , mul_61}              <=  image_data_out[63:32];
                    7:
                        {mul_21 , mul_31 , mul_41 , mul_51 , mul_61}     <=  image_data_out[63:24];
                endcase

                right_shift <= right_shift + 1;
                c_state <= c_state - 1;
            end
            11: begin
                if(con_result1 < con_result2)
                    con_result1 <= con_result2 ;

                if(con_result3 < con_result4)
                    con_result3 <= con_result4 ;

                kernel_cnt <= 0;
                if(next_row) begin
                    x <= 0 ;
                    right_shift <= 0;
                    y <= y - 3 ;
                end
                else begin
                    x <= x + 2;
                    y <= y - 5 ;

                    if(x[2:0] != 6) begin
                        right_shift <=  right_shift - 1; //
                    end
                end

                c_state <= c_state + 1;
            end
            12: begin
                if(con_result1 < con_result3)
                    con_result1 <= con_result3 ;

                if(conve_cnt == 5) begin
                    conve_cnt <= 0;
                    con_result1 <= 0 ;
                    con_result2 <= 0 ;
                    con_result3 <= 0 ;
                    con_result4 <= 0 ;
                    {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 , mul_61} <=  0 ;
                    {mul_12 , mul_22 , mul_32 , mul_42 ,  mul_52}         <=  0 ;
                    {mul_62 , mul_72 , mul_82 , mul_92 ,  mul_102}        <=  0 ;

                    right_shift <=  right_shift + 1;

                    if(mode0_finish)
                        c_state <= c_state + 1;
                    else
                        c_state <= 9;
                end
                else begin
                    conve_cnt <= conve_cnt + 1;
                end
            end

            13: begin
                x <= 0 ;
                y <= 0 ;
                decon_cnt <= 0;
                right_shift <= 0;
                kernel_cnt <= 0;

                if(out_cnt == 20) begin
                    if(valid_cnt == 16) begin
                        image_addr_reg <= 0;
                        kernel_addr_reg <= -1;
                        kernel_CS <= 0; //stand by
                        load_cnt <= 1;
                        c_state <= 0 ;  // read next valid1
                    end
                    else
                        c_state <= 3 ;  // read next valid 2
                end
            end
            14: begin // DECONV
                x <= x + 1;

                kernel_cnt <= 4;
                y <= -4 ;
                decon_cnt <= - 4 ;

                mul_11 <= image_data_out[63:56];
                mul_12 <= kernel_data_out[39:32];

                c_state <=  c_state + 1;
            end
            15: begin //first output
                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  0 ;
                {mul_12 , mul_22 , mul_32 , mul_42 , mul_52 } <=  0 ;
                right_shift <= right_shift + 1;
                c_state <=  c_state + 1;
            end
            16: begin  // 16 ~  17  : CONVELUTION
                con_result1 <= add_result1;

                case(x)
                    0 :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {kernel_data_out[39:32] , 32'b0};
                    1 :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {kernel_data_out[31:24] , kernel_data_out[39:32] , 24'b0};
                    2 :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {kernel_data_out[23:16] , kernel_data_out[31:24] , kernel_data_out[39:32] , 16'b0};
                    3 :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {kernel_data_out[15: 8] , kernel_data_out[23:16] , kernel_data_out[31:24] , kernel_data_out[39:32] , 8'b0};
                    last_address2 - 3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {8'b0 , kernel_data_out[ 7: 0] , kernel_data_out[15: 8] , kernel_data_out[23:16] , kernel_data_out[31:24] };

                    last_address2 - 2:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {16'b0 , kernel_data_out[ 7: 0] , kernel_data_out[15: 8] , kernel_data_out[23:16]};

                    last_address2 - 1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {24'b0 , kernel_data_out[ 7: 0] , kernel_data_out[15: 8] };

                    last_address2 :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {32'b0 , kernel_data_out[7: 0]};

                    default :
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52}  <=  {kernel_data_out[ 7: 0] , kernel_data_out[15: 8] , kernel_data_out[23:16] , kernel_data_out[31:24] , kernel_data_out[39:32] };

                endcase

                if( out_image)
                    {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  0;
                else begin
                    if(x < 5)
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[63: 24];
                    else if(x > last_address2 - 5)
                        {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[39: 0];
                    else begin
                        case(x[2:0])
                            4 :
                                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[63: 24];
                            5:
                                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[55: 16];
                            6:
                                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[47: 8];
                            7:
                                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  image_data_out[39: 0];
                            0:
                                {mul_11 , mul_21 , mul_31 , mul_41 }          <=  image_data_out[31: 0];
                            1:
                                {mul_11 , mul_21 , mul_31 }                   <=  image_data_out[23: 0];
                            2:
                                {mul_11 , mul_21 }                            <=  image_data_out[15: 0];
                            3:
                                {mul_11}                                      <=  image_data_out[ 7: 0];
                        endcase
                    end
                end

                y <= y + 1;
                if(kernel_cnt > 0)
                    kernel_cnt <= kernel_cnt - 1;

                right_shift <= right_shift - 1;
                c_state <= c_state + 1;
            end

            17: begin
                if( out_image)
                    {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <=  0;
                else begin
                    if(x > 4 && x < last_address2 - 4) begin
                        case(x[2:0])
                            0:
                                {mul_51}                                      <=  image_data_out[63:56];
                            1:
                                {mul_41 , mul_51 }                            <=  image_data_out[63:48];
                            2:
                                {mul_31 , mul_41 , mul_51 }                   <=  image_data_out[63:40];
                            3:
                                {mul_21 , mul_31 , mul_41 , mul_51 }          <=  image_data_out[63:32];
                        endcase
                    end
                end

                right_shift <= right_shift + 1;
                decon_cnt <= decon_cnt + 1;

                if(conve_cnt == 4) begin
                    conve_cnt <= 0;
                    c_state <= c_state + 1;
                end
                else begin
                    conve_cnt <= conve_cnt + 1;
                    c_state <= c_state - 1;
                end

            end
            18: begin
                decon_cnt <= 0;
                c_state <= c_state + 1;

                kernel_cnt <= 4;
                if(x == last_address2 ) begin
                    x <= 0 ;
                    right_shift <= 0;
                    y <= y - 4 ;
                end
                else begin
                    x <= x + 1;
                    y <= y - 5 ;

                    if(x != 11 && x != 19 && x != 27 ) begin
                        right_shift <=  right_shift - 1; //
                    end
                end

                con_result1 <= add_result1;
                c_state <= c_state + 1;
            end

            19: begin
                if( decon_cnt == 8) begin
                    decon_cnt <= y ;

                    con_result1 <= 0;
                    {mul_11 , mul_21 , mul_31 , mul_41 , mul_51 } <= 0 ;

                    right_shift <= right_shift + 1;
                    if( mode1_finish )
                        c_state <= 13;
                    else
                        c_state <= 16;
                end
                else begin
                    decon_cnt <=  decon_cnt + 1;
                end
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_value <= 0;
        out_temp  <= 0 ;

        out_cnt <= 0;
    end
    else begin
        case(c_state)
            7: begin
                if(add_result1 > add_result2)
                    out_temp <= add_result1;
                else
                    out_temp <= add_result2;
            end
            8 : begin
                out_valid <= 1;
                out_cnt <= 1;

                if(add_result3 > add_result4) begin
                    if( add_result3 > out_temp  ) begin
                        out_temp <= add_result3;
                        out_value <= add_result3[0];
                    end
                    else   begin
                        out_value <= out_temp[0];
                    end
                end
                else begin
                    if( add_result4 > out_temp  ) begin
                        out_temp <= add_result4;
                        out_value <= add_result4[0];
                    end
                    else   begin
                        out_value <= out_temp[0];
                    end
                end

            end
            9, 10 ,11 ,12: begin
                if(out_cnt == 20) begin
                    out_cnt <= 1 ;
                    out_value <= con_result1[0];
                    out_temp <= con_result1;
                end
                else begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end
            13: begin  // last output
                if(out_cnt == 20) begin
                    out_cnt <= 0 ;
                    out_value <= 0;
                    out_valid <= 0;
                end
                else begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end
            15: begin
                out_value <= mul_result1[0];
                out_valid <= 1;
                out_temp <= mul_result1;
                out_cnt <= 1 ;
            end
            16,17,18,19: begin
                if(out_cnt == 20) begin
                    out_cnt <= 1 ;
                    out_value <= con_result1[0];
                    out_temp <= con_result1;
                end
                else begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end
        endcase
    end
end
endmodule  // 1171533.739563 7
           // 1108794.0005478 8
