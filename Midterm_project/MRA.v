module MRA(
           // CHIP IO
           clk            	,
           rst_n          	,
           in_valid       	,
           frame_id        ,
           net_id         	,
           loc_x          	,
           loc_y         	,
           cost	 	,
           busy         	,

           // AXI4 IO
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
           rready_m_inf,

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
           bready_m_inf
       );

// ===============================================================
//  					Input / Output
// ===============================================================

// << CHIP io port with system >>
input 		      clk,rst_n;
input 		      in_valid;
input  [4:0] 	      frame_id;
input  [3:0]        net_id;
input  [5:0]        loc_x;
input  [5:0]        loc_y;
output reg [13:0]   cost;
output reg          busy;

parameter ID_WIDTH   = 4,
          DATA_WIDTH = 128,
          ADDR_WIDTH = 32 ;

// SRAM port declaraion
reg  [6:0]frame_sram_addr;
reg  [6:0]frame_sram_addr_in;
reg  [127:0]frame_sram_datain;
wire [127:0]frame_sram_dataout;
reg  frame_sram_web;
wire [6:0] addr_add1 ;
assign addr_add1 = frame_sram_addr + 1 ;
Frame frame1( .A0(frame_sram_addr_in[0]) , .A1(frame_sram_addr_in[1]) , .A2(frame_sram_addr_in[2]) , .A3(frame_sram_addr_in[3]) , .A4(frame_sram_addr_in[4]) , .A5(frame_sram_addr_in[5]) , .A6(frame_sram_addr_in[6]),
              .DO0(frame_sram_dataout[ 0]) ,  .DO1(frame_sram_dataout[ 1]) ,  .DO2(frame_sram_dataout[ 2]) ,  .DO3(frame_sram_dataout[ 3]) , . DO4(frame_sram_dataout[ 4]) ,  .DO5(frame_sram_dataout[ 5]) ,  .DO6(frame_sram_dataout[ 6]) ,  .DO7(frame_sram_dataout[ 7]) ,
              .DO8(frame_sram_dataout[ 8]) ,  .DO9(frame_sram_dataout[ 9]) , .DO10(frame_sram_dataout[10]) , .DO11(frame_sram_dataout[11]) , .DO12(frame_sram_dataout[12]) , .DO13(frame_sram_dataout[13]) , .DO14(frame_sram_dataout[14]) , .DO15(frame_sram_dataout[15]) ,
              .DO16(frame_sram_dataout[16]) , .DO17(frame_sram_dataout[17]) , .DO18(frame_sram_dataout[18]) , .DO19(frame_sram_dataout[19]) , .DO20(frame_sram_dataout[20]) , .DO21(frame_sram_dataout[21]) , .DO22(frame_sram_dataout[22]) , .DO23(frame_sram_dataout[23]) ,
              .DO24(frame_sram_dataout[24]) , .DO25(frame_sram_dataout[25]) , .DO26(frame_sram_dataout[26]) , .DO27(frame_sram_dataout[27]) , .DO28(frame_sram_dataout[28]) , .DO29(frame_sram_dataout[29]) , .DO30(frame_sram_dataout[30]) , .DO31(frame_sram_dataout[31]) ,
              .DO32(frame_sram_dataout[32]) , .DO33(frame_sram_dataout[33]) , .DO34(frame_sram_dataout[34]) , .DO35(frame_sram_dataout[35]) , .DO36(frame_sram_dataout[36]) , .DO37(frame_sram_dataout[37]) , .DO38(frame_sram_dataout[38]) , .DO39(frame_sram_dataout[39]) ,
              .DO40(frame_sram_dataout[40]) , .DO41(frame_sram_dataout[41]) , .DO42(frame_sram_dataout[42]) , .DO43(frame_sram_dataout[43]) , .DO44(frame_sram_dataout[44]) , .DO45(frame_sram_dataout[45]) , .DO46(frame_sram_dataout[46]) , .DO47(frame_sram_dataout[47]) ,
              .DO48(frame_sram_dataout[48]) , .DO49(frame_sram_dataout[49]) , .DO50(frame_sram_dataout[50]) , .DO51(frame_sram_dataout[51]) , .DO52(frame_sram_dataout[52]) , .DO53(frame_sram_dataout[53]) , .DO54(frame_sram_dataout[54]) , .DO55(frame_sram_dataout[55]) ,
              .DO56(frame_sram_dataout[56]) , .DO57(frame_sram_dataout[57]) , .DO58(frame_sram_dataout[58]) , .DO59(frame_sram_dataout[59]) , .DO60(frame_sram_dataout[60]) , .DO61(frame_sram_dataout[61]) , .DO62(frame_sram_dataout[62]) , .DO63(frame_sram_dataout[63]) ,
              .DO64(frame_sram_dataout[64]) , .DO65(frame_sram_dataout[65]) , .DO66(frame_sram_dataout[66]) , .DO67(frame_sram_dataout[67]) , .DO68(frame_sram_dataout[68]) , .DO69(frame_sram_dataout[69]) , .DO70(frame_sram_dataout[70]) , .DO71(frame_sram_dataout[71]) ,
              .DO72(frame_sram_dataout[72]) , .DO73(frame_sram_dataout[73]) , .DO74(frame_sram_dataout[74]) , .DO75(frame_sram_dataout[75]) , .DO76(frame_sram_dataout[76]) , .DO77(frame_sram_dataout[77]) , .DO78(frame_sram_dataout[78]) , .DO79(frame_sram_dataout[79]) ,
              .DO80(frame_sram_dataout[80]) , .DO81(frame_sram_dataout[81]) , .DO82(frame_sram_dataout[82]) , .DO83(frame_sram_dataout[83]) , .DO84(frame_sram_dataout[84]) , .DO85(frame_sram_dataout[85]) , .DO86(frame_sram_dataout[86]) , .DO87(frame_sram_dataout[87]) ,
              .DO88(frame_sram_dataout[88]) , .DO89(frame_sram_dataout[89]) , .DO90(frame_sram_dataout[90]) , .DO91(frame_sram_dataout[91]) , .DO92(frame_sram_dataout[92]) , .DO93(frame_sram_dataout[93]) , .DO94(frame_sram_dataout[94]) , .DO95(frame_sram_dataout[95]) ,
              .DO96(frame_sram_dataout[96]) , .DO97(frame_sram_dataout[97]) , .DO98(frame_sram_dataout[98]) , .DO99(frame_sram_dataout[99]) , .DO100(frame_sram_dataout[100]) , .DO101(frame_sram_dataout[101]) , .DO102(frame_sram_dataout[102]) , .DO103(frame_sram_dataout[103]) ,
              .DO104(frame_sram_dataout[104]) , .DO105(frame_sram_dataout[105]) , .DO106(frame_sram_dataout[106]) , .DO107(frame_sram_dataout[107]) , .DO108(frame_sram_dataout[108]) , .DO109(frame_sram_dataout[109]) , .DO110(frame_sram_dataout[110]) , .DO111(frame_sram_dataout[111]) ,
              .DO112(frame_sram_dataout[112]) , .DO113(frame_sram_dataout[113]) , .DO114(frame_sram_dataout[114]) , .DO115(frame_sram_dataout[115]) , .DO116(frame_sram_dataout[116]) , .DO117(frame_sram_dataout[117]) , .DO118(frame_sram_dataout[118]) , .DO119(frame_sram_dataout[119]) ,
              .DO120(frame_sram_dataout[120]) , .DO121(frame_sram_dataout[121]) , .DO122(frame_sram_dataout[122]) , .DO123(frame_sram_dataout[123]) , .DO124(frame_sram_dataout[124]) , .DO125(frame_sram_dataout[125]) , .DO126(frame_sram_dataout[126]) , .DO127(frame_sram_dataout[127]) ,
              .DI0(frame_sram_datain[0]) , .DI1(frame_sram_datain[1]) , .DI2(frame_sram_datain[2]) , .DI3(frame_sram_datain[3]) , .DI4(frame_sram_datain[4]) , .DI5(frame_sram_datain[5]) , .DI6(frame_sram_datain[6]) , .DI7(frame_sram_datain[7]) ,
              .DI8(frame_sram_datain[8]) , .DI9(frame_sram_datain[9]) , .DI10(frame_sram_datain[10]) , .DI11(frame_sram_datain[11]) , .DI12(frame_sram_datain[12]) , .DI13(frame_sram_datain[13]) , .DI14(frame_sram_datain[14]) , .DI15(frame_sram_datain[15]) ,
              .DI16(frame_sram_datain[16]) , .DI17(frame_sram_datain[17]) , .DI18(frame_sram_datain[18]) , .DI19(frame_sram_datain[19]) , .DI20(frame_sram_datain[20]) , .DI21(frame_sram_datain[21]) , .DI22(frame_sram_datain[22]) , .DI23(frame_sram_datain[23]) ,
              .DI24(frame_sram_datain[24]) , .DI25(frame_sram_datain[25]) , .DI26(frame_sram_datain[26]) , .DI27(frame_sram_datain[27]) , .DI28(frame_sram_datain[28]) , .DI29(frame_sram_datain[29]) , .DI30(frame_sram_datain[30]) , .DI31(frame_sram_datain[31]) ,
              .DI32(frame_sram_datain[32]) , .DI33(frame_sram_datain[33]) , .DI34(frame_sram_datain[34]) , .DI35(frame_sram_datain[35]) , .DI36(frame_sram_datain[36]) , .DI37(frame_sram_datain[37]) , .DI38(frame_sram_datain[38]) , .DI39(frame_sram_datain[39]) ,
              .DI40(frame_sram_datain[40]) , .DI41(frame_sram_datain[41]) , .DI42(frame_sram_datain[42]) , .DI43(frame_sram_datain[43]) , .DI44(frame_sram_datain[44]) , .DI45(frame_sram_datain[45]) , .DI46(frame_sram_datain[46]) , .DI47(frame_sram_datain[47]) ,
              .DI48(frame_sram_datain[48]) , .DI49(frame_sram_datain[49]) , .DI50(frame_sram_datain[50]) , .DI51(frame_sram_datain[51]) , .DI52(frame_sram_datain[52]) , .DI53(frame_sram_datain[53]) , .DI54(frame_sram_datain[54]) , .DI55(frame_sram_datain[55]) ,
              .DI56(frame_sram_datain[56]) , .DI57(frame_sram_datain[57]) , .DI58(frame_sram_datain[58]) , .DI59(frame_sram_datain[59]) , .DI60(frame_sram_datain[60]) , .DI61(frame_sram_datain[61]) , .DI62(frame_sram_datain[62]) , .DI63(frame_sram_datain[63]) ,
              .DI64(frame_sram_datain[64]) , .DI65(frame_sram_datain[65]) , .DI66(frame_sram_datain[66]) , .DI67(frame_sram_datain[67]) , .DI68(frame_sram_datain[68]) , .DI69(frame_sram_datain[69]) , .DI70(frame_sram_datain[70]) , .DI71(frame_sram_datain[71]) ,
              .DI72(frame_sram_datain[72]) , .DI73(frame_sram_datain[73]) , .DI74(frame_sram_datain[74]) , .DI75(frame_sram_datain[75]) , .DI76(frame_sram_datain[76]) , .DI77(frame_sram_datain[77]) , .DI78(frame_sram_datain[78]) , .DI79(frame_sram_datain[79]) ,
              .DI80(frame_sram_datain[80]) , .DI81(frame_sram_datain[81]) , .DI82(frame_sram_datain[82]) , .DI83(frame_sram_datain[83]) , .DI84(frame_sram_datain[84]) , .DI85(frame_sram_datain[85]) , .DI86(frame_sram_datain[86]) , .DI87(frame_sram_datain[87]) ,
              .DI88(frame_sram_datain[88]) , .DI89(frame_sram_datain[89]) , .DI90(frame_sram_datain[90]) , .DI91(frame_sram_datain[91]) , .DI92(frame_sram_datain[92]) , .DI93(frame_sram_datain[93]) , .DI94(frame_sram_datain[94]) , .DI95(frame_sram_datain[95]) ,
              .DI96(frame_sram_datain[96]) , .DI97(frame_sram_datain[97]) , .DI98(frame_sram_datain[98]) , .DI99(frame_sram_datain[99]) , .DI100(frame_sram_datain[100]) , .DI101(frame_sram_datain[101]) , .DI102(frame_sram_datain[102]) , .DI103(frame_sram_datain[103]) ,
              .DI104(frame_sram_datain[104]) , .DI105(frame_sram_datain[105]) , .DI106(frame_sram_datain[106]) , .DI107(frame_sram_datain[107]) , .DI108(frame_sram_datain[108]) , .DI109(frame_sram_datain[109]) , .DI110(frame_sram_datain[110]) , .DI111(frame_sram_datain[111]) ,
              .DI112(frame_sram_datain[112]) , .DI113(frame_sram_datain[113]) , .DI114(frame_sram_datain[114]) , .DI115(frame_sram_datain[115]) , .DI116(frame_sram_datain[116]) , .DI117(frame_sram_datain[117]) , .DI118(frame_sram_datain[118]) , .DI119(frame_sram_datain[119]) ,
              .DI120(frame_sram_datain[120]) , .DI121(frame_sram_datain[121]) , .DI122(frame_sram_datain[122]) , .DI123(frame_sram_datain[123]) , .DI124(frame_sram_datain[124]) , .DI125(frame_sram_datain[125]) , .DI126(frame_sram_datain[126]) , .DI127(frame_sram_datain[127]) ,
              .CK(clk), .WEB(frame_sram_web), .OE(1'b1), .CS(1'b1));

