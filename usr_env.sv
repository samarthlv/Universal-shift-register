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
