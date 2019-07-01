package TestModule;

interface Fifo_IFC;
	method Action enq (Int #(32) x);
	method Int#(32) first();
	method Int#(32) second();
	method Action deq();

endinterface

module mkFifo(Fifo_IFC);
//Instantiating the registers for the FIFO to use

Reg #(Int #(32)) x0 <- mkRegU;
Reg #(Int #(32)) x1 <- mkRegU;

//Instantiating Tail and Head Pointers

Reg #(Bit #(1)) tp <- mkReg(0);
Reg #(Bit #(1)) hp <- mkReg(0);
Reg #(Int#(32)) ne <-mkReg(0);

method Action enq(Int#(32) x) if (ne<2);
	ne<=ne+1;
	if(tp==0)
	x0<=x;
	else
	x1<=x;	
	tp<=~tp;
	
endmethod

method Int#(32) first() if (ne>0);
	if(hp==0)
	return x0;
	else
	return x1;
endmethod

method Int#(32) second() if(ne==2);
	
	if(hp==0)
	return x1;
	else
	return x0;
	
	
endmethod

method Action deq() if (ne>0);
	ne<=ne-1;
	hp<=~hp;
	
endmethod


endmodule

import LFSR :: *;

(* synthesize *)
module mkTop();
//Instantiating Counter of elements
	Reg #(Int#(32)) nel<-mkReg(0);
//Intantiating the FIFO
	Fifo_IFC fifo <- mkFifo;
LFSR #(Bit #(8)) lfsr <- mkLFSR_8;
//The rule to enqueue elements
rule enq1 (nel==0);
	nel<=nel+1;
	Bit#(32) v = zeroExtend (lfsr.value ());
      	lfsr.next ();
	Int#(32) x = unpack (v);
	fifo.enq(x);
	$display("x0: %0d",x);
endrule

rule enq2 (nel==1);
	nel<=nel+1;
	Bit#(32) v = zeroExtend (lfsr.value ());
      	lfsr.next ();
	Int#(32) x = unpack (v);
	fifo.enq(x);
	$display("x0: %0d, x1: %0d",fifo.first,x);
endrule

rule deq1 (nel==2);
	nel<=nel+1;
	fifo.deq();
	$display("x0: %0d", fifo.first);
endrule
rule deq2 (nel==3);
	nel<=nel+1;
	fifo.deq();
$finish;
endrule
endmodule

endpackage