reg  [6:0]weight_sram_addr;
reg  [6:0]weight_sram_addr_in;
reg  [127:0]weight_sram_datain;
wire [127:0]weight_sram_dataout;
reg  weight_sram_web;
Weight weight1( .A0(weight_sram_addr_in[0]) , .A1(weight_sram_addr_in[1]) , .A2(weight_sram_addr_in[2]) , .A3(weight_sram_addr_in[3]) , .A4(weight_sram_addr_in[4]) , .A5(weight_sram_addr_in[5]) , .A6(weight_sram_addr_in[6]),
                .DO0(weight_sram_dataout[ 0]) ,  .DO1(weight_sram_dataout[ 1]) ,  .DO2(weight_sram_dataout[ 2]) ,  .DO3(weight_sram_dataout[ 3]) , . DO4(weight_sram_dataout[ 4]) ,  .DO5(weight_sram_dataout[ 5]) ,  .DO6(weight_sram_dataout[ 6]) ,  .DO7(weight_sram_dataout[ 7]) ,
                .DO8(weight_sram_dataout[ 8]) ,  .DO9(weight_sram_dataout[ 9]) , .DO10(weight_sram_dataout[10]) , .DO11(weight_sram_dataout[11]) , .DO12(weight_sram_dataout[12]) , .DO13(weight_sram_dataout[13]) , .DO14(weight_sram_dataout[14]) , .DO15(weight_sram_dataout[15]) ,
                .DO16(weight_sram_dataout[16]) , .DO17(weight_sram_dataout[17]) , .DO18(weight_sram_dataout[18]) , .DO19(weight_sram_dataout[19]) , .DO20(weight_sram_dataout[20]) , .DO21(weight_sram_dataout[21]) , .DO22(weight_sram_dataout[22]) , .DO23(weight_sram_dataout[23]) ,
                .DO24(weight_sram_dataout[24]) , .DO25(weight_sram_dataout[25]) , .DO26(weight_sram_dataout[26]) , .DO27(weight_sram_dataout[27]) , .DO28(weight_sram_dataout[28]) , .DO29(weight_sram_dataout[29]) , .DO30(weight_sram_dataout[30]) , .DO31(weight_sram_dataout[31]) ,
                .DO32(weight_sram_dataout[32]) , .DO33(weight_sram_dataout[33]) , .DO34(weight_sram_dataout[34]) , .DO35(weight_sram_dataout[35]) , .DO36(weight_sram_dataout[36]) , .DO37(weight_sram_dataout[37]) , .DO38(weight_sram_dataout[38]) , .DO39(weight_sram_dataout[39]) ,
                .DO40(weight_sram_dataout[40]) , .DO41(weight_sram_dataout[41]) , .DO42(weight_sram_dataout[42]) , .DO43(weight_sram_dataout[43]) , .DO44(weight_sram_dataout[44]) , .DO45(weight_sram_dataout[45]) , .DO46(weight_sram_dataout[46]) , .DO47(weight_sram_dataout[47]) ,
                .DO48(weight_sram_dataout[48]) , .DO49(weight_sram_dataout[49]) , .DO50(weight_sram_dataout[50]) , .DO51(weight_sram_dataout[51]) , .DO52(weight_sram_dataout[52]) , .DO53(weight_sram_dataout[53]) , .DO54(weight_sram_dataout[54]) , .DO55(weight_sram_dataout[55]) ,
                .DO56(weight_sram_dataout[56]) , .DO57(weight_sram_dataout[57]) , .DO58(weight_sram_dataout[58]) , .DO59(weight_sram_dataout[59]) , .DO60(weight_sram_dataout[60]) , .DO61(weight_sram_dataout[61]) , .DO62(weight_sram_dataout[62]) , .DO63(weight_sram_dataout[63]) ,
                .DO64(weight_sram_dataout[64]) , .DO65(weight_sram_dataout[65]) , .DO66(weight_sram_dataout[66]) , .DO67(weight_sram_dataout[67]) , .DO68(weight_sram_dataout[68]) , .DO69(weight_sram_dataout[69]) , .DO70(weight_sram_dataout[70]) , .DO71(weight_sram_dataout[71]) ,
                .DO72(weight_sram_dataout[72]) , .DO73(weight_sram_dataout[73]) , .DO74(weight_sram_dataout[74]) , .DO75(weight_sram_dataout[75]) , .DO76(weight_sram_dataout[76]) , .DO77(weight_sram_dataout[77]) , .DO78(weight_sram_dataout[78]) , .DO79(weight_sram_dataout[79]) ,
                .DO80(weight_sram_dataout[80]) , .DO81(weight_sram_dataout[81]) , .DO82(weight_sram_dataout[82]) , .DO83(weight_sram_dataout[83]) , .DO84(weight_sram_dataout[84]) , .DO85(weight_sram_dataout[85]) , .DO86(weight_sram_dataout[86]) , .DO87(weight_sram_dataout[87]) ,
                .DO88(weight_sram_dataout[88]) , .DO89(weight_sram_dataout[89]) , .DO90(weight_sram_dataout[90]) , .DO91(weight_sram_dataout[91]) , .DO92(weight_sram_dataout[92]) , .DO93(weight_sram_dataout[93]) , .DO94(weight_sram_dataout[94]) , .DO95(weight_sram_dataout[95]) ,
                .DO96(weight_sram_dataout[96]) , .DO97(weight_sram_dataout[97]) , .DO98(weight_sram_dataout[98]) , .DO99(weight_sram_dataout[99]) , .DO100(weight_sram_dataout[100]) , .DO101(weight_sram_dataout[101]) , .DO102(weight_sram_dataout[102]) , .DO103(weight_sram_dataout[103]) ,
                .DO104(weight_sram_dataout[104]) , .DO105(weight_sram_dataout[105]) , .DO106(weight_sram_dataout[106]) , .DO107(weight_sram_dataout[107]) , .DO108(weight_sram_dataout[108]) , .DO109(weight_sram_dataout[109]) , .DO110(weight_sram_dataout[110]) , .DO111(weight_sram_dataout[111]) ,
                .DO112(weight_sram_dataout[112]) , .DO113(weight_sram_dataout[113]) , .DO114(weight_sram_dataout[114]) , .DO115(weight_sram_dataout[115]) , .DO116(weight_sram_dataout[116]) , .DO117(weight_sram_dataout[117]) , .DO118(weight_sram_dataout[118]) , .DO119(weight_sram_dataout[119]) ,
                .DO120(weight_sram_dataout[120]) , .DO121(weight_sram_dataout[121]) , .DO122(weight_sram_dataout[122]) , .DO123(weight_sram_dataout[123]) , .DO124(weight_sram_dataout[124]) , .DO125(weight_sram_dataout[125]) , .DO126(weight_sram_dataout[126]) , .DO127(weight_sram_dataout[127]) ,
                .DI0(weight_sram_datain[0]) , .DI1(weight_sram_datain[1]) , .DI2(weight_sram_datain[2]) , .DI3(weight_sram_datain[3]) , .DI4(weight_sram_datain[4]) , .DI5(weight_sram_datain[5]) , .DI6(weight_sram_datain[6]) , .DI7(weight_sram_datain[7]) ,
                .DI8(weight_sram_datain[8]) , .DI9(weight_sram_datain[9]) , .DI10(weight_sram_datain[10]) , .DI11(weight_sram_datain[11]) , .DI12(weight_sram_datain[12]) , .DI13(weight_sram_datain[13]) , .DI14(weight_sram_datain[14]) , .DI15(weight_sram_datain[15]) ,
                .DI16(weight_sram_datain[16]) , .DI17(weight_sram_datain[17]) , .DI18(weight_sram_datain[18]) , .DI19(weight_sram_datain[19]) , .DI20(weight_sram_datain[20]) , .DI21(weight_sram_datain[21]) , .DI22(weight_sram_datain[22]) , .DI23(weight_sram_datain[23]) ,
                .DI24(weight_sram_datain[24]) , .DI25(weight_sram_datain[25]) , .DI26(weight_sram_datain[26]) , .DI27(weight_sram_datain[27]) , .DI28(weight_sram_datain[28]) , .DI29(weight_sram_datain[29]) , .DI30(weight_sram_datain[30]) , .DI31(weight_sram_datain[31]) ,
                .DI32(weight_sram_datain[32]) , .DI33(weight_sram_datain[33]) , .DI34(weight_sram_datain[34]) , .DI35(weight_sram_datain[35]) , .DI36(weight_sram_datain[36]) , .DI37(weight_sram_datain[37]) , .DI38(weight_sram_datain[38]) , .DI39(weight_sram_datain[39]) ,
                .DI40(weight_sram_datain[40]) , .DI41(weight_sram_datain[41]) , .DI42(weight_sram_datain[42]) , .DI43(weight_sram_datain[43]) , .DI44(weight_sram_datain[44]) , .DI45(weight_sram_datain[45]) , .DI46(weight_sram_datain[46]) , .DI47(weight_sram_datain[47]) ,
                .DI48(weight_sram_datain[48]) , .DI49(weight_sram_datain[49]) , .DI50(weight_sram_datain[50]) , .DI51(weight_sram_datain[51]) , .DI52(weight_sram_datain[52]) , .DI53(weight_sram_datain[53]) , .DI54(weight_sram_datain[54]) , .DI55(weight_sram_datain[55]) ,
                .DI56(weight_sram_datain[56]) , .DI57(weight_sram_datain[57]) , .DI58(weight_sram_datain[58]) , .DI59(weight_sram_datain[59]) , .DI60(weight_sram_datain[60]) , .DI61(weight_sram_datain[61]) , .DI62(weight_sram_datain[62]) , .DI63(weight_sram_datain[63]) ,
                .DI64(weight_sram_datain[64]) , .DI65(weight_sram_datain[65]) , .DI66(weight_sram_datain[66]) , .DI67(weight_sram_datain[67]) , .DI68(weight_sram_datain[68]) , .DI69(weight_sram_datain[69]) , .DI70(weight_sram_datain[70]) , .DI71(weight_sram_datain[71]) ,
                .DI72(weight_sram_datain[72]) , .DI73(weight_sram_datain[73]) , .DI74(weight_sram_datain[74]) , .DI75(weight_sram_datain[75]) , .DI76(weight_sram_datain[76]) , .DI77(weight_sram_datain[77]) , .DI78(weight_sram_datain[78]) , .DI79(weight_sram_datain[79]) ,
                .DI80(weight_sram_datain[80]) , .DI81(weight_sram_datain[81]) , .DI82(weight_sram_datain[82]) , .DI83(weight_sram_datain[83]) , .DI84(weight_sram_datain[84]) , .DI85(weight_sram_datain[85]) , .DI86(weight_sram_datain[86]) , .DI87(weight_sram_datain[87]) ,
                .DI88(weight_sram_datain[88]) , .DI89(weight_sram_datain[89]) , .DI90(weight_sram_datain[90]) , .DI91(weight_sram_datain[91]) , .DI92(weight_sram_datain[92]) , .DI93(weight_sram_datain[93]) , .DI94(weight_sram_datain[94]) , .DI95(weight_sram_datain[95]) ,
                .DI96(weight_sram_datain[96]) , .DI97(weight_sram_datain[97]) , .DI98(weight_sram_datain[98]) , .DI99(weight_sram_datain[99]) , .DI100(weight_sram_datain[100]) , .DI101(weight_sram_datain[101]) , .DI102(weight_sram_datain[102]) , .DI103(weight_sram_datain[103]) ,
                .DI104(weight_sram_datain[104]) , .DI105(weight_sram_datain[105]) , .DI106(weight_sram_datain[106]) , .DI107(weight_sram_datain[107]) , .DI108(weight_sram_datain[108]) , .DI109(weight_sram_datain[109]) , .DI110(weight_sram_datain[110]) , .DI111(weight_sram_datain[111]) ,
                .DI112(weight_sram_datain[112]) , .DI113(weight_sram_datain[113]) , .DI114(weight_sram_datain[114]) , .DI115(weight_sram_datain[115]) , .DI116(weight_sram_datain[116]) , .DI117(weight_sram_datain[117]) , .DI118(weight_sram_datain[118]) , .DI119(weight_sram_datain[119]) ,
                .DI120(weight_sram_datain[120]) , .DI121(weight_sram_datain[121]) , .DI122(weight_sram_datain[122]) , .DI123(weight_sram_datain[123]) , .DI124(weight_sram_datain[124]) , .DI125(weight_sram_datain[125]) , .DI126(weight_sram_datain[126]) , .DI127(weight_sram_datain[127]) ,
                .CK(clk), .WEB(weight_sram_web), .OE(1'b1), .CS(1'b1));

