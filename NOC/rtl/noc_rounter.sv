// ---------------------------------------------------------------------
//
// FILE NAME    : noc_rounter.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
// 5x5 rounter, use X-Y rounting algorithm to avoid deadlock, no virtual channel
// use axi stream interface, x,y coordinate in user bits
//   tid;   response interface return same id with request.
//   tdest; dest address
//   tuser; dest x,y coordinate, and write enable
// ---------------------------------------------------------------------

module noc_rounter #(
//add parameters there
parameter DIM_N = 5,
parameter DX_W  = 2,
parameter DY_W  = 2,
parameter CUR_X = 0,
parameter CUR_Y = 0
)(
//input output begin
input                   clk,
input                   rst_n,
axi4_stream_if.Slave    noc_req_i[DIM_N-1:0],
axi4_stream_if.Master   noc_req_o[DIM_N-1:0]
);
localparam IF_TBW = $bits(noc_req_i[0].tdata    ) +
                    $bits(noc_req_i[0].tstrb    ) +
                    $bits(noc_req_i[0].tkeep    ) +
                    $bits(noc_req_i[0].tlast    ) +
                    $bits(noc_req_i[0].tid      ) +
                    $bits(noc_req_i[0].tdest    ) +
                    $bits(noc_req_i[0].tuser    );
axi4_stream_if #(
  .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
  .TID_W   ( $bits(noc_req_i[0].tid      )  ),
  .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
  .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
) noc_req_pipe_i[DIM_N-1:0]();

axi4_stream_if #(
  .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
  .TID_W   ( $bits(noc_req_i[0].tid      )  ),
  .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
  .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
) noc_req_pipe_o[DIM_N-1:0]();

logic[DIM_N-1:0][$clog2(DIM_N)-1:0] port_swb; //Rout compute: which port to go
logic[DIM_N-1:0][IF_TBW-1:0]        swc_info_i;
logic[DIM_N-1:0][IF_TBW-1:0]        swc_info_o;
logic[DIM_N-1:0]                    swc_mreq_i,swc_mrdy_o;
logic[DIM_N-1:0]                    swc_sreq_o,swc_srdy_i;
for (genvar i = 0; i < DIM_N; i=i+1) begin:INPIPE
    axi4_stream_pipe #(
    .FWD_EN ( 1 ),
    .BWD_EN ( 1 )
    )u_inpipe_inst(
    .clk      (clk               ),
    .rst_n    (rst_n             ),
    .axi_if_i (noc_req_i[i]      ),
    .axi_if_o (noc_req_pipe_i[i] )
     );
    assign swc_info_i[i] = {
                          noc_req_pipe_i[i].tdata,
                          noc_req_pipe_i[i].tstrb,
                          noc_req_pipe_i[i].tkeep,
                          noc_req_pipe_i[i].tlast,
                          noc_req_pipe_i[i].tid  ,
                          noc_req_pipe_i[i].tdest,
                          noc_req_pipe_i[i].tuser
                         };
    logic[DX_W-1:0] if_x;
    logic[DY_W-1:0] if_y;
    logic           cx_equal;
    logic           cy_equal;
    logic           cx_w;
    logic           cy_n;
    assign {if_y,if_x} = noc_req_pipe_i[i].tuser[DY_W+DX_W-1:0];
    //P:0, E:1, W:2, N:3, S:4
    assign cx_equal = if_x == (DX_W)'(CUR_X);
    assign cy_equal = if_y == (DY_W)'(CUR_Y);
    assign cx_w     = if_x < (DX_W)'(CUR_X);
    assign cy_n     = if_y < (DY_W)'(CUR_Y);
    assign port_swb[i] = cx_equal && cy_equal ? ($clog2(DIM_N))'(0) :
                         cx_equal && cy_n     ? ($clog2(DIM_N))'(3) :
                         cx_equal && !cy_n    ? ($clog2(DIM_N))'(4) :
                         cx_w                 ? ($clog2(DIM_N))'(2) :
                         //!cx_w                ? ($clog2(DIM_N))'(1) :
                                                ($clog2(DIM_N))'(1) ;

    assign swc_mreq_i[i]            = noc_req_pipe_i[i].tvalid;
    assign noc_req_pipe_i[i].tready = swc_mrdy_o[i];

    assign noc_req_pipe_o[i].tvalid = swc_sreq_o[i];
    assign swc_srdy_i[i]            = noc_req_pipe_o[i].tready;

    assign   {
               noc_req_pipe_o[i].tdata,
               noc_req_pipe_o[i].tstrb,
               noc_req_pipe_o[i].tkeep,
               noc_req_pipe_o[i].tlast,
               noc_req_pipe_o[i].tid  ,
               noc_req_pipe_o[i].tdest,
               noc_req_pipe_o[i].tuser
              } = swc_info_o[i];

    axi4_stream_pipe #(
    .FWD_EN ( 1 ),
    .BWD_EN ( 1 )
    )u_outpipe_inst(
    .clk      (clk               ),
    .rst_n    (rst_n             ),
    .axi_if_i (noc_req_pipe_o[i] ),
    .axi_if_o (noc_req_o[i]      )
     );
end:INPIPE
//switch: 5x5 crossbar

SwMToN #(.IN_N                          (DIM_N ),
         .OUT_N                         (DIM_N ),
         .TAG_W                         (IF_TBW),
         .ARB_EN                        (1    ))
    u_SwMToN (/*AUTOINST*/
              // Outputs
              .uprdy_o                  (swc_mrdy_o),
              .dnreq_o                  (swc_sreq_o),
              .dntag_o                  (swc_info_o),
              // Inputs
              .clk                      (clk       ),
              .rst_n                    (rst_n     ),
              .upreq_i                  (swc_mreq_i),
              .up_swb_i                 (port_swb  ),
              .uptag_i                  (swc_info_i),
              .dnrdy_i                  (swc_srdy_i));
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


