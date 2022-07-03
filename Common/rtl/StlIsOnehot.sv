// ---------------------------------------------------------------------
//
// FILE NAME    : StlIsOnehot.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlIsOnehot #(
parameter WIDTH = 16,
parameter CMP_EN= 0
)(
input   logic[WIDTH-1:0] data_i,
output  logic            vld_o
);

if(CMP_EN) begin:CMP_IMP
logic[WIDTH-1:0] onehot_hit;
    for (genvar i = 0; i < WIDTH; i=i+1) begin:EQUALCMP
        assign onehot_hit[i] = ((WIDTH)'(1) << i) == data_i;
    end
    assign vld_o = |onehot_hit;
end:CMP_IMP
else begin:XOR_IMP
    
  localparam WIDTH_EXP = 2**($clog2(WIDTH));
  
  logic [WIDTH_EXP-1:0] i_flg;
  logic [WIDTH_EXP*2-2:0] flg_xor,flg_and,flg_and_or;
  always_comb begin
     i_flg = '0;
     i_flg = data_i; 
  end

     for (genvar i = 0; i <= $clog2(WIDTH); i=i+1) begin
         if(i==$clog2(WIDTH)) begin
             for (genvar j = 0; j < 2**i; j=j+1) begin
               always_comb begin
                 flg_xor[2**i-1 + j]    = i_flg[j];
                 flg_and[2**i-1 + j]    = '0;
                 flg_and_or[2**i-1 + j] = '0;
                end
             end
         end else begin
             for (genvar j = 0; j < 2**i; j=j+1) begin
                 always_comb begin
                 flg_xor[2**i-1 + j]    = flg_xor[(2**i-1 + j)*2+1] ^ flg_xor[(2**i-1 + j)*2+2];
                 flg_and[2**i-1 + j]    = flg_xor[(2**i-1 + j)*2+1] & flg_xor[(2**i-1 + j)*2+2];
                 flg_and_or[2**i-1 + j] = flg_and_or[(2**i-1 + j)*2+1] |  flg_and_or[(2**i-1 + j)*2+2] | flg_and[2**i-1 + j];
                 end
             end
         end
     end

    assign vld_o  = flg_xor[0]&(~flg_and_or[0]);
end:XOR_IMP

endmodule
