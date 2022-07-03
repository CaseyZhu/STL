// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class dma_base_vseq extends dv_base_vseq #(
    .CFG_T               (dma_env_cfg),
    .COV_T               (dma_env_cov),
    .VIRTUAL_SEQUENCER_T (dma_virtual_sequencer)
  );
  `uvm_object_utils(dma_base_vseq)

  // various knobs to enable certain routines
  bit do_dma_init = 1'b1;

  `uvm_object_new

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init();
    if (do_dma_init) dma_init();
  endtask

  virtual task dut_shutdown();
    // check for pending dma operations and wait for them to complete
    // TODO
  endtask

  // setup basic dma features
  virtual task dma_init();
    `uvm_error(`gfn, "FIXME")
  endtask

endclass : dma_base_vseq
