module SORT_IP #(parameter IP_WIDTH = 8) (
           // Input signals
           IN_character, IN_weight,
           // Output signals
           OUT_character
       );

input [IP_WIDTH*4-1:0]  IN_character;  // each character 4 bits
input [IP_WIDTH*5-1:0]  IN_weight;     // each weight 5 bits

output  [IP_WIDTH*4-1:0] OUT_character; // each character 4 bits


reg [4:0] w_temp;
reg [4:0] c_temp;

wire [3:0]  character_temp [IP_WIDTH - 1 : 0 ];  // each character 4 bits
wire [4:0]  weight_temp    [IP_WIDTH - 1 : 0 ];  // each weight 5 bits

reg [3:0]  character [IP_WIDTH - 1 : 0 ];  // each character 4 bits
reg [4:0]  weight    [IP_WIDTH - 1 : 0 ];  // each weight 5 bits

genvar  gen_i;
generate
    for( gen_i = 0 ; gen_i < IP_WIDTH ; gen_i =  gen_i + 1) begin
        assign weight_temp[gen_i] =    IN_weight[ (gen_i*5) + 4 : (gen_i * 5)];
        assign character_temp[gen_i] = IN_character[ (gen_i*4) + 3 : (gen_i * 4)];
    end
endgenerate

integer  i , j ;
always@(*) begin
    for( i = 0 ; i < IP_WIDTH ; i =  i + 1) begin
        weight[i] =  weight_temp[i];
        character[i] = character_temp[i];
    end

    // bouble sort
    for( i = 0 ; i < IP_WIDTH ; i =  i + 1) begin
        for( j = IP_WIDTH - 1 ; j > i  ; j =  j - 1) begin
            if(weight[j] < weight[j - 1]) begin

                c_temp = character[j];
                character[j] = character[j - 1];
                character[j - 1] =  c_temp ;

                w_temp = weight[j];
                weight[j] = weight[j - 1];
                weight[j - 1] =  w_temp ;
            end
        end
    end
end

generate
    for( gen_i = 0 ; gen_i < IP_WIDTH ; gen_i =  gen_i + 1) begin
        assign OUT_character[(gen_i*4) + 3: (gen_i*4)] =  character[gen_i];
    end
endgenerate

endmodule