// -------------------------------

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel
output wire [ID_WIDTH-1:0]      arid_m_inf; // In this project, we only use this to recognize master
output wire [1:0]            arburst_m_inf; // only INCR: 2b’01 support in this Project
output wire [2:0]             arsize_m_inf; // We only support 3b’100 which is 16 Bytes
output wire [7:0]              arlen_m_inf;
output reg                  arvalid_m_inf;
input  wire                  arready_m_inf;
output reg [ADDR_WIDTH-1:0]  araddr_m_inf;
assign arid_m_inf    = 0 ;
assign arburst_m_inf = 2'b01;
assign arsize_m_inf  = 3'b100 ;
assign arlen_m_inf = 127;

// ------------------------
// (2)	axi read data channel
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf; // This project only support 128 bit data width
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf; // In this project we only issue OKAY(2’b00)

// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel
output wire [ID_WIDTH-1:0]      awid_m_inf; // In this project, we only use this to recognize master
output wire [1:0]            awburst_m_inf; // only INCR(2’b01) support in this Project
output wire [2:0]             awsize_m_inf; // We only support 3b’100 which is 16 Bytes
output wire [7:0]              awlen_m_inf;
output reg                  awvalid_m_inf;
input  wire                  awready_m_inf;
output reg [ADDR_WIDTH-1:0]  awaddr_m_inf;
assign awid_m_inf    = 0 ;
assign awburst_m_inf = 2'b01 ;
assign awsize_m_inf  = 3'b100 ;
assign awlen_m_inf = 127;
// -------------------------
// (2)	axi write data channel
output reg                   wvalid_m_inf;
input  wire                  wready_m_inf;
output reg [DATA_WIDTH-1:0]   wdata_m_inf;
output reg                    wlast_m_inf;
// -------------------------
// (3)	axi write response channel
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output reg                    bready_m_inf;
input  wire  [1:0]             bresp_m_inf; // In this project we only issue OKAY(2’b00)
// -----------------------------

