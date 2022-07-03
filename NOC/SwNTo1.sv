// ---------------------------------------------------------------------
//
// FILE NAME    : SwNTo1.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
// if the path have pre-allocated no need to arb
// ---------------------------------------------------------------------

module SwNTo1 #(
//add parameters there
parameter IN_N  = 8,
parameter TAG_W = 4,
parameter ARB_EN= 0
)(
//input output begin
input                               clk,
input                               rst_n,
input  logic[IN_N-1:0]              upreq_i,
input  logic[IN_N-1:0][TAG_W-1:0]   uptag_i,
output logic[IN_N-1:0]              uprdy_o,

output logic                        dnreq_o,
output logic[TAG_W-1:0]             dntag_o,
input  logic                        dnrdy_i
);

if (ARB_EN) begin:ARBBETWEEN_N
    
    StlArbiter #(
                 // Parameters
                 .REQ_N                 (IN_N ),
                 .DAT_W                 (TAG_W),
                 .WGT_W                 (1    ),
                 .TYPE                  (1    ), //round-robin
                 .KEEP_EN               (0    )) //no keep
        u_StlArbiter (/*AUTOINST*/
                      // Outputs
                      .req_rdy_o        (uprdy_o),
                      .grt_vld_o        (dnreq_o),
                      .grt_dat_o        (dntag_o),
                      // Inputs
                      .clk              (clk    ),
                      .rst_n            (rst_n  ),
                      .arb_keep         (1'b0   ),
                      .req_vld_i        (upreq_i),
                      .req_dat_i        (uptag_i),
                      .req_wgt_i        ('0     ),
                      .grt_rdy_i        (dnrdy_i));

end:ARBBETWEEN_N
else begin:NOARB
   assign dnreq_o = |upreq_i; 
   assign uprdy_o = upreq_i & {IN_N{dnrdy_i}};
   logic[TAG_W-1:0][IN_N-1:0]   uptag_and;
   for (genvar i = 0; i < TAG_W; i=i+1) begin:TAGAND
       for (genvar j = 0; j < IN_N; j=j+1) begin:TAGANDTANS
           assign  uptag_and[i][j] = uptag_i[j][i] & upreq_i[i];
       end:TAGANDTANS
       assign dntag_o[i] = |uptag_and[i];
   end:TAGAND

end:NOARB
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" "../Common/rtl")
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


