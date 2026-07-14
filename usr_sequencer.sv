class usr_sequencer extends uvm_sequencer #(usr_seq_item);
  `uvm_component_utils(usr_sequencer)

  function new(string name = "usr_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
