// ---------------------------------------------------------------------
//
// FILE NAME    : StlSort.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlSort #(
//add parameters there
parameter   DN   = 16,
parameter   CW   = 4,  //compare data width
parameter   DW   = 8,  //data selectout with the compare data
parameter   MODE = 0,  //0: down 1:up
localparam  NW   = $clog2(DN) 
)(
input logic                    clk,
input logic                    rst_n,
//input output begin
input  logic  [DN-1:0][DW-1:0] datsel_i, //atouch data
input  logic  [DN-1:0][CW-1:0] datcmp_i, //unsort data
output logic  [DN-1:0][DW-1:0] datsel_o,
output logic  [DN-1:0][CW-1:0] datcmp_o  //sorted data
);
//padding to 2**N
localparam PDN = 2**(NW==0 ? 1 : NW);

logic  [PDN-1:0][DW-1:0] pdatsel_i; //atouch data
logic  [PDN-1:0][CW-1:0] pdatcmp_i; //unsort data
logic  [PDN-1:0][DW-1:0] pdatsel_o;
logic  [PDN-1:0][CW-1:0] pdatcmp_o;

for (genvar i = 0; i < DN; i=i+1) begin:DATA_ASSIGN
    always_comb begin
        pdatsel_i[i] = datsel_i[i]; //atouch data
        pdatcmp_i[i] = datcmp_i[i]; //unsort data
        datsel_o[i]  = pdatsel_o[i];
        datcmp_o[i]  = pdatcmp_o[i];
    end
    
end:DATA_ASSIGN

for (genvar i = DN; i < PDN; i=i+1) begin:TIE0
    always_comb begin
        pdatsel_i[i] = '0; //atouch data
        pdatcmp_i[i] = '0; //unsort data
    end
end:TIE0

if(NW <= 1) begin:SORT2
    StlSwap #(
    . CW   ( CW   ),  //compare data width
    . DW   ( DW   ),  //data selectout with the compare data
    . MODE ( MODE )
    )i_StlSwap2(
    . datsel_i(pdatsel_i), //atouch data
    . datcmp_i(pdatcmp_i), //unsort data
    . datsel_o(pdatsel_o),
    . datcmp_o(pdatcmp_o) 
    ); 
end:SORT2
else begin:SORT_SPLIT
   //split into to sorted group
    logic  [PDN-1:0][DW-1:0] sdatsel_o;
    logic  [PDN-1:0][CW-1:0] sdatcmp_o;
    for (genvar i = 0; i < 2; i=i+1) begin:RECUR
        localparam MODES = (i + MODE) % 2;
        StlSort #(
        .DN   ( PDN/2       ),
        .CW   ( CW          ),  //compare data width
        .DW   ( DW          ),  //data selectout with the compare data
        .MODE ( MODES       ) 
        )i_StlSort(
        .clk     (clk     ),
        .rst_n   (rst_n   ),
                          
        .datsel_i(pdatsel_i[i*PDN/2+:PDN/2]), //atouch data
        .datcmp_i(pdatcmp_i[i*PDN/2+:PDN/2]), //unsort data
        .datsel_o(sdatsel_o[i*PDN/2+:PDN/2]),
        .datcmp_o(sdatcmp_o[i*PDN/2+:PDN/2])  //sorted data
        );
    end:RECUR
    logic  [NW:0][PDN-1:0][DW-1:0] cdatsel_o;
    logic  [NW:0][PDN-1:0][CW-1:0] cdatcmp_o;
    always_comb begin
        cdatsel_o[0] = sdatsel_o;
        cdatcmp_o[0] = sdatcmp_o;
    end 
    for (genvar i = 0; i < NW; i=i+1) begin:BISORT
        for (genvar j = 0; j < PDN/2; j=j+1) begin:SWAP
            localparam STEP = NW-1 - i;
            localparam IDX0 = j%(2**STEP) + (j/(2**STEP))*(2**(STEP+1));
            localparam IDX1 = IDX0 + 2**STEP;
            logic[1:0][CW-1:0] swap_datcmp_i,swap_datcmp_o;
            logic[1:0][DW-1:0] swap_datsel_i,swap_datsel_o;
            always_comb begin
                swap_datcmp_i = {cdatcmp_o[i][IDX1],cdatcmp_o[i][IDX0]};
                swap_datsel_i = {cdatsel_o[i][IDX1],cdatsel_o[i][IDX0]};
                {cdatcmp_o[i+1][IDX1],cdatcmp_o[i+1][IDX0]} = swap_datcmp_o;
                {cdatsel_o[i+1][IDX1],cdatsel_o[i+1][IDX0]} = swap_datsel_o;
            end
            
             StlSwap #(
            . CW   ( CW   ),  //compare data width
            . DW   ( DW   ),  //data selectout with the compare data
            . MODE ( MODE )
            )i_StlSwapS(
            . datsel_i(swap_datsel_i), //atouch data
            . datcmp_i(swap_datcmp_i), //unsort data
            . datsel_o(swap_datsel_o),
            . datcmp_o(swap_datcmp_o) 
            );
        end:SWAP
    end:BISORT
    always_comb begin
        pdatsel_o = cdatsel_o[NW];
        pdatcmp_o = cdatcmp_o[NW];
    end
    
end:SORT_SPLIT

///////////////////////////////////////////////////////
// assertions
///////////////////////////////////////////////////////

// covered off
// pragma coverage block = off, expr = off, fsm = off, toggle = off
// synopsys translate_off
// synthesis translate_off
// pragma translate_off

for (genvar i = 0; i < DN-1; i=i+1) begin:ASERTION
   SORT_CHECK: assert property (
    @(posedge clk) disable iff (!rst_n)
     MODE ? (pdatcmp_o[i+1] >= pdatcmp_o[i]) : (pdatcmp_o[i+1] <= pdatcmp_o[i])
    ) else $fatal("%m: Sort results is not right.");   
end
               
// pragma translate_on
// synthesis translate_on
// synopsys translate_on
// pragma coverage block = on, expr = on, fsm = on, toggle = on
// covered on
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


