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
// reuests is the read write command
// response is the data or ack from the target
// ---------------------------------------------------------------------

module tb #(
//add parameters there
parameter MSH_W = 4, //need >1
parameter MSH_H = 4, //need >1
parameter NODE_N= MSH_W*MSH_H
);
logic clk,rst_n;
initial begin
  clk  =0;
  rst_n=0;
  #10;
  rst_n=1;
  #1000;
  $finish();
end
always #0.5 clk = ~clk;
axi4_stream_if #(
  .TDATA_W ( 32      ),
  .TID_W   ( 6       ),
  .TDEST_W ( 5       ),
  .TUSER_W ( 5       )
) noc_req_i[NODE_N-1:0]();

axi4_stream_if #(
  .TDATA_W ( 32  ),
  .TID_W   ( 6   ),
  .TDEST_W ( 5   ),
  .TUSER_W ( 5   )
) noc_req_o[NODE_N-1:0]();

axi4_stream_if #(
  .TDATA_W ( 32      ),
  .TID_W   ( 6       ),
  .TDEST_W ( 5       ),
  .TUSER_W ( 5       )
) noc_rsp_i[NODE_N-1:0]();

axi4_stream_if #(
  .TDATA_W ( 32  ),
  .TID_W   ( 6   ),
  .TDEST_W ( 5   ),
  .TUSER_W ( 5   )
) noc_rsp_o[NODE_N-1:0]();

noc_nxn #(
. MSH_W (MSH_W ),
. MSH_H (MSH_H ),
. NODE_N(NODE_N)
)u_noc_nxn(
 .clk      (clk      ),
 .rst_n    (rst_n    ),
 .noc_req_i(noc_req_i),
 .noc_req_o(noc_req_o),
 .noc_rsp_i(noc_rsp_i),
 .noc_rsp_o(noc_rsp_o)
);

for (genvar i = 0;i<NODE_N ; i++) begin:LOOPBACK
        //axi4_stream_pipe #(
        //.FWD_EN ( 1 ),
        //.BWD_EN ( 1 )
        //)u_inpipe_inst_loop(
        //.clk      (clk                   ),
        //.rst_n    (rst_n                 ),
        //.axi_if_i (noc_req_o[i]          ),
        //.axi_if_o (noc_rsp_i[i]          )
        // ); 
    always_comb begin
        noc_rsp_i[i].tvalid  = noc_req_o[i].tvalid;
        noc_req_o[i].tready  = noc_rsp_i[i].tready;
        noc_rsp_i[i].tdata   = noc_req_o[i].tdata ;
        noc_rsp_i[i].tstrb   = noc_req_o[i].tstrb ;
        noc_rsp_i[i].tkeep   = noc_req_o[i].tkeep ;
        noc_rsp_i[i].tlast   = noc_req_o[i].tlast ;
        noc_rsp_i[i].tid     = noc_req_o[i].tid   ;
        noc_rsp_i[i].tdest   = noc_req_o[i].tuser ;
        noc_rsp_i[i].tuser   = noc_req_o[i].tdest ;
    end
    
    assign noc_rsp_o[i].tready = 1'b1;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            noc_req_i[i].tvalid <= 1'b0;
            noc_req_i[i].tid    <= i;
            noc_req_i[i].tdest  <= 0;
            noc_req_i[i].tuser  <= 0;
            noc_req_i[i].tdata  <= 0;
            noc_req_i[i].tstrb  <= 0;
            noc_req_i[i].tkeep  <= 0;
            noc_req_i[i].tlast  <= 0;
        end else if (~noc_req_i[i].tvalid ) begin
            noc_req_i[i].tvalid <= 1 &&(noc_req_i[i].tdata < 32);//({$random}%2) && (i==0);
            noc_req_i[i].tdata  <= noc_req_i[i].tdata + 1;
            noc_req_i[i].tdest  <= noc_req_i[i].tdest + 1;
            noc_req_i[i].tuser  <= i;
        end else if (noc_req_i[i].tvalid && noc_req_i[i].tready) begin
            noc_req_i[i].tvalid <= 0;//({$random}%2) && (i==0);
        end
    end
end:LOOPBACK


endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


