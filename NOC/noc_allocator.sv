// ---------------------------------------------------------------------
//
// FILE NAME    : noc_allocator.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-30     zhuzhiqi   initial coding
// NxN allocator use wavefront method, allocate roundrobin can control outside
// this module
// ---------------------------------------------------------------------

module noc_allocator #(
//add parameters there
parameter DIM_N = 8
)(
//input output begin
input  logic[DIM_N-1:0][DIM_N-1:0] req_i,
output logic[DIM_N-1:0][DIM_N-1:0] grn_o
);
localparam DIMW = $clog2(DIM_N);
//tokenpos
logic[DIM_N-1:0][1:0][DIM_N-1:0] token_ena;
for (genvar i = 0; i < DIM_N; i=i+1) begin:WAVEFRONT
     for (genvar j = 0; j < DIM_N; j=j+1) begin:GRANT
         localparam TOKEN_POS = (DIMW)'( (((DIM_N-j)%DIM_N) + i)%DIM_N );
         if(i==0)  begin:FIRSTWAVE
             assign grn_o[TOKEN_POS][j]        = req_i[TOKEN_POS][j];
             assign token_ena[i][0][j]         = !req_i[TOKEN_POS][j];
             assign token_ena[i][1][TOKEN_POS] = !req_i[TOKEN_POS][j];
         end:FIRSTWAVE
         else begin:OTHERWAVE
             assign grn_o[TOKEN_POS][j]        = req_i[TOKEN_POS][j] && 
                                                 token_ena[i-1][1][TOKEN_POS] &&
                                                 token_ena[i-1][0][j];
             assign token_ena[i][0][j]         = token_ena[i-1][0][j] && !grn_o[TOKEN_POS][j];
             assign token_ena[i][1][TOKEN_POS] = token_ena[i-1][1][TOKEN_POS] &&
                                                 !grn_o[TOKEN_POS][j];
         end:OTHERWAVE
     end:GRANT

end:WAVEFRONT


endmodule



