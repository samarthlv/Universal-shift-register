class usr_driver extends uvm_driver #(usr_seq_item);
  `uvm_component_utils(usr_driver)

  virtual usr_if vif;
  int sent_count;

  function new(string name = "usr_driver", uvm_component parent = null);
    super.new(name, parent);
    sent_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual usr_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("USR_DRV", "virtual interface not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    usr_seq_item req;

    vif.clr      <= 1'b0;
    vif.sel      <= 2'b00;
    vif.shift_en <= 1'b0;
    vif.data_in  <= 4'b0000;

    forever begin
      seq_item_port.get_next_item(req);
      @(negedge vif.clk);
      vif.clr      <= req.clr;
      vif.sel      <= req.sel;
      vif.shift_en <= req.shift_en;
      vif.data_in  <= req.data_in;
      sent_count++;
      `uvm_info("USR_DRV",
        $sformatf("The transaction sent to DUT is\n%s", req.sprint()),
        UVM_LOW)
      seq_item_port.item_done();
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("USR_DRV",
      $sformatf("USR DRIVER: The number of transactions sent from driver are : %0d",
      sent_count), UVM_LOW)
  endfunction
endclass
