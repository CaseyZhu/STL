// ---------------------------------------------------------------------
//
// FILE NAME    : PingPong.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-05-24     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlPingPong #(
//add parameters there, fast have high priority
parameter DATA_W = 1024
)(
input                           clk,
input                           rst_n,
input  logic                    upreq_vld_i,
input  logic[DATA_W-1:0]        upreq_dat_i,
output logic                    upreq_rdy_o,

output  logic                   dnreq_vld_o,
output  logic[DATA_W-1:0]       dnreq_dat_o,
input   logic                   dnreq_rdy_i 
);
logic                   hsk_i, hsk_o, pp_wptr,pp_rptr;
logic [1:0][DATA_W-1:0] data_pp;
logic [1:0]             pp_vld;

assign upreq_rdy_o = ~pp_vld[pp_wptr];
assign hsk_i       = upreq_vld_i && upreq_rdy_o;
assign dnreq_vld_o = pp_vld[pp_rptr];
assign hsk_o       = dnreq_vld_o && dnreq_rdy_i;
assign dnreq_dat_o = data_pp[pp_rptr];

`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        pp_wptr <=  'h0;
    end else if (hsk_i) begin
        pp_wptr <=  ~pp_wptr;
    end
`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        pp_rptr <=  'h0;
    end else if (hsk_o) begin
        pp_rptr <=  ~pp_rptr;
    end
always_ff @(posedge clk) begin
    if (hsk_i) begin
      data_pp[pp_wptr] <= upreq_dat_i;
    end
end
for (genvar i = 0; i < 2; i=i+1) begin:VLDCTRL
    `ALWAYS_CLK(clk, rst_n)
        if (!rst_n) begin
            pp_vld[i] <=  'h0;
        end else if (hsk_o&&(pp_rptr==(1)'(i))) begin
            pp_vld[i] <=  'h0;
        end else if (hsk_i&&(pp_wptr==(1)'(i))) begin
            pp_vld[i] <=  'h1;
        end
end:VLDCTRL
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


