// ---------------------------------------------------------------------
//
// FILE NAME    : Rshift.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2021-06-22     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlRshift #(
//add parameters there
parameter DIM_N = 16,
parameter DAT_W = 10,
parameter SHT_W = 4 ,
parameter MODE  = 0  //0 left rotate shift, 1 right rotate shift 
)(
input  logic[DIM_N-1:0][DAT_W-1:0] data_i,
input  logic[SHT_W-1:0]            shft  ,
output logic[DIM_N-1:0][DAT_W-1:0] data_o
);
logic[DAT_W-1:0][DIM_N-1:0] data_i_trans;
logic[DAT_W-1:0][DIM_N-1:0] data_i_shft_msb,data_i_shft_lsb,data_i_shft;
for (genvar i = 0; i < DAT_W; i=i+1) begin:DW_ASS
    if(MODE) begin:RIGHT
        assign {data_i_shft_msb[i],data_i_shft_lsb[i]} = { data_i_trans[i], data_i_trans[i]} >> shft;
        assign data_i_shft[i] = data_i_shft_lsb[i] ;
    end else begin:LEFT
        assign {data_i_shft_msb[i],data_i_shft_lsb[i]} = { data_i_trans[i], data_i_trans[i]} << shft;
        assign data_i_shft[i] =  data_i_shft_msb[i];
    end
    for (genvar j = 0; j < DIM_N; j=j+1) begin:DM_ASS
        assign data_i_trans[i][j] = data_i[j][i];
        assign data_o[j][i]       = data_i_shft[i][j];
    end:DM_ASS
end:DW_ASS

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


