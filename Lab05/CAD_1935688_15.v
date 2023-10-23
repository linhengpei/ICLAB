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


reg  [11:0] image_addr_a;
reg  [11:0] image_addr_b;
//assign image_addr_b = image_addr_a + 1;

reg [31:0] image_data_in_a;
wire [31:0] image_data_in_b;
assign image_data_in_b = 0;

wire [31:0] image_data_out_a;
wire [31:0] image_data_out_b;
wire [63:0] image_data_out;
assign image_data_out = {image_data_out_a , image_data_out_b};
reg  image_WEB_A;
wire image_WEB_B;
assign image_WEB_B = 1 ; //always read
wire CS , OE;
assign CS = 1;
assign OE = 1;

IMAGE image_sram(.A0(image_addr_a[0]), .A1(image_addr_a[1]), .A2(image_addr_a[2]), .A3(image_addr_a[3]), .A4(image_addr_a[4]), .A5(image_addr_a[5]), .A6(image_addr_a[6]), .A7(image_addr_a[7]), .A8(image_addr_a[8]), .A9(image_addr_a[9]), .A10(image_addr_a[10]), .A11(image_addr_a[11]),
                 .B0(image_addr_b[0]), .B1(image_addr_b[1]), .B2(image_addr_b[2]), .B3(image_addr_b[3]), .B4(image_addr_b[4]), .B5(image_addr_b[5]), .B6(image_addr_b[6]), .B7(image_addr_b[7]), .B8(image_addr_b[8]), .B9(image_addr_b[9]), .B10(image_addr_b[10]), .B11(image_addr_b[11]),
                 .DOA0 (image_data_out_a[0]) ,  .DOA1(image_data_out_a[1]) ,  .DOA2(image_data_out_a[2]) ,  .DOA3(image_data_out_a[3]) ,  .DOA4(image_data_out_a[4]) ,  .DOA5(image_data_out_a[5]) ,  .DOA6(image_data_out_a[6]) ,  .DOA7(image_data_out_a[7]) ,
                 .DOA8 (image_data_out_a[8]) ,  .DOA9(image_data_out_a[9]) , .DOA10(image_data_out_a[10]), .DOA11(image_data_out_a[11]), .DOA12(image_data_out_a[12]), .DOA13(image_data_out_a[13]), .DOA14(image_data_out_a[14]), .DOA15(image_data_out_a[15]),
                 .DOA16(image_data_out_a[16]), .DOA17(image_data_out_a[17]), .DOA18(image_data_out_a[18]), .DOA19(image_data_out_a[19]), .DOA20(image_data_out_a[20]), .DOA21(image_data_out_a[21]), .DOA22(image_data_out_a[22]), .DOA23(image_data_out_a[23]),
                 .DOA24(image_data_out_a[24]), .DOA25(image_data_out_a[25]), .DOA26(image_data_out_a[26]), .DOA27(image_data_out_a[27]), .DOA28(image_data_out_a[28]), .DOA29(image_data_out_a[29]), .DOA30(image_data_out_a[30]), .DOA31(image_data_out_a[31]),
                 .DOB0 (image_data_out_b[0]) ,  .DOB1(image_data_out_b[1]) ,  .DOB2(image_data_out_b[2]) ,  .DOB3(image_data_out_b[3]) ,  .DOB4(image_data_out_b[4]) ,  .DOB5(image_data_out_b[5]) ,  .DOB6(image_data_out_b[6]) ,  .DOB7(image_data_out_b[7]) ,
                 .DOB8 (image_data_out_b[8]) ,  .DOB9(image_data_out_b[9]) , .DOB10(image_data_out_b[10]), .DOB11(image_data_out_b[11]), .DOB12(image_data_out_b[12]), .DOB13(image_data_out_b[13]), .DOB14(image_data_out_b[14]), .DOB15(image_data_out_b[15]),
                 .DOB16(image_data_out_b[16]), .DOB17(image_data_out_b[17]), .DOB18(image_data_out_b[18]), .DOB19(image_data_out_b[19]), .DOB20(image_data_out_b[20]), .DOB21(image_data_out_b[21]), .DOB22(image_data_out_b[22]), .DOB23(image_data_out_b[23]),
                 .DOB24(image_data_out_b[24]), .DOB25(image_data_out_b[25]), .DOB26(image_data_out_b[26]), .DOB27(image_data_out_b[27]), .DOB28(image_data_out_b[28]), .DOB29(image_data_out_b[29]), .DOB30(image_data_out_b[30]), .DOB31(image_data_out_b[31]),
                 .DIA0 (image_data_in_a[0]) ,  .DIA1(image_data_in_a[1]) ,  .DIA2(image_data_in_a[2]) ,  .DIA3(image_data_in_a[3]) ,  .DIA4(image_data_in_a[4]) ,  .DIA5(image_data_in_a[5]) ,  .DIA6(image_data_in_a[6]) ,  .DIA7(image_data_in_a[7]) ,
                 .DIA8 (image_data_in_a[8]) ,  .DIA9(image_data_in_a[9]) , .DIA10(image_data_in_a[10]), .DIA11(image_data_in_a[11]), .DIA12(image_data_in_a[12]), .DIA13(image_data_in_a[13]), .DIA14(image_data_in_a[14]), .DIA15(image_data_in_a[15]),
                 .DIA16(image_data_in_a[16]), .DIA17(image_data_in_a[17]), .DIA18(image_data_in_a[18]), .DIA19(image_data_in_a[19]), .DIA20(image_data_in_a[20]), .DIA21(image_data_in_a[21]), .DIA22(image_data_in_a[22]), .DIA23(image_data_in_a[23]),
                 .DIA24(image_data_in_a[24]), .DIA25(image_data_in_a[25]), .DIA26(image_data_in_a[26]), .DIA27(image_data_in_a[27]), .DIA28(image_data_in_a[28]), .DIA29(image_data_in_a[29]), .DIA30(image_data_in_a[30]), .DIA31(image_data_in_a[31]),
                 .DIB0 (image_data_in_b[0]) ,  .DIB1(image_data_in_b[1]) ,  .DIB2(image_data_in_b[2]) ,  .DIB3(image_data_in_b[3]) ,  .DIB4(image_data_in_b[4]) ,  .DIB5(image_data_in_b[5]) ,  .DIB6(image_data_in_b[6]) ,  .DIB7(image_data_in_b[7]) ,
                 .DIB8 (image_data_in_b[8]) ,  .DIB9(image_data_in_b[9]) , .DIB10(image_data_in_b[10]), .DIB11(image_data_in_b[11]), .DIB12(image_data_in_b[12]), .DIB13(image_data_in_b[13]), .DIB14(image_data_in_b[14]), .DIB15(image_data_in_b[15]),
                 .DIB16(image_data_in_b[16]), .DIB17(image_data_in_b[17]), .DIB18(image_data_in_b[18]), .DIB19(image_data_in_b[19]), .DIB20(image_data_in_b[20]), .DIB21(image_data_in_b[21]), .DIB22(image_data_in_b[22]), .DIB23(image_data_in_b[23]),
                 .DIB24(image_data_in_b[24]), .DIB25(image_data_in_b[25]), .DIB26(image_data_in_b[26]), .DIB27(image_data_in_b[27]), .DIB28(image_data_in_b[28]), .DIB29(image_data_in_b[29]), .DIB30(image_data_in_b[30]), .DIB31(image_data_in_b[31]),
                 .WEAN (image_WEB_A) , .WEBN(image_WEB_B), .CKA(~clk), .CKB(~clk), .CSA(CS), .CSB(CS), .OEA(OE), .OEB(OE) );

