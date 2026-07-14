class usr_coverage extends uvm_component;
  `uvm_component_utils(usr_coverage)

  uvm_analysis_imp #(usr_seq_item, usr_coverage) analysis_export;

  bit       clr;
  bit [1:0] sel;
  bit       shift_en;
  bit [3:0] data_in;

  covergroup usr_cg;
    coverpoint clr;
    coverpoint sel {
      bins sel_00 = {2'b00};
      bins sel_01 = {2'b01};
      bins sel_10 = {2'b10};
      bins sel_11 = {2'b11};
    }
    coverpoint shift_en;
    coverpoint data_in {
      bins zero     = {4'b0000};
      bins ones     = {4'b1111};
      bins alt_a    = {4'b1010};
      bins alt_5    = {4'b0101};
      bins low_vals[]  = {[4'b0001:4'b0100]};
      bins mid_vals[]  = {[4'b0110:4'b1001]};
      bins high_vals[] = {[4'b1011:4'b1110]};
    }
    cross sel, shift_en;
    cross clr, sel, shift_en;
  endgroup

  function new(string name = "usr_coverage", uvm_component parent = null);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
    usr_cg = new();
  endfunction

  function void write(usr_seq_item tx);
    clr      = tx.clr;
    sel      = tx.sel;
    shift_en = tx.shift_en;
    data_in  = tx.data_in;
    usr_cg.sample();
  endfunction
endclass
