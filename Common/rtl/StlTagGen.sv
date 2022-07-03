// ---------------------------------------------------------------------
//
// FILE NAME    : TagGen.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-04-11     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlTagGen #(
//add parameters there
parameter TAG_W = 6
)(
input                    clk,
input                    rst_n,
input   logic            hsk_i,
output  logic            tag_rdy,
output  logic[TAG_W-1:0] tag,

input   logic[TAG_W-1:0] rls_tag,
input   logic            rls_en
);

localparam WTAG_DP = 2**TAG_W;
//table id  
logic                                                         space_add,space_dec,d_done,n_wtag_ready;
logic [TAG_W:0]                                               buf_space_cnt,n_buf_space_cnt;
always_comb begin
   space_add       = rls_en;
   space_dec       = hsk_i; 
   n_buf_space_cnt = (TAG_W+1)'(buf_space_cnt + space_add - space_dec);
   n_wtag_ready    = |n_buf_space_cnt;
end

`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
       buf_space_cnt  <=  (TAG_W+1)'(WTAG_DP);
    end else if (space_add || space_dec) begin
       buf_space_cnt  <=  n_buf_space_cnt;
    end
`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        tag_rdy <=  'h1;
    end else if (space_add || space_dec) begin
        tag_rdy <=  n_wtag_ready;
    end

logic [WTAG_DP-1:0]  b_vld,b_vld_rls,b_vld_cmp;
logic [TAG_W-1:0]    n_o_wtag,tag_add1,n_vld_wtag;
logic                o_wtag_vld;
logic                tag_alloc_hsk;

//assign b_vld_rls = rls_en ? {(WTAG_DP-1)'(0),1'b1} << rls_tag : '0;
assign b_vld_cmp =  b_vld;

StlCmp #(
     .TYPE   ("FSTL"          ), //first valid from left
     .CMP_N  ( WTAG_DP        ),
     .CMP_DW ( 1              ),  //use compare
     .DAT_DW ( 1              ),  //selectout the inf
     .CMP_NW ( TAG_W          )
 )u_StlCmp(
     .clk   (clk              ),
     .rst_n (rst_n            ),
     .vld_i (b_vld_cmp        ),
     .cmp_i ({WTAG_DP{1'b0}}  ),
     .dat_i ({WTAG_DP{1'b0}}  ),
     .idx_o (n_vld_wtag       ),
     .cmp_o (                 ),
     .dat_o (                 )
);

always_comb begin
    n_o_wtag =  b_vld[tag_add1] ? tag_add1 :
               (|b_vld)        ? n_vld_wtag :
                rls_tag;
end

for (genvar i = 0; i < WTAG_DP; i=i+1) begin:WTAG_ID 
    `ALWAYS_CLK(clk, rst_n)
        if (!rst_n) begin
            b_vld[i] <=  'h1;
        end else if (tag_alloc_hsk && (n_o_wtag == (TAG_W)'(i))) begin
            b_vld[i]  <=  'h0;
        end else if ( rls_en && (rls_tag == (TAG_W)'(i)) ) begin
            b_vld[i] <=  'h1;
        end 
     
end:WTAG_ID
assign tag_alloc_hsk = (~o_wtag_vld || o_wtag_vld&&hsk_i)&&n_wtag_ready;
`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
       o_wtag_vld  <=  'h0;
    end else if (tag_alloc_hsk) begin
       o_wtag_vld  <=  'h1;
    end else if (hsk_i) begin
       o_wtag_vld  <=  'h0;
    end
`ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        tag      <=  'h0;
        tag_add1 <=  'h0;
    end else if (tag_alloc_hsk) begin
        tag      <=  n_o_wtag;
        tag_add1 <=  n_o_wtag + 'h1;
    end

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


