package TestModule;


import Vector :: *;

interface Sort_IFC#(numeric type n_t);
   method Action put(Int #(32) x);
   method ActionValue #(Int #(32)) get;
endinterface


module mkBubblesort(Sort_IFC#(n_t));


Integer n= valueOf (n_t);
Integer jMax =n-1;

Reg #(Int #(16)) rg_inj<- mkReg(0);


Vector #(n_t, Reg #(Int #(32))) xs <- replicateM (mkReg (maxBound));

//Generate n-1 rules (concurrent) to swap xs[i] and xs[i+1] if unordered
for (Integer i=0;i<n-1;i=i+1)
	rule r1_swap_i (xs[i]>xs[i+1]);
	xs[i]<=xs[i+1];
	xs[i+1]<=xs[i];
	endrule

function Bool done();
Bool b=(rg_inj==fromInteger(n));
for (Integer i = 0; i < n-1; i = i+1)
b = b && (xs[i] <= xs[i+1]);
return b;
endfunction

method Action put (Int #(32) x) if ((rg_inj < fromInteger(n)) && xs[jMax] == maxBound);
      xs[jMax] <= x;
      rg_inj <= rg_inj + 1;
   endmethod

   // Outputs: drain by shifting them out of x0
   method ActionValue#(Int #(32)) get () if (done);
      writeVReg (xs, shiftInAtN (readVReg (xs), maxBound));
      if (xs[1] == maxBound) rg_inj <= 0;
      return xs[0];
endmethod

endmodule


//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

import LFSR :: *;
typedef 20 N_t;

Int #(32) n = fromInteger (valueOf (N_t));
//////////////////////////////////////////////////////////////
(*synthesize*)
module mkBubblesort_nt (Sort_IFC #(N_t));
   Sort_IFC #(N_t) m <- mkBubblesort;
   return m;
endmodule

//////////////////////////////////////////////////////////////

(* synthesize *)
module mkTop();
      Reg #(Int#(32)) rg_j1 <- mkReg (0);
   Reg #(Int#(32)) rg_j2 <- mkReg (0);

   // Instantiate an 8-bit random number generator from BSV lib
   LFSR #(Bit #(8)) lfsr <- mkLFSR_8;

   // Instantiate the parallel sorter
   Sort_IFC #(N_t) sorter <- mkBubblesort_nt;

   rule rl_feed_inputs (rg_j1 < n);
      Bit#(32) v = zeroExtend (lfsr.value ());
      lfsr.next ();
      Int#(32) x = unpack (v);
      sorter.put (x);
      rg_j1 <= rg_j1 + 1;
      $display (" x_%0d = %0d", rg_j1, x);
   endrule

   rule rl_drain_outputs (rg_j2 < n);
      let y <- sorter.get ();
      rg_j2 <= rg_j2 + 1;
      $display ("                                    y_%0d = %0d",  rg_j2, y);
      if (rg_j2 == n-1) $finish;
endrule
endmodule



endpackage
