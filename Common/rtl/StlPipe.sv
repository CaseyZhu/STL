// ---------------------------------------------------------------------
//
// FILE NAME    : Pipe.v
// AUTHOR       : zhuzhiqi
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-04-18     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`include  "StlDefine.sv"
module StlPipe #(
//add parameters there
parameter DATA_W = 10,
parameter FWD_EN = 1,  //valid && data regout
parameter BWD_EN = 1   //ready regout
)(
input                      clk,
input                      rst_n,
input  logic               upvld_i,
output logic               uprdy_o,
input  logic [DATA_W-1:0]  updat_i,

output logic               dnvld_o,
input logic                dnrdy_i,
output logic [DATA_W-1:0]  dndat_o
);
logic               fwd_upvld_i;
logic               fwd_uprdy_o;
logic [DATA_W-1:0]  fwd_updat_i,updat_sv_i;
logic               sv_vld_i,sv_i_en,sv_i_set;
if(BWD_EN) begin:PP_BWD_EN
    `ALWAYS_CLK(clk, rst_n)
        if (!rst_n) begin
            uprdy_o <=  'h1;
        end else if (sv_i_en) begin
            uprdy_o <=  'h0;
        end else if (sv_i_set) begin
            uprdy_o <=  'h1;
        end
     always@(posedge clk) begin
         if(sv_i_en) updat_sv_i <= updat_i;
     end
     assign sv_vld_i  = ~uprdy_o;
     assign sv_i_en   = upvld_i    && ~fwd_uprdy_o && uprdy_o;
     assign sv_i_set  = sv_vld_i &&  fwd_uprdy_o;
     assign fwd_upvld_i = sv_vld_i || upvld_i;
     assign fwd_updat_i= sv_vld_i ? updat_sv_i : updat_i;
end:PP_BWD_EN
else begin:PP_BWD_NEN
     assign fwd_upvld_i = upvld_i;
     assign fwd_updat_i = updat_i;
     assign uprdy_o     = fwd_uprdy_o;
end:PP_BWD_NEN
//forward
if(FWD_EN) begin:PP_FWD_EN
   assign fwd_uprdy_o = ~dnvld_o || dnrdy_i; 
   `ALWAYS_CLK(clk, rst_n)
       if (!rst_n) begin
          dnvld_o  <=  'h0;
       end else if (fwd_uprdy_o) begin
          dnvld_o  <=  fwd_upvld_i;
       end 
   always@(posedge clk) begin
       if(fwd_uprdy_o && fwd_upvld_i) dndat_o <= fwd_updat_i;
   end
end:PP_FWD_EN
else  begin:PP_FWD_NEN
    assign fwd_uprdy_o = dnrdy_i;
    assign dnvld_o     = fwd_upvld_i;
    assign dndat_o    = fwd_updat_i;
end:PP_FWD_NEN
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