wire CLK;
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
                   .CK(~clk), .WEB(kernel_WEB), .OE(OE), .CS(kernel_CS));

reg signed  [7:0] mul_11 , mul_12 , mul_21 , mul_22 , mul_31 , mul_32 , mul_41 , mul_42 , mul_51 , mul_52;
wire signed[15:0] mul_result1 , mul_result2 , mul_result3 , mul_result4 , mul_result5 ;
assign mul_result1 = mul_11 * mul_12 ;
assign mul_result2 = mul_21 * mul_22 ;
assign mul_result3 = mul_31 * mul_32 ;
assign mul_result4 = mul_41 * mul_42 ;
assign mul_result5 = mul_51 * mul_52 ;


reg [4:0] out_cnt ;

reg signed [19:0] con_result ;
wire signed [19:0] add_result;
reg signed[19:0] out_temp;
reg signed [19:0] max;
assign add_result = (mul_result1 + mul_result2) + (mul_result3 + mul_result4) + (mul_result5 + con_result);


reg [4:0] valid_cnt; // numbers of valid2
reg [2:0] counter;
reg [4:0] c_state ;
parameter Idle          =  0,
          Load_image    =  1,
          Load_kernel   =  2,
          Load_id1      =  3,
          Load_id2      =  4,

          Convelution   =  5,
          Output0       = 15,

          Deconvelution = 16,
          Output1       = 26;