reg [4:0] c_state , n_state ;

reg [4:0] frame_r;
reg [3:0] net_cnt; // max : 15
reg counter;
reg [3:0] net_r  [14:0];  // 4 bits * 15
reg [5:0] Source_x[14:0]; // 6 bits * 15
reg [5:0] Source_y[14:0]; // 6 bits * 15
reg [5:0] Sink_x[14:0];   // 6 bits * 15
reg [5:0] Sink_y[14:0];   // 6 bits * 15

reg [31:0] frame_start  ;
reg [31:0] weight_start ;
always@(*) begin
    frame_start  = {16'd1 ,frame_r , 11'b0};
    weight_start = {16'd2 ,frame_r , 11'b0};
end

// filling ----------------------------
integer  i,j;
reg [1:0] path_cnt;

reg [1:0] frame [63:0][63:0];
reg [1:0] next_frame [65:0][65:0];
always@(*) begin // next frame logic
    for(i = 0 ; i <= 65 ; i = i + 1 ) begin
        for(j = 0 ; j <= 65 ; j = j + 1 ) begin
            if(i > 0 && i < 65 && j > 0 && j < 65  )
                next_frame[i][j] = frame[ i - 1 ][ j - 1 ] ;
            else
                next_frame[i][j] = 0 ;
        end
    end // zero padding
