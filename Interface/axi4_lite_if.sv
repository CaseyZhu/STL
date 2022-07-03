// ---------------------------------------------------------------------
//
// FILE NAME    : axi4_lite_if.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-28     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
interface axi4_lite_if #(
  parameter int ADDR_W = 16,
  parameter int DATA_W = 32
);

logic                          aw_valid;
logic                          aw_ready;
logic [ADDR_W - 1 : 0]         aw_addr;
logic [2 : 0]                  aw_prot;

logic                           w_valid;
logic                           w_ready;
logic [DATA_W - 1 : 0]          w_data;
logic [DATA_W / 8 - 1 : 0]      w_strb;

logic                           b_valid;
logic                           b_ready;
logic [1 : 0]                   b_resp;

logic                          ar_valid;
logic                          ar_ready;
logic [ADDR_W - 1 : 0]         ar_addr;
logic [2 : 0]                  ar_prot;

logic                           r_valid;
logic                           r_ready;
logic [DATA_W - 1 : 0]          r_data;
logic [1 : 0]                   r_resp;

modport Master(
  output aw_valid,
  input  aw_ready,
  output aw_addr,
  output aw_prot,
  output  w_valid,
  input   w_ready,
  output  w_data,
  output  w_strb,
  input   b_valid,
  output  b_ready,
  input   b_resp,
  output ar_valid,
  input  ar_ready,
  output ar_addr,
  output ar_prot,
  input   r_valid,
  output  r_ready,
  input   r_data,
  input   r_resp
);

modport Slave(
  input  aw_valid,
  output aw_ready,
  input  aw_addr,
  input  aw_prot,
  input   w_valid,
  output  w_ready,
  input   w_data,
  input   w_strb,
  output  b_valid,
  input   b_ready,
  output  b_resp,
  input  ar_valid,
  output ar_ready,
  input  ar_addr,
  input  ar_prot,
  output  r_valid,
  input   r_ready,
  output  r_data,
  output  r_resp
);

endinterface

