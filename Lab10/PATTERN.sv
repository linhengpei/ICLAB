`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

integer i_pat;
integer i_mod9;
integer latency;
integer i,j,t;

logic [ 1:0] action_temp ;
logic [ 2:0] type_temp ;
logic [ 1:0] size_temp ;
logic [ 3:0] date_month ;
logic [ 4:0] date_day ;
logic [ 7:0] box_number;
logic [11:0] black;
logic [11:0] green;
logic [11:0] milk;
logic [11:0] pineapple;
logic complete ;
logic [1:0]err_msg ;
logic [63:0]dram_data;
string action_str ;
string type_str ;
string size_str ;
string err_str;

parameter PAT_NUM    = 3600 ;
string reset_color       = "\033[1;0m";
string txt_black_prefix  = "\033[1;30m";
string txt_red_prefix    = "\033[1;31m";
string txt_green_prefix  = "\033[1;32m";
string txt_yellow_prefix = "\033[1;33m";
string txt_blue_prefix   = "\033[1;34m";
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";

integer make_cnt;
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 256 box
class random_act; //Class representing a random action.
    randc Action  act_id;
    constraint range{
        act_id inside{Make_drink, Supply, Check_Valid_Date};
    }
endclass

class random_type; //Class representing a random type.
    randc  Bev_Type Type;
    constraint range{
        Type inside{ Black_Tea , Milk_Tea , Extra_Milk_Tea , Green_Tea ,
        Green_Milk_Tea , Pineapple_Juice  , Super_Pineapple_Tea , Super_Pineapple_Milk_Tea } ;
    }
endclass

class random_size; //Class representing a random size.
    randc Bev_Size Size;
    constraint range{
        Size inside{ L, M, S};
    }
endclass

class random_date; //Class representing a random date.
    randc Date Date;
    constraint range{
        Date.M inside{ [1:12]};
        if (Date.M == 2) {
            Date.D inside {[1:28]};
        } else if (Date.M == 4 || Date.M == 6 || Date.M == 9 || Date.M == 11) {
            Date.D inside {[1:30]};
        }else{
            Date.D inside {[1:31]};
        }
    }
endclass // need modify

class random_box; //Class representing a random box from 0 to 255.
    randc logic [7:0] box_id;
    constraint range{
        box_id inside{[0:255]};
    }
endclass

class random_quantity; //Class representing a random box from 0 to 255.
    randc logic [11:0] Quantity;
    constraint range{
        Quantity inside{[0:4095]};
    }
endclass

initial $readmemh(DRAM_p_r, golden_DRAM);

integer cnt;
initial begin
    make_cnt = 0;
    cnt = 0;
    reset_signal_task;
    for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin

        input_task;
        wait_out_valid_task;
        check_ans_task;
        str_task;

        $display(txt_blue_prefix , "PASS PATTERN NO. %4d " , i_pat , 
                 txt_green_prefix ,"%-11s  %-2s %s %-25s %s", action_str ,
                 txt_yellow_prefix , size_str , type_str,        
                 txt_green_prefix ,err_str,  reset_color,);
                 //"%4d" ,cnt);
        /*
        if(action_temp == 0 && err_msg == 1)    begin
                cnt = cnt + 1;
        end
        */   
    end 
    YOU_PASS_task;
end
task str_task;
    case(action_temp)
       0 :  action_str = "Make drink";
       1 :  action_str = "Supply";
       2 : action_str  = "Check ";
    endcase

    size_str = " ";
    type_str = "                         ";
    if(action_temp == 0)begin
        case(size_temp)
        0 : size_str = "L";
        1 : size_str = "M";
        3 : size_str = "S";
        endcase

        case(type_temp)
        0 : type_str = "Black_Tea" ;
        1 : type_str = "Milk_Tea" ;
        2 : type_str = "Extra_Milk_Tea" ;
        3 : type_str = "Green_Tea" ;
        4 : type_str = "Green_Milk_Tea" ;
        5 : type_str = "Pineapple_Juice" ;
        6 : type_str = "Super_Pineapple_Tea" ;
		7 : type_str = "Super_Pineapple_Milk_Tea" ;
        endcase
    end

    case(err_msg)
       0: err_str = "No_Err" ; 
       1: err_str = "No_Exp";   
       2: err_str = "No_Ing" ;  
       3: err_str = "Ing_OF" ;                             
    endcase

endtask

task reset_signal_task;
    begin
        inf.rst_n            = 1'b1;
        inf.sel_action_valid = 1'b0;
        inf.type_valid       = 1'b0;
        inf.size_valid       = 1'b0;
        inf.date_valid       = 1'b0;
        inf.box_no_valid     = 1'b0;
        inf.box_sup_valid    = 1'b0; 
        inf.D                = 72'bx; // All X
        
        #(5);
        inf.rst_n = 1'b0;
        #(3);
        
        if(inf.out_valid !== 0 || inf.err_msg !== 0 || inf.complete !== 0  ) begin
            $display("*                                                                       *");
            $display("*                        Reset output non 0 !!                          *");
            $display("*                                                                       *");
            YOU_FAIL_task;
        end
        #(20);
        inf.rst_n = 1'b1;
    end
endtask

random_act   r_action = new();
random_type  r_type = new();
random_size  r_size = new();
random_date  r_date = new();
random_box   r_box_number = new();
random_quantity  r_quantity = new();


task input_task;
    begin
        if(inf.out_valid!== 1) begin
            
            if(i_pat == 0) begin
                @(negedge clk);
            end
            /*
            else begin
                t = $urandom_range(0, 3); // The next input
                repeat(t) @(negedge clk);
            end
            */

            // Action
            inf.sel_action_valid = 1'b1;    
            //r_action.randomize(); 
            //action_temp = r_action.act_id;   
            //action_temp = 2;
            ///////////////////////////////////////
            if(i_pat == 0)begin
                action_temp = Make_drink;
            end
            else if(i_pat > 1800)begin
                    action_temp = 0;
            end
            else begin    
                i_mod9 = i_pat %9;
                case(i_mod9)
                        1,3,0 : action_temp = 0;
                        2,5,6 : action_temp = 1;
                        4,7,8 : action_temp = 2;
                endcase
            end    
            //////////////////////////////////////
            inf.D.d_act = action_temp;
            @(negedge clk);
            inf.sel_action_valid = 1'b0;
            inf.D.d_act = 2'bX;

            case(action_temp)  // for input
            Make_drink: make_task();
            Supply: supply_task();
            Check_Valid_Date:check_task();
            endcase

            case(action_temp)  // for answer
            Make_drink: make_gold_task();
            Supply: supply_gold_task();
            Check_Valid_Date:check_gold_task();
        endcase
        end
    end
endtask

task make_task();
   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Type
    inf.type_valid = 1'b1;   
    r_type.randomize();
    //type_temp = r_type.Type;
    /////////////////////////////
    type_temp = make_cnt % 8;
    /////////////////////////////
    inf.D.d_type = type_temp;
    @(negedge clk);
    inf.type_valid = 1'b0;
    inf.D.d_type = 3'bX;

   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Size
    inf.size_valid = 1'b1;  
    r_size.randomize();
    //size_temp = r_size.Size;    
    /////////////////////////////////////
    case(make_cnt % 3)
        0: size_temp = 0;
        1: size_temp = 1;
        2: size_temp = 3;
    endcase
    /////////////////////////////////////
    inf.D.d_size = size_temp;
    @(negedge clk);
    inf.size_valid = 1'b0;
    inf.D.d_size = 2'bX;

   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Date
    inf.date_valid = 1'b1;       
    r_date.randomize();
    //date_month = r_date.Date.M;
    //date_day = r_date.Date.D;  
    /////////////////////////////////////
    if(make_cnt < 20 )begin // No_ing
        date_month = 4'd1;
        date_day = 5'd1;  
    end  // No_Exp
    else begin
        date_month = 4'd12;
        date_day = 5'd31;  
    end   
    /////////////////////////////////////

    inf.D.d_date = {date_month,date_day};
    @(negedge clk);
    inf.date_valid = 1'b0;
    inf.D.d_date = 9'bX;

  //  t = $urandom_range(0, 3); 
  //  repeat(t) @(negedge clk);

    // Barrel Number
    inf.box_no_valid = 1'b1;       
    
    r_box_number.randomize();
    //box_number = r_box_number.box_id;
    ////////////////////////////////////
    if(make_cnt < 20 )  // No_ing
        box_number = 8'd0;  
    else 
        box_number = r_box_number.box_id;
    ////////////////////////////////////
    inf.D.d_box_no = box_number;
    @(negedge clk);
    inf.box_no_valid = 1'b0;
    inf.D.d_box_no = 8'bX;


     make_cnt =  make_cnt + 1;
endtask

task supply_task();

   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Date
    inf.date_valid = 1'b1;       
    
    r_date.randomize();
    date_month = r_date.Date.M;
    date_day = r_date.Date.D;  
    //date_month = 1;
    //date_day = 1; // 01/01 

    inf.D.d_date = {date_month,date_day};
    @(negedge clk);
    inf.date_valid = 1'b0;
    inf.D.d_date = 9'bX;

   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Barrel Number
    inf.box_no_valid = 1'b1;       
    r_box_number.randomize();
    box_number = r_box_number.box_id;
    inf.D.d_box_no = box_number;
    @(negedge clk);
    inf.box_no_valid = 1'b0;
    inf.D.d_box_no = 8'bX;
 
    
    for(i = 0 ; i < 4 ; i = i + 1)begin
       // t = $urandom_range(0, 3); 
       // repeat(t) @(negedge clk);

        // Black tea
        inf.box_sup_valid = 1'b1;       
        r_quantity.randomize();
        inf.D.d_ing = r_quantity.Quantity;

        case(i)
        0:  black =  inf.D.d_ing;
        1:  green =  inf.D.d_ing;
        2:  milk =  inf.D.d_ing;
        3:  pineapple =  inf.D.d_ing;
        endcase   // for debug

        @(negedge clk);
        inf.box_sup_valid = 1'b0;
        inf.D.d_ing = 12'bX;
    end
endtask

task check_task();
   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Date
    inf.date_valid = 1'b1;       
    r_date.randomize();
    date_month = r_date.Date.M;
    date_day = r_date.Date.D;  
    inf.D.d_date = {date_month,date_day};
    @(negedge clk);
    inf.date_valid = 1'b0;
    inf.D.d_date = 9'bX;

   // t = $urandom_range(0, 3); 
   // repeat(t) @(negedge clk);

    // Barrel Number
    inf.box_no_valid = 1'b1;       
    r_box_number.randomize();
    box_number = r_box_number.box_id;
    inf.D.d_box_no = box_number;
    @(negedge clk);
    inf.box_no_valid = 1'b0;
    inf.D.d_box_no = 8'bX;
endtask

task wait_out_valid_task;
    begin
        latency = 0;
        while (inf.out_valid!== 1'b1) begin
            if(latency == 1000) begin
                $display("*                           over 1000 cycles                            *");
                YOU_FAIL_task;
            end
            latency = latency + 1;
            @(negedge clk);
        end
    end
endtask  //need to remove 


task check_ans_task;
    begin
        if(inf.out_valid === 1) begin       
            if(inf.err_msg !== err_msg || inf.complete != complete) begin 
                $display("True err_msg is : %d",err_msg);
                $display("your answer is : %d",inf.err_msg);
                YOU_FAIL_task;
            end
            @(negedge clk);
        end
    end
endtask
logic [11:0]make_black , make_green , make_milk , make_pineapple;
logic [63:0]dram_write;
task make_gold_task;
    for(i = 0 ; i < 8 ; i = i + 1)
        dram_data[ 8 *i +: 8 ] = golden_DRAM [ (65536 + 8 * box_number + i)]; // 256 box
    
    if({date_month,date_day} > {dram_data[35:32] , dram_data[4:0]} )begin // expired
        complete = 0;
        err_msg = 2'b01 ; // No_Exp
    end
    else begin
        calculate();
        if(dram_data[63:52] < make_black || dram_data[51:40] < make_green || 
         dram_data[31:20] < make_milk || dram_data[19:8] < make_pineapple)begin
            complete = 0;
            err_msg = 2'b10 ; // No_Ing
        end
        else begin
            complete = 1;
            err_msg = 2'b00 ; // No_err

            dram_write = dram_data;
            dram_write[63:52] = dram_data[63:52] - make_black;
            dram_write[51:40] = dram_data[51:40] - make_green;
            dram_write[31:20] = dram_data[31:20] - make_milk;
            dram_write[19: 8] = dram_data[19: 8] - make_pineapple;

            for(i = 0 ; i < 8 ; i = i + 1)
               golden_DRAM [ (65536 + 8 * box_number + i)] = dram_write[ 8 *i +: 8 ] ; // 256 box
        end
    end
endtask

task calculate;
    make_black = 0;
    make_green = 0;
    make_milk = 0;
    make_pineapple = 0;
    case(type_temp)
        Black_Tea :
            make_black = 960;
        Milk_Tea  : begin
            make_black = 720;
            make_milk = 240;
        end
        Extra_Milk_Tea : begin
            make_black = 480;
            make_milk  = 480;
        end
        Green_Tea :
            make_green = 960;
        Green_Milk_Tea : begin
            make_green = 480;
            make_milk  = 480;
        end
        Pineapple_Juice : begin
            make_pineapple = 960;
        end
        Super_Pineapple_Tea : begin
            make_black = 480;
            make_pineapple  = 480;
        end
        Super_Pineapple_Milk_Tea : begin
            make_black = 480;
            make_milk  = 240;
            make_pineapple = 240;
        end
    endcase

    case(size_temp)
        M : begin
            make_black =  make_black  - (make_black >> 2);
            make_green =  make_green  - (make_green >> 2);
            make_milk  =  make_milk   - (make_milk  >> 2);
            make_pineapple =  make_pineapple  - (make_pineapple >> 2);
        end
        S : begin
            make_black = (make_black >> 1);
            make_green = (make_green >> 1);
            make_milk  = (make_milk  >> 1);
            make_pineapple = (make_pineapple >> 1);
        end
    endcase
endtask


task supply_gold_task();
    for(i = 0 ; i < 8 ; i = i + 1)
        dram_data[ 8 *i +: 8 ] = golden_DRAM [ (65536 + 8 * box_number + i)]; // 256 box
    
    complete = 1;
    err_msg = 2'b00 ; // No_err
    dram_write[39:32] = date_month;
    dram_write[7:0]   = date_day;
    
    if(dram_data[63:52] + black > 4095 )begin
       complete = 0; 
       err_msg = 2'b11 ; // Img_OF
       dram_write[63:52] = 4095;  
    end
    else begin
         dram_write[63:52] = dram_data[63:52] + black;
    end

    if(dram_data[51:40] + green > 4095 )begin
       complete = 0; 
       err_msg = 2'b11 ; // Img_OF
       dram_write[51:40] = 4095;  
    end
    else begin
        dram_write[51:40] = dram_data[51:40] + green;
    end

    if(dram_data[31:20] + milk > 4095 )begin
       complete = 0; 
       err_msg = 2'b11 ; // Img_OF
       dram_write[31:20] = 4095;  
    end
    else begin
         dram_write[31:20] = dram_data[31:20] + milk;
    end

    if(dram_data[19:8] + pineapple > 4095 )begin
       complete = 0; 
       err_msg = 2'b11 ; // Img_OF
       dram_write[19:8] = 4095;  
    end
    else begin
         dram_write[19:8] = dram_data[19:8] +  pineapple ;
    end

    for(i = 0 ; i < 8 ; i = i + 1)
        golden_DRAM [ (65536 + 8 * box_number + i)] = dram_write[ 8 *i +: 8 ] ; // 256 box

endtask

task check_gold_task();
    for(i = 0 ; i < 8 ; i = i + 1)
        dram_data[ 8 *i +: 8 ] = golden_DRAM [ (65536 + 8 * box_number + i)]; // 256 box
    
    if({date_month,date_day} > {dram_data[35:32] , dram_data[4:0]} )begin // expired
        complete = 0;
        err_msg = 2'b01 ; // No_Exp
    end
    else begin
        complete = 1;
        err_msg = 2'b00 ; // No_err
    end
endtask


task YOU_PASS_task;
    begin
        $display("*************************************************************************");
        $display("*                         Congratulations                               *");
        $display("*************************************************************************");
        $finish;
    end
endtask

task YOU_FAIL_task;
    begin
        $display("*************************************************************************");
        $display("*                             Wrong Answer                              *");
        $display("*************************************************************************");
        $finish;
    end
endtask



endprogram
