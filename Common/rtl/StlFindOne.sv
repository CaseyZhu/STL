// ---------------------------------------------------------------------
//
// FILE NAME    : StlFindOne.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-29     zhuzhiqi   initial coding
// find first one the specified postion in left/right, 
// ---------------------------------------------------------------------

module StlFindOne #(
//add parameters there
parameter REQ_N  = 16,
parameter DATA_W = 32, 
parameter TYPE   = 0  //0, left, 1 right
)(
//input output begin
input                                clk,
input                                rst_n,
input  logic[REQ_N-1:0]              req_i,
input  logic[REQ_N-1:0][DATA_W-1:0]  req_data_i,
input  logic[$clog2(REQ_N)-1:0]      start_pos_i,

output logic[$clog2(REQ_N)-1:0]      fone_pos_o,
output logic[DATA_W-1:0]             data_sel_o

);
localparam CMPTYPE = TYPE == 0 ? "FRSTL" : "FRSTR";
logic[REQ_N-1:0]                    req_rotate;
logic[REQ_N-1:0][DATA_W-1:0]        req_data_rotate;
logic[$clog2(REQ_N)-1:0]            pos_from_zero;

StlRshift #(
.DIM_N (REQ_N           ),
.DAT_W (DATA_W          ),
.SHT_W ($clog2(REQ_N)   ),
.MODE  (1               ) //0 left rotate shift, 1 right rotate shift 
)i_dat_rshift(
.data_i (req_data_i     ),
.shft   (start_pos_i    ),
.data_o (req_data_rotate)
);
StlRshift #(
.DIM_N (REQ_N           ),
.DAT_W (1               ),
.SHT_W ($clog2(REQ_N)   ),
.MODE  (1               ) //0 left rotate shift, 1 right rotate shift 
)i_req_rshift(
.data_i (req_i          ),
.shft   (start_pos_i    ),
.data_o (req_rotate     )
);

StlCmp #(/*AUTOINSTPARAM*/
         // Parameters
         .TYPE                          (CMPTYPE       ),
         .CMP_N                         (REQ_N         ),
         .CMP_DW                        (1             ),
         .DAT_DW                        (DATA_W        ),
         .CMP_NW                        ($clog2(REQ_N)))
    u_StlCmp (/*AUTOINST*/
              // Outputs
              .idx_o                    (pos_from_zero   ),
              .cmp_o                    (                ),
              .dat_o                    (data_sel_o      ),
              // Inputs
              .clk                      (clk             ),
              .rst_n                    (rst_n           ),
              .vld_i                    (req_rotate      ),
              .cmp_i                    ('0              ),
              .dat_i                    (req_data_rotate));
assign fone_pos_o = ($clog2(REQ_N))'(pos_from_zero + start_pos_i);
endmodule



