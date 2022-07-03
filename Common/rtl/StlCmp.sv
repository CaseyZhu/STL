// ---------------------------------------------------------------------
//
// FILE NAME    : StlCmp.v
// AUTHOR       : zhuzhiqi
// EMAIL        : 929481945@qq.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-03-23     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlCmp #(
//add parameters there
parameter TYPE   = "MIN", //min/max/first left 1 pos/ first right 1 pos, invalid postion will ignore
parameter CMP_N  = 16,
parameter CMP_DW = 32,  //use compare when min/max
parameter DAT_DW = 32,  //selectout the inf
parameter CMP_NW = 4
)(
input    clk,
input    rst_n,
input  logic[CMP_N-1:0]              vld_i,
input  logic[CMP_N-1:0][CMP_DW-1:0]  cmp_i,
input  logic[CMP_N-1:0][DAT_DW-1:0]  dat_i,
output logic[CMP_NW-1:0]             idx_o,
output logic[CMP_DW-1:0]             cmp_o,
output logic[DAT_DW-1:0]             dat_o
);
localparam CMP_N_AL = 2**CMP_NW;
logic [CMP_N_AL*2-2:0]                          ena_i_sel;
logic [CMP_N_AL*2-2:0][CMP_DW-1:0]              cmp_i_sel;
logic [CMP_N_AL*2-2:0][DAT_DW-1:0]              dat_i_sel;
logic [CMP_N_AL*2-2:0][CMP_NW-1:0]              idx_i_sel;


for (genvar i = 0; i <= CMP_NW; i=i+1) begin:FIND_LEVEL
    if(i==CMP_NW ) begin:LAST_NODE
        for (genvar j = 0; j < 2**i; j=j+1) begin:NODE
            if(j < CMP_N) begin:INPUTASSIGN
                assign ena_i_sel[2**i-1 + j]    = vld_i[j];
                assign cmp_i_sel[2**i-1 + j]    = cmp_i[j];
                assign dat_i_sel[2**i-1 + j]    = dat_i[j];
                assign idx_i_sel[2**i-1 + j]    = (CMP_NW)'(j);
            end:INPUTASSIGN
            else begin:TIE0
                assign ena_i_sel[2**i-1 + j]    = '0;
                assign cmp_i_sel[2**i-1 + j]    = '0;
                assign dat_i_sel[2**i-1 + j]    = '0;
                assign idx_i_sel[2**i-1 + j]    = (CMP_NW)'(j);
            end:TIE0
        end:NODE 
    end:LAST_NODE
    else begin:CMP_NODE
        for (genvar j = 0; j < 2**i; j=j+1) begin:NODE
            logic  sel_right;
            assign ena_i_sel[2**i-1 + j]    =  ena_i_sel[(2**i-1 + j)*2+2] || ena_i_sel[(2**i-1 + j)*2 + 1];
            if(TYPE == "MIN") begin:MIN
                assign sel_right            = ~ena_i_sel[(2**i-1 + j)*2+1] || 
                                               (
                                                cmp_i_sel[(2**i-1 + j)*2 + 2] 
                                                <
                                                cmp_i_sel[(2**i-1 + j)*2+1]
                                               ) && ena_i_sel[(2**i-1 + j)*2+2];
            end:MIN
            else if(TYPE == "MAX") begin:MAX
                assign sel_right            = ~ena_i_sel[(2**i-1 + j)*2+1] || 
                                               (
                                                cmp_i_sel[(2**i-1 + j)*2 + 2] 
                                                >
                                                cmp_i_sel[(2**i-1 + j)*2+1]
                                               ) && ena_i_sel[(2**i-1 + j)*2+2];
            end:MAX
            else if(TYPE == "FSTL") begin:FIRSTL
                assign sel_right            = ~ena_i_sel[(2**i-1 + j)*2+1];
            end:FIRSTL
            else  begin:FIRSTR
                assign sel_right            =  ena_i_sel[(2**i-1 + j)*2+2]; 
            end:FIRSTR

            assign cmp_i_sel[2**i-1 + j]    =  sel_right ? cmp_i_sel[(2**i-1 + j)*2 + 2] : cmp_i_sel[(2**i-1 + j)*2+1];
            assign dat_i_sel[2**i-1 + j]    =  sel_right ? dat_i_sel[(2**i-1 + j)*2 + 2] : dat_i_sel[(2**i-1 + j)*2+1];
            assign idx_i_sel[2**i-1 + j]    =  sel_right ? idx_i_sel[(2**i-1 + j)*2 + 2] : idx_i_sel[(2**i-1 + j)*2+1];
        end:NODE    
    end:CMP_NODE
    
end:FIND_LEVEL

assign    idx_o = idx_i_sel[0];
assign    cmp_o = cmp_i_sel[0];
assign    dat_o = dat_i_sel[0];

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


