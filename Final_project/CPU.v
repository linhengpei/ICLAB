//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(
           clk,
           rst_n,
           IO_stall,

           awid_m_inf,
           awaddr_m_inf,
           awsize_m_inf,
           awburst_m_inf,
           awlen_m_inf,
           awvalid_m_inf,
           awready_m_inf,

           wdata_m_inf,
           wlast_m_inf,
           wvalid_m_inf,
           wready_m_inf,

           bid_m_inf,
           bresp_m_inf,
           bvalid_m_inf,
           bready_m_inf,

           arid_m_inf,
           araddr_m_inf,
           arlen_m_inf,
           arsize_m_inf,
           arburst_m_inf,
           arvalid_m_inf,

           arready_m_inf,
           rid_m_inf,
           rdata_m_inf,
           rresp_m_inf,
           rlast_m_inf,
           rvalid_m_inf,
           rready_m_inf
       );
// Input port
input  clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/

// axi write address channel
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;

assign  awid_m_inf = 0;
assign  awsize_m_inf = 3'b001;
assign  awburst_m_inf = 2'b01;
// axi write data channel
output  reg  [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg  [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output   reg [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output   reg [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;

assign  arid_m_inf = 0;
assign  arlen_m_inf[13:7] = 7'd127;
assign  arlen_m_inf[ 6:0] = 7'd127;
assign  arsize_m_inf[5:3] = 3'b001;
assign  arsize_m_inf[2:0] = 3'b001;
assign  arburst_m_inf[3:2] = 2'b01;
assign  arburst_m_inf[1:0] = 2'b01;
// -----------------------------
// axi read data channel
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output   reg [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------
//
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/
reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

//###########################################
//
// Wrtie down your design below
//
//###########################################

reg signed[ 7:0]I_sram_addr;  // Instruction Sram
reg [15:0]I_data_in;
wire [15:0]I_data_out;
reg I_web ;
CACHE Inst( .A0(I_sram_addr[0]), .A1(I_sram_addr[1]), .A2(I_sram_addr[2]), .A3(I_sram_addr[3]), .A4(I_sram_addr[4]), .A5(I_sram_addr[5]), .A6(I_sram_addr[6]), .A7(I_sram_addr[7]),
            .DO0(I_data_out[0]), .DO1(I_data_out[1]), .DO2(I_data_out[2]), .DO3(I_data_out[3]), .DO4(I_data_out[4]), .DO5(I_data_out[5]), .DO6(I_data_out[6]), .DO7(I_data_out[7]),
            .DO8(I_data_out[8]), .DO9(I_data_out[9]), .DO10(I_data_out[10]), .DO11(I_data_out[11]), .DO12(I_data_out[12]), .DO13(I_data_out[13]), .DO14(I_data_out[14]), .DO15(I_data_out[15]),
            .DI0(I_data_in[0]), .DI1(I_data_in[1]), .DI2(I_data_in[2]), .DI3(I_data_in[3]), .DI4(I_data_in[4]), .DI5(I_data_in[5]), .DI6(I_data_in[6]), .DI7(I_data_in[7]),
            .DI8(I_data_in[8]), .DI9(I_data_in[9]), .DI10(I_data_in[10]), .DI11(I_data_in[11]), .DI12(I_data_in[12]), .DI13(I_data_in[13]), .DI14(I_data_in[14]), .DI15(I_data_in[15]),
            .CK(clk), .WEB(I_web), .OE(1'b1), .CS(1'b1));

reg signed[ 7:0]D_sram_addr; // Data Sram
reg [15:0]D_data_in;
wire [15:0]D_data_out;
reg D_web ;
CACHE Data( .A0(D_sram_addr[0]), .A1(D_sram_addr[1]), .A2(D_sram_addr[2]), .A3(D_sram_addr[3]), .A4(D_sram_addr[4]), .A5(D_sram_addr[5]), .A6(D_sram_addr[6]), .A7(D_sram_addr[7]),
            .DO0(D_data_out[0]), .DO1(D_data_out[1]), .DO2(D_data_out[2]), .DO3(D_data_out[3]), .DO4(D_data_out[4]), .DO5(D_data_out[5]), .DO6(D_data_out[6]), .DO7(D_data_out[7]),
            .DO8(D_data_out[8]), .DO9(D_data_out[9]), .DO10(D_data_out[10]), .DO11(D_data_out[11]), .DO12(D_data_out[12]), .DO13(D_data_out[13]), .DO14(D_data_out[14]), .DO15(D_data_out[15]),
            .DI0(D_data_in[0]), .DI1(D_data_in[1]), .DI2(D_data_in[2]), .DI3(D_data_in[3]), .DI4(D_data_in[4]), .DI5(D_data_in[5]), .DI6(D_data_in[6]), .DI7(D_data_in[7]),
            .DI8(D_data_in[8]), .DI9(D_data_in[9]), .DI10(D_data_in[10]), .DI11(D_data_in[11]), .DI12(D_data_in[12]), .DI13(D_data_in[13]), .DI14(D_data_in[14]), .DI15(D_data_in[15]),
            .CK(clk), .WEB(D_web), .OE(1'b1), .CS(1'b1));

reg  [15:0] I_out_buff , D_out_buff;
always@(posedge clk ) begin
    I_out_buff <= I_data_out;
    D_out_buff <= D_data_out;
end

wire [2:0] opcode ;
reg  signed [15:0]  rd_data , rs_data , rt_data;
wire signed [ 4:0] immediate ;
wire signed [10:0] load_address;
//reg signed [10:0] load_address;
assign  opcode    = I_out_buff[15: 13];
assign  immediate = I_out_buff[ 4:  0] ;
assign  load_address = rs_data + immediate ;
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        load_address <=0;
    end
    else begin
        load_address <= (rs_data + immediate) ;
    end
end
*/



reg read_inst , read_data;       // Need read : 1
reg read_inst_f , read_data_f;   // read_finish
reg write_data  ;                // Need write : 1
reg write_data_f;                // write_finish
reg [7:0] out_cnt;

reg signed [11:0]  PC ;  // Program counter
reg [3:0]I_dram_addr , D_dram_addr; // Dram address

reg [3:0] c_state ;
parameter Load_Dram   = 0 ,
          Fetch       = 1 ,
          Check_Inst  = 2 ,
          Load        = 3 ,
          Decode      = 4 , // Instruction decode
          // Execute     = 5 ,
          Mult        = 5 ,
          Check_data  = 6 ,
          Data_buff   = 7 ,
          Write_back  = 8 ,
          Write_Dram  = 9 ;

reg first ;
reg [1:0] I_sram_start , I_sram_end ;
reg [1:0] D_sram_start , D_sram_end ;
reg [10:0] min ,max ; // save changed data range
reg [3:0] inst_cnt;
reg store_flag;


/*
ADD 
SUB
Set         Fetch -> Check_Inst -> Load -> Decode -> Write_back
Mult        Fetch -> Check_Inst -> Load -> Decode -> Mult -      -> Write_back
Load        Fetch -> Check_Inst -> Load -> Decode -> Check_data  -> Data_buff  -> Write_back 
Store       Fetch -> Check_Inst -> Load -> Decode -> Check_data  -> Data_buff  -> Write_back
Branch      Fetch -> Check_Inst -> Load -> Decode -> Write_back
Jump        Fetch -> Check_Inst -> Load -> Decode -> Write_back
*/
wire [31:0] mult_out;
DW02_mult_2_stage #( 16 , 16)
                  U1 ( .A(rs_data), .B(rt_data), .TC(1'b1), .CLK(clk), .PRODUCT(mult_out) );
/*
always@(*) begin  // rt_data rs_data block
    //case(I_out_buff[12: 9])
    case(I_data_out[12: 9])
        0:
            rs_data = core_r0;
        1:
            rs_data = core_r1;
        2:
            rs_data = core_r2;
        3:
            rs_data = core_r3;
        4:
            rs_data = core_r4;
        5:
            rs_data = core_r5;
        6:
            rs_data = core_r6;
        7:
            rs_data = core_r7;
        8:
            rs_data = core_r8;
        9:
            rs_data = core_r9;
        10:
            rs_data = core_r10;
        11:
            rs_data = core_r11;
        12:
            rs_data = core_r12;
        13:
            rs_data = core_r13;
        14:
            rs_data = core_r14;
        15:
            rs_data = core_r15;
    endcase
 
    //case(I_out_buff[8: 5])
    case(I_data_out[8: 5])
        0:
            rt_data = core_r0;
        1:
            rt_data = core_r1;
        2:
            rt_data = core_r2;
        3:
            rt_data = core_r3;
        4:
            rt_data = core_r4;
        5:
            rt_data = core_r5;
        6:
            rt_data = core_r6;
        7:
            rt_data = core_r7;
        8:
            rt_data = core_r8;
        9:
            rt_data = core_r9;
        10:
            rt_data = core_r10;
        11:
            rt_data = core_r11;
        12:
            rt_data = core_r12;
        13:
            rt_data = core_r13;
        14:
            rt_data = core_r14;
        15:
            rt_data = core_r15;
    endcase
end
*/

always@(posedge clk or negedge rst_n) begin  // rt_data rs_data block
    if(!rst_n) begin
        rs_data <= 0;
        rt_data <= 0;
    end
    else begin
        //case(I_data_out[12: 9])
        case(I_out_buff[12: 9])
            0:
                rs_data <= core_r0;
            1:
                rs_data <= core_r1;
            2:
                rs_data <= core_r2;
            3:
                rs_data <= core_r3;
            4:
                rs_data <= core_r4;
            5:
                rs_data <= core_r5;
            6:
                rs_data <= core_r6;
            7:
                rs_data <= core_r7;
            8:
                rs_data <= core_r8;
            9:
                rs_data <= core_r9;
            10:
                rs_data <= core_r10;
            11:
                rs_data <= core_r11;
            12:
                rs_data <= core_r12;
            13:
                rs_data <= core_r13;
            14:
                rs_data <= core_r14;
            15:
                rs_data <= core_r15;
        endcase

        // case(I_data_out[8: 5])
        case(I_out_buff[8: 5])
            0:
                rt_data <= core_r0;
            1:
                rt_data <= core_r1;
            2:
                rt_data <= core_r2;
            3:
                rt_data <= core_r3;
            4:
                rt_data <= core_r4;
            5:
                rt_data <= core_r5;
            6:
                rt_data <= core_r6;
            7:
                rt_data <= core_r7;
            8:
                rt_data <= core_r8;
            9:
                rt_data <= core_r9;
            10:
                rt_data <= core_r10;
            11:
                rt_data <= core_r11;
            12:
                rt_data <= core_r12;
            13:
                rt_data <= core_r13;
            14:
                rt_data <= core_r14;
            15:
                rt_data <= core_r15;
        endcase
    end
end

/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_data <= 0;
    end
    else begin
        case( {opcode[2] ,opcode[0]} )
            2'b00 : begin
                if(I_data_out[0]) begin // SUB
                    rd_data <= rs_data - rt_data ;
                end
                else begin              // ADD
                    rd_data <= rs_data + rt_data ;
                end
            end
            2'b01 : begin
                if(I_data_out[0]) begin   //  Mult
                    rd_data <= rs_data * rt_data ;
                    //c_state <= Mult ;
                end
                else begin
                    rd_data <= ( rs_data < rt_data );
                end
            end
        endcase
    end
end
*/
always@(posedge clk or negedge rst_n) begin  // core block
    if(!rst_n) begin
        core_r0 <= 0 ;
        core_r1 <= 0 ;
        core_r2 <= 0 ;
        core_r3 <= 0 ;
        core_r4 <= 0 ;
        core_r5 <= 0 ;
        core_r6 <= 0 ;
        core_r7 <= 0 ;
        core_r8 <= 0 ;
        core_r9 <= 0 ;
        core_r10 <= 0 ;
        core_r11 <= 0 ;
        core_r12 <= 0 ;
        core_r13 <= 0 ;
        core_r14 <= 0 ;
        core_r15 <= 0 ;
    end
    else if(c_state == Write_back) begin
        if(opcode[1]) begin
            if(opcode[0] == 0) begin     //Load
                case(I_out_buff[8:5])
                    0:
                        core_r0 <= D_out_buff;
                    1:
                        core_r1 <=D_out_buff;
                    2:
                        core_r2 <= D_out_buff;
                    3:
                        core_r3 <= D_out_buff;
                    4:
                        core_r4 <= D_out_buff;
                    5:
                        core_r5 <= D_out_buff;
                    6:
                        core_r6 <= D_out_buff;
                    7:
                        core_r7 <= D_out_buff;
                    8:
                        core_r8 <= D_out_buff;
                    9:
                        core_r9 <= D_out_buff;
                    10:
                        core_r10 <= D_out_buff;
                    11:
                        core_r11 <= D_out_buff;
                    12:
                        core_r12 <= D_out_buff;
                    13:
                        core_r13 <= D_out_buff;
                    14:
                        core_r14 <= D_out_buff;
                    15:
                        core_r15 <= D_out_buff;
                endcase
            end
        end
        else begin
            if(opcode[2] == 0) begin // exclude Branch Jump
                case(I_out_buff[4:1])
                    0:
                        core_r0 <= rd_data;
                    1:
                        core_r1 <= rd_data;
                    2:
                        core_r2 <= rd_data;
                    3:
                        core_r3 <= rd_data;
                    4:
                        core_r4 <= rd_data;
                    5:
                        core_r5 <= rd_data;
                    6:
                        core_r6 <= rd_data;
                    7:
                        core_r7 <= rd_data;
                    8:
                        core_r8 <= rd_data;
                    9:
                        core_r9 <= rd_data;
                    10:
                        core_r10 <= rd_data;
                    11:
                        core_r11 <= rd_data;
                    12:
                        core_r12 <= rd_data;
                    13:
                        core_r13 <= rd_data;
                    14:
                        core_r14 <= rd_data;
                    15:
                        core_r15 <= rd_data;
                endcase
            end
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        IO_stall <= 1;

        I_dram_addr <= 0 ;
        D_dram_addr <= 0 ;

        PC <= 0;
        c_state <= Load_Dram;
        inst_cnt <= 0;
        first <= 1;
        rd_data <= 0;

        ///////////////////////////////////
        /*   sram reset   */
        I_web <= 1; // read
        D_web <= 1; // read

        D_sram_addr <= 255;
        I_sram_addr <= 255;

        read_inst <= 1 ; // need read inst
        read_data <= 1 ; // need read data
        write_data <= 0 ; // dont need write data

        I_sram_start <= 2'b00 ;
        I_sram_end   <= 2'b01 ;
        D_sram_start <= 2'b00 ;
        D_sram_end   <= 2'b01 ;

        store_flag <= 0;
    end
    else begin
        case(c_state)
            Load_Dram : begin
                //////////////////////////////////////////  INST
                if(rvalid_m_inf[1] ) begin //   Read Instrution
                    I_sram_addr <= I_sram_addr + 1;
                    I_data_in <= rdata_m_inf[31:16];
                end
                else if(!first && read_inst_f && !I_web) begin
                    I_sram_addr <= PC[8:1];        // first instruction
                end

                if( rvalid_m_inf[1])
                    I_web <= 0 ;  //  Write
                else if(read_inst_f)
                    I_web <= 1 ;  // Read

                if(rvalid_m_inf[1])
                    read_inst <= 0 ;

                //////////////////////////////////////////  DATA
                if(rvalid_m_inf[0] ) begin  //   Read Data
                    D_sram_addr <= D_sram_addr + 1;
                    D_data_in <= rdata_m_inf[15:0];
                end

                if( rvalid_m_inf[0])
                    D_web <= 0 ;  //  Write
                else if(read_data_f)
                    D_web <= 1 ;  // Read

                if(rvalid_m_inf[0])
                    read_data <= 0 ;

                if(read_inst_f && read_data_f && !read_inst && !read_data ) begin
                    c_state <= Fetch ;
                end
            end
            Fetch : begin
                IO_stall <= 1;
                D_web <= 1; // Read

                first <= 0;
                if(first) begin
                    I_dram_addr <=  I_dram_addr + 1 ;
                    D_dram_addr <=  D_dram_addr + 1 ;
                    read_inst <= 1 ;
                    read_data <= 1 ; // read one more time
                    c_state <= Load_Dram ;
                end
                else begin
                    c_state <= Check_Inst ;
                end
            end

            Check_Inst : begin // 2
                IO_stall <= 1;
                D_web <= 1; // Read

                if( PC[9:8] != I_sram_start  && PC[9:8] != I_sram_end  ) begin // out side
                    if(PC[9:8] == I_sram_start + 3) begin
                        I_sram_start <= I_sram_start - 1 ;
                        I_sram_end   <= I_sram_end   - 1 ;
                        I_dram_addr <= I_dram_addr   - 2 ;
                    end
                    else begin
                        I_sram_start <= I_sram_start + 1 ;
                        I_sram_end   <= I_sram_end   + 1 ;
                        I_dram_addr <= I_dram_addr  + 1 ;
                    end

                    I_sram_addr <= {!PC[8] , 7'h7F};
                    read_inst <= 1 ;
                    c_state <= Load_Dram ;
                end
                else begin
                    c_state <= Load ;
                end
            end
            Load: begin  // Load rs_data rd_data
                c_state <= Decode ;
            end
            Decode: begin // 4
                if(opcode[2:1] == 2'b01) begin // Load Store
                    D_sram_addr <= load_address[7:0]; // load
                    c_state <= Check_data ;
                end
                else begin   // c_state == Execute;
                    PC <= PC + 2 ;
                    I_sram_addr <=  I_sram_addr  + 1;  // next inst
                    c_state <= Write_back ;
                    case( {opcode[2] ,opcode[0]} )
                        2'b00 : begin
                            if(I_out_buff[0]) begin // SUB
                                rd_data <= rs_data - rt_data ;
                            end
                            else begin              // ADD
                                rd_data <= rs_data + rt_data ;
                            end
                        end
                        2'b01 : begin
                            if(I_out_buff[0]) begin   //  Mult
                                //rd_data <= rs_data * rt_data ;
                                c_state <= Mult ;
                            end
                            else begin
                                rd_data <= ( rs_data < rt_data );
                            end
                        end
                        2'b10: begin // Branch
                            if(rs_data == rt_data) begin
                                PC <= PC + (immediate + 1 )* 2 ;
                                I_sram_addr <=  I_sram_addr  + immediate + 1;
                            end
                        end
                        2'b11: begin // Jump
                            PC <= I_out_buff[11:0];
                            I_sram_addr <= I_out_buff[11:1];
                        end
                    endcase
                end
            end

            Mult: begin // 6
                rd_data <= mult_out;
                c_state <= Write_back;
            end

            Check_data : begin // 7
                if( load_address[8:7] != D_sram_start  && load_address[8:7] != D_sram_end ) begin // outside
                    if(load_address[8:7] == D_sram_start - 1) begin
                        D_sram_start <= D_sram_start - 1 ;
                        D_sram_end   <= D_sram_end   - 1 ;
                        D_dram_addr  <= D_dram_addr  - 2 ;
                    end
                    else begin
                        D_sram_start <= D_sram_start + 1 ;
                        D_sram_end   <= D_sram_end   + 1 ;
                        D_dram_addr  <= D_dram_addr  + 1 ;
                    end
                    D_sram_addr <= {!load_address[7] , 7'h7F};

                    read_data <= 1 ;
                    c_state <= Load_Dram ;
                end
                else begin
                    PC <= PC + 2;
                    c_state <= Data_buff;
                end
            end

            Data_buff: begin// save D_data_out --> D_out_buff
                if(opcode[0])   // Store
                    store_flag <= 1;
                I_sram_addr <=  I_sram_addr  + 1;  // next inst
                c_state <= Write_back;
            end

            Write_back : begin // 8
                awaddr_m_inf <= {20'd1 , load_address , 1'b0};
                if(opcode[1]) begin  // Load Store
                    if(opcode[0]) begin  // Store
                        D_web <= 0; //Write
                        case(I_out_buff[8:5])
                            0:
                                D_data_in <= core_r0 ;
                            1:
                                D_data_in <= core_r1 ;
                            2:
                                D_data_in <= core_r2 ;
                            3:
                                D_data_in <= core_r3 ;
                            4:
                                D_data_in <= core_r4 ;
                            5:
                                D_data_in <= core_r5 ;
                            6:
                                D_data_in <= core_r6 ;
                            7:
                                D_data_in <= core_r7 ;
                            8:
                                D_data_in <= core_r8 ;
                            9:
                                D_data_in <= core_r9 ;
                            10:
                                D_data_in <= core_r10 ;
                            11:
                                D_data_in <= core_r11 ;
                            12:
                                D_data_in <= core_r12 ;
                            13:
                                D_data_in <= core_r13 ;
                            14:
                                D_data_in <= core_r14 ;
                            15:
                                D_data_in <= core_r15 ;
                        endcase
                    end
                end
                /*
                if(inst_cnt == 9 ) begin
                    inst_cnt <= 0;
                end
                else begin
                    inst_cnt <= inst_cnt + 1;
                end

                if(inst_cnt == 9 && store_flag ) begin
                    c_state <= Write_Dram;
                end
                else begin
                    IO_stall <= 0;
                    c_state <= Check_Inst;
                end
                */
                if( store_flag ) begin
                    c_state <= Write_Dram;
                end
                else begin
                    IO_stall <= 0;
                    c_state <= Check_Inst;
                end
            end
            Write_Dram : begin // 9
                D_web <= 1; // Read

                write_data <= 1 ;

                // if(wready_m_inf || awvalid_m_inf || awready_m_inf ) begin
                //      D_sram_addr <= D_sram_addr + 1;
                //   end
                //   else if (!wvalid_m_inf) begin
                //D_sram_addr <= min[7:0] ;
                //    end

                if(bvalid_m_inf) begin
                    write_data <= 0 ;
                    IO_stall <= 0;
                    store_flag <= 0;
                    c_state  <=  Check_Inst;
                end
            end
        endcase
    end
end
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        min <= 11'h7FF;
        max <= 11'h000;
    end
    else if(bvalid_m_inf) begin
        max <= 11'h000;
        min <= 11'h7FF;
    end
    else if(c_state == Write_back && opcode == 3'b011 ) begin // store
        if(load_address < min ) begin
            min <= load_address ;
        end
 
        if( load_address > max ) begin
            max <= load_address;
        end
    end
end
*/
/*
reg [1:0]data_state_w;
reg [15:0] temp1 , temp2 , temp3;
assign awaddr_m_inf = {20'd1 , min , 1'b0};
//assign awlen_m_inf = max - min ;
always@(posedge clk or negedge rst_n) begin  // Write data block
    if(!rst_n) begin
        awlen_m_inf <= 0;
        awvalid_m_inf <= 0;
 
        wvalid_m_inf <= 0;
        wdata_m_inf <= 0;
        wlast_m_inf <= 0;
 
        bready_m_inf  <= 0;
 
        out_cnt <= 0 ;
        temp1 <= 0;
        temp2 <= 0;
        data_state_w <= 0;
    end
    else begin
        awlen_m_inf <= max - min ;
        case(data_state_w)
            0: begin
                out_cnt <= 0;
                if(write_data && !awready_m_inf ) begin
                    awvalid_m_inf <= 1;
                end
                else begin
                    awvalid_m_inf <= 0;
                    if(awready_m_inf) begin
                        wdata_m_inf <= D_out_buff;
                        if(awlen_m_inf == 0 )
                            wlast_m_inf <= 1;
                        wvalid_m_inf  <= 1;
                        data_state_w <= 1;
                    end
                end
            end
            1: begin
                temp1 <= D_out_buff ;
                if(!awready_m_inf)
                    data_state_w <= 2 ;
            end
            2: begin
                temp2 <= D_out_buff ;
                data_state_w <= 3 ;
            end
            3: begin
                if(bvalid_m_inf) begin
                    bready_m_inf <= 0;
                    data_state_w <= 0;
                end
                else if(wready_m_inf) begin
                    if(out_cnt == awlen_m_inf ) begin
                        wlast_m_inf <= 0;
                        wvalid_m_inf <= 0;
                        bready_m_inf <= 1;
                    end
                    else begin
                        out_cnt <= out_cnt + 1;
                        case(out_cnt)
                            0:
                                wdata_m_inf <= temp1 ;
                            1:
                                wdata_m_inf <= temp2 ;
                            2:
                                wdata_m_inf <= temp3 ;
                            default:
                                wdata_m_inf <= D_out_buff;
                        endcase
 
                        if(out_cnt == awlen_m_inf -  1) begin
                            wlast_m_inf  <= 1;
                        end
                    end
                end
 
                temp3 <= D_out_buff;
            end
        endcase
    end
end
*/

reg data_state_w;
//assign awaddr_m_inf = {20'd1 , PC[11:9] , D_sram_addr , 1'b0};
assign awlen_m_inf = 0;
always@(posedge clk or negedge rst_n) begin  // Write data block
    if(!rst_n) begin
        awvalid_m_inf <= 0;

        wvalid_m_inf <= 0;
        wdata_m_inf <= 0;
        wlast_m_inf <= 0;

        bready_m_inf  <= 0;
        data_state_w <= 0;
    end
    else begin
        case(data_state_w)
            0: begin
                if(write_data && !awready_m_inf ) begin
                    awvalid_m_inf <= 1;
                end
                else begin
                    awvalid_m_inf <= 0;
                    if(awready_m_inf) begin
                        wdata_m_inf <= D_out_buff;
                        wlast_m_inf <= 1;
                        wvalid_m_inf  <= 1;
                        data_state_w <= 1;
                    end
                end
            end
            1: begin
                if(bvalid_m_inf) begin
                    bready_m_inf <= 0;
                    data_state_w <= 0;
                end
                else if(wready_m_inf) begin
                    wlast_m_inf <= 0;
                    wvalid_m_inf <= 0;
                    bready_m_inf <= 1;
                end
            end
        endcase
    end
end
assign  araddr_m_inf[63:32] = {20'd1 , I_dram_addr , 8'b0} ;
assign  araddr_m_inf[31: 0] = {20'd1 , D_dram_addr , 8'b0} ;

reg inst_state_r ;
reg data_state_r ;
always@(posedge clk or negedge rst_n) begin  // Read instrution block
    if(!rst_n) begin
        arvalid_m_inf[1] <= 0;
        rready_m_inf[1] <= 0;
        read_inst_f <= 0;
        inst_state_r <= 0;
    end
    else begin
        case(inst_state_r)
            0: begin
                if(read_inst && !arready_m_inf[1] ) begin
                    arvalid_m_inf[1] <= 1;
                    read_inst_f      <= 0 ; // finish
                end
                else begin
                    arvalid_m_inf[1] <= 0;
                    if(arready_m_inf[1]) begin
                        rready_m_inf[1]  <= 1;
                        inst_state_r <= 1;
                    end
                end
            end
            1: begin
                if(rlast_m_inf[1] ) begin
                    read_inst_f  <= 1 ; // finish ;
                    rready_m_inf[1] <= 0;
                    inst_state_r <= 0;
                end
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin  // Read data block
    if(!rst_n) begin
        arvalid_m_inf[0] <= 0;
        rready_m_inf[0] <= 0;
        read_data_f <= 0; // finish == 0
        data_state_r <= 0;
    end
    else begin
        case(data_state_r)
            0: begin
                if(read_data && !arready_m_inf[0] ) begin
                    arvalid_m_inf[0] <= 1;
                    read_data_f      <= 0 ; // finish
                end
                else begin
                    arvalid_m_inf[0] <= 0;
                    if(arready_m_inf[0]) begin
                        rready_m_inf[0]  <= 1;
                        data_state_r <= 1;
                    end
                end
            end
            1: begin
                if(rlast_m_inf[0] ) begin
                    read_data_f  <= 1 ; // finish ;
                    rready_m_inf[0] <= 0;
                    data_state_r <= 0;
                end
            end
        endcase
    end
end

endmodule  // 3.4_ 



















