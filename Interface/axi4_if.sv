// ---------------------------------------------------------------------
//
// FILE NAME    : axi4_if.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// r_elease history
// 0.1  2022-06-28     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------

interface axi4_if#(
  parameter int DATA_W   = 32,
  parameter int ADDR_W   = 16,
  parameter int ID_W     = 1,
  parameter int AWUSER_W = 1,
  parameter int WUSER_W  = 1,
  parameter int BUSER_W  = 1,
  parameter int ARUSER_W = 1,
  parameter int RUSER_W  = 1
);

logic [ID_W - 1 : 0]       aw_id;
logic [ADDR_W - 1 : 0]     aw_addr;
logic [7 : 0]              aw_len;
logic [2 : 0]              aw_size;
logic [1 : 0]              aw_burst;
logic                      aw_lock;
logic [3 : 0]              aw_cache;
logic [2 : 0]              aw_prot;
logic [3 : 0]              aw_qos;
logic [3 : 0]              aw_region;
logic [AWUSER_W - 1 : 0]   aw_user;
logic                      aw_valid;
logic                      aw_ready;

logic [DATA_W - 1 : 0]     w_data;
logic [DATA_W / 8 - 1 : 0] w_strb;
logic                      w_last;
logic [WUSER_W - 1 : 0]    w_user;
logic                      w_valid;
logic                      w_ready;

logic [ID_W - 1 : 0]       b_id;
logic [1 : 0]              b_resp;
logic [BUSER_W - 1 : 0]    b_user;
logic                      b_valid;
logic                      b_ready;

logic [ID_W - 1 : 0]       ar_id;
logic [ADDR_W - 1 : 0]     ar_addr;
logic [7 : 0]              ar_len;
logic [2 : 0]              ar_size;
logic [1 : 0]              ar_burst;
logic                      ar_lock;
logic [3 : 0]              ar_cache;
logic [2 : 0]              ar_prot;
logic [3 : 0]              ar_qos;
logic [3 : 0]              ar_region;
logic [ARUSER_W - 1 : 0]   ar_user;
logic                      ar_valid;
logic                      ar_ready;

logic [ID_W - 1 : 0]       r_id;
logic [DATA_W - 1 : 0]     r_data;
logic [1 : 0]              r_resp;
logic                      r_last;
logic [RUSER_W - 1 : 0]    r_user;
logic                      r_valid;
logic                      r_ready;

modport Master(
  output aw_id,
  output aw_addr,
  output aw_len,
  output aw_size,
  output aw_burst,
  output aw_lock,
  output aw_cache,
  output aw_prot,
  output aw_qos,
  output aw_region,
  output aw_user,
  output aw_valid,
  input  aw_ready,
  output w_data,
  output w_strb,
  output w_last,
  output w_user,
  output w_valid,
  input  w_ready,
  input  b_id,
  input  b_resp,
  input  b_user,
  input  b_valid,
  output b_ready,
  output ar_id,
  output ar_addr,
  output ar_len,
  output ar_size,
  output ar_burst,
  output ar_lock,
  output ar_cache,
  output ar_prot,
  output ar_qos,
  output ar_region,
  output ar_user,
  output ar_valid,
  input  ar_ready,
  input  r_id,
  input  r_data,
  input  r_resp,
  input  r_last,
  input  r_user,
  input  r_valid,
  output r_ready
);

modport Slave(
  input  aw_id,
  input  aw_addr,
  input  aw_len,
  input  aw_size,
  input  aw_burst,
  input  aw_lock,
  input  aw_cache,
  input  aw_prot,
  input  aw_qos,
  input  aw_region,
  input  aw_user,
  input  aw_valid,
  output aw_ready,
  input  w_data,
  input  w_strb,
  input  w_last,
  input  w_user,
  input  w_valid,
  output w_ready,
  output b_id,
  output b_resp,
  output b_user,
  output b_valid,
  input  b_ready,
  input  ar_id,
  input  ar_addr,
  input  ar_len,
  input  ar_size,
  input  ar_burst,
  input  ar_lock,
  input  ar_cache,
  input  ar_prot,
  input  ar_qos,
  input  ar_region,
  input  ar_user,
  input  ar_valid,
  output ar_ready,
  output r_id,
  output r_data,
  output r_resp,
  output r_last,
  output r_user,
  output r_valid,
  input  r_ready
);


endinterface
