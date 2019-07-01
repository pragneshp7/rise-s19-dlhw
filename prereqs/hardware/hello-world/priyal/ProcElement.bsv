package ProcElement;

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
endpackage


