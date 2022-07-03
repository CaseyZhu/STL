// ---------------------------------------------------------------------
//
// FILE NAME    : StlArbiter.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-27     zhuzhiqi   initial coding
// arbiter realize by StlCmp MAX
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlArbiter #(
//add parameters there
    parameter REQ_N   = 8,
    parameter DAT_W   = 16,
    parameter WGT_W   = 1,
    parameter TYPE    = 0,//0: fixed priority by weight. 1, round-robin. 2, weighted round robin.
    parameter KEEP_EN = 0
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        arb_keep, //keep using previous arb results
    input  logic [REQ_N-1:0]            req_vld_i,
    input  logic [REQ_N-1:0][DAT_W-1:0] req_dat_i,
    input  logic [REQ_N-1:0][WGT_W-1:0] req_wgt_i,
    output logic [REQ_N-1:0]            req_rdy_o,
    output logic                        grt_vld_o,
    output logic [DAT_W-1:0]            grt_dat_o,
    input  logic                        grt_rdy_i
);
localparam CMP_W = TYPE==1 ? 1       :
                   TYPE==2 ? 1+WGT_W :
                   WGT_W;
localparam REQ_NW = $clog2(REQ_N);
logic [REQ_NW-1:0]           cmp_out_id,grant_id,grant_id_sv;
logic                        grt_hsk,out_hsk;
logic [REQ_N-1:0]            rr_flg;
logic [REQ_N-1:0][CMP_W-1:0] arb_cmp_value;
logic [DAT_W-1:0]            cmp_dat_o;
for (genvar i = 0; i < REQ_N; i=i+1) begin:COUNTER
    if(TYPE>0) begin:ROUND
        `ALWAYS_CLK(clk, rst_n)
            if (!rst_n) begin
                rr_flg[i] <=  'h0;
            end else if (grt_hsk) begin
                rr_flg[i] <=  ((REQ_NW)'(i) > cmp_out_id);
            end
         if(TYPE==1) begin:ROBIN
             assign arb_cmp_value[i] = rr_flg[i];
         end else begin:WEIGHT
             assign arb_cmp_value[i] = {req_wgt_i[i],rr_flg[i]};
         end:WEIGHT
    end else begin:FIXED
        assign arb_cmp_value[i] = {req_wgt_i[i]};
    end:FIXED
    assign req_rdy_o[i] = grt_rdy_i && (grant_id == (REQ_NW)'(i));
end:COUNTER

/*StlCmp AUTO_TEMPLATE (
)*/
StlCmp #(/*AUTOINSTPARAM*/
         // Parameters
         .TYPE                          ("MAX"),
         .CMP_N                         (REQ_N),
         .CMP_DW                        (CMP_W),
         .DAT_DW                        (DAT_W),
         .CMP_NW                        (REQ_NW))
    u_StlCmp (/*AUTOINST*/
              // Outputs
              .idx_o                    (cmp_out_id),
              .cmp_o                    (          ),
              .dat_o                    (cmp_dat_o),
              // Inputs
              .clk                      (clk),
              .rst_n                    (rst_n),
              .vld_i                    (req_vld_i),
              .cmp_i                    (arb_cmp_value),
              .dat_i                    (req_dat_i));


if (KEEP_EN) begin:KEEP
    `ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        grant_id_sv <=  'h0;
    end else if (out_hsk) begin
        grant_id_sv <=  grant_id;
    end
    assign grant_id  = arb_keep ? grant_id_sv : cmp_out_id;
    assign grt_vld_o = req_vld_i[grant_id]; 
    assign out_hsk   = grt_vld_o && grt_rdy_i;
    assign grt_hsk   = out_hsk && !arb_keep;
    assign grt_dat_o = cmp_dat_o;
end:KEEP
else begin:NOKEEP
    assign grant_id  = cmp_out_id;
    assign grt_vld_o = |req_vld_i; 
    assign grt_hsk   = grt_vld_o && grt_rdy_i; 
    assign grt_dat_o = cmp_dat_o;
end:NOKEEP
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


