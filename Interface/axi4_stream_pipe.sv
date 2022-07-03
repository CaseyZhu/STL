// ---------------------------------------------------------------------
//
// FILE NAME    : axi4_stream_pipe.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-07-03     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

module axi4_stream_pipe #(
//add parameters there
parameter FWD_EN = 1,
parameter BWD_EN = 1
)(
//input output begin
input                      clk,
input                      rst_n,
axi4_stream_if.Slave       axi_if_i ,           
axi4_stream_if.Master      axi_if_o
);

localparam T_TTW =  $bits(axi_if_i.tdata    ) +      
                    $bits(axi_if_i.tstrb    ) +      
                    $bits(axi_if_i.tkeep    ) +      
                    $bits(axi_if_i.tlast    ) +      
                    $bits(axi_if_i.tid      ) +      
                    $bits(axi_if_i.tdest    ) +      
                    $bits(axi_if_i.tuser    );

//=============================================================================
//Stream:tvalid/tid/tuser
logic[T_TTW-1:0] t_winf  ,t_rinf   ;
     StlPipe#(
       .DATA_W   (T_TTW ),
       .BWD_EN   (BWD_EN),
       .FWD_EN   (FWD_EN)
     ) u_StlPipe(
       .clk    (clk             ) ,
       .rst_n  (rst_n           ) ,
       .upvld_i(axi_if_i.tvalid ) ,
       .uprdy_o(axi_if_i.tready ) ,
       .updat_i(t_winf          ) ,
       .dnvld_o(axi_if_o.tvalid ) ,
       .dnrdy_i(axi_if_o.tready ) ,
       .dndat_o(t_rinf          )
     ); 

always_comb begin
   t_winf  = { axi_if_i.tdata,
               axi_if_i.tstrb,
               axi_if_i.tkeep,
               axi_if_i.tlast,
               axi_if_i.tid  ,
               axi_if_i.tdest,
               axi_if_i.tuser
              }; 

             {
               axi_if_o.tdata,
               axi_if_o.tstrb,
               axi_if_o.tkeep,
               axi_if_o.tlast,
               axi_if_o.tid  ,
               axi_if_o.tdest,
               axi_if_o.tuser
              } = t_rinf ;

end
endmodule
// Local Variables:
// verilog-library-directories:("." "*/" )
// verilog-auto-output-ignore-regexp: "^\\(gb_.*\\)$"
// verilog-auto-inst-param-value:t
// End:


