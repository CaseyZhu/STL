// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package dma_env_pkg;
  // dep packages
  import uvm_pkg::*;
  import top_pkg::*;
  import dv_utils_pkg::*;
  import dv_lib_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters

  // types
  typedef dv_base_reg_block dma_reg_block;

  // functions

  // package sources
  `include "dma_env_cfg.sv"
  `include "dma_env_cov.sv"
  `include "dma_virtual_sequencer.sv"
  `include "dma_scoreboard.sv"
  `include "dma_env.sv"
  `include "dma_vseq_list.sv"

endpackage
