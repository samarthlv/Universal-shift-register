class usr_monitor extends uvm_component;
  `uvm_component_utils(usr_monitor)

  virtual usr_if vif;
  uvm_analysis_port #(usr_seq_item) ap;
  int mon_count;

  function new(string name = "usr_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
    mon_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual usr_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("USR_MON", "virtual interface not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    usr_seq_item tx;

    forever begin
      @(posedge vif.clk);
      #1;
      tx = usr_seq_item::type_id::create("tx");
      tx.clr      = vif.clr;
      tx.sel      = vif.sel;
      tx.shift_en = vif.shift_en;
      tx.data_in  = vif.data_in;
      tx.out      = vif.out;
      mon_count++;
      `uvm_info("USR_MON",
        $sformatf("The data collected from monitor is\n%s", tx.sprint()),
        UVM_LOW)
      ap.write(tx);
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("USR_MON",
      $sformatf("USR MONITOR: The number of transactions collected in monitor are : %0d",
      mon_count), UVM_LOW)
  endfunction
endclass
 
 