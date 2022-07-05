//module function: same id with diferent tag need keep order
module keep_id_order #(
    parameter ID_W    = 8,
    parameter OUST_N  = 5,   //same id outstanding
    parameter TAG_W   = 10
) (
   input  logic             clk,               
   input  logic             rst_n,             
   input  logic             req_hsk_i,             
   input  logic [ ID_W-1:0] req_id_i,          
   input  logic [TAG_W-1:0] req_tag_i,         
   output logic             id_send_en_o,     
   input  logic             rls_hsk_i,             
   input  logic [ ID_W-1:0] rls_id_i          
    
);
logic[2**ID_W-1:0][OUST_N-1:0] id_send_flag;
logic[2**ID_W-1:0][TAG_W-1:0]  tag_sv_buf;
for (genvar i = 0; i<2**ID_W; i++) begin:IDRECORD
    logic flag_add,flag_dec;
    assign flag_add = req_hsk_i && (req_id_i == (ID_W)'(i));
    assign flag_dec = rls_hsk_i && (rls_id_i == (ID_W)'(i));
    always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
            id_send_flag[i] <= '0;
       end if(flag_add || flag_dec) begin
            id_send_flag[i] <= id_send_flag[i] + (ID_W)'(flag_add) + (ID_W)'(flag_dec);
       end
    end
    always_ff @(clk ) begin 
        if(flag_add) tag_sv_buf[i] <= req_tag_i;
    end  
end:IDRECORD

assign id_send_en_o = (|id_send_flag[req_id_i]) && 
                      (req_tag_i != tag_sv_buf[req_id_i]) &&
                      !(&id_send_flag[req_id_i]) 
                      ||
                      !(|id_send_flag[req_id_i]);

endmodule
