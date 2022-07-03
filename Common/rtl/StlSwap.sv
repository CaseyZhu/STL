// ---------------------------------------------------------------------
//
// FILE NAME    : StlSwap.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlSwap #(
//add parameters there
parameter   CW   = 4,  //compare data width
parameter   DW   = 8,  //data selectout with the compare data
parameter   MODE = 0
)(
input  logic  [1:0][DW-1:0] datsel_i, //atouch data
input  logic  [1:0][CW-1:0] datcmp_i, //unsort data
output logic  [1:0][DW-1:0] datsel_o,
output logic  [1:0][CW-1:0] datcmp_o
);

    logic sel_right;
    if(MODE) begin:UP
        assign sel_right = datcmp_i[0] > datcmp_i[1];
    end else begin:DN
        assign sel_right = datcmp_i[0] < datcmp_i[1];
    end
    always_comb begin
        datsel_o[0] = sel_right ? datsel_i[1] : datsel_i[0];
        datsel_o[1] = sel_right ? datsel_i[0] : datsel_i[1];
        datcmp_o[0] = sel_right ? datcmp_i[1] : datcmp_i[0];
        datcmp_o[1] = sel_right ? datcmp_i[0] : datcmp_i[1];
    end

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


