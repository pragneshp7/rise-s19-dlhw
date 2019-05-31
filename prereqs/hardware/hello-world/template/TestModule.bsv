import FIFO::*;

(* synthesize *)
module mkTop ();

    rule finish_sim;
        $display("Hello world Priyal");
        $finish;
    endrule
endmodule
