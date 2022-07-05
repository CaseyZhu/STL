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

module noc_nxn #(
//add parameters there
parameter MSH_W = 4, //need >1
parameter MSH_H = 4, //need >1
parameter NODE_N= MSH_W*MSH_H
)(
//input output begin
input    clk,
input    rst_n,

axi4_stream_if.Slave    noc_req_i[NODE_N-1:0],
axi4_stream_if.Master   noc_rsp_o[NODE_N-1:0],

axi4_stream_if.Slave    noc_rsp_i[NODE_N-1:0],
axi4_stream_if.Master   noc_req_o[NODE_N-1:0]
);

noc_nxn_mesh #(
. MSH_W (MSH_W ),
. MSH_H (MSH_H ),
. NODE_N(NODE_N)
)u_noc_nxn_mesh_req(
 .clk      (clk      ),
 .rst_n    (rst_n    ),
 .noc_req_i(noc_req_i),
 .noc_req_o(noc_req_o)
);

noc_nxn_mesh #(
. MSH_W (MSH_W ),
. MSH_H (MSH_H ),
. NODE_N(NODE_N)
)u_noc_nxn_mesh_rsp(
 .clk      (clk      ),
 .rst_n    (rst_n    ),
 .noc_req_i(noc_rsp_i),
 .noc_req_o(noc_rsp_o)
);
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


