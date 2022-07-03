// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class dma_virtual_sequencer extends dv_base_virtual_sequencer #(
    .CFG_T(dma_env_cfg),
    .COV_T(dma_env_cov)
  );
  `uvm_component_utils(dma_virtual_sequencer)


  `uvm_component_new

endclass
