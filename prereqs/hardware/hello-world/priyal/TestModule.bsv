import FIFO::*;

(* synthesize *)
module mkTop ();

    rule finish_sim;
        $display("Hello Priyal");
        $finish;
    endrule
endmodule
