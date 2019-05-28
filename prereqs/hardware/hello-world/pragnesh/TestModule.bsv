package TestModule;

import Vector :: *;

interface Bubblesort_IFC #(numeric type n_t, type t);
method Action put (t x);
method ActionValue #(t) get;
endinterface

module mkBubblesort (Bubblesort_IFC #(n_t,t))

provisos (Bits #(t, wt), Ord #(t), Eq #(t), Bounded #(t));
Integer n = valueOf (n_t);
Integer jMax = n - 1;
Reg #(UInt #(16))  rg_inj <- mkReg (0);
Vector #(n_t, Reg #(t)) xs <- replicateM (mkReg (maxBound));

for (Integer i = 0; i < n-1; i = i+1)
rule sl_swap_i (xs[i] > xs [i+1]);
	xs [i] <= xs [i+1];
	xs [i+1] <= xs [i];
endrule

function Bool done ();
Bool b = (rg_inj == fromInteger (n));
for (Integer i = 0; i < n-1; i=i+1)
b = b && (xs[i] <= xs [i+1]);
return b;
endfunction

method Action put (t x) if ((rg_inj < fromInteger(n)) && xs[jMax] == maxBound);
xs[jMax] <= x;
rg_inj <= rg_inj + 1;
endmethod


method ActionValue #(t) get () if (done);
writeVReg (xs, shiftInAtN (readVReg (xs), maxBound));
if (xs[1] == maxBound) rg_inj <= 0;
return xs[0];
endmethod
endmodule

import LFSR :: *;

typedef 20 N_t;
typedef UInt #(24) MyT;

MyT n = fromInteger (valueOf(N_t));

(* synthesize *)
module mkBubblesort_nt_UInt20 (Bubblesort_IFC #(N_t, MyT));
Bubblesort_IFC #(N_t, MyT) m <- mkBubblesort;
return m;
endmodule

(* synthesize *)
module mkTop (Empty);

Reg #(MyT) rg_j1 <- mkReg(0);
Reg #(MyT)rg_j2 <- mkReg(0);

LFSR #(Bit#(8)) lfsr <- mkLFSR_8; 

Bubblesort_IFC #(N_t, MyT) sorter <- mkBubblesort_nt_UInt20;

rule rl_feed_inputs (rg_j1 < n);
lfsr.next();
MyT x = unpack (zeroExtend (lfsr.value()));
sorter.put(x);
rg_j1 <= rg_j1 + 1;
$display ("x_%0d = %0d", rg_j1, x);
endrule

rule rl_drain_outputs (rg_j2 < n);
let y <- sorter.get ();
rg_j2 <= rg_j2 + 1;
$display("                        y_%0d = %0d", rg_j2 ,y);
if (rg_j2 == n-1) $finish;
endrule
endmodule
endpackage


























