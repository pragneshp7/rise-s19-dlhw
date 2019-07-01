import StmtFSM ::*;
import ProcElement ::*;
import Vector ::*;

interface Ifc_PE;
    method ActionValue#(Bit#(32)) rightoutput;
    method Action upinput(Bit#(32) y);
    method ActionValue#(Bit#(32)) downoutput;
    method Action leftinput(Bit#(32) x);
    method Action weightinp (Bit#(32) w);
    method ActionValue#(Bit#(32)) weightoutput;
endinterface


(* synthesize *)
module mkPE (Ifc_PE);
    
    //Register Initialisation

    Reg#(Bit#(32)) rg_pixel <- mkReg(0);   
    Reg#(Bit#(32)) rg_weight <- mkReg(0);
    Reg#(Bit#(32)) rg_psumi <- mkReg(0);
    Wire#(Bit#(32)) wr_psumo <- mkDWire(0);


    rule rl_psum;
         wr_psumo  <= rg_psumi + rg_weight * rg_pixel;      
    endrule 

    //Weight setting Stage
    //weightoutput can only called one clock cycle after weightinp
 
    method Action weightinp (Bit#(32) w);
        rg_weight <= w;
    endmethod
    method ActionValue#(Bit#(32)) weightoutput;
        return rg_weight;
    endmethod

    //Left right pixel input stage

    method Action  leftinput (Bit#(32) x);
        rg_pixel <= x;
    endmethod
    method ActionValue#(Bit#(32)) rightoutput;
        return rg_pixel;
    endmethod

    //Diagnal input output
    method Action upinput (Bit#(32) y);
        rg_psumi <= y;
    endmethod
    method ActionValue#(Bit#(32)) downoutput;
        return wr_psumo;
    endmethod
endmodule

(* synthesize *)
module mkTop (Empty);
    Vector#(4,Ifc_PE) col0 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col1 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col2 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col3 <- replicateM(mkPE);
    Vector#(4,Vector#(4,Ifc_PE)) array = newVector;
    array[0]=col0;
    array[1]=col1;
    array[2]=col2;
    array[3]=col3;

    Stmt test=
    (seq
            action
                array[0][0].leftinput(4);
                array[0][0].weightinp(2);
                array[0][0].upinput(0);
                let x = array[0][0].rightoutput;
                $display("Your output is %d",x );
            endaction
            action
                array[0][0].leftinput(2);
                array[0][0].upinput(10);
                let x = array[0][0].downoutput;
                $display("Your output is %d",x );
            endaction
            action  
                 let x = array[0][0].downoutput;
                $display("Your output is %d",x);
            endaction
        endseq
    );
    mkAutoFSM(test);
endmodule
