package TestModule;

interface Sort_IFC;
	method Action put(Int #(32)x);
	method ActionValue #(Int #(32)) get;
endinterface

(* synthesize *)
module mkBubblesort(Sort_IFC);
	Reg #(Bit #(3)) rg_pc<- mkReg(0);
	Reg #(UInt #(3)) rg_j<- mkReg(0);
	Reg #(Bool) re_swapped<-mkRegU;
//Registers to hold the values to be sorted
//They are uninitialised
	Reg #(Int #(32)) x0 <- mkRegU;
	Reg #(Int #(32)) x1 <- mkRegU;
	Reg #(Int #(32)) x2 <- mkRegU;
	Reg #(Int #(32)) x3 <- mkRegU;
	Reg #(Int #(32)) x4 <- mkRegU;
//Rules

rule r1_swap_0_1(rg_pc==1);
	if(x0>x1)begin
		x0<=x1; rg_swapped<=True;
	end
	rg_pc<=2;
endrule

rule rl_swap_1_2 (rg_pc == 2);
      if (x1 > x2) begin
	 x1 <= x2; x2 <= x1; rg_swapped <= True;
      end
      rg_pc <= 3;
   endrule

rule rl_swap_2_3 (rg_pc == 3);
      if (x2 > x3) begin
	 x2 <= x3; x3 <= x2; rg_swapped <= True;
      end
      rg_pc <= 4;
endrule

rule rl_swap_3_4 (rg_pc == 4);
      if (x3 > x4) begin
	 x3 <= x4; x4 <= x3; rg_swapped <= True;
      end
      rg_pc <= 5;
endrule

function Action shift(Int #(32) y);
	action
	x0<=x1; x1<=x2; x2<= x3; x3 <= x4; x4 <= y;
	endaction
endfunction

method Action put(Int#(32) x) if(rg_pc==0);
shift(x);
rg_j<=rg_j+1;
if (rg_j==4) begin
	rg_pc<=1;
	rg_swapped<=False;
end
endmethod

method ActionValue#(Int#(32)) get() if ((rg_j!=0)&&(rg_pc==6));
	shift(?);
	rg_j<=rg_j-1;
	if(rg_j==1)
	rg_pc<=0;
	return x0;
endmethod
endmodule

Int#(32) n = 5;

// ================================================================
// Testbench module

(* synthesize *)
module mkTop (Empty);
   Reg #(Int#(32)) rg_j1 <- mkReg (0);
   Reg #(Int#(32)) rg_j2 <- mkReg (0);

   // Instantiate an 8-bit random number generator from BSV lib
   LFSR #(Bit #(8)) lfsr <- mkLFSR_8;

   // Instantiate the parallel sorter
   Sort_IFC sorter <- mkBubblesort;

   rule rl_feed_inputs (rg_j1 < n);
      Bit#(32) v = zeroExtend (lfsr.value ());
      lfsr.next ();
      Int#(32) x = unpack (v);
      sorter.put (x);
      rg_j1 <= rg_j1 + 1;
      $display ("%0d: x_%0d = %0d", cur_cycle, rg_j1, x);
   endrule

   rule rl_drain_outputs (rg_j2 < n);
      let y <- sorter.get ();
      rg_j2 <= rg_j2 + 1;
      $display ("                                %0d: y_%0d = %0d", cur_cycle, rg_j2, y);
      if (rg_j2 == n-1) $finish;
   endrule
endmodule

