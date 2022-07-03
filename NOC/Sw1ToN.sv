// ---------------------------------------------------------------------
//
// FILE NAME    : Sw1ToN.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module Sw1ToN #(
//add parameters there
parameter OUT_N = 8,
parameter OUT_W = 3,
parameter TAG_W = 4
)(
//input output begin
input logic                         upreq_i,
input logic[TAG_W-1:0]              uptag_i,
input logic[OUT_W-1:0]              up_swb_i,
output logic                        uprdy_o,

output logic[OUT_N-1:0]             dnreq_o,
output logic[OUT_N-1:0][TAG_W-1:0]  dntag_o,
input  logic[OUT_N-1:0]             dnrdy_i
);

assign dntag_o = {OUT_N{uptag_i}};
for (genvar i = 0; i < OUT_N; i=i+1) begin:OUTASSIGN
    assign dnreq_o[i] = upreq_i && (up_swb_i == (OUT_W)'(i)); 
end:OUTASSIGN
localparam ALIGN_N = 2**OUT_W;
logic[ALIGN_N-1:0] rdy_align_i;
assign rdy_align_i[OUT_N-1:0] = dnrdy_i;
if (ALIGN_N > OUT_N) begin :PADDINGZERO
    assign rdy_align_i[ALIGN_N-1:OUT_N] = '0;
end
assign uprdy_o = rdy_align_i[up_swb_i];
endmodule



