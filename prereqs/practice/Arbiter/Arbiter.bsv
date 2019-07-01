package TestModule;

interface Arbiter_IFC;
	method Action putvalue1 (Bit #(32) x);
	method Action putvalue2 (Bit #(32) y);
	method ActionValue #(Bit #(32)) get;
endinterface

(* synthesize *)
module mkArbiter (Arbiter_IFC);     //Main Module

Wire #(Bit#(32))  datain1 <- mkWire();
Wire #(Bit #(32))  datain2 <- mkWire();
Wire #(Bit #(32))  dataout  <- mkWire();
Reg #(Bit #(1))  toggle <- mkReg(0); //Register for Round Robin Scheduling

(* descending_urgency= "rl_p3,rl_p2,rl_p1"*) /*Used in the case if both puts are called. Then R3 should
be given higher priority for round robin scheduling*/

rule rl_p1; //Where only put1 is called/ data1 is true
    dataout <= datain1;
endrule

rule rl_p2; //When only put2 is called/ Data2 is true
    dataout <= datain2;
endrule

rule rl_p3;//When both puts are called/ Toggle the toggle register, depending on the current value give appropriate value as output
    if (toggle == 0) 
            dataout <= datain1; 
    else 
        begin 
        dataout <= datain2; 
    end
    toggle <= ~toggle;
endrule

method Action putvalue1 (Bit #(32) x); //Take data 1 input
    datain1 <= x;
endmethod

method Action putvalue2 (Bit #(32) y); //Take data 2 input
    datain2 <= y;
endmethod

method ActionValue #(Bit#(32)) get(); //Give Output
    return dataout;
endmethod

endmodule

//TestBench

import StmtFSM::*;
(* synthesize *)
module mkTop(Empty);
Arbiter_IFC arb <- mkArbiter;
Wire#(Bit #(32)) x <- mkWire();
Wire#(Bit #(32)) y <- mkWire();
Reg#(Bit #(32)) rg_cntr <- mkReg(0);
rule rl_counter;
rg_cntr <= rg_cntr + 1;
endrule

rule rl_cycle1 (rg_cntr == 0);
    $display("%t starting", $time);
endrule

rule rl_cycle2 (rg_cntr == 1);
    
    arb.putvalue1(1);
endrule

rule rl_cycle2in (rg_cntr == 1);    
    arb.putvalue2(2);
endrule

rule rl_cycle2out (rg_cntr == 1);
    $display ("%t output = %0d", $time, arb.get);
endrule

rule rl_cycle3 (rg_cntr == 2);
    
    arb.putvalue1(1);
endrule

rule rl_cycle3in (rg_cntr == 2);
    
    arb.putvalue2(2);
endrule

rule rl_cycle3out (rg_cntr == 2);
    $display ("%t output = %0d", $time, arb.get);
endrule

rule rl_cycle4 (rg_cntr == 3);
    
    arb.putvalue2(3);
endrule

rule rl_cycle4out (rg_cntr == 3);
    $display ("%t output = %0d", $time, arb.get);
    $finish;
endrule
endmodule
endpackage 
