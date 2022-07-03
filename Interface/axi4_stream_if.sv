// ---------------------------------------------------------------------
//
// FILE NAME    : axi4_stream_if.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-28     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
interface axi4_stream_if #(
  parameter int TDATA_W = 32,
  parameter int TID_W   = 1,
  parameter int TDEST_W = 1,
  parameter int TUSER_W = 1
);

logic                           tvalid;
logic                           tready;
logic [TDATA_W - 1 : 0]         tdata;
logic [TDATA_W / 8 - 1 : 0]     tstrb;
logic [TDATA_W / 8 - 1 : 0]     tkeep;
logic                           tlast;
logic [TID_W - 1 : 0]           tid;
logic [TDEST_W - 1 : 0]         tdest;
logic [TUSER_W - 1 : 0]         tuser;

modport Master(
  output tvalid,
  input  tready,
  output tdata ,
  output tstrb,
  output tkeep,
  output tlast,
  output tid,
  output tdest,
  output tuser
);

modport Slave(
  input  tvalid,
  output tready,
  input  tdata,
  input  tstrb,
  input  tkeep,
  input  tlast,
  input  tid,
  input  tdest,
  input  tuser
);

endinterface

