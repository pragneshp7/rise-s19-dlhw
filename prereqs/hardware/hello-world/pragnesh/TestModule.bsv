import FIFO::*;

(* synthesize *)
module mkTop ();

    rule finish_sim;
        $display("Hello Pragnesh");
        $finish;
    endrule
endmodule
