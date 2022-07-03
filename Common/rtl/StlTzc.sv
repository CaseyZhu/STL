// ---------------------------------------------------------------------
//
// FILE NAME    : Tzc.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2021-06-21     zhuzhiqi   initial coding
// look up first 1 or trailing zeros count use binary tree
// ---------------------------------------------------------------------

module StlTzc #(
parameter   DW = 8,
parameter   CW = 3
)(
//input output begin
input  logic  [DW-1:0] data_i,
output logic  [CW  :0] pos_from1,
output logic  [CW-1:0] pos_from0 
);
localparam DW_P = 2**($clog2(DW));
logic[DW_P-1:0]                 data_i_p;
logic[DW_P-2:0]                 node_sel;
logic[DW_P-2:0][CW-1:0]         node_index;
logic[DW_P-2:0][CW  :0]         mask_index;
always_comb begin
    data_i_p          = '1;
    data_i_p[DW-1:0]  = data_i;
end
for (genvar l = 0; l < CW; l=l+1) begin:LEVEL
    if(l==CW-1) begin :LAST_LEVEL
        for (genvar i = 0; i < 2**l; i=i+1) begin:NODE_SEL
          assign node_sel[2**l-1+i]   =  data_i_p[2*i] |
                                         data_i_p[2*i + 1];
          assign node_index[2**l-1+i] =  data_i_p[2*i] ?
                                         (CW)'(2*i) : 
                                         (CW)'(2*i + 1);
          assign mask_index[2**l-1+i] =  data_i_p[2*i] ?
                                         (CW+1)'(2*i + 1) : 
                                         (CW+1)'(2*i + 2); 
        end:NODE_SEL
    end else begin:OTHER_LEVEL
        for (genvar i = 0; i < 2**l; i=i+1) begin:NODE_SEL
          assign node_sel[2**l-1+i]   =  node_sel[2**(l+1)-1+2*i] |
                                         node_sel[2**(l+1)-1+2*i + 1];
          assign node_index[2**l-1+i] =  node_sel[2**(l+1)-1+2*i] ?
                                         node_index[2**(l+1)-1+2*i] :
                                         node_index[2**(l+1)-1+2*i + 1];
          assign mask_index[2**l-1+i] =  node_sel[2**(l+1)-1+2*i] ?
                                         mask_index[2**(l+1)-1+2*i] :
                                         mask_index[2**(l+1)-1+2*i + 1];
        end:NODE_SEL
    end
end:LEVEL
//assign o_count[CW:0]   = node_sel[0] ? (CW+1)'(node_index[0]) : (CW+1)'(1<<CW);
assign pos_from0 = node_index[0] ;
assign pos_from1 = node_sel[0] ? mask_index[0] : '0;
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


