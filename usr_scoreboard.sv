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