end

// retrace ----------------------------
reg [3:0] re_cnt; // save source - sink pairs number
reg [5:0] source_x , source_y;
reg [5:0] sink_x   , sink_y;

always@(*) begin
    source_x = Source_x[ re_cnt ] ;
    source_y = Source_y[ re_cnt ] ;
    sink_x   =   Sink_x[ re_cnt ] ;
    sink_y   =   Sink_y[ re_cnt ] ;
end

reg [5:0] retrace_x , retrace_y ;
reg [5:0] n_retrace_x , n_retrace_y;
reg [1:0] targer;
reg [6:0] sram_addr; // cal correct addr
always@(*) begin
    if(path_cnt[1] == 1 ) //find 3 or 2
        targer = 3 ;
    else
        targer = 2 ;

    if(next_frame[retrace_y + 2][retrace_x + 1] == targer ) begin //down
        n_retrace_x =  retrace_x ;
        n_retrace_y =  retrace_y + 1;
    end
    else if(next_frame[retrace_y ][retrace_x + 1] == targer ) begin  // up
        n_retrace_x =  retrace_x    ;
        n_retrace_y =  retrace_y - 1;
    end
    else if(next_frame[retrace_y + 1][retrace_x + 2] == targer ) begin //right
        n_retrace_x =  retrace_x + 1;
        n_retrace_y =  retrace_y    ;
    end
    else begin //left
        n_retrace_x =  retrace_x - 1;
        n_retrace_y =  retrace_y    ;
    end

    sram_addr = { n_retrace_y , n_retrace_x[5]} ;
