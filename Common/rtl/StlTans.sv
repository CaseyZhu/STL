// ---------------------------------------------------------------------
//
// FILE NAME    : StlTans.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module StlTans #(
//add parameters there
parameter WX = 4,
parameter WY = 5
)(
input  logic [WX-1:0][WY-1:0] data_i,
output logic [WY-1:0][WX-1:0] data_o
);
for (genvar i = 0; i < WX; i=i+1) begin
    for (genvar j = 0; j < WY; j=j+1) begin
        assign data_o[j][i] = data_i[i][j];
    end
end


endmodule



