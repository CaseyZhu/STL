// ---------------------------------------------------------------------
//
// FILE NAME    : StlOneHot2Bin.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-27     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlOneHot2Bin #(
//add parameters there
parameter OHTW = 16,
parameter BINW = 4
)(
input   clk,
input   rst_n,
input   logic[OHTW-1:0] onehot_i,
output  logic[BINW-1:0] bin_o
);
for (genvar i = 0; i < BINW; i=i+1) begin:BINBIT
    logic [OHTW/2-1:0] binpos;
    localparam SPOS = 1 << i;
    localparam STEP = 1 << (i+1);
    for (genvar j = 0; j < OHTW/STEP; j=j+1) begin:ACTIVEPOS
        assign binpos[j*SPOS+:SPOS] = onehot_i[(j*STEP+SPOS)+:SPOS];
    end:ACTIVEPOS
    assign bin_o[i] = |binpos;
end:BINBIT
///////////////////////////////////////////////////////
// assertions
///////////////////////////////////////////////////////

// covered off
// pragma coverage block = off, expr = off, fsm = off, toggle = off
// synopsys translate_off
// synthesis translate_off
// pragma translate_off

    CHECK: assert property (
    @(posedge clk) disable iff (!rst_n)
        (|onehot_i) |-> (onehot_i == (1<<bin_o) ) 
    ) else $fatal("%m: Sort results is not right.");   

               
// pragma translate_on
// synthesis translate_on
// synopsys translate_on
// pragma coverage block = on, expr = on, fsm = on, toggle = on
// covered on
endmodule



