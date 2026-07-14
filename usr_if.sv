interface usr_if;
  logic       clk;
  logic       clr;
  logic [1:0] sel;
  logic       shift_en;
  logic [3:0] data_in;
  logic [3:0] out;

  clocking drv_cb @(posedge clk);
    output clr;
    output sel;
    output shift_en;
    output data_in;
    input  out;
  endclocking

  clocking mon_cb @(posedge clk);
    input clr;
    input sel;
    input shift_en;
    input data_in;
    input out;
  endclocking

  modport DRV (clocking drv_cb, input clk);
  modport MON (clocking mon_cb, input clk);
  modport DUT (input clk, clr, sel, shift_en, data_in, output out);
endinterface
