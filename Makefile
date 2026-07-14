UVM_HOME = /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm-1.2
VCS      = vcs
SIMV     = ./simv
TOP      = tb_top
TEST     = usr_test

VCS_CMD = $(VCS) -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
	+incdir+$(UVM_HOME) \
	$(UVM_HOME)/uvm_pkg.sv \
	usr_if.sv usr_rtl.sv usr_pkg.sv tb_top.sv \
	-top $(TOP) -l compile.log

SIM_CMD = $(SIMV) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_LOW -l sim.log

.PHONY: all comp run clean

all: comp run

comp:
	$(VCS_CMD)

run:
	$(SIM_CMD) | tee sim.out

clean:
	rm -rf csrc simv simv.daidir ucli.key vc_hdrs.h DVEfiles *.log sim.out *.vpd *.key
