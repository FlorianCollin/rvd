VHDL_FILES = constants_pkg.vhd \
decoblock.vhd \
fsm.vhd inst_register.vhd pc_plus_4.vhd mux4_1.vhd \
control_unit.vhd \
mem_ram_xilinx.vhd mux_boot_loader.vhd data_to_bootloader.vhd \
mem_unit.vhd \
alu.vhd register_file.vhd imm_gen.vhd mux2_1.vhd adder.vhd data_to_processing.vhd \
subsystem.vhd cos_cordic_nw.vhd sin_cordic_nw.vhd \
initial_rotation.vhd cordic_stage_0.vhd cordic_stage_1.vhd cordic_stage_2.vhd cordic_stage_3.vhd cordic_stage_4.vhd cordic_stage_5.vhd cordic_stage_6.vhd cordic_stage_7.vhd \
my_cordic_rotati.vhd init_system.vhd \
pre_cordic.vhd top_level.vhd select_resultat.vhd \
cordic_final.vhd \
processing_unit.vhd \
cpu_riscv.vhd \
tb_cpu_riscv.vhd




EXECUTABLE = tb_cpu_riscv

WORKDIR = work

GHDL_FLAGS = --std=08 --workdir=$(WORKDIR)

SIM_COMMAND = ghdl -r $(GHDL_FLAGS) $(EXECUTABLE) --vcd=tb.vcd --stop-time=1000ns

all: compile elaborate simulate

compile:
	@echo "Compiling VHDL files..."
	@for file in $(VHDL_FILES); do \
	    echo "Compiling $$file..."; \
	    ghdl -a $(GHDL_FLAGS) $$file; \
	done

elaborate: compile
	@echo "Elaborating top-level design..."
	@ghdl -e $(GHDL_FLAGS) $(EXECUTABLE)

simulate: elaborate
	@echo "Running simulation..."
	@$(SIM_COMMAND)

wave:
	@echo "Displaying simulation waveform..."
	@gtkwave tb.vcd

clean:
	@echo "Cleaning up..."
	@rm -f ./work/* 

.PHONY: all compile elaborate simulate wave clean