end

reg [3:0] weight_target;
reg [3:0] weight_temp;
reg [127:0] new_frame_in;
always@(*) begin
    weight_target = 0;
    for( i = 0 ; i < 32 ; i = i + 1) begin
        if( n_retrace_x[4:0] == i) begin
            new_frame_in[i*4 +: 4] = net_r[re_cnt];
        end
        else
            new_frame_in[i*4 +: 4] = frame_sram_dataout[i*4 +: 4];
        if( retrace_x[4:0] == i)
            weight_target =  weight_sram_dataout[i*4 +: 4];
    end
end


parameter Idle          = 0 ,
          Read_frame    = 1 ,
          Read_frame2   = 2 ,
          Read_weight   = 3 ,
          Read_weight2  = 4 ,
          Next_round    = 5 ,
          Wave          = 6 ,
          Retrace       = 7 ,
          Retrace2      = 8 ,
          Write_frame   = 9 ,
          Write_frame2 = 10 ,
          Write_frame3 = 11 ;


always@(*) begin
    frame_sram_addr_in = frame_sram_addr;
    weight_sram_addr_in = weight_sram_addr;
    if(c_state == Retrace ) begin
        frame_sram_addr_in = sram_addr;
        weight_sram_addr_in = sram_addr;
    end
    else if(c_state == Retrace2 ) begin
        frame_sram_addr_in  = sram_addr;
        weight_sram_addr_in = sram_addr;
    end
    else if(wready_m_inf) begin
        frame_sram_addr_in = addr_add1;
    end
