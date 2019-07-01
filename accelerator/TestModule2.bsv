package TestModule2;

interface Ifc_PEArray;
    method Action xinput1 (Bit#(32) x);
    method Action xinput2 (Bit#(32) x);
    method Action xinput3 (Bit#(32) x);
    method Action xinput4 (Bit#(32) x);
    method Action xinput5 (Bit#(32) x);
    method Action xinput6 (Bit#(32) x);
    method Action xinput7 (Bit#(32) x);
    
    method Action yinput1 (Bit#(32) x);
    method Action yinput2 (Bit#(32) x);
    method Action yinput3 (Bit#(32) x);
    method Action yinput4 (Bit#(32) x);
    method Action winput1 (Bit#(32) x); 
    method Action winput2 (Bit#(32) x); 
    method Action winput3 (Bit#(32) x);
    method Action winput4 (Bit#(32) x); 

    method ActionValue #(Bit#(32)) youtput1;
    method ActionValue #(Bit#(32)) youtput2;
    method ActionValue #(Bit#(32)) youtput3;
    method ActionValue #(Bit#(32)) youtput4;

    method Action weighttran (Bit#(32) x);
    method Action convs (Bit#(32) x);
endinterface

interface Ifc_PE;
    method Bit#(32) rightoutput();
    method Action upinput(Bit#(32) y);
    method Bit#(32) downoutput();
    method Action leftinput(Bit#(32) x);
    method Action weightinp (Bit#(32) w);
    method Bit#(32) weightoutput();
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
        rg_pixel <= 0;
        rg_psumi <= 0;
    endmethod
    method Bit#(32) weightoutput();
        return rg_weight;
    endmethod

    //Left right pixel input stage

    method Action  leftinput (Bit#(32) x);
        rg_pixel <= x;
    endmethod
    method Bit#(32) rightoutput();
        return rg_pixel;
    endmethod

    //Diagnal input output
    method Action upinput (Bit#(32) y);
        rg_psumi <= y;
    endmethod
    method Bit#(32) downoutput();
        return wr_psumo;
    endmethod
endmodule

import StmtFSM ::*;
import Vector ::*;
(* synthesize *)
module mkPEArray (Ifc_PEArray); 
 
    Vector#(4,Ifc_PE) col0 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col1 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col2 <- replicateM(mkPE);
    Vector#(4,Ifc_PE) col3 <- replicateM(mkPE);
    Vector#(4,Vector#(4,Ifc_PE)) array = newVector;
    array[0]=col0;
    array[1]=col1;
    array[2]=col2;
    array[3]=col3;

    Vector#(6,Reg#(Bit#(32))) delay <- replicateM(mkRegU);
        Reg#(Bit#(32)) weighttrans <- mkReg(0);
        Reg#(Bit#(32)) conv <- mkReg(0);

    rule rl_xconnect2 (weighttrans == 0 && conv == 1);
               let x = array[1][0].rightoutput;
               array[0][1].leftinput(x);
    endrule

    rule rl_xconnect3 (weighttrans == 0 && conv == 1);
               let x = array[2][0].rightoutput;
               array[1][1].leftinput(x);
               let y = array[1][1].rightoutput;
               array[0][2].leftinput(y);
    endrule

    rule rl_xconnect4 (weighttrans == 0 && conv == 1);
               let x = array[3][0].rightoutput;
               array[2][1].leftinput(x);
               let y = array[2][1].rightoutput;
               array[1][2].leftinput(y);
               let z = array[1][2].rightoutput;
               array[0][3].leftinput(z);
    endrule

    rule rl_xconnect5 (weighttrans == 0 && conv == 1);
               let a = delay[0];
               array[3][1].leftinput(a);
               let x = array[3][1].rightoutput;
               array[2][2].leftinput(x);
               let y = array[2][2].rightoutput;
               array[1][3].leftinput(y);
    endrule

    rule rl_xconnect6 (weighttrans == 0 && conv == 1);
               let a = delay[1];
               delay[2] <= a;
               let b = delay[2];
               array[3][2].leftinput(b);
               let x = array[3][2].rightoutput;
               array[2][3].leftinput(x);
    endrule

    rule rl_xconnect7 (weighttrans == 0 && conv == 1);
               let a = delay[3];
               delay[4] <= a;
               let b = delay[4];
               delay[5] <= b;
               let x = delay[5];
               array[3][3].leftinput(x);
    endrule

    rule rl_wconnect1 (weighttrans == 1 && conv == 0);
        let x = array[0][0].weightoutput;
                array[1][0].weightinp(x); 
        let y = array[1][0].weightoutput;
                array[2][0].weightinp(y);
        let z = array[2][0].weightoutput;
                array[3][0].weightinp(z); 
    endrule

    rule rl_wconnect2 (weighttrans == 1 && conv == 0);
        let x = array[0][1].weightoutput;
                array[1][1].weightinp(x); 
        let y = array[1][1].weightoutput;
                array[2][1].weightinp(y);
        let z = array[2][1].weightoutput;
                array[3][1].weightinp(z); 
    endrule 
    rule rl_wconnect3 (weighttrans == 1 && conv == 0);
        let x = array[0][2].weightoutput;
                array[1][2].weightinp(x); 
        let y = array[1][2].weightoutput;
                array[2][2].weightinp(y);
        let z = array[2][2].weightoutput;
                array[3][2].weightinp(z); 
    endrule
     rule rl_wconnect4 (weighttrans == 1 && conv == 0);
        let x = array[0][3].weightoutput;
                array[1][3].weightinp(x); 
        let y = array[1][3].weightoutput;
                array[2][3].weightinp(y);
        let z = array[2][3].weightoutput;
                array[3][3].weightinp(z); 
    endrule
    
    rule rl_yconnect1 (weighttrans == 0 && conv == 1);
        let x = array[0][0].downoutput;
                array[0][1].upinput(x); 
        let y = array[0][1].downoutput;
                array[0][2].upinput(y);
        let z = array[0][2].downoutput;
                array[0][3].upinput(z); 
    endrule

    rule rl_yconnect2 (weighttrans == 0 && conv == 1);
        let x = array[1][0].downoutput;
                array[1][1].upinput(x); 
        let y = array[1][1].downoutput;
                array[1][2].upinput(y);
        let z = array[1][2].downoutput;
                array[1][3].upinput(z); 
    endrule

    rule rl_yconnect3 (weighttrans == 0 && conv == 1);
        let x = array[2][0].downoutput;
                array[2][1].upinput(x); 
        let y = array[2][1].downoutput;
                array[2][2].upinput(y);
        let z = array[2][2].downoutput;
                array[2][3].upinput(z); 
    endrule
    rule rl_yconnect4 (weighttrans == 0 && conv == 1);
        let x = array[3][0].downoutput;
                array[3][1].upinput(x); 
        let y = array[3][1].downoutput;
                array[3][2].upinput(y);
        let z = array[3][2].downoutput;
                array[3][3].upinput(z); 
    endrule

    method Action weighttran (Bit#(32) x);
        if (x == 1) weighttrans <= 1;
        else weighttrans <= 0;
    endmethod
    
    method Action convs (Bit#(32) x);
        if (x == 1) conv <= 1;
        else conv <= 0;
    endmethod

    method Action xinput1 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[0][0].leftinput(x);
    endmethod
    method Action xinput2 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[1][0].leftinput(x);
    endmethod
    method Action xinput3 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[2][0].leftinput(x);
    endmethod
    method Action xinput4 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[3][0].leftinput(x);
    endmethod
    method Action xinput5 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        delay[0] <= x;
    endmethod
    method Action xinput6 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        delay[1] <= x;
    endmethod
    method Action xinput7 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        delay[3] <= x;
    endmethod
    method Action yinput1 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[0][0].upinput(x);
    endmethod
    method Action yinput2 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[1][0].upinput(x);
    endmethod
    method Action yinput3 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[2][0].upinput(x);
    endmethod
    method Action yinput4 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        array[3][0].upinput(x);
    endmethod

    method ActionValue #(Bit#(32)) youtput1 if (weighttrans == 0 && conv == 1);
        let x = array[0][3].downoutput;
        return x;
    endmethod
    method ActionValue #(Bit#(32)) youtput2 if (weighttrans == 0 && conv == 1);
        let x = array[1][3].downoutput;
        return x;
    endmethod
    method ActionValue #(Bit#(32)) youtput3 if (weighttrans == 0 && conv == 1);
        let x = array[2][3].downoutput;
        return x;
    endmethod
    method ActionValue #(Bit#(32)) youtput4 if (weighttrans == 0 && conv == 1);
        let x = array[3][3].downoutput;
        return x;
    endmethod
    method Action winput1 (Bit#(32) x) if (weighttrans == 1 && conv == 0);
        array[0][0].weightinp(x);
    endmethod
    method Action winput2 (Bit#(32) x) if (weighttrans == 1 && conv == 0);
        array[0][1].weightinp(x);
    endmethod
    method Action winput3 (Bit#(32) x) if (weighttrans == 1 && conv == 0);
        array[0][2].weightinp(x);
    endmethod
    method Action winput4 (Bit#(32) x) if (weighttrans == 1 && conv == 0);
        array[0][3].weightinp(x);
    endmethod

endmodule

(* synthesize *)
module mkTop (Empty); 
    Ifc_PEArray arr <- mkPEArray;
    Stmt test=
    (seq
            action
                $display("%t blah", $time);
            endaction
            action
                arr.weighttran(1);
                $display("%t Weight Transfer started", $time);
            endaction
            action
                arr.winput1(1);
                arr.winput2(1);
                arr.winput3(1);
                arr.winput4(1);
                $display("%t Weight transfer 1",$time);
            endaction
            action
                $display ("%t Weight transfer 2", $time);
            endaction
            action
                $display ("%t Weight transfer 3", $time);
            endaction
            action
                arr.weighttran(0);
                arr.convs(1);
            $display ("%t Weight transfer ended", $time);
            endaction
            action
                arr.xinput1(1);
                arr.xinput2(1);
                arr.xinput3(1);
                arr.xinput4(1);
                arr.xinput5(1);
                arr.xinput6(1);
                arr.xinput7(1);
                arr.yinput1(0);
                arr.yinput2(0);
                arr.yinput3(0);
                arr.yinput4(0);
                $display("%t Conv started",$time);
            endaction
            action
                arr.xinput1(2);
                arr.xinput2(2);
                arr.xinput3(2);
                arr.xinput4(2);
                arr.xinput5(2);
                arr.xinput6(2);
                arr.xinput7(2);
                arr.yinput1(0);
                arr.yinput2(0);
                arr.yinput3(0);
                arr.yinput4(0);
                $display("%t Conv cycle",$time);
            endaction
            action
                arr.xinput1(3);
                arr.xinput2(3);
                arr.xinput3(3);
                arr.xinput4(3);
                arr.xinput5(3);
                arr.xinput6(3);
                arr.xinput7(3);
                arr.yinput1(0);
                arr.yinput2(0);
                arr.yinput3(0);
                arr.yinput4(0);
                $display("%t Conv cycle 2",$time);
            endaction
            action
                arr.xinput1(4);
                arr.xinput2(4);
                arr.xinput3(4);
                arr.xinput4(4);
                arr.xinput5(4);
                arr.xinput6(4);
                arr.xinput7(4);
                arr.yinput1(0);
                arr.yinput2(0);
                arr.yinput3(0);
                arr.yinput4(0);

                $display("%t Conv cycle 3",$time);
            endaction
            action
                let x = arr.youtput1;
                $display("%t y11 = %0d", $time, x); 
                let y = arr.youtput2;
                $display("%t y12 = %0d", $time, y);
                let z = arr.youtput3;
                $display("%t y13 = %0d", $time, z);
                let a = arr.youtput4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                 let x = arr.youtput1;
                $display("%t y11 = %0d", $time, x); 
                let y = arr.youtput2;
                $display("%t y12 = %0d", $time, y);
                let z = arr.youtput3;
                $display("%t y13 = %0d", $time, z);
                let a = arr.youtput4;
                $display("%t y14 = %0d", $time, a);

            endaction
            action
                 let x = arr.youtput1;
                $display("%t y11 = %0d", $time, x); 
                let y = arr.youtput2;
                $display("%t y12 = %0d", $time, y);
                let z = arr.youtput3;
                $display("%t y13 = %0d", $time, z);
                let a = arr.youtput4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                 let x = arr.youtput1;
                $display("%t y11 = %0d", $time, x); 
                let y = arr.youtput2;
                $display("%t y12 = %0d", $time, y);
                let z = arr.youtput3;
                $display("%t y13 = %0d", $time, z);
                let a = arr.youtput4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                 let x = arr.youtput1;
                $display("%t y11 = %0d", $time, x); 
                let y = arr.youtput2;
                $display("%t y12 = %0d", $time, y);
                let z = arr.youtput3;
                $display("%t y13 = %0d", $time, z);
                let a = arr.youtput4;
                $display("%t y14 = %0d", $time, a);
            endaction
        endseq
    );
    mkAutoFSM(test);
endmodule

endpackage






	 
