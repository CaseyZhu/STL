// ---------------------------------------------------------------------
//
// FILE NAME    : SwMToN.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module SwMToN #(
//add parameters there
parameter IN_N  = 5,
parameter OUT_N = 5,
parameter TAG_W = 32,
parameter ARB_EN= 0
)(
//input output begin
input                                    clk,
input                                    rst_n,
input  logic[IN_N-1:0]                   upreq_i,
input  logic[IN_N-1:0][$clog2(IN_N)-1:0] up_swb_i,
input  logic[IN_N-1:0][TAG_W-1:0]        uptag_i,
output logic[IN_N-1:0]                   uprdy_o,

output logic[OUT_N-1:0]                  dnreq_o,
output logic[OUT_N-1:0][TAG_W-1:0]       dntag_o,
input  logic[OUT_N-1:0]                  dnrdy_i
);

logic[IN_N-1:0][OUT_N-1:0]             req_1ton,req_1ton_rdy;
logic[IN_N-1:0][OUT_N-1:0][TAG_W-1:0]  req_1ton_tag;

logic[OUT_N-1:0][IN_N-1:0]             req_1ton_trans,req_1ton_rdy_trans;
logic[OUT_N-1:0][IN_N-1:0][TAG_W-1:0]  req_1ton_tag_trans;

for (genvar i = 0; i < IN_N; i=i+1) begin:SW1TON

    Sw1ToN #(.OUT_N                     (OUT_N        ),
             .OUT_W                     ($clog2(OUT_N)),
             .TAG_W                     (TAG_W        ))
        u_Sw1ToN (
                  // Outputs
                  .uprdy_o              (uprdy_o[i]),
                  .dnreq_o              (req_1ton[i]),
                  .dntag_o              (req_1ton_tag[i]),
                  // Inputs
                  .upreq_i              (upreq_i[i]),
                  .uptag_i              (uptag_i[i]),
                  .up_swb_i             (up_swb_i[i]),
                  .dnrdy_i              (req_1ton_rdy[i]));

end:SW1TON
StlTans #(.WX   (OUT_N),
          .WY   (IN_N))
 u_StlTansRdy (
            .data_o               (req_1ton_rdy),
            // Inputs
            .data_i               (req_1ton_rdy_trans));

StlTans #(.WX   (IN_N),
          .WY   (OUT_N))
 u_StlTansReq (
            .data_o               (req_1ton_trans),
            // Inputs
            .data_i               (req_1ton));

for (genvar i = 0; i < OUT_N; i=i+1) begin:TRANSTAGS
    for (genvar j = 0; j < IN_N; j=j+1) begin:TRANSTAG
        assign req_1ton_tag_trans[i][j] = req_1ton_tag[j][i];
    end:TRANSTAG
end:TRANSTAGS

for (genvar i = 0; i < OUT_N; i=i+1) begin:SWNTO1
   
   SwNTo1 #(.IN_N                       (IN_N), 
            .TAG_W                      (TAG_W),
            .ARB_EN                     (ARB_EN))
       u_SwNTo1 (            
                 // Outputs
                 .uprdy_o               (req_1ton_rdy_trans[i]),
                 .dnreq_o               (dnreq_o[i]),
                 .dntag_o               (dntag_o[i]),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .upreq_i               (req_1ton_trans[i]),
                 .uptag_i               (req_1ton_tag_trans[i]),
                 .dnrdy_i               (dnrdy_i[i]));

end:SWNTO1

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" "../Common/rtl/")
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


