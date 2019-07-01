import StmtFSM ::*;
import ProcElement ::*;

(* synthesize *)
module mkTop (Empty); 
    Ifc_PE pe <- mkPE;

    Stmt test=
    (seq
            action
                pe.leftinput(4);
                pe.weightinp(2);
                pe.upinput(0);
                let x = pe.rightoutput;
                $display("Your output is %d",x );
            endaction
            action
                pe.leftinput(2);
                pe.upinput(10);
                let x = pe.downoutput;
                $display("Your output is %d",x );
            endaction
            action  
                 let x = pe.downoutput;
                $display("Your output is %d",x);
            endaction
        endseq
    );
    mkAutoFSM(test);
endmodule
