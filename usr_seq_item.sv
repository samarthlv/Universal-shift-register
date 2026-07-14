class usr_seq_item extends uvm_sequence_item;
  rand bit       clr;
  rand bit [1:0] sel;
  rand bit       shift_en;
  rand bit [3:0] data_in;
       logic [3:0] out;

  `uvm_object_utils_begin(usr_seq_item)
    `uvm_field_int(clr, UVM_DEFAULT)
    `uvm_field_int(sel, UVM_DEFAULT)
    `uvm_field_int(shift_en, UVM_DEFAULT)
    `uvm_field_int(data_in, UVM_DEFAULT)
    `uvm_field_int(out, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "usr_seq_item");
    super.new(name);
  endfunction
endclass
