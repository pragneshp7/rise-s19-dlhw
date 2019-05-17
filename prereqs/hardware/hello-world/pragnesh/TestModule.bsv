import FIFO::*;

(* synthesize *)
module mkTop ();

    rule finish_sim;
        $display("Hello Chennai");
        $finish;
    endrule
endmodule