end

always@(*) begin  //   frame_sram_datain block
    frame_sram_datain = rdata_m_inf;
    if(c_state == Retrace2  ) begin
        frame_sram_datain = new_frame_in;
    end
end

always@(*) begin //    frame_sram_web block
    if(c_state == Read_frame2 || c_state == Retrace2)
        frame_sram_web   = 0;
    else
        frame_sram_web   = 1;
end

always@(*) begin  //    weight_sram_web block
    if(c_state ==  Read_weight2  || c_state == Next_round)
        weight_sram_web  = 0;
    else
        weight_sram_web  = 1;
end

always @(*) begin // next stage logic
    n_state = c_state;
    case(c_state)
        Idle : begin
            if(in_valid)
                n_state = Read_frame;
        end
        Read_frame: begin
            if(arready_m_inf == 1)
                n_state = Read_frame2;
        end
        Read_frame2: begin
            if(rlast_m_inf == 1 ) begin
                n_state = Read_weight;
            end
        end
        Read_weight: begin
            if(arready_m_inf == 1)
                n_state = Read_weight2;
        end
        Read_weight2: begin
            if(rlast_m_inf == 1 ) begin
                n_state = Next_round;
            end
        end
        Next_round: begin
            n_state = Wave;
        end
        Wave : begin
            if( frame[ sink_y ][ sink_x ][1] ) // sink be changed
                n_state =  Retrace;
            else
                n_state = Wave;
        end
        Retrace: begin
            n_state = Retrace2;
        end
        Retrace2: begin
            if( n_retrace_x == source_x && n_retrace_y == source_y) begin// retrace to start point
                if(re_cnt + 1 != net_cnt ) // calculate next source - sink
                    n_state = Next_round;
                else   // end of retrace
                    n_state = Write_frame;
            end
            else
                n_state = Retrace;
        end

        Write_frame: begin
            if(awready_m_inf == 1)
                n_state =  Write_frame2;
        end
        Write_frame2: begin
            if(frame_sram_addr == 127 ) begin
                n_state =  Write_frame3;
            end
        end
        Write_frame3: begin
            if(bvalid_m_inf  == 1) begin
                n_state = Idle;
            end
        end
    endcase
end

always@(posedge clk  or negedge rst_n ) begin // FSM
    if(!rst_n)
        c_state <= Idle;
    else
        c_state <= n_state;
