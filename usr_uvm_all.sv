`timescale 1ns/1ps

interface usr_if;
  logic       clk;
  logic       clr;
  logic [1:0] sel;
  logic       shift_en;
  logic [3:0] data_in;
  logic [3:0] out;
endinterface

package usr_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

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

  class usr_sequence extends uvm_sequence #(usr_seq_item);
    `uvm_object_utils(usr_sequence)

    function new(string name = "usr_sequence");
      super.new(name);
    endfunction

    task body();
      usr_seq_item req;

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b1;
      req.sel      = 2'b00;
      req.shift_en = 1'b0;
      req.data_in  = 4'b0000;
      finish_item(req);

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b0;
      req.sel      = 2'b00;
      req.shift_en = 1'b0;
      req.data_in  = 4'b1010;
      finish_item(req);

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b0;
      req.sel      = 2'b00;
      req.shift_en = 1'b1;
      req.data_in  = 4'b1100;
      finish_item(req);

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b0;
      req.sel      = 2'b01;
      req.shift_en = 1'b1;
      req.data_in  = 4'b0111;
      finish_item(req);

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b0;
      req.sel      = 2'b10;
      req.shift_en = 1'b1;
      req.data_in  = 4'b1001;
      finish_item(req);

      req = usr_seq_item::type_id::create("req");
      start_item(req);
      req.clr      = 1'b0;
      req.sel      = 2'b11;
      req.shift_en = 1'b0;
      req.data_in  = 4'b1111;
      finish_item(req);

      repeat (20) begin
        req = usr_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize()) begin
          `uvm_error("USR_SEQ", "Randomization failed")
        end
        finish_item(req);
      end
    endtask
  endclass

  class usr_sequencer extends uvm_sequencer #(usr_seq_item);
    `uvm_component_utils(usr_sequencer)

    function new(string name = "usr_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass

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

  class usr_scoreboard extends uvm_component;
    `uvm_component_utils(usr_scoreboard)

    uvm_analysis_imp #(usr_seq_item, usr_scoreboard) analysis_export;
    logic [3:0] exp_out;
    bit         started;
    int         cmp_count;

    function new(string name = "usr_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      analysis_export = new("analysis_export", this);
      exp_out = 4'bxxxx;
      started = 1'b0;
      cmp_count = 0;
    endfunction

    function logic [3:0] predict_next_out(logic [3:0] prev_out, usr_seq_item tx);
      logic [3:0] next_out;
      begin
        if (tx.clr) begin
          next_out = 4'b0000;
        end
        else begin
          case (tx.sel)
            2'b00: begin
              if (tx.shift_en) begin
                next_out[0] = prev_out[1];
                next_out[1] = prev_out[2];
                next_out[2] = prev_out[3];
                next_out[3] = 1'b0;
              end
              else begin
                next_out = tx.data_in;
              end
            end

            2'b01: begin
              if (tx.shift_en) begin
                next_out[0] = prev_out[1];
                next_out[1] = prev_out[2];
                next_out[2] = prev_out[3];
                next_out[3] = tx.data_in[3];
              end
              else begin
                next_out = tx.data_in;
              end
            end

            2'b10: begin
              if (tx.shift_en) begin
                next_out[3] = prev_out[2];
                next_out[2] = prev_out[1];
                next_out[1] = prev_out[0];
                next_out[0] = tx.data_in[0];
              end
              else begin
                next_out = tx.data_in;
              end
            end

            default: begin
              if (tx.shift_en) begin
                next_out = tx.data_in;
              end
              else begin
                next_out = 4'bxxxx;
              end
            end
          endcase
        end

        return next_out;
      end
    endfunction

    function void write(usr_seq_item tx);
      logic [3:0] next_exp_out;

      if (!started) begin
        exp_out  = tx.out;
        started  = 1'b1;
        `uvm_info("USR_SCB", "Scoreboard started", UVM_LOW)
        return;
      end

      next_exp_out = predict_next_out(tx.out, tx);
      cmp_count++;

      `uvm_info("USR_SCB",
        $sformatf("Scoreboard packet:\n%sExpected out = %0h\nActual out   = %0h\nNext exp out = %0h",
        tx.sprint(), exp_out, tx.out, next_exp_out),
        UVM_LOW)

      if (tx.out !== exp_out) begin
        `uvm_error("USR_SCB",
          $sformatf("Mismatch: clr=%0b sel=%0b shift_en=%0b data_in=%0h exp_out=%0h act_out=%0h",
          tx.clr, tx.sel, tx.shift_en, tx.data_in, exp_out, tx.out))
      end
      else begin
        `uvm_info("USR_SCB",
          $sformatf("Match: clr=%0b sel=%0b shift_en=%0b data_in=%0h out=%0h",
          tx.clr, tx.sel, tx.shift_en, tx.data_in, tx.out), UVM_LOW)
      end

      exp_out = next_exp_out;
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("USR_SCB",
        $sformatf("USR SCOREBOARD: The number of compared transactions in scoreboard are : %0d",
        cmp_count), UVM_LOW)
    endfunction
  endclass

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
        bins zero      = {4'b0000};
        bins ones      = {4'b1111};
        bins alt_a     = {4'b1010};
        bins alt_5     = {4'b0101};
        bins low_vals  = {[4'b0001:4'b0100]};
        bins mid_vals  = {[4'b0110:4'b1001]};
        bins high_vals = {[4'b1011:4'b1110]};
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

  class usr_agent extends uvm_agent;
    `uvm_component_utils(usr_agent)

    usr_sequencer sequencer;
    usr_driver    driver;
    usr_monitor   monitor;

    function new(string name = "usr_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = usr_sequencer::type_id::create("sequencer", this);
      driver    = usr_driver   ::type_id::create("driver", this);
      monitor   = usr_monitor  ::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
  endclass

  class usr_env extends uvm_env;
    `uvm_component_utils(usr_env)

    usr_agent      agent;
    usr_scoreboard scoreboard;
    usr_coverage   coverage;

    function new(string name = "usr_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent      = usr_agent     ::type_id::create("agent", this);
      scoreboard = usr_scoreboard::type_id::create("scoreboard", this);
      coverage   = usr_coverage  ::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agent.monitor.ap.connect(scoreboard.analysis_export);
      agent.monitor.ap.connect(coverage.analysis_export);
    endfunction
  endclass

  class usr_test extends uvm_test;
    `uvm_component_utils(usr_test)

    usr_env      env;
    usr_sequence seq;

    function new(string name = "usr_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = usr_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq = usr_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      repeat (3) @(posedge env.agent.driver.vif.clk);
      phase.drop_objection(this);
    endtask
  endclass
endpackage

import uvm_pkg::*;
import usr_pkg::*;

module tb_top;
  usr_if usr_vif();

  usr dut (
    .clr      (usr_vif.clr),
    .clk      (usr_vif.clk),
    .sel      (usr_vif.sel),
    .shift_en (usr_vif.shift_en),
    .data_in  (usr_vif.data_in),
    .out      (usr_vif.out)
  );

  initial begin
    usr_vif.clk = 1'b0;
    forever #5 usr_vif.clk = ~usr_vif.clk;
  end

  initial begin
    uvm_config_db#(virtual usr_if)::set(null, "*", "vif", usr_vif);
    run_test("usr_test");
  end
endmodule
