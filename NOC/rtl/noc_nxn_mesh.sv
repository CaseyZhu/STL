// ---------------------------------------------------------------------
//
// FILE NAME    : noc_nxn_mesh.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-04     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module noc_nxn_mesh #(
//add parameters there
parameter MSH_W = 4, //need >1
parameter MSH_H = 4, //need >1
parameter NODE_N= MSH_W*MSH_H
)(
//input output begin
input    clk,
input    rst_n,

axi4_stream_if.Slave    noc_req_i[NODE_N-1:0],
axi4_stream_if.Master   noc_req_o[NODE_N-1:0]
);
localparam DIM_N = 5; //rounter scrossbar size
localparam DX_W  = 2;
localparam DY_W  = 2;
axi4_stream_if #(
  .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
  .TID_W   ( $bits(noc_req_i[0].tid      )  ),
  .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
  .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
) noc_req_pipe_i[NODE_N*DIM_N-1:0](); //vcs not support multi-dimension module inst [NODE_N-1:0][DIM_N-1:0]

axi4_stream_if #(
  .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
  .TID_W   ( $bits(noc_req_i[0].tid      )  ),
  .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
  .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
) noc_req_pipe_o[NODE_N*DIM_N-1:0]();//[NODE_N-1:0][DIM_N-1:0]
for (genvar i = 0; i < MSH_H; i=i+1) begin:REQW
    for (genvar j = 0; j < MSH_W; j=j+1) begin:REQH
        //P:0, E:1, W:2, N:3, S:4
        localparam NDP= i*MSH_W + j;
        localparam NDE= i*MSH_W +j+1;
        localparam NDW= i*MSH_W +j-1;
        localparam NDN= (i-1)*MSH_W +j;
        localparam NDS= (i+1)*MSH_W +j;
        localparam DE = 1;
        localparam DW = 2;
        localparam DN = 3;
        localparam DS = 4;
        
        //current i,o
        axi4_stream_if #(
        .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
        .TID_W   ( $bits(noc_req_i[0].tid      )  ),
        .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
        .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
        ) noc_creq_i[DIM_N-1:0]();
        
        axi4_stream_if #(
        .TDATA_W ( $bits(noc_req_i[0].tdata    )  ),
        .TID_W   ( $bits(noc_req_i[0].tid      )  ),
        .TDEST_W ( $bits(noc_req_i[0].tdest    )  ),
        .TUSER_W ( $bits(noc_req_i[0].tuser    )  )
        ) noc_creq_o[DIM_N-1:0]();
        //use pipe as the link
        //P input/output
        axi4_stream_pipe #(
        .FWD_EN ( 1 ),
        .BWD_EN ( 1 )
        )u_inpipe_inst_pi(
        .clk      (clk                   ),
        .rst_n    (rst_n                 ),
        .axi_if_i (noc_req_i[NDP]        ),
        .axi_if_o (noc_req_pipe_i[NDP*DIM_N+0])
         );
        axi4_stream_pipe #(
        .FWD_EN ( 1 ),
        .BWD_EN ( 1 )
        )u_inpipe_inst_po(
        .clk      (clk                   ),
        .rst_n    (rst_n                 ),
        .axi_if_i (noc_req_pipe_o[NDP*DIM_N+0]),
        .axi_if_o (noc_req_o[NDP]        )
         );
        if(j==0) begin:NOWEST
            assign noc_req_pipe_i[NDP*DIM_N+DW].tvalid = '0;
            assign noc_req_pipe_o[NDP*DIM_N+DW].tready = '0;
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_e(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDE*DIM_N+DW]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DE])
             );
        end else if(j==MSH_W-1) begin:NOEAST
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_w(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDW*DIM_N+DE]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DW])
             );
            assign noc_req_pipe_i[NDP*DIM_N+DE].tvalid = '0;
            assign noc_req_pipe_o[NDP*DIM_N+DE].tready = '0;
        end else begin:CNORMAL
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_w(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDW*DIM_N+DE]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DW])
             );
           axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_e(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDE*DIM_N+DW]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DE])
             );

        end

        if(i==0) begin:NONORTH
            assign noc_req_pipe_i[NDP*DIM_N+DN].tvalid = '0;
            assign noc_req_pipe_o[NDP*DIM_N+DN].tready = '0;
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_s(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDS*DIM_N+DN]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DS])
             );
        end else if(i==MSH_H-1) begin:NOSOUTH
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_n(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDN*DIM_N+DS]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DN])
             );
            assign noc_req_pipe_i[NDP*DIM_N+DS].tvalid = '0;
            assign noc_req_pipe_o[NDP*DIM_N+DS].tready = '0;
        end else begin:RNORMAL
            axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_s(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDS*DIM_N+DN]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DS])
             );
             axi4_stream_pipe #(
            .FWD_EN ( 1 ),
            .BWD_EN ( 1 )
            )u_inpipe_inst_n(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_o[NDN*DIM_N+DS]),
            .axi_if_o (noc_req_pipe_i[NDP*DIM_N+DN])
             );
        end
        noc_rounter #(
        . DIM_N ( DIM_N),
        . DX_W  ( DX_W ),
        . DY_W  ( DY_W ),
        . CUR_X ( j    ),
        . CUR_Y ( i    )
        )u_noc_rounter(
        . clk         (clk       ),
        . rst_n       (rst_n     ),
        . noc_req_i   (noc_creq_i),
        . noc_req_o   (noc_creq_o)
        );
        //connect io
        for (genvar i = 0; i < DIM_N; i=i+1) begin:IOCONNECT
            localparam POSIO = NDP * DIM_N + i;
            axi4_stream_pipe #(
            .FWD_EN ( 0 ),
            .BWD_EN ( 0 )
            )u_inpipe_inst_i(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_req_pipe_i[POSIO] ),
            .axi_if_o (noc_creq_i[i]         )
            );
             axi4_stream_pipe #(
            .FWD_EN ( 0 ),
            .BWD_EN ( 0 )
            )u_inpipe_inst_o(
            .clk      (clk                   ),
            .rst_n    (rst_n                 ),
            .axi_if_i (noc_creq_o[i]         ),
            .axi_if_o (noc_req_pipe_o[POSIO] )
            );
        end:IOCONNECT
    end:REQH
end:REQW

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