reg [1:0] size_temp ;
reg [3:0] Image_index ;
reg  mode_temp;

reg [3:0] row ;
reg [5:0] shift;
reg next_row ;
reg mode0_finish;
reg [11:0]last_address;
reg out_ready;

always@(*) begin
    case(size_temp)
        0: begin
            row =  2;
            next_row = (shift == 3);
            last_address = {(Image_index) , 4'b0} + 15;
            mode0_finish = (image_addr_b == last_address);
        end
        1: begin
            row = 4;
            next_row = (shift == 11);
            last_address = {(Image_index) , 6'b0} + 63;
            mode0_finish = (image_addr_b == last_address);
        end
        2,3: begin
            row = 8;
            next_row = (shift == 27);
            last_address = {(Image_index) , 8'b0} + 255;
            mode0_finish = (image_addr_b == last_address);
        end
    endcase
end
/////////// mode 0

reg [5:0]x;
reg [5:0]y;

reg signed [3:0] shift2;
reg next_row2 ;
reg [5:0] last_address2;

reg out_image; // calculate edge od image when deconvelution
always@(*) begin
    case(size_temp)
        0: begin
            last_address2 = 11 ;
        end
        1: begin
            last_address2 = 19 ;
        end
        2,3: begin
            last_address2 = 35 ;
        end
    endcase
    next_row2 = (x == last_address2);
    out_image = (counter > y && y < 4) || (  y - counter > last_address2 - 4 && y > last_address2 - 4 ) ;
end
/////////// mode 1


wire image_finish;
reg start;
assign image_finish = ( ( (size_temp == 0) && (image_addr_a ==  255) ) ||
                        ( (size_temp == 1) && (image_addr_a == 1023) ) ||
                        ( (size_temp == 2) && (image_addr_a == 4095) && start ) ) ;

wire kernel_finish;
assign kernel_finish = (kernel_addr == 79) ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin

        shift <= 0;
        start <= 0;

        image_addr_a <= 4095;
        image_WEB_A <= 1; //read

        image_addr_b <= 0;

        kernel_addr <= -1;

        //kernel_WEB  <= 1; //read
        kernel_CS <= 0; //stand by

        out_ready <= 0;
        max <= 0;

        valid_cnt <= 0;

        x <= 0;
        y <= 0;
        c_state <= 0;
        counter <= 1;
    end
    else begin
        case(c_state)
            Idle: begin
                valid_cnt <= 0;
                if(in_valid) begin
                    image_data_in_a[31:24] <= matrix;
                    size_temp <= matrix_size;

                    c_state <= c_state + 1;
                end
            end
            Load_image: begin
                image_WEB_A <= 1; //read

                case(counter)
                    0:
                        image_data_in_a[31:24] <= matrix;
                    1:
                        image_data_in_a[23:16] <= matrix;
                    2:
                        image_data_in_a[15:8] <= matrix;
                    3: begin
                        image_data_in_a[7:0] <= matrix;
                        image_WEB_A <= 0;  //Write
                        image_addr_a <=  image_addr_a + 1;
                        start <= 1;
                    end
                endcase

                if(counter == 3)
                    counter <= 0;
                else
                    counter <= counter + 1;

                if(image_finish) begin
                    c_state <= c_state + 1;
                    kernel_data_in[39:32] <= matrix;
                end
            end
            Load_kernel: begin
                image_WEB_A <= 1; //read

                kernel_WEB  <= 1; //read

                case(counter)
                    0:
                        kernel_data_in[39:32] <= matrix;
                    1:
                        kernel_data_in[31:24] <= matrix;
                    2:
                        kernel_data_in[23:16] <= matrix;
                    3:
                        kernel_data_in[15:8] <= matrix;
                    4: begin
                        kernel_data_in[7:0] <= matrix;
                        kernel_WEB  <= 0; //Write
                        kernel_CS <= 1;

                        kernel_addr <= kernel_addr + 1;
                    end
                endcase

                if(counter == 4)
                    counter <= 0;
                else
                    counter <= counter + 1;

                if(kernel_finish)
                    c_state <= c_state + 1;
            end

            Load_id1: begin
                if(in_valid2) begin
                    valid_cnt <=  valid_cnt + 1;

                    mode_temp <= mode;
                    Image_index <= matrix_idx;


                    c_state <= c_state + 1;
                end
            end
            Load_id2: begin // save kernel_index
                kernel_addr <= 5 * matrix_idx ;


                kernel_WEB <= 1; // read
                kernel_CS <= 1;

                case(size_temp)  // save image_index
                    0: begin
                        image_addr_a <= {Image_index , 4'd0};
                        image_addr_b <= {Image_index , 4'd0} + 1;
                    end
                    1: begin
                        image_addr_a <= {Image_index , 6'd0};
                        image_addr_b <= {Image_index , 6'd0} + 1;
                    end
                    2: begin
                        image_addr_a <= {Image_index , 8'd0};
                        image_addr_b <= {Image_index , 8'd0} + 1;
                    end
                endcase

                if(mode_temp == 0) begin // Convelution
                    c_state <=  c_state + 1;
                end
                else begin             // Deconvelution;
                    c_state <= Deconvelution;
                end
            end
            5: begin  // start calculate  up left
                if(add_result > max)  // save max in out_temp
                    out_temp <= add_result;
                else
                    out_temp <= max;

                max <= {1'b1 , 19'b0}; // -2 ^ 19
                con_result <= 0;
                counter <= 1;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;
                case( shift[1:0] ) // only 0 2 is posible
                    0:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[63:24];
                    2:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[47:8];
                endcase

                kernel_addr <=  kernel_addr  + 1;
                image_addr_a <= image_addr_a + row;
                image_addr_b <= image_addr_b + row;

                c_state <= c_state  +  1;
            end
            6: begin
                con_result <= add_result;
                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 0 2 is posible
                    0:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[63:24];
                    2:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[47:8];
                endcase

                if(counter == 4) begin //dont need to change new image address
                    kernel_addr <=  kernel_addr  - 4;
                    image_addr_a <= image_addr_a - {row,2'b0};
                    image_addr_b <= image_addr_b - {row,2'b0};

                    shift <= shift + 1 ;
                    c_state <= c_state  +  1;
                    counter <= 0 ;
                end
                else begin
                    counter <= counter + 1 ;
                    kernel_addr <=  kernel_addr  + 1;
                    image_addr_a <= image_addr_a + row;
                    image_addr_b <= image_addr_b + row;
                end
            end
            7: begin // up right
                if(add_result > max)
                    max <= add_result;

                con_result <= 0;
                counter <= 1;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 1 3 is posible
                    1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[55:16];
                    3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                endcase

                kernel_addr <=  kernel_addr  + 1;
                image_addr_a <= image_addr_a + row;
                image_addr_b <= image_addr_b + row;

                c_state <= c_state  +  1;
            end
            8: begin
                con_result <= add_result;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 1 3 is posible
                    1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[55:16];
                    3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                endcase

                if(counter == 4) begin
                    kernel_addr <=  kernel_addr  - 4;
                    image_addr_a <= image_addr_a - row * 3;
                    image_addr_b <= image_addr_b - row * 3;

                    shift <= shift -  1 ;
                    c_state <= c_state  +  1;
                    counter <= 0 ;
                end
                else begin
                    kernel_addr <=  kernel_addr  + 1;
                    image_addr_a <= image_addr_a + row;
                    image_addr_b <= image_addr_b + row;

                    counter <= counter + 1 ;
                end
            end
            9: begin // down left
                if(add_result > max)
                    max <= add_result;

                con_result <= 0;
                counter <= 1;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 0 2 is posible
                    0:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[63:24];
                    2:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[47:8];
                endcase

                kernel_addr <=  kernel_addr  + 1;
                image_addr_a <= image_addr_a + row;
                image_addr_b <= image_addr_b + row;

                c_state <= c_state  +  1;
            end
            10: begin
                con_result <= add_result;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 0 2 is posible
                    0:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[63:24];
                    2:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[47:8];
                endcase

                if(counter == 4) begin
                    kernel_addr <=  kernel_addr  - 4;
                    image_addr_a <= image_addr_a - {row,2'b0};
                    image_addr_b <= image_addr_b - {row,2'b0};

                    shift <= shift +  1 ;

                    c_state <= c_state  +  1;
                    counter <= 0 ;
                end
                else begin
                    kernel_addr <=  kernel_addr  + 1;
                    image_addr_a <= image_addr_a + row;
                    image_addr_b <= image_addr_b + row;

                    counter <= counter + 1 ;
                end
            end
            11: begin // down left
                if(add_result > max)
                    max <= add_result;

                con_result <= 0;
                counter <= 1;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 1 3 is posible
                    1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[55:16];
                    3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                endcase

                kernel_addr <=  kernel_addr  + 1;
                image_addr_a <= image_addr_a + row;
                image_addr_b <= image_addr_b + row;

                c_state <= c_state  +  1;
            end
            12: begin
                con_result <= add_result;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 1 3 is posible
                    1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[55:16];
                    3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                endcase

                kernel_addr <=  kernel_addr  + 1;
                image_addr_a <= image_addr_a + row;
                image_addr_b <= image_addr_b + row;

                if(counter == 3) begin
                    c_state <= c_state  +  1;
                    counter <= 0 ;
                end
                else begin
                    counter <= counter + 1 ;
                end
            end
            13: begin  // last cycle
                con_result <= add_result;

                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= kernel_data_out ;

                case( shift[1:0] ) // only 1 3 is posible
                    1:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[55:16];
                    3:
                        {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                endcase

                kernel_addr <=  kernel_addr  - 4;
                shift <= shift + 1 ;

                if(shift[1:0] == 3) begin
                    if(next_row ) begin
                        shift <= 0;
                        image_addr_a <= image_addr_a - {row,2'b0} + 2 ;
                        image_addr_b <= image_addr_b - {row,2'b0} + 2 ;
                    end
                    else begin
                        image_addr_a <= image_addr_a - {row,2'b0} - row + 1;
                        image_addr_b <= image_addr_b - {row,2'b0} - row + 1;
                    end
                end
                else begin //dont need to change new image address
                    image_addr_a <= image_addr_a - row * 5;
                    image_addr_b <= image_addr_b - row * 5;
                end

                out_ready <= 1 ; // start output

                if( mode0_finish && shift[1:0] == 3 )
                    c_state <=  c_state + 1;
                else
                    c_state <= 5;
            end
            14: begin


                image_addr_a <= -1;
                image_addr_b <= 0;

                kernel_addr <= -1;
                kernel_CS <= 0;

                start <= 0;
                counter <= 1;

                shift <= 0;
                out_ready <= 0;

                if(add_result > max)  // save max in out_temp
                    out_temp <= add_result;
                else
                    out_temp <= max;

                c_state <=  c_state + 1 ;
            end
            15: begin
                if(out_cnt == 20) begin
                    if(valid_cnt == 16)
                        c_state <= Idle ;      // read next valid1
                    else
                        c_state <= Load_id1 ;  // read next invalid 2
                end
            end

            // deconvelution
            16: begin
                {mul_11 , mul_21 , mul_31 , mul_41 , mul_51} <= { kernel_data_out[39:32] , 32'b0} ; // kernel[0]
                {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= {  image_data_out[63:56] , 32'b0} ; //  image[0]

                con_result <= 0;

                x <= 1;
                y <= 0;
                counter <= 0;
                c_state <= c_state + 1 ;
            end

            17: begin
                out_temp  <= add_result;
                shift2 <= -3 ;

                image_addr_a <= image_addr_a  ;
                image_addr_b <= image_addr_b  ;

                c_state <= c_state + 1 ;
            end

            18: begin
                {mul_51 , mul_41 , mul_31 , mul_21 , mul_11} <= kernel_data_out ;

                case(x)
                    0 : begin
                        mul_11  <= kernel_data_out[39:32] ; //mul_1 <== mul_5
                        { mul_21 , mul_31 , mul_41 ,mul_51 } <= 0 ;
                    end
                    1 : begin
                        {mul_21 , mul_11 } <= kernel_data_out [39:24] ; //mul_1 <== mul_4  mul_2 <== mul_5
                        { mul_31 , mul_41 ,mul_51 } <= 0 ;
                    end
                    2 : begin
                        {mul_31 , mul_21 , mul_11 } <= kernel_data_out[39:16] ;
                        { mul_41 ,mul_51 } <= 0 ;
                    end
                    3 : begin
                        {mul_41 , mul_31 , mul_21 ,mul_11} <= kernel_data_out[39:8 ] ;
                        mul_51  <= 0 ;
                    end
                    last_address2 - 3 : begin
                        mul_11  <= 0 ;
                        {mul_51 , mul_41 , mul_31 ,mul_21} <=  kernel_data_out[31:0]  ;
                    end
                    last_address2 - 2 : begin
                        { mul_21 , mul_11 } <= 0 ;
                        {mul_51 , mul_41 , mul_31 } <=  kernel_data_out[23:0]  ;
                    end
                    last_address2 - 1: begin
                        { mul_31 , mul_21 , mul_11 } <= 0 ;
                        {mul_51 , mul_41 } <=  kernel_data_out[15:0]  ;
                    end
                    last_address2 : begin
                        { mul_41 , mul_31 , mul_21 , mul_11 } <= 0 ;
                        mul_51 <= kernel_data_out[7:0]  ;
                    end
                endcase

                c_state <= c_state + 1 ;
            end
            19: begin
                if(out_image) begin
                    {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= 0;
                end
                else begin
                    case( shift2 ) // only 0 2 is posible
                        -4,-3,-2,-1,0:
                            {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[63:24];
                        1:
                            {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[56:16];
                        2:
                            {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[47:8];
                        3,4,5,6,7:
                            {mul_12 , mul_22 , mul_32 , mul_42 , mul_52} <= image_data_out[39:0];
                    endcase
                end

                c_state <= c_state + 1 ;
            end
            20: begin
                con_result <= add_result ;

                if(counter == 4) begin
                    counter <= 0 ;
                    c_state <= c_state + 1;
                end
                else  begin
                    kernel_addr <= kernel_addr + 1;
                    image_addr_a <= image_addr_a  - row;
                    image_addr_b <= image_addr_b  - row;

                    counter <= counter  + 1;
                    c_state <= 18 ;
                end
            end

            21: begin
                if(shift2 == 3 && (x < last_address2 - 4)) begin // right shift 1
                    shift2 <= 0;
                    image_addr_a <= image_addr_a + {row,2'b0} + 1;
                    image_addr_b <= image_addr_b + {row,2'b0} + 1;
                end
                else begin
                    if(shift2 == 7) begin //next row
                        shift2 <= -4;
                        image_addr_a <= image_addr_a + {row,2'b0} + 2 ;
                        image_addr_b <= image_addr_b + {row,2'b0} + 2 ;
                    end
                    else begin //dont need to change new image address
                        image_addr_a <= image_addr_a + {row,2'b0};
                        image_addr_b <= image_addr_b + {row,2'b0};
                        shift2 <= shift2 + 1;
                    end
                end

                kernel_addr <= kernel_addr - 4;

                c_state <= c_state + 1 ;
            end
            22:   // wait until 20 cycles
                c_state <= c_state + 1;
            23:
                c_state <= c_state + 1;
            24:
                c_state <= c_state + 1;

            25: begin // save out_temp
                out_temp  <= con_result;
                con_result <= 0;

                c_state <= 18 ;

                if(x == last_address2 ) begin
                    x <= 0 ;
                    if(y == last_address2) begin
                        c_state <= c_state + 1 ;
                    end
                    else begin
                        y <= y + 1 ;
                    end
                end
                else begin
                    x <= x + 1;
                end
            end

            Output1: begin // wait next instruction

                image_addr_a <= -1;
                image_addr_b <= 0;


                kernel_CS <= 0;
                kernel_addr <= -1;

                counter <= 1;
                start <= 0;

                if(out_cnt == 20) begin // output_finish
                    if(valid_cnt == 16)
                        c_state <= Idle ;      // read next valid1
                    else
                        c_state <= Load_id1 ;  // read next invalid 2
                end
            end
        endcase
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_value <= 0;

        out_cnt <= 0;
    end
    else begin
        case(c_state)
            5: begin
                if( out_ready ) begin
                    out_valid <= 1;
                    out_cnt <= 1;
                    if(add_result > max)  // save max in out_temp
                        out_value <= add_result[0];
                    else
                        out_value <= max[0];
                end
            end
            6 , 7 , 8 , 9 , 10 ,
            11,12 , 13: begin
                if( out_ready ) begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end
            14: begin
                out_cnt <= 1;
                if(add_result > max)  // save max in out_temp
                    out_value <= add_result[0];
                else
                    out_value <= max[0];
            end

            Output0: begin //last output
                if(out_cnt == 20) begin
                    out_cnt <= 0 ;
                    out_valid <= 0;
                    out_value <= 0;
                end
                else begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end

            17: begin
                out_valid <= 1;
                out_value <= add_result[0];

                out_cnt   <= 1;
            end
            18,19,20,21,
            22,23,24: begin
                out_value <= out_temp[out_cnt] ;
                out_cnt <= out_cnt + 1 ;
            end
            25: begin
                out_value <= con_result[0];
                out_cnt <= 1;
            end
            Output1: begin
                if(out_cnt == 20) begin
                    out_cnt <= 0 ;
                    out_valid <= 0;
                    out_value <= 0;
                end
                else begin
                    out_value <= out_temp[out_cnt] ;
                    out_cnt <= out_cnt + 1 ;
                end
            end
        endcase
    end
end
endmodule
