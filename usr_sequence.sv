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
