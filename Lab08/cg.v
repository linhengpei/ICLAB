// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
           //Input Port
           clk,
           rst_n,
           cg_en,
           in_valid,
           Img,
           Kernel,
           Weight,
           Opt,

           //Output Port
           out_valid,
           out
       );
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

//---------------------------------------------------------------------
//   INPUTS & OUTPUTS
//---------------------------------------------------------------------
input rst_n, clk, in_valid;
input cg_en;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATIONS
//---------------------------------------------------------------------

reg [ 1:0] Opt_temp  ;
reg [31:0] Weight_temp  [3:0];
reg [31:0] Kernel_temp [26:0];
reg [31:0] Img_temp    [31:0];

reg [31:0] mul_1[9:0] ;
reg [31:0] mul_2[9:0] ;
wire[31:0] mul_result[9:0] ;
wire[ 7:0] status_inst;
wire [2:0] inst_rnd;
assign inst_rnd = 0;
// ================================================================= Multiplier
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul0 ( .a(mul_1[0]), .b(mul_2[0]), .rnd(inst_rnd), .z(mul_result[0]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul1 ( .a(mul_1[1]), .b(mul_2[1]), .rnd(inst_rnd), .z(mul_result[1]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul2 ( .a(mul_1[2]), .b(mul_2[2]), .rnd(inst_rnd), .z(mul_result[2]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul3 ( .a(mul_1[3]), .b(mul_2[3]), .rnd(inst_rnd), .z(mul_result[3]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul4 ( .a(mul_1[4]), .b(mul_2[4]), .rnd(inst_rnd), .z(mul_result[4]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul5 ( .a(mul_1[5]), .b(mul_2[5]), .rnd(inst_rnd), .z(mul_result[5]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul6 ( .a(mul_1[6]), .b(mul_2[6]), .rnd(inst_rnd), .z(mul_result[6]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul7 ( .a(mul_1[7]), .b(mul_2[7]), .rnd(inst_rnd), .z(mul_result[7]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul8 ( .a(mul_1[8]), .b(mul_2[8]), .rnd(inst_rnd), .z(mul_result[8]), .status(status_inst));
DW_fp_mult #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
           mul9 ( .a(mul_1[9]), .b(mul_2[9]), .rnd(inst_rnd), .z(mul_result[9]), .status(status_inst));
// =================================================================

reg [1:0]x;
reg [4:0]y;
reg [4:0]y_count;
wire [6:0]position;
assign position = {y,x};
integer i ,j ;
reg [1:0] c_state , n_state;
reg [9:0] state_cnt;

reg [31:0]conve[15:0];
reg [31:0]conve2[15:0];
reg con_n;
reg [3:0] con_index;
reg [31:0] max_pool[3:0];
reg [31:0] fully1  [3:0];
reg [31:0] fully2  [3:0];
reg [31:0] normal  [3:0];
reg [31:0] active  [3:0];
reg [31:0] distance[3:0];

reg [31:0] adjust0 , adjust1 ;
reg [31:0] i4,i5,i6,i7;

wire [31:0] sum_1[3:0] ;
wire [31:0] sum_2[3:0] ;
wire [31:0] sum_3[3:0] ;
wire [31:0] sum_result[3:0];
reg abs;

assign sum_1[0] = mul_result[0];
assign sum_2[0] = mul_result[1];
assign sum_3[0] = mul_result[2];
assign sum_1[1] = mul_result[3];
assign sum_2[1] = mul_result[4];
assign sum_3[1] = mul_result[5];
assign sum_1[2] = mul_result[6];
assign sum_2[2] = mul_result[7];
assign sum_3[2] = mul_result[8];

assign sum_1[3] = (abs)? {1'b0 , sum_result[0][30:0]} : sum_result[0];
assign sum_2[3] = (abs)? {1'b0 , sum_result[1][30:0]} : sum_result[1];
assign sum_3[3] = (abs)? {1'b0 , sum_result[2][30:0]} : sum_result[2];

// ================================================================= Adder3
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_1 (.a(sum_1[0]),.b(sum_2[0]) , .c(sum_3[0]) , .rnd(inst_rnd), .z(sum_result[0]), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_2 (.a(sum_1[1]),.b(sum_2[1]) , .c(sum_3[1]) , .rnd(inst_rnd), .z(sum_result[1]), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_3 (.a(sum_1[2]),.b(sum_2[2]) , .c(sum_3[2]) , .rnd(inst_rnd), .z(sum_result[2]), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_4 (.a(sum_1[3]),.b(sum_2[3]) , .c(sum_3[3]) , .rnd(inst_rnd), .z(sum_result[3]), .status(status_inst));
//===================================================================

wire [31:0] add_21;
reg  [31:0] add_22;
wire [31:0] add_result2;
assign add_21 = mul_result[9];
DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          add_2 ( .a(add_21), .b(add_22), .rnd(inst_rnd), .z(add_result2), .status(status_inst) );
//===================================================================

reg [31:0] cmp_11 , cmp_12 , cmp_21 , cmp_22 ;
wire [31:0]cmp1_z0 , cmp1_z1 , cmp2_z0 , cmp2_z1 ;
wire [31:0] cmp3_z0 , cmp3_z1 , cmp4_z0 , cmp4_z1 ; // cmp3_z1 is Max , cmp4_z0 is min
reg [1:0] Max_addr,Min_addr;
reg [1:0] Med_addr1,Med_addr2;
wire aeqb_inst[3:0];
wire altb_inst[3:0];
wire agtb_inst[3:0];
wire unordered;
wire zctr;
assign zctr = 0;
// zctr == 0 z0 = min(a,b) , z1 = Max(a,b)
always@(*) begin
    case({agtb_inst[2], agtb_inst[1] ,agtb_inst[0]})
        3'b000 : begin
            Max_addr  = 3;
            Med_addr1 = 1;
        end
        3'b001: begin
            Max_addr  = 3;
            Med_addr1 = 0;
        end
        3'b010: begin
            Max_addr  = 2;
            Med_addr1 = 1;
        end
        3'b011: begin
            Max_addr  = 2;
            Med_addr1 =
            0;
        end
        3'b100 : begin
            Max_addr  = 1;
            Med_addr1 = 3;
        end
        3'b110: begin
            Max_addr  = 1;
            Med_addr1 = 2;
        end
        3'b101 : begin
            Max_addr  = 0;
            Med_addr1 = 3;
        end
        3'b111: begin
            Max_addr  = 0;
            Med_addr1 = 2;
        end
    endcase

    case({agtb_inst[3], agtb_inst[1] ,agtb_inst[0]})
        3'b010: begin
            Min_addr  = 0;
            Med_addr2 = 3;
        end
        3'b000: begin
            Min_addr  = 0;
            Med_addr2 = 2;
        end
        3'b011: begin
            Min_addr  = 1;
            Med_addr2 = 3;
        end
        3'b001: begin
            Min_addr  = 1;
            Med_addr2 = 2;
        end
        3'b100 : begin
            Min_addr  = 2;
            Med_addr2 = 0;
        end
        3'b101: begin
            Min_addr  = 2;
            Med_addr2 = 1;
        end
        3'b110 : begin
            Min_addr  = 3;
            Med_addr2 = 0;
        end
        3'b111: begin
            Min_addr  = 3;
            Med_addr2 = 1;
        end
    endcase
end

// ================================================================= Comparater
DW_fp_cmp #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          cmp_1 ( .a(cmp_11), .b(cmp_12), .zctr(zctr), .aeqb(aeqb_inst[0]), .altb(altb_inst[0]), .agtb(agtb_inst[0]), .unordered(unordered_inst) , .z0(cmp1_z0), .z1(cmp1_z1), .status0(status_inst), .status1(status_inst) );
DW_fp_cmp #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          cmp_2 ( .a(cmp_21), .b(cmp_22), .zctr(zctr), .aeqb(aeqb_inst[1]), .altb(altb_inst[1]), .agtb(agtb_inst[1]), .unordered(unordered_inst) , .z0(cmp2_z0), .z1(cmp2_z1), .status0(status_inst), .status1(status_inst) );
DW_fp_cmp #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          cmp_3 ( .a(cmp1_z1), .b(cmp2_z1), .zctr(zctr),.aeqb(aeqb_inst[2]), .altb(altb_inst[2]), .agtb(agtb_inst[2]), .unordered(unordered_inst) , .z0(cmp3_z0), .z1(cmp3_z1), .status0(status_inst), .status1(status_inst) );
DW_fp_cmp #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          cmp_4 ( .a(cmp1_z0), .b(cmp2_z0), .zctr(zctr),.aeqb(aeqb_inst[3]), .altb(altb_inst[3]), .agtb(agtb_inst[3]), .unordered(unordered_inst) , .z0(cmp4_z0), .z1(cmp4_z1), .status0(status_inst), .status1(status_inst) );
//===================================================================

reg  [31:0] as_11 , as_12 , as_21 ,as_22 ;
wire [31:0] as_11_in , as_12_in , as_21_in ,as_22_in ;
reg         op1 , op2; // op == 0 add , op == 1 sub
wire [31:0] as_result1 , as_result2;

assign as_11_in = (state_cnt == 110) ? fully2[Med_addr1] : as_11;
assign as_12_in = (state_cnt == 110) ? cmp4_z0 : as_12;
assign as_21_in = (state_cnt == 110) ? cmp3_z1 : as_21;
assign as_22_in = (state_cnt == 110) ? cmp4_z0 : as_22;
//=================================================================== SubAdder
DW_fp_addsub #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
             addsub_1 ( .a(as_11_in), .b(as_12_in), .rnd(inst_rnd),.op(op1), .z(as_result1), .status(status_inst) );
DW_fp_addsub #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
             addsub_2 ( .a(as_21_in), .b(as_22_in), .rnd(inst_rnd),.op(op2), .z(as_result2), .status(status_inst) );
//===================================================================

wire [31:0] div_11;
wire [31:0] div_12;
wire [31:0] one;
assign one = 32'h 3f800000; // 1 in IEEE 754
assign div_11 = as_result1;
assign div_12 = as_result2;
wire [31:0] div_result1;
// ================================================================= Divider
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
          Div_1( .a(div_11), .b(div_12), .rnd(inst_rnd), .z(div_result1), .status(status_inst));
// =================================================================

wire [31:0] add_11 , add_12;
wire [31:0] add_result1;
assign add_11 = sum_result[3] ;
assign add_12 = (abs) ? {1'b0 , as_result1[30:0] } : conve[con_index]; //last data

//=================================================================== Adder
DW_fp_add #( inst_sig_width, inst_exp_width, inst_ieee_compliance)
          add_1 ( .a(add_11), .b(add_12), .rnd(inst_rnd), .z(add_result1), .status(status_inst) );

reg [31:0]exp_1 ;
wire[31:0]exp_result1 ;
// ================================================================= Exponential
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch)
          exp1 (.a(exp_1),.z(exp_result1),.status(status_inst) );
// =================================================================


// new function
reg [31:0]Equalization[15:0];
// =================================================================
reg [31:0] sum_11 , sum_12 , sum_13 , sum_21 , sum_22 , sum_23 , sum_31 , sum_32 , sum_33;
wire [31:0] sum_result1 , sum_result2 , sum_result3 , sum_result4 ;

// ================================================================= Adder3
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_5 (.a(sum_11),.b(sum_12) , .c(sum_13) , .rnd(inst_rnd), .z(sum_result1), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_6 (.a(sum_21),.b(sum_22) , .c(sum_23) , .rnd(inst_rnd), .z(sum_result2), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_7 (.a(sum_31),.b(sum_32) , .c(sum_33) , .rnd(inst_rnd), .z(sum_result3), .status(status_inst));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
           sum3_8 (.a(sum_result1),.b(sum_result2) , .c(sum_result3) , .rnd(inst_rnd), .z(sum_result4), .status(status_inst));
//===================================================================

wire [31:0] div_21;
wire [31:0] div_22;
wire [31:0] nine;
assign nine = 32'h 41100000; // 9 in IEEE 754
assign div_21 = sum_result4;
assign div_22 = nine;
wire [31:0] div_result2;
// ================================================================= Divider
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
          Div_2( .a(div_21), .b(div_22), .rnd(inst_rnd), .z(div_result2), .status(status_inst));
// =================================================================

reg [31:0]test[15:0][15:0];
reg [31:0]test2[15:0][15:0];

wire TEST_CLK;
wire  test_clk_sleep;
wire test_clk_gate;
assign test_clk_sleep = 1;

GATED_OR GATED_test( .CLOCK(clk) , .SLEEP_CTRL(test_clk_sleep), .RST_N(rst_n), .CLOCK_GATED(test_clk_gate));
assign TEST_CLK = (cg_en)? test_clk_gate: clk ;
//always@(posedge TEST_CLK or negedge rst_n)begin
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0 ;  i < 16 ; i = i + 1) begin
            for(j = 0 ;  j < 16 ; j = j + 1) begin
                test[i][j] <= 0;
                test2[i][j] <= 0;
            end
        end
    end
    else begin
        if(cg_en == 0) begin
            for(i = 0 ;  i < 16 ; i = i + 1) begin
                for(j = 0 ;  j < 16 ; j = j + 1) begin
                    test[i][j]  <= ~test[i][j] ;
                    test2[i][j] <= ~test2[i][j] ;
                end
            end
        end
    end
end

genvar m,k,l;
wand flag;
wand flag_array[15:0][15:0];
wand flag2;
wand flag_array2[15:0][15:0];
generate
    for(m = 0 ; m < 16 ; m = m + 1) begin
        for(k = 0 ; k < 16 ; k = k + 1) begin
            for(l = 0 ; l < 32 ; l = l + 1) begin
                assign flag_array[m][k] = test[m][k][l];
                assign flag_array2[m][k] = test2[m][k][l];
            end
        end
    end

    for(m = 0 ; m < 16 ; m = m + 1) begin
        for(k = 0 ; k < 16 ; k = k + 1) begin
            assign flag  = flag_array[m][k];
            assign flag2 = flag_array2[m][k];
        end
    end
endgenerate


parameter Load1     =  0,
          Load2     =  1,
          Calculate =  2,
          Output    =  3;
always@(posedge clk or negedge rst_n ) begin //fsm
    if(!rst_n )
        c_state <= Load1;
    else
        c_state <= n_state;
end

always@(*) begin  //next state logic
    n_state = c_state;
    case(c_state)
        Load1 : begin
            if(state_cnt == 4)
                n_state = Load2;
        end
        Load2 : begin
            if(state_cnt == 100)
                n_state = Calculate;
        end
        Calculate: begin
            if(state_cnt == 113)
                n_state = Output;
        end
        Output : begin
            n_state = Load1;
        end
    endcase
end

always@(posedge clk) begin // sum3 control by state_cnt
    case(state_cnt)  // 66 ~ 83 Equalization first map
        66 : begin
            sum_11 <= conve2[0];
            sum_12 <= conve2[0];
            sum_13 <= conve2[1];
            sum_21 <= conve2[0];
            sum_22 <= conve2[0];
            sum_23 <= conve2[1];
            sum_31 <= conve2[4];
            sum_32 <= conve2[4];
            sum_33 <= conve2[5];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        67: begin
            Equalization[0] <= div_result2;
            sum_11 <= conve2[0];
            sum_12 <= conve2[1];
            sum_13 <= conve2[2];
            sum_21 <= conve2[0];
            sum_22 <= conve2[1];
            sum_23 <= conve2[2];
            sum_31 <= conve2[4];
            sum_32 <= conve2[5];
            sum_33 <= conve2[6];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
            end
        end
        68: begin
            Equalization[1] <= div_result2;
            sum_11 <= conve2[1];
            sum_12 <= conve2[2];
            sum_13 <= conve2[3];
            sum_21 <= conve2[1];
            sum_22 <= conve2[2];
            sum_23 <= conve2[3];
            sum_31 <= conve2[5];
            sum_32 <= conve2[6];
            sum_33 <= conve2[7];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
            end
        end
        69: begin
            Equalization[2] <= div_result2;
            sum_11 <= conve2[2];
            sum_12 <= conve2[3];
            sum_13 <= conve2[3];
            sum_21 <= conve2[2];
            sum_22 <= conve2[3];
            sum_23 <= conve2[3];
            sum_31 <= conve2[6];
            sum_32 <= conve2[7];
            sum_33 <= conve2[7];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end

        70: begin
            Equalization[3] <= div_result2;
            sum_11 <= conve2[0];
            sum_12 <= conve2[0];
            sum_13 <= conve2[1];
            sum_21 <= conve2[4];
            sum_22 <= conve2[4];
            sum_23 <= conve2[5];
            sum_31 <= conve2[8];
            sum_32 <= conve2[8];
            sum_33 <= conve2[9];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        71: begin
            Equalization[4] <= div_result2;
            sum_11 <= conve2[0];
            sum_12 <= conve2[1];
            sum_13 <= conve2[2];
            sum_21 <= conve2[4];
            sum_22 <= conve2[5];
            sum_23 <= conve2[6];
            sum_31 <= conve2[8];
            sum_32 <= conve2[9];
            sum_33 <= conve2[10];
        end
        72: begin
            Equalization[5] <= div_result2;
            sum_11 <= conve2[1];
            sum_12 <= conve2[2];
            sum_13 <= conve2[3];
            sum_21 <= conve2[5];
            sum_22 <= conve2[6];
            sum_23 <= conve2[7];
            sum_31 <= conve2[9];
            sum_32 <= conve2[10];
            sum_33 <= conve2[11];
        end
        73: begin
            Equalization[6] <= div_result2;
            sum_11 <= conve2[2];
            sum_12 <= conve2[3];
            sum_13 <= conve2[3];
            sum_21 <= conve2[6];
            sum_22 <= conve2[7];
            sum_23 <= conve2[7];
            sum_31 <= conve2[10];
            sum_32 <= conve2[11];
            sum_33 <= conve2[11];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end
        74: begin
            Equalization[7] <= div_result2;
            sum_11 <= conve2[4];
            sum_12 <= conve2[4];
            sum_13 <= conve2[5];
            sum_21 <= conve2[8];
            sum_22 <= conve2[8];
            sum_23 <= conve2[9];
            sum_31 <= conve2[12];
            sum_32 <= conve2[12];
            sum_33 <= conve2[13];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        75: begin
            Equalization[8] <= div_result2;
            sum_11 <= conve2[4];
            sum_12 <= conve2[5];
            sum_13 <= conve2[6];
            sum_21 <= conve2[8];
            sum_22 <= conve2[9];
            sum_23 <= conve2[10];
            sum_31 <= conve2[12];
            sum_32 <= conve2[13];
            sum_33 <= conve2[14];
        end

        76: begin
            Equalization[9] <= div_result2;
            sum_11 <= conve2[5];
            sum_12 <= conve2[6];
            sum_13 <= conve2[7];
            sum_21 <= conve2[9];
            sum_22 <= conve2[10];
            sum_23 <= conve2[11];
            sum_31 <= conve2[13];
            sum_32 <= conve2[14];
            sum_33 <= conve2[15];
        end

        77: begin
            Equalization[10] <= div_result2;
            sum_11 <= conve2[6];
            sum_12 <= conve2[7];
            sum_13 <= conve2[7];
            sum_21 <= conve2[10];
            sum_22 <= conve2[11];
            sum_23 <= conve2[11];
            sum_31 <= conve2[14];
            sum_32 <= conve2[15];
            sum_33 <= conve2[15];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end
        78: begin
            Equalization[11] <= div_result2;
            sum_11 <= conve2[8];
            sum_12 <= conve2[8];
            sum_13 <= conve2[9];
            sum_21 <= conve2[12];
            sum_22 <= conve2[12];
            sum_23 <= conve2[13];
            sum_31 <= conve2[12];
            sum_32 <= conve2[12];
            sum_33 <= conve2[13];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        79: begin
            Equalization[12] <= div_result2;
            sum_11 <= conve2[8];
            sum_12 <= conve2[9];
            sum_13 <= conve2[10];
            sum_21 <= conve2[12];
            sum_22 <= conve2[13];
            sum_23 <= conve2[14];
            sum_31 <= conve2[12];
            sum_32 <= conve2[13];
            sum_33 <= conve2[14];

            if(Opt_temp[0]) begin // zero padding
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        80: begin
            Equalization[13] <= div_result2;
            sum_11 <= conve2[9];
            sum_12 <= conve2[10];
            sum_13 <= conve2[11];
            sum_21 <= conve2[13];
            sum_22 <= conve2[14];
            sum_23 <= conve2[15];
            sum_31 <= conve2[13];
            sum_32 <= conve2[14];
            sum_33 <= conve2[15];

            if(Opt_temp[0]) begin // zero padding
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        81: begin
            Equalization[14] <= div_result2;
            sum_11 <= conve2[10];
            sum_12 <= conve2[11];
            sum_13 <= conve2[11];
            sum_21 <= conve2[14];
            sum_22 <= conve2[15];
            sum_23 <= conve2[15];
            sum_31 <= conve2[14];
            sum_32 <= conve2[15];
            sum_33 <= conve2[15];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        ////////////////////////////// 91 ~ 106  Equalizaion 2
        91 : begin
            sum_11 <= conve[0];
            sum_12 <= conve[0];
            sum_13 <= conve[1];
            sum_21 <= conve[0];
            sum_22 <= conve[0];
            sum_23 <= conve[1];
            sum_31 <= conve[4];
            sum_32 <= conve[4];
            sum_33 <= add_result1; // conve[5]

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        92: begin
            Equalization[0] <= div_result2;
            sum_11 <= conve[0];
            sum_12 <= conve[1];
            sum_13 <= conve[2];
            sum_21 <= conve[0];
            sum_22 <= conve[1];
            sum_23 <= conve[2];
            sum_31 <= conve[4];
            sum_32 <= conve[5];
            sum_33 <= add_result1;

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
            end
        end
        93: begin
            Equalization[1] <= div_result2;
            sum_11 <= conve[1];
            sum_12 <= conve[2];
            sum_13 <= conve[3];
            sum_21 <= conve[1];
            sum_22 <= conve[2];
            sum_23 <= conve[3];
            sum_31 <= conve[5];
            sum_32 <= conve[6];
            sum_33 <= add_result1;

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
            end
        end
        94: begin
            Equalization[2] <= div_result2;
            sum_11 <= conve[2];
            sum_12 <= conve[3];
            sum_13 <= conve[3];
            sum_21 <= conve[2];
            sum_22 <= conve[3];
            sum_23 <= conve[3];
            sum_31 <= conve[6];
            sum_32 <= conve[7];
            sum_33 <= conve[7];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_12 <= 0;
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end

        95: begin
            Equalization[3] <= div_result2;
            sum_11 <= conve[0];
            sum_12 <= conve[0];
            sum_13 <= conve[1];
            sum_21 <= conve[4];
            sum_22 <= conve[4];
            sum_23 <= conve[5];
            sum_31 <= conve[8];
            sum_32 <= conve[8];
            sum_33 <= add_result1;

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        96: begin
            Equalization[4] <= div_result2;
            sum_11 <= conve[0];
            sum_12 <= conve[1];
            sum_13 <= conve[2];
            sum_21 <= conve[4];
            sum_22 <= conve[5];
            sum_23 <= conve[6];
            sum_31 <= conve[8];
            sum_32 <= conve[9];
            sum_33 <= add_result1;
        end
        97: begin
            Equalization[5] <= div_result2;
            sum_11 <= conve[1];
            sum_12 <= conve[2];
            sum_13 <= conve[3];
            sum_21 <= conve[5];
            sum_22 <= conve[6];
            sum_23 <= conve[7];
            sum_31 <= conve[9];
            sum_32 <= conve[10];
            sum_33 <= add_result1;
        end
        98: begin
            Equalization[6] <= div_result2;
            sum_11 <= conve[2];
            sum_12 <= conve[3];
            sum_13 <= conve[3];
            sum_21 <= conve[6];
            sum_22 <= conve[7];
            sum_23 <= conve[7];
            sum_31 <= conve[10];
            sum_32 <= conve[11];
            sum_33 <= conve[11];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end
        99: begin
            Equalization[7] <= div_result2;
            sum_11 <= conve[4];
            sum_12 <= conve[4];
            sum_13 <= conve[5];
            sum_21 <= conve[8];
            sum_22 <= conve[8];
            sum_23 <= conve[9];
            sum_31 <= conve[12];
            sum_32 <= conve[12];
            sum_33 <= add_result1;

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
            end
        end
        100: begin
            Equalization[8] <= div_result2;
            sum_11 <= conve[4];
            sum_12 <= conve[5];
            sum_13 <= conve[6];
            sum_21 <= conve[8];
            sum_22 <= conve[9];
            sum_23 <= conve[10];
            sum_31 <= conve[12];
            sum_32 <= conve[13];
            sum_33 <= add_result1;
        end

        101: begin
            Equalization[9] <= div_result2;
            sum_11 <= conve[5];
            sum_12 <= conve[6];
            sum_13 <= conve[7];
            sum_21 <= conve[9];
            sum_22 <= conve[10];
            sum_23 <= conve[11];
            sum_31 <= conve[13];
            sum_32 <= conve[14];
            sum_33 <= add_result1;
        end

        102: begin
            Equalization[10] <= div_result2;
            sum_11 <= conve[6];
            sum_12 <= conve[7];
            sum_13 <= conve[7];
            sum_21 <= conve[10];
            sum_22 <= conve[11];
            sum_23 <= conve[11];
            sum_31 <= conve[14];
            sum_32 <= conve[15];
            sum_33 <= conve[15];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_33 <= 0;
            end
        end
        103: begin
            Equalization[11] <= div_result2;
            sum_11 <= conve[8];
            sum_12 <= conve[8];
            sum_13 <= conve[9];
            sum_21 <= conve[12];
            sum_22 <= conve[12];
            sum_23 <= conve[13];
            sum_31 <= conve[12];
            sum_32 <= conve[12];
            sum_33 <= conve[13];

            if(Opt_temp[0]) begin // zero padding
                sum_11 <= 0;
                sum_21 <= 0;
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        104: begin
            Equalization[12] <= div_result2;
            sum_11 <= conve[8];
            sum_12 <= conve[9];
            sum_13 <= conve[10];
            sum_21 <= conve[12];
            sum_22 <= conve[13];
            sum_23 <= conve[14];
            sum_31 <= conve[12];
            sum_32 <= conve[13];
            sum_33 <= conve[14];

            if(Opt_temp[0]) begin // zero padding
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        105: begin
            Equalization[13] <= div_result2;
            sum_11 <= conve[9];
            sum_12 <= conve[10];
            sum_13 <= conve[11];
            sum_21 <= conve[13];
            sum_22 <= conve[14];
            sum_23 <= conve[15];
            sum_31 <= conve[13];
            sum_32 <= conve[14];
            sum_33 <= conve[15];

            if(Opt_temp[0]) begin // zero padding
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
        106: begin
            Equalization[14] <= div_result2;
            sum_11 <= conve[10];
            sum_12 <= conve[11];
            sum_13 <= conve[11];
            sum_21 <= conve[14];
            sum_22 <= conve[15];
            sum_23 <= conve[15];
            sum_31 <= conve[14];
            sum_32 <= conve[15];
            sum_33 <= conve[15];

            if(Opt_temp[0]) begin // zero padding
                sum_13 <= 0;
                sum_23 <= 0;
                sum_31 <= 0;
                sum_32 <= 0;
                sum_33 <= 0;
            end
        end
    endcase
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out <= 0;

        for(i = 0 ; i < 16 ; i = i + 1 ) begin
            conve2[i] <= 0;
        end

        state_cnt <= 0;
    end
    else begin
        case(c_state)
            Load1: begin
                out_valid <= 0;
                out       <= 0;
                if(in_valid) begin
                    if(state_cnt == 0)
                        Opt_temp <= Opt ;
                    if(state_cnt < 4)
                        Weight_temp[state_cnt] <= Weight;

                    Kernel_temp[state_cnt] <= Kernel;
                    Img_temp[state_cnt] <= Img;

                    state_cnt <= state_cnt + 1;
                end
            end
            Load2: begin // start calculate
                if(state_cnt < 27)
                    Kernel_temp[state_cnt] <= Kernel;
                if(state_cnt < 32) begin
                    Img_temp[state_cnt] <= Img;
                end
                else if(state_cnt < 64) begin
                    Img_temp[state_cnt - 32] <= Img;
                end
                else if(state_cnt < 96 )
                    Img_temp[state_cnt - 64] <= Img;

                if(state_cnt == 53) begin
                    for(i = 0 ; i < 15 ; i = i + 1 ) begin
                        conve2[i] <= conve[i];
                    end
                    conve2[15] <= add_result1;
                end
                else  if(state_cnt ==  65) begin
                    conve2[0] <= adjust0;
                    conve2[1] <= adjust1;
                    conve2[2] <= add_result2;
                end

                ////////////////////////////////////
                if(state_cnt == 82) begin
                    conve2[15] <= div_result2;
                    for(i = 0; i < 15 ; i ++) begin
                        conve2[i] <= Equalization[i];
                    end
                end
                /////////////////////////////
                state_cnt <= state_cnt + 1;
            end
            Calculate : begin // start calculate
                if(flag && flag2)
                    conve2[0] <= 0;
                //
                state_cnt <= state_cnt + 1;
            end
            Output: begin
                out_valid <= 1;
                out <= add_result1;
                state_cnt <= 0;
            end
        endcase
    end
end

// multiplier control by c_state

always@(posedge clk) begin
    case(c_state)
        Load1: begin // initial
            x <= 0;
            y <= 0;
            y_count <= 0;

            con_n <= 0; // first picture
            abs <= 0 ;
            con_index <= 15;
            for(i = 0 ; i <= 15 ; i = i + 1)  begin
                conve[i] <= 0;
            end

            for(i = 0 ; i < 9 ; i = i + 1) begin
                mul_1[i] <= 0;
                mul_2[i] <= 0;
            end

        end
        Load2 : begin

            case(y_count[4:2])
                0: begin
                    for(i = 0 ; i < 9 ; i = i + 1)
                        mul_1[i] <= Kernel_temp[i];
                    if(y_count[1:0] == 0) begin
                        case(x)
                            2'b00: begin
                                mul_1[5] <= Kernel;
                                mul_1[6] <= 0 ;
                                mul_1[7] <= 0 ;
                                mul_1[8] <= 0 ;
                            end
                            2'b01: begin
                                mul_1[6] <= Kernel ;
                                mul_1[7] <= 0 ;
                                mul_1[8] <= 0 ;
                            end
                            2'b10: begin
                                mul_1[7] <= Kernel ;
                                mul_1[8] <= 0 ;
                            end
                            2'b11: begin
                                mul_1[8] <= Kernel ;
                            end
                        endcase
                    end
                end
                3: begin
                    for(i = 0 ; i < 9 ; i = i + 1)
                        mul_1[i] <= Kernel_temp[i];
                end
                1,4: begin
                    for(i = 0 ; i < 9 ; i = i + 1)
                        mul_1[i] <= Kernel_temp[i + 9];
                end
                2,5: begin
                    for(i = 0 ; i < 9 ; i = i + 1)
                        mul_1[i] <= Kernel_temp[i + 18];
                end
            endcase

            mul_2[0] <= Img_temp[position - 5];
            mul_2[1] <= Img_temp[position - 4];
            mul_2[2] <= Img_temp[position - 3];
            mul_2[3] <= Img_temp[position - 1];
            mul_2[4] <= Img_temp[position    ];
            mul_2[5] <= Img_temp[position + 1];
            mul_2[6] <= Img_temp[position + 3];
            mul_2[7] <= Img_temp[position + 4];

            if(Opt_temp[0]) begin // Zero padding
                if(y_count[1:0] < 3) begin
                    if(x == 3)
                        mul_2[8] <= 0;
                    else
                        mul_2[8] <= Img;
                end
                else
                    mul_2[8] <= 0;
            end
            else begin      // Replication paddin
                if(y_count[1:0] < 3) begin
                    if(x == 3)
                        mul_2[8] <= Img_temp[position + 4];
                    else
                        mul_2[8] <= Img;
                end
                else begin
                    if(x == 3)
                        mul_2[8] <= Img_temp[position    ];
                    else
                        mul_2[8] <= Img_temp[position + 1];
                end
            end

            if(Opt_temp[0]) begin // Zero padding
                case(y_count[1:0])
                    0: begin
                        mul_2[0] <= 0;
                        mul_2[1] <= 0;
                        mul_2[2] <= 0;
                        if(x == 0) begin
                            mul_2[3] <= 0;
                            mul_2[6] <= 0;
                        end
                        if(x == 3) begin
                            mul_2[5] <= 0;
                        end
                    end
                    1,2: begin
                        if(x == 0) begin
                            mul_2[0] <= 0;
                            mul_2[3] <= 0;
                            mul_2[6] <= 0;
                        end
                        if(x == 3) begin
                            mul_2[2] <= 0;
                            mul_2[5] <= 0;
                        end
                    end
                    3: begin
                        mul_2[6] <= 0;
                        mul_2[7] <= 0;
                        if(x == 0) begin
                            mul_2[0] <= 0;
                            mul_2[3] <= 0;
                        end
                        if(x == 3) begin
                            mul_2[2] <= 0;
                            mul_2[5] <= 0;
                        end
                    end
                endcase
            end
            else begin      // Replication paddin
                case (y_count[1:0])
                    0: begin
                        mul_2[0] <= Img_temp[position - 1];
                        mul_2[1] <= Img_temp[position    ];
                        mul_2[2] <= Img_temp[position + 1];
                        if(x == 0) begin
                            mul_2[0] <= Img_temp[position    ];
                            mul_2[3] <= Img_temp[position    ];
                            mul_2[6] <= Img_temp[position + 4];
                        end
                        if(x == 3) begin
                            mul_2[2] <= Img_temp[position    ];
                            mul_2[5] <= Img_temp[position    ];
                        end
                    end
                    1,2: begin
                        if(x == 0) begin
                            mul_2[0] <= Img_temp[position - 4];
                            mul_2[3] <= Img_temp[position    ];
                            mul_2[6] <= Img_temp[position + 4];
                        end
                        if(x == 3) begin
                            mul_2[2] <= Img_temp[position - 4];
                            mul_2[5] <= Img_temp[position    ];
                        end
                    end
                    3: begin
                        mul_2[6] <= Img_temp[position - 1];
                        mul_2[7] <= Img_temp[position    ];
                        if(x == 0) begin
                            mul_2[0] <= Img_temp[position - 4];
                            mul_2[3] <= Img_temp[position    ];
                            mul_2[6] <= Img_temp[position    ];
                        end
                        if(x == 3) begin
                            mul_2[2] <= Img_temp[position - 4];
                            mul_2[5] <= Img_temp[position    ];
                        end
                    end
                endcase
            end

            conve[con_index] <= add_result1;
            con_index <= con_index + 1;

            x <= x + 1;
            if(x == 3) begin
                y <= y + 1;
                y_count <= y_count + 1;
                if(y == 7)
                    y <= 0;
            end

            if(x == 0 && y_count == 12)
                for( i = 0 ; i < 16 ; i = i + 1)
                    conve[i] <= 0;
        end
        Calculate: begin
            case(state_cnt )
                101: begin
                    conve[15] <= add_result1; //save con2[15]
                end

                107: begin // 101 ~103 con2 Fully_connected
                    mul_1[0] <= max_pool[0];
                    mul_2[0] <= Weight_temp[0];
                    mul_1[1] <= max_pool[1];
                    mul_2[1] <= Weight_temp[2];
                    mul_1[2] <= 0 ;

                    mul_1[3] <= max_pool[0];
                    mul_2[3] <= Weight_temp[1];
                    mul_1[4] <= max_pool[1];
                    mul_2[4] <= Weight_temp[3];
                    mul_1[5] <= 0 ;
                end
                108 : begin
                    fully2[0] <= sum_result[0];
                    fully2[1] <= sum_result[1];

                    mul_1[0] <= max_pool[2];
                    mul_2[0] <= Weight_temp[0];
                    mul_1[1] <= cmp3_z1;
                    mul_2[1] <= Weight_temp[2];

                    mul_1[3] <= max_pool[2];
                    mul_2[3] <= Weight_temp[1];
                    mul_1[4] <= cmp3_z1;
                    mul_2[4] <= Weight_temp[3];
                end
                109: begin // write back to fully
                    fully2[2] <= sum_result[0];
                    fully2[3] <= sum_result[1];
                end

                112: begin//L1 distance
                    abs <= 1;
                    mul_1[0] <= {1'b1,distance[1][30:0]}; // - distance[1]
                    mul_2[0] <= one;
                    mul_2[1] <= one;
                    mul_1[2] <= 0;
                    mul_2[2] <= 0;

                    mul_1[3] <= {1'b1,distance[2][30:0]}; // - distance[2]
                    mul_2[3] <= one;
                    mul_2[4] <= one;
                    mul_1[5] <= 0;
                    mul_2[5] <= 0;

                    mul_1[6] <= {1'b1,distance[3][30:0]}; // - distance[3]
                    mul_2[6] <= one;
                    mul_2[7] <= one;
                    mul_1[8] <= 0;
                    mul_2[8] <= 0;
                end
                113: begin
                    mul_1[1] <= active[1];
                    mul_1[4] <= active[2];
                    mul_1[7] <= active[3];
                    case(Med_addr2)
                        1:
                            mul_1[1] <= div_result1;
                        2:
                            mul_1[4] <= div_result1;
                        3:
                            mul_1[7] <= div_result1;
                    endcase
                end
            endcase
        end
    endcase
end

// multiplier control by state_cnt
always@(posedge clk) begin
    case(state_cnt)
        10: begin
            i4 <= Img_temp[4];
            i5 <= Img_temp[5];
            i6 <= Img_temp[6];
            i7 <= Img_temp[7];
        end
        54: begin //54 ~ 64 con1 adjust
            if(Opt_temp[0]) // Zero padding
                mul_1[9] <= 0;
            else
                mul_1[9] <= i4; // Img_temp[4]
            mul_2[9] <= Kernel_temp[6];

            add_22 <= conve2[0];
        end
        55: begin
            adjust0 <= add_result2; // 1st add in con1[0]
        end
        56: begin
            mul_1[9] <= i4; // Img_temp[4]
            mul_2[9] <= Kernel_temp[7];

            add_22 <= adjust0;
        end
        57: begin
            adjust0 <= add_result2; // 2nd add in con1[0]
        end
        58: begin
            mul_1[9] <= i5; //Img_temp[5];
            mul_2[9] <= Kernel_temp[8];

            add_22 <= adjust0;
        end
        59: begin
            adjust0 <= add_result2; // 3rd add in con1[0]
        end
        60: begin
            mul_1[9] <= i5 ; //Img_temp[5];
            mul_2[9] <= Kernel_temp[7];

            add_22 <= conve2[1];
        end
        61: begin
            adjust1 <= add_result2; // 1st add in con1[1]
        end
        62: begin
            mul_1[9] <= i6;//Img_temp[6];
            mul_2[9] <= Kernel_temp[8];

            add_22 <= adjust1;
        end
        63: begin
            adjust1 <= add_result2; // 2st add in con1[1]
        end
        64: begin
            mul_1[9] <= i7 ; //Img_temp[7];
            mul_2[9] <= Kernel_temp[8];

            add_22 <= conve2[2];
        end

        88: begin// 88 ~ 96  con1 fully connected
            mul_1[9] <= max_pool[2];
            mul_2[9] <= Weight_temp[1];
        end
        89: begin
            add_22 <= mul_result[9];

            mul_1[9] <= max_pool[3];
            mul_2[9] <= Weight_temp[3];
        end
        90: begin
            fully1[3] <= add_result2 ; // 2*1 3*3

            mul_1[9] <= max_pool[2];
            mul_2[9] <= Weight_temp[0];
        end
        91: begin
            add_22 <= mul_result[9];

            mul_1[9] <= max_pool[3];
            mul_2[9] <= Weight_temp[2];
        end
        92: begin
            fully1[2] <= add_result2 ; // 2*0 3*2

            mul_1[9] <= max_pool[0];
            mul_2[9] <= Weight_temp[1];
        end
        93: begin
            add_22 <= mul_result[9];

            mul_1[9] <= max_pool[1];
            mul_2[9] <= Weight_temp[3];
        end
        94: begin
            fully1[1] <= add_result2 ; // 0*1 1*3

            mul_1[9] <= max_pool[0];
            mul_2[9] <= Weight_temp[0];
        end
        95: begin
            add_22 <= mul_result[9];

            mul_1[9] <= max_pool[1];
            mul_2[9] <= Weight_temp[2];
        end
        96: begin
            fully1[0] <= add_result2; // 0*0 1*2
        end
    endcase
end

//comparater  control by state_cnt
always@(posedge clk) begin
    case({state_cnt})
        83: begin //83 ~ 87 con1  max pooling
            cmp_11 <= conve2[0];
            cmp_12 <= conve2[1];
            cmp_21 <= conve2[4];
            cmp_22 <= conve2[5];
        end
        84: begin
            max_pool[0] <= cmp3_z1;

            cmp_11 <= conve2[2];
            cmp_12 <= conve2[3];
            cmp_21 <= conve2[6];
            cmp_22 <= conve2[7];
        end
        85: begin
            max_pool[1] <= cmp3_z1;

            cmp_11 <= conve2[8];
            cmp_12 <= conve2[9];
            cmp_21 <= conve2[12];
            cmp_22 <= conve2[13];

        end
        86: begin
            max_pool[2] <= cmp3_z1;

            cmp_11 <= conve2[10];
            cmp_12 <= conve2[11];
            cmp_21 <= conve2[14];
            cmp_22 <= conve2[15];
        end
        87: begin
            max_pool[3] <= cmp3_z1;
        end

        98: begin // 82 find Max_addr Min_addr
            cmp_11 <= fully1[0];
            cmp_12 <= fully1[1];
            cmp_21 <= fully1[2];
            cmp_22 <= fully1[3];
        end


        104: begin //98~102 con2  max pooling
            cmp_11 <= Equalization[0];
            cmp_12 <= Equalization[1];
            cmp_21 <= Equalization[4];
            cmp_22 <= Equalization[5];
        end
        105: begin
            max_pool[0] <= cmp3_z1;
            cmp_11 <=  Equalization[2];
            cmp_12 <=  Equalization[3];
            cmp_21 <=  Equalization[6];
            cmp_22 <=  Equalization[7];
        end
        106: begin
            max_pool[1] <= cmp3_z1;
            cmp_11 <= Equalization[8];
            cmp_12 <= Equalization[9];
            cmp_21 <= Equalization[12];
            cmp_22 <= Equalization[13];
        end
        107: begin
            max_pool[2] <= cmp3_z1;
            cmp_11 <= Equalization[10];
            cmp_12 <= Equalization[11];
            cmp_21 <= Equalization[14];
            cmp_22 <=  div_result2    ;
        end
        108: begin
            max_pool[3] <= cmp3_z1;
        end

        109: begin // 103 find Max_addr Min_addr
            cmp_11 <= fully2[0];
            cmp_12 <= fully2[1];
            cmp_21 <= sum_result[0];
            cmp_22 <= sum_result[1];
        end

    endcase
end

wire DIV_CLK;
reg  div_clk_sleep;
wire div_clk_gate;

always@(posedge clk) begin
    case(state_cnt)
        0 :
            div_clk_sleep <= 1 ;
        98:
            div_clk_sleep <= 0 ;
        104:
            div_clk_sleep <= 1 ;
        109:
            div_clk_sleep <= 0 ;
        113:
            div_clk_sleep <= 1 ;
    endcase
end

GATED_OR GATED_div( .CLOCK(clk) , .SLEEP_CTRL(div_clk_sleep), .RST_N(rst_n), .CLOCK_GATED(div_clk_gate));
assign DIV_CLK = (cg_en)? div_clk_gate: clk ;

//sub_adder divider control by state_cnt
//always@(posedge DIV_CLK) begin
always@(posedge clk) begin
    case(state_cnt)
        99: begin // 83 ~ 85 con1 normalize
            op1 <= 1  ;
            op2 <= 1  ; // op == 0 add , op == 1 sub
            as_11 <= fully1[Med_addr1];
            as_12 <= cmp4_z0;
            as_21 <= cmp3_z1;
            as_22 <= cmp4_z0;
        end// cmp3_z1 is Max , cmp4_z0 is min
        100: begin
            as_11 <= fully1[Med_addr2];
        end
        101: begin // 85~87 con1 activate

            op1 <= 1  ;
            op2 <= 0  ; // op == 0 add , op == 1 sub

            as_11 <= one;
            as_21 <= one;
            as_22 <= exp_result1;
            if(Opt_temp[1]) begin // Tanh
                as_12 <= exp_result1;
                active[Max_addr] <= 32'h3f42f7d6 ; // 0.761594
                active[Min_addr] <= 32'h00000000 ; // 0.000000
            end
            else begin //segmoid
                as_12 <= 0;
                active[Max_addr] <= 32'h3f3b26a8 ; // 0.731059
                active[Min_addr] <= 32'h3f000000 ; // 0.500000
            end
        end
        102: begin
            as_22 <= exp_result1;
            if(Opt_temp[1]) // Tanh
                as_12 <= exp_result1;
            else             //segmoid
                as_12 <= 0;

            active[Med_addr1] <= div_result1;
        end
        103: begin
            active[Med_addr2] <= div_result1;
        end
        104: begin // save active
            for(i = 0 ;i < 4 ; i = i + 1) begin
                distance[i] <= active[i];
            end
            op1 <= 1  ;
            op2 <= 1  ; // op == 0 add , op == 1 sub
        end
        110: begin
            as_11 <= fully2[Med_addr2];
            as_12 <= cmp4_z0;
            as_21 <= cmp3_z1;
            as_22 <= cmp4_z0;
        end

        111: begin // 105 ~ 107 con2 activate

            op1 <= 1  ;
            op2 <= 0  ; // op == 0 add , op == 1 sub

            as_11 <= one;
            as_21 <= one;
            as_22 <= exp_result1;
            if(Opt_temp[1]) begin // Tanh
                as_12 <= exp_result1;
                active[Max_addr] <= 32'h3f42f7d6 ; // 0.761594
                active[Min_addr] <= 32'h00000000 ; // 0.000000
            end
            else begin //segmoid
                as_12 <= 0;
                active[Max_addr] <= 32'h3f3b26a8 ; // 0.731059
                active[Min_addr] <= 32'h3f000000 ; // 0.500000
            end

        end
        112: begin
            as_22 <= exp_result1;
            if(Opt_temp[1]) // Tanh
                as_12 <= exp_result1;
            else             //segmoid
                as_12 <= 0;

            active[Med_addr1] <= div_result1;
        end
        113: begin
            op1 <= 1  ;
            op2 <= 1  ; // op == 0 add , op == 1 sub
            as_11 <= distance[0];
            as_12 <= active[0];
            if(Med_addr2 == 0)
                as_12 <= div_result1;
        end
    endcase
end

wire [31:0] minus_div_result1;
wire sign ;
wire [7:0] exp ;
assign sign = !div_result1[31];
assign exp = (Opt_temp[1]) ?(div_result1[30:23] + 1) : div_result1[30:23];
assign  minus_div_result1 = { sign , exp ,div_result1[22:0]};

wire EXP_CLK;
reg  exp_clk_sleep;
wire exp_clk_gate;

always@(posedge clk) begin
    case(state_cnt)
        0:
            exp_clk_sleep <= 1; //sleep
        99:
            exp_clk_sleep <= 0;
        101:
            exp_clk_sleep <= 1;  //sleep
        109:
            exp_clk_sleep <= 0;
        111:
            exp_clk_sleep <= 1; //sleep
    endcase
end
GATED_OR GATED_exp( .CLOCK(clk) , .SLEEP_CTRL(exp_clk_sleep), .RST_N(rst_n), .CLOCK_GATED(exp_clk_gate));
assign EXP_CLK = (cg_en)? exp_clk_gate: clk ;

//always@(posedge EXP_CLK) begin
always@(posedge clk) begin
    case(state_cnt)
        100,101,110,111: begin // 84 ~ 85 con1 activate    104 ~ 105 con2 activate
            exp_1 <=  minus_div_result1 ; //  normal[Med_addr1]  e ^ (-z)
        end
    endcase
end
endmodule // 16 * 32 * 32 bits test
