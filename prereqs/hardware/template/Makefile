V_PATHS=/media/anmol/shakti-tools/Bluespec-2018.10.beta1/lib/Verilog/
all:
	bsc -verilog TestModule.bsv
	verilator -Wall -Wno-PINCONNECTEMPTY -Wno-WIDTH -Wno-STMTDLY -Wno-UNUSED -Wno-BLKSEQ --cc sim_main.cpp --exe mkTop.v -I${V_PATHS}
	make -C obj_dir -f VmkTop.mk VmkTop
	@printf "\n\n"
	./obj_dir/VmkTop