end
reg first;
// AXI interface
always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        first <= 1;
        path_cnt <= 0;
        re_cnt <= 0;

        cost <= 0;
        weight_temp <= 0;
    end
    else begin
        case(c_state)
            Idle: begin
                cost <= 0;
                first <= 1;
                weight_temp <= 0;

                frame_sram_addr <= 0;

                weight_sram_addr <= -1;
                weight_sram_datain <= 0;

                // (1)	axi read address channel
                arvalid_m_inf <= 0;
                araddr_m_inf  <= 0;

                // (2)	axi read data channel
                rready_m_inf <= 0 ;

                // (1) 	axi write address channel
                awvalid_m_inf <= 0;
                awaddr_m_inf <= 0;

                // (2)	axi write data channel
                wvalid_m_inf <= 0;
                wdata_m_inf  <= 0;
                wlast_m_inf  <= 0;

                // (3)	axi write response channel
                bready_m_inf <= 0;

                path_cnt <= 0;
                re_cnt <= 0;
            end

            Read_frame: begin // frame read address channel
                araddr_m_inf <= frame_start  ;

                if(arready_m_inf == 0) begin
                    arvalid_m_inf <= 1;
                end
                else begin
                    arvalid_m_inf <= 0;
                    rready_m_inf <= 1;
                end
            end

            Read_frame2: begin // frame read data channel
                if(rvalid_m_inf  == 1 ) begin
                    frame_sram_addr <= addr_add1;
                    //frame_sram_datain <= rdata_m_inf;

                    if(addr_add1[0] == 1) begin //
                        for (i = 0 ; i <= 31 ; i = i + 1)
                            frame[frame_sram_addr[6:1]][i] <= (rdata_m_inf[4*i +: 4] == 0)? 0 : 1 ;
                    end
                    else begin
                        for (i = 0 ; i <= 31 ; i = i + 1)
                            frame[frame_sram_addr[6:1]][i + 32] <= (rdata_m_inf[4*i +: 4] == 0)? 0 : 1 ;
                    end
                end

                if(rlast_m_inf == 1 ) begin //    frame_sram_web <= 0 ; // write
                    rready_m_inf <= 0;
                    arvalid_m_inf <= 1;
                    araddr_m_inf <= weight_start  ;
                end
            end

            Read_weight: begin  // weight read address channel
                if(arready_m_inf == 1) begin
                    arvalid_m_inf <= 0;
                    rready_m_inf <= 1;
                end
            end

            Read_weight2: begin // weight read data channel

                if(rvalid_m_inf  == 1 ) begin
                    weight_sram_addr <= weight_sram_addr + 1;
                    weight_sram_datain <= rdata_m_inf;
                end

            end

            Next_round: begin
                first <= 1;
                weight_temp <= 0;
                for(i = 0 ; i < 64 ; i = i + 1 ) begin  //  clear up 2 and 3
                    for(j = 0 ; j < 64 ; j = j + 1 ) begin
                        frame[i][j] <= {1'b0, {(~frame[i][j][1]) & frame[i][j][0]}}; //    if(frame[i][j] != 1)  frame[i][j]  <= 0 ;
                    end
                end
                path_cnt <= 0;
                frame[source_y][source_x][1] <= 1; // start from 3 -> 2 -> 2 -> 3
                frame[ sink_y ][ sink_x ][0] <= 0; // end point
            end

            Wave : begin
                for(i = 1 ; i < 65 ; i = i + 1 ) begin
                    for(j = 1 ; j < 65 ; j = j + 1 ) begin
                        if( (next_frame[i][j] == 0)  &&  ( next_frame[ i + 1 ][ j ][1]  || next_frame[ i ][ j + 1 ][1]  ||  next_frame[ i - 1 ][ j ][1] || next_frame[ i ][ j - 1 ][1] ))
                            frame[i - 1][j - 1] <= {1'b1,path_cnt[1]};
                    end
                end

                if( frame[ sink_y ][ sink_x ][1] ) begin
                    path_cnt <= path_cnt - 2;
                    retrace_x <= sink_x ;
                    retrace_y <= sink_y ;  // save retrace start position (sink)
                end
                else begin  // deasination (sink) still 0
                    path_cnt <= path_cnt + 1;
                end
            end
            Retrace: begin //read weight and frame
                frame[retrace_y][retrace_x] <= 1;
                if(!first)
                    weight_temp <= weight_target ;
                else
                    first <= 0;
            end

            Retrace2: begin //add cost save new frame
                retrace_x <= n_retrace_x;
                retrace_y <= n_retrace_y;
                path_cnt <= path_cnt - 1;

                if(n_retrace_x == source_x && n_retrace_y == source_y) begin
                    if(re_cnt + 1 != net_cnt) begin // new target - sink pairs
                        re_cnt <= re_cnt + 1;
                    end
                end
                cost <= cost + weight_temp;   // add cost
            end

            Write_frame: begin // frame write address channel
                awaddr_m_inf <= frame_start  ;
                frame_sram_addr <= 0;

                if(awready_m_inf == 0) begin
                    awvalid_m_inf <= 1;
                end
                else begin
                    awvalid_m_inf <= 0;
                    wvalid_m_inf <= 1;
                    frame_sram_addr <= addr_add1;
                    wdata_m_inf     <= frame_sram_dataout;
                end
            end

            Write_frame2: begin
                if(wready_m_inf == 1) begin
                    frame_sram_addr <= addr_add1;
                    wdata_m_inf <= frame_sram_dataout;
                    if(frame_sram_addr == 127)
                        wlast_m_inf <= 1;
                end
            end
            Write_frame3: begin // frame write respond channel
                wlast_m_inf <= 0;
                wvalid_m_inf <= 0;

                if(bvalid_m_inf  == 0 ) begin
                    bready_m_inf <= 1;
                end
                else begin
                    bready_m_inf <= 0;
                end
            end
        endcase
    end
end

reg c_state2 , n_state2;

parameter IDLE = 0,
          LOAD = 1;

always@(*) begin // n_state2 logic
    n_state2 = c_state2;
    case(c_state2)
        IDLE: begin
            if(in_valid)
                n_state2 = LOAD;
        end
        LOAD: begin
            if(bvalid_m_inf  == 1)
                n_state2 = IDLE;
        end
    endcase
end

always@(posedge clk or negedge rst_n ) begin
    if(!rst_n)
        c_state2 <= IDLE;
    else
        c_state2 <= n_state2;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        net_cnt <= 0;
        counter <= 0;
        busy <= 0;
    end
    else begin
        case(c_state2)
            IDLE: begin
                net_cnt <= 0;
                counter <= 0;
                busy <= 0;
                if(in_valid) begin
                    frame_r <= frame_id ;
                    net_r   [net_cnt] <= net_id;
                    Source_x[net_cnt] <= loc_x;
                    Source_y[net_cnt] <= loc_y;
                end
            end
            LOAD: begin
                if(in_valid) begin
                    counter <= ~ counter;
                    if(counter == 0) begin
                        Sink_x[net_cnt] <= loc_x;
                        Sink_y[net_cnt] <= loc_y;
                        net_cnt <= net_cnt + 1;
                    end
                    else begin
                        net_r  [net_cnt] <= net_id;
                        Source_x[net_cnt] <= loc_x;
                        Source_y[net_cnt] <= loc_y;
                    end
                end
                else begin
                    if(bvalid_m_inf  == 1)
                        busy <= 0;
                    else
                        busy <= 1;
                end
            end
        endcase
    end
end
endmodule // 2476213.007088    9.5
          // 2483525.040442    9.4
          // 2500217.721912    9.3
