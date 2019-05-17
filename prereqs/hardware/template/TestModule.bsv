import FIFO::*;

(* synthesize *)
module mkTop ();

    rule finish_sim;
        $display("Hello world");
        $finish;
    endrule
endmodule
