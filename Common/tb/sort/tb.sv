// ---------------------------------------------------------------------
//
// FILE NAME    : tb.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`timescale 1ns/100ps
module tb ;

logic clk, rst_n;
logic [15:0][7:0]  datcmp_i;
logic [15:0][15:0] datsel_i;
logic [15:0][7:0]  datcmp_o;
logic [15:0][15:0] datsel_o;

initial begin
    clk = 0;rst_n=0;
    #10;
    rst_n = 1;
    #1000;
    $finish();
end
always #0.5 clk = ~clk;
for (genvar i = 0; i < 16; i=i+1) begin
   always_ff@(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
            datcmp_i[i] <=  'h0;
            datsel_i[i] <=  'h0;
       end else  begin
            datcmp_i[i] <=  {$random}%(2**8);//'h0;
            datsel_i[i] <=  i;//'h0;
       end
   end
end

/*StlSort AUTO_TEMPLATE (
)*/
StlSort #(/*AUTOINSTPARAM*/
          // Parameters
          .DN                           (16),
          .CW                           (8),
          .DW                           (16),
          .MODE                         (1))
    u_StlSort (/*AUTOINST*/
               // Outputs
               .datsel_o                (datsel_o/*[DN-1:0][DW-1:0]*/),
               .datcmp_o                (datcmp_o/*[DN-1:0][DW-1:0]*/),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .datsel_i                (datsel_i/*[DN-1:0][DW-1:0]*/),
               .datcmp_i                (datcmp_i/*[DN-1:0][CW-1:0]*/));

endmodule
// Local Variables:
// verilog-library-directories:("." "*/" "../../rtl")
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


