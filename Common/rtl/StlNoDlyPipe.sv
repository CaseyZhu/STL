// ---------------------------------------------------------------------
//
// FILE NAME    : StlNoDlyPipe.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
// use this to improve performance 
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlNoDlyPipe #(
//add parameters there
parameter DATA_W  = 10,
parameter PIPE_EN = 1 //pipe enable
)(
//input output begin
input                      clk,
input                      rst_n,
input  logic               upvld_i,
output logic               uprdy_o,
input  logic [DATA_W-1:0]  updat_i,

output logic               dnvld_o,
input logic                dnrdy_i,
output logic [DATA_W-1:0]  dndata_o
);
if(PIPE_EN) begin:PIPEENABLE
    logic buf_vld,buf_rdy, buf_wen, hsk_o;
    logic [DATA_W-1:0] buf_dat;
    assign buf_rdy = ~buf_vld;
    assign uprdy_o = dnrdy_i || buf_rdy;
    assign buf_wen = upvld_i && (buf_rdy&&~dnrdy_i || buf_vld&&dnrdy_i);
    assign dnvld_o = buf_vld || upvld_i;
    assign hsk_o   = dnvld_o && dnrdy_i;
    assign dndata_o= buf_vld ? buf_dat : updat_i;
    `ALWAYS_CLK(clk, rst_n)
        if (!rst_n) begin
           buf_vld <=  'h0;
        end else if (buf_wen) begin
           buf_vld <=  'h1;
        end else if (hsk_o) begin
           buf_vld <=  'h0; 
        end
    always_ff @(posedge clk) begin
        if (buf_wen) begin
           buf_dat <= updat_i;
        end
    end

end:PIPEENABLE
else begin:BYPASS
    always_comb begin
        dnvld_o  = upvld_i;
        uprdy_o  = dnrdy_i;
        dndata_o = updat_i;
    end
    
end:BYPASS
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


