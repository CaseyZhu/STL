// ---------------------------------------------------------------------
//
// FILE NAME    : StlMatrixArbiter.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-27     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlMatrixArbiter #(
    parameter REQ_N   = 8,
    parameter DAT_W   = 16,
    parameter KEEP_EN = 0
) (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        arb_keep, //keep using previous arb results
    input  logic [REQ_N-1:0]            req_vld_i,
    input  logic [REQ_N-1:0][DAT_W-1:0] req_dat_i,
    output logic [REQ_N-1:0]            req_rdy_o,
    output logic                        grt_vld_o,
    output logic [DAT_W-1:0]            grt_dat_o,
    input  logic                        grt_rdy_i
);
  logic [        REQ_N-1:0][REQ_N-1:0] arb_matrix;
  logic [$clog2(REQ_N)-1:0]            grant_id;
  logic                                grt_hsk,out_hsk;
  logic[REQ_N-1:0]                     grant_onehot,grant_keep;
  for (genvar i = 0; i < REQ_N; ++i) begin : MATRIX_ROW
        for (genvar j=0; j<REQ_N; ++j) begin:MATRIX_CLO
           if(i==j) begin   
                assign arb_matrix[i][j] = 1'b0;
           end else if(i<j) begin
                `ALWAYS_CLK(clk, rst_n)
                    if(!rst_n) begin
                         arb_matrix[i][j] <= 1'b1; 
                    end else if(grt_hsk ) begin
                         arb_matrix[i][j] <= (grant_id==($clog2(REQ_N))'(i)) ? 1'b1 : 
                                             (grant_id==($clog2(REQ_N))'(j)) ? 1'b0 :
                                             arb_matrix[i][j];
                    end
           end else begin
                assign arb_matrix[i][j] = ~arb_matrix[j][i];
           end
        end:MATRIX_CLO
  end : MATRIX_ROW

  for (genvar i=0; i<REQ_N; ++i) begin:ARBAND
    if(KEEP_EN) begin
        assign grant_onehot[i] = arb_keep ? grant_keep[i] : 
                                ((req_vld_i & arb_matrix[i]) == '0) && req_vld_i[i];
    end else begin
        assign grant_onehot[i] = ((req_vld_i & arb_matrix[i]) == '0) && req_vld_i[i];
    end
    assign req_rdy_o[i]    = grant_onehot[i] & grt_rdy_i;
  end:ARBAND
  StlOneHot2Bin #(
    //add parameters there
    .OHTW (REQ_N),
    .BINW ($clog2(REQ_N))
    )i_StlOneHot2Bin(
    .clk     (clk    ),
    .rst_n   (rst_n  ),
    .onehot_i(grant_onehot),
    .bin_o   (grant_id)
    );
  if (KEEP_EN) begin
      `ALWAYS_CLK(clk, rst_n)
          if (!rst_n) begin
              grant_keep <=  'h0;
          end else if (out_hsk) begin
              grant_keep <=  req_rdy_o;
          end
      assign out_hsk   = grt_vld_o && grt_rdy_i;
      assign grt_vld_o = req_vld_i[grant_id]; 
      assign grt_hsk   = out_hsk && !arb_keep;
  end else begin
      assign grt_vld_o = |req_vld_i; 
      assign grt_hsk   = grt_vld_o && grt_rdy_i;
  end 
  assign grt_dat_o = req_dat_i[grant_id];
  
  
endmodule


