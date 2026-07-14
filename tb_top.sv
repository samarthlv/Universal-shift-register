`timescale 1ns/1ps

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



