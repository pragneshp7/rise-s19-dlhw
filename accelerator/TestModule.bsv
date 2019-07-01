package TestModule;

import BRAMCore ::*;

interface Ifc_SysArray;
method Action xwritestat (Bit#(1) stat);
method ActionValue#(Bit#(1)) xwritestatreturn;
method Action writex (Bit#(32) x);
method ActionValue#(Bit#(32)) y1bankoutputread;
method ActionValue#(Bit#(32)) y2bankoutputread;
method ActionValue#(Bit#(32)) y3bankoutputread;
method ActionValue#(Bit#(32)) y4bankoutputread;
endinterface

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

    method Bit#(32) youtput1();
    method Bit#(32) youtput2();
    method Bit#(32) youtput3();
    method Bit#(32) youtput4();

    method Action weighttran (Bit#(32) x);
    method Action convs (Bit#(32) x);
endinterface

interface Ifc_PEFifo;
    method Action xfifoin1 (Bit#(32) x);
    method Action xfifoin2 (Bit#(32) x);
    method Action xfifoin3 (Bit#(32) x);
    method Action xfifoin4 (Bit#(32) x);
    method Action xfifoin5 (Bit#(32) x);
    method Action xfifoin6 (Bit#(32) x);
    method Action xfifoin7 (Bit#(32) x);

    method Action yfifoin1 (Bit#(32) x);
    method Action yfifoin2 (Bit#(32) x);
    method Action yfifoin3 (Bit#(32) x);
    method Action yfifoin4 (Bit#(32) x);
    
    method ActionValue #(Bit#(32)) yfifoout1;
    method ActionValue #(Bit#(32)) yfifoout2;
    method ActionValue #(Bit#(32)) yfifoout3;
    method ActionValue #(Bit#(32)) yfifoout4;
   
    method Action wfifoin1 (Bit#(32) x);
    method Action wfifoin2 (Bit#(32) x);
    method Action wfifoin3 (Bit#(32) x);
    method Action wfifoin4 (Bit#(32) x);

    method Action tr_inputfifo (Bit#(32) x);
    method Action tr_outfifo (Bit#(32) x);
    method Action tr_weightfifo (Bit#(32) x);
    method Action tr_weigh (Bit#(32) x);
    method Action tr_conv (Bit#(32) x);
    method Bit#(32) tr_convout ();


    interface Ifc_PEArray pearray;
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
//$display("%t weightinp: %0d fired",$time,w);

        rg_weight <= w;
    endmethod
    method Bit#(32) weightoutput();
        return rg_weight;
    endmethod

    //Left right pixel input stage

    method Action leftinput (Bit#(32) x);
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
$display("%t xcon2 x:%0d array[0][1]: %0d",$time,x, array[0][1].rightoutput);
    endrule

    rule rl_xconnect3 (weighttrans == 0 && conv == 1);
               let x = array[2][0].rightoutput;
               array[1][1].leftinput(x);
               let y = array[1][1].rightoutput;
               array[0][2].leftinput(y);
$display("%t xcon3 x:%0d array[1][1]: %0d",$time,x, array[1][1].rightoutput);
$display("%t xcon3 y:%0d array[0][2]: %0d",$time,y, array[0][2].rightoutput);
    endrule

    rule rl_xconnect4 (weighttrans == 0 && conv == 1);
               let x = array[3][0].rightoutput;
               array[2][1].leftinput(x);
               let y = array[2][1].rightoutput;
               array[1][2].leftinput(y);
               let z = array[1][2].rightoutput;
               array[0][3].leftinput(z);
$display("%t xcon4 x:%0d array[2][1]: %0d",$time,x, array[2][1].rightoutput);
$display("%t xcon4 y:%0d array[1][2]: %0d",$time,y, array[1][2].rightoutput);
$display("%t xcon4 z:%0d array[0][3]: %0d",$time,z, array[0][3].rightoutput);
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
      // $display("%t rl_wconnec1 fired",$time);
 let x = array[0][0].weightoutput;
                array[1][0].weightinp(x);
$display("%t wcon x:%0d array[1][0]: %0d",$time,x, array[1][0].weightoutput);

        let y = array[1][0].weightoutput;
                array[2][0].weightinp(y);
$display("%t wcon y:%0d array[2][0]: %0d",$time,y, array[2][0].weightoutput);


                let z = array[2][0].weightoutput;
                array[3][0].weightinp(z); 
$display("%t wcon z:%0d array[3][0]: %0d",$time,z, array[3][0].weightoutput);


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
$display("%t ycon1 x:%0d array[0][1]: %0d",$time,x, array[0][1].downoutput);
$display("%t ycon1 y:%0d array[0][2]: %0d",$time,y, array[0][2].downoutput); 
$display("%t ycon1 z:%0d array[0][3]: %0d",$time,z, array[0][3].downoutput); 
    endrule

    rule rl_yconnect2 (weighttrans == 0 && conv == 1);
        let x = array[1][0].downoutput;
                array[1][1].upinput(x); 
        let y = array[1][1].downoutput;
                array[1][2].upinput(y);
        let z = array[1][2].downoutput;
                array[1][3].upinput(z); 
$display("%t ycon2 x:%0d array[1][1]: %0d",$time,x, array[1][1].downoutput);
$display("%t ycon2 y:%0d array[1][2]: %0d",$time,y, array[1][2].downoutput); 
$display("%t ycon2 z:%0d array[1][3]: %0d",$time,z, array[1][3].downoutput); 
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
        $display("%t xinput1: %0d",$time, x);
        array[0][0].leftinput(x);
    endmethod
    method Action xinput2 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        $display("%t xinput2: %0d",$time, x);
        array[1][0].leftinput(x);
    endmethod
    method Action xinput3 (Bit#(32) x) if (weighttrans == 0 && conv == 1);
        $display("%t xinput3: %0d",$time, x);
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

    method Bit#(32) youtput1 if (weighttrans == 0 && conv == 1);
        let x = array[0][3].downoutput;
        return x;
    endmethod
    method Bit#(32) youtput2 if (weighttrans == 0 && conv == 1);
        let x = array[1][3].downoutput;
        return x;
    endmethod
    method Bit#(32) youtput3 if (weighttrans == 0 && conv == 1);
        let x = array[2][3].downoutput;
        return x;
    endmethod
    method Bit#(32) youtput4 if (weighttrans == 0 && conv == 1);
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

import FIFOF ::*;
(* synthesize *)
module mkPEFifo (Ifc_PEFifo);

    Ifc_PEArray pearr <- mkPEArray;
   

    Reg #(Bit#(32)) inputfifo <- mkReg(0);
    Reg #(Bit#(32)) weightfifo <- mkReg(0);
    Reg #(Bit#(32)) outfifo <- mkReg(0);
    Reg #(Bit#(32)) conout <- mkReg(0);
    Reg #(Bit#(32)) con <- mkReg(0);
    Reg #(Bit#(32)) weigh <- mkReg(0);
    Reg #(Bit#(32)) counter <- mkReg(0); //for initialising conout
    Reg #(Bit#(32)) counter2 <- mkReg(0);

    FIFOF #(Bit#(32)) fifox1 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox2 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox3 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox4 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox5 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox6 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifox7 <- mkSizedFIFOF(6);
 
    FIFOF #(Bit#(32)) fifoyin1 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoyin2 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoyin3 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoyin4 <- mkSizedFIFOF(6);   

    FIFOF #(Bit#(32)) fifow1 <- mkSizedFIFOF(4);
    FIFOF #(Bit#(32)) fifow2 <- mkSizedFIFOF(4);
    FIFOF #(Bit#(32)) fifow3 <- mkSizedFIFOF(4);
    FIFOF #(Bit#(32)) fifow4 <- mkSizedFIFOF(4);
    
    FIFOF #(Bit#(32)) fifoy1 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoy2 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoy3 <- mkSizedFIFOF(6);
    FIFOF #(Bit#(32)) fifoy4 <- mkSizedFIFOF(6);

    rule rl_counter (con == 1 && weigh == 0);
        counter <= counter + 1;
    endrule

    rule rl_counter2 (conout == 1);
        counter2 <= counter2 +1;
    endrule
   
    rule rl_conout_start (counter == 3);
        conout <= 1;
    endrule
    
    rule rl_conout_end (counter2 == 13);
            conout <= 0;
            counter <= 0;
            counter2 <= 0;
            con <= 0;
    endrule

    rule rl_xinput1 (con == 1 && weigh == 0);// && fifox1.notEmpty); //conv same as convs in PEArray
        let x = fifox1.first;
        pearr.xinput1(x);
        fifox1.deq;
    endrule
    rule rl_xinput2 (con == 1 && weigh == 0);// && fifox2.notEmpty); 
        let x = fifox2.first;
        pearr.xinput2(x);
       //  $display("%t rl_xinput1 fired",$time);
        fifox2.deq;
    endrule
    rule rl_xinput3 (con == 1 && weigh == 0);// && fifox3.notEmpty); 
        let x = fifox3.first;
        pearr.xinput3(x);
        fifox3.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput4 (con == 1 && weigh == 0);// && fifox4.notEmpty); 
        let x = fifox4.first;
        pearr.xinput4(x);
        fifox4.deq;
 //$display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput5 (con == 1 && weigh == 0);// && fifox5.notEmpty); 
        let x = fifox5.first;
        pearr.xinput5(x);
        fifox5.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput6 (con == 1 && weigh == 0);// && fifox6.notEmpty); 
        let x = fifox6.first;
        pearr.xinput6(x);
        fifox6.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput7 (con == 1 && weigh == 0);// && fifox7.notEmpty); 
        let x = fifox7.first;
        pearr.xinput7(x);
        fifox7.deq;
  //       $display("%t rl_xinput1 fired",$time);
    endrule
    
    rule rl_yinput1 (con == 1 && weigh == 0 );//&& fifoyin1.notEmpty); //conv same as convs in PEArray


        let x = fifoyin1.first;
        pearr.yinput1(x);
        fifoyin1.deq;
    endrule
    rule rl_yinput2 (con == 1 && weigh == 0);// && fifoyin2.notEmpty); 
        let x = fifoyin2.first;
        pearr.yinput2(x);
        fifoyin2.deq;
    endrule
    rule rl_yinput3 (con == 1 && weigh == 0);// && fifoyin3.notEmpty); 
        let x = fifoyin3.first;
        pearr.yinput3(x);
        fifoyin3.deq;
    endrule
    rule rl_yinput4 (con == 1 && weigh == 0);// && fifoyin4.notEmpty); 
        let x = fifoyin4.first;
        pearr.yinput4(x);
        fifoyin4.deq;
    endrule
    
    rule rl_winput1 (weigh == 1 && con == 0);// && fifow1.notEmpty);
        let f = fifow1.first;
        pearr.winput1(f);
        fifow1.deq;

    endrule
    rule rl_winput2 (weigh == 1 && con == 0);// && fifow2.notEmpty);
        let m = fifow2.first;
        pearr.winput2(m);
        fifow2.deq;
// $display("%t rl_winput2 fired",$time);
    endrule
    rule rl_winput3 (weigh == 1 && con == 0);// && fifow3.notEmpty);
        let k = fifow3.first;
        pearr.winput3(k);
        fifow3.deq; 
  //       $display("%t rl_winput3 fired",$time);
    endrule
    rule rl_winput4 (weigh == 1 && con == 0);// && fifow4.notEmpty);
        let l = fifow4.first;
        pearr.winput4(l);
        fifow4.deq;
 //$display("%t rl_winput4 fired",$time);
    endrule

    rule rl_youtput1 (conout == 1 && weigh == 0);// && fifoy1.notFull);
        fifoy1.enq(pearr.youtput1);


    endrule
    rule rl_youtput2 (conout == 1 && weigh == 0);// && fifoy2.notFull);

    fifoy2.enq(pearr.youtput2);
    endrule
    rule rl_youtput3 (conout == 1 && weigh == 0);// && fifoy3.notFull);
        fifoy3.enq(pearr.youtput3);
    endrule
    rule rl_youtput4 (conout == 1 && weigh == 0);// && fifoy4.notFull);
        fifoy4.enq(pearr.youtput4);
    endrule
 
    method Action xfifoin1 (Bit#(32) x) if (inputfifo == 1);// && fifox1.notFull);
        fifox1.enq(x);

    endmethod
    method Action xfifoin2 (Bit#(32) x) if (inputfifo == 1);// && fifox2.notFull);
        fifox2.enq(x);
    endmethod
    method Action xfifoin3 (Bit#(32) x) if (inputfifo == 1);// && fifox3.notFull);
        fifox3.enq(x);
    endmethod
    method Action xfifoin4 (Bit#(32) x) if (inputfifo == 1);// && fifox4.notFull);
        fifox4.enq(x);
    endmethod
    method Action xfifoin5 (Bit#(32) x) if (inputfifo == 1);// && fifox5.notFull);
        fifox5.enq(x);
    endmethod
    method Action xfifoin6 (Bit#(32) x) if (inputfifo == 1);// && fifox6.notFull);
        fifox6.enq(x);
    endmethod
    method Action xfifoin7 (Bit#(32) x) if (inputfifo == 1);// && fifox7.notFull);
        fifox7.enq(x);
    endmethod

    method Action wfifoin1 (Bit#(32) x) if (weightfifo == 1);// && fifow1.notFull);
        fifow1.enq(x);
    endmethod
    method Action wfifoin2 (Bit#(32) x) if (weightfifo == 1);// && fifow2.notFull);
        fifow2.enq(x);
    endmethod
    method Action wfifoin3 (Bit#(32) x) if (weightfifo == 1);// && fifow3.notFull);
        fifow3.enq(x);
    endmethod
    method Action wfifoin4 (Bit#(32) x) if (weightfifo == 1);// && fifow4.notFull);
        fifow4.enq(x);
    endmethod

    method Action yfifoin1 (Bit#(32) x) if (inputfifo == 1);// && fifoyin1.notFull);
        fifoyin1.enq(x);
    endmethod
    method Action yfifoin2 (Bit#(32) x) if (inputfifo == 1);// && fifoyin2.notFull);
        fifoyin2.enq(x);
    endmethod
    method Action yfifoin3 (Bit#(32) x) if (inputfifo == 1);// && fifoyin3.notFull);
        fifoyin3.enq(x);
    endmethod
    method Action yfifoin4 (Bit#(32) x) if (inputfifo == 1);// && fifoyin4.notFull);
        fifoyin4.enq(x);
    endmethod
 
    method ActionValue #(Bit#(32)) yfifoout1 if (outfifo == 1);// && fifoy1.notEmpty);
        let r = fifoy1.first;
        fifoy1.deq;
        return r;

    endmethod

    method ActionValue #(Bit#(32)) yfifoout2 if (outfifo == 1);// && fifoy2.notEmpty);
        let t = fifoy2.first;
        fifoy2.deq;
        return t;
    endmethod

    method ActionValue #(Bit#(32)) yfifoout3 if (outfifo == 1);// && fifoy3.notEmpty);
        let u = fifoy3.first;
        fifoy3.deq;
        return u;
    endmethod

    method ActionValue #(Bit#(32)) yfifoout4 if (outfifo == 1);// && fifoy4.notEmpty);
        let o = fifoy4.first;
        fifoy4.deq;

        return o;
    endmethod

    method Action tr_weigh (Bit#(32) x);
        if (x == 1) weigh <= 1;
        else weigh <= 0;
    endmethod
    
    method Action tr_conv (Bit#(32) x);
        if (x == 1) con <= 1;
        else con <= 0;
    endmethod

    method Bit#(32) tr_convout();
        return conout;
    endmethod

    method Action tr_inputfifo (Bit#(32) x);
        if (x == 1) inputfifo <= 1;
        else inputfifo <= 0;
    endmethod
    
    method Action tr_outfifo (Bit#(32) x);
        if (x == 1) outfifo <= 1;
        else outfifo <= 0;
    endmethod

    method Action tr_weightfifo (Bit#(32) x);
        if (x == 1) weightfifo <= 1;
        else weightfifo <= 0;
    endmethod
    interface pearray = pearr;
endmodule

/*

interface Ifc_PEFifo;
    method Action xfifoin1 (Bit#(32) x);
    method Action xfifoin2 (Bit#(32) x);
    method Action xfifoin3 (Bit#(32) x);
    method Action xfifoin4 (Bit#(32) x);
    method Action xfifoin5 (Bit#(32) x);
    method Action xfifoin6 (Bit#(32) x);
    method Action xfifoin7 (Bit#(32) x);

    method Action yfifoin1 (Bit#(32) x);
    method Action yfifoin2 (Bit#(32) x);
    method Action yfifoin3 (Bit#(32) x);
    method Action yfifoin4 (Bit#(32) x);
    
    method ActionValue #(Bit#(32)) yfifoout1;
    method ActionValue #(Bit#(32)) yfifoout2;
    method ActionValue #(Bit#(32)) yfifoout3;
    method ActionValue #(Bit#(32)) yfifoout4;
   
    method Action wfifoin1 (Bit#(32) x);
    method Action wfifoin2 (Bit#(32) x);
    method Action wfifoin3 (Bit#(32) x);
    method Action wfifoin4 (Bit#(32) x);

    method Action tr_inputfifo (Bit#(32) x); Activates X and Y fifosin
    method Action tr_outfifo (Bit#(32) x); Activates deq of Y fifoout 
    method Action tr_weightfifo (Bit#(32) x); Activates W fifo
    method Action tr_weigh (Bit#(32) x); Activates weight tranfer
    method Action tr_conv (Bit#(32) x); Activates deq of input fifo
    interface Ifc_PEArray pearray;
endinterface

*/


(* synthesize *)
module mkTop (Ifc_SysArray);


    Ifc_PEFifo pefifo <- mkPEFifo;


    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x1bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x2bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x3bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x4bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x5bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x6bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) x7bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(32)) y1bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(32)) y2bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(32)) y3bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(32)) y4bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(32)) wbank <- mkBRAMCore2(32,False);
    
    //BRAM X write 
    Reg#(Bit#(5)) rg_xwriadd <- mkReg(0);
    Reg#(Bit#(5)) rg_xwricase <- mkReg(0);
    Reg#(Bit#(1)) rg_xwritestat <- mkReg(0);


/*
 
    method Action xwritestat (Bit#(1) stat);
        rg_xwritestat <= stat;
    endmethod

    
    method ActionValue#(Bit#(1)) xwritestatreturn;
        return rg_xwritestat;
    endmethod


    method Action writex (Bit#(32) x) if ((rg_xwriadd<16) && (rg_xwritestat == 1));
        rg_xwriadd <= rg_xwriadd + 1;
        if(rg_xwricase == 0)
            x1bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 1)
            x2bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 2)
            x3bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 3)
            x4bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 4)
            x5bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 5)
            x6bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 6)
            x7bank.a.put(True,rg_xwriadd,x);
    endmethod

        rule rl_xwritestatus ((rg_xwritestat == 1) && (rg_xwriadd == 13) && (rg_xwricase != 6));
        rg_xwriadd <= 0;
        rg_xwricase <= rg_xwricase +1;
    endrule


    rule rl_xwriteend((rg_xwritestat == 1) && (rg_xwriadd == 13) && (rg_xwricase == 6));
        rg_xwriadd <= 0;
        rg_xwricase <= 0;
        rg_xwritestat <= 0;
    endrule
*/
   

//BRAM W write
    Reg#(Bit#(1)) rg_wwritestat <- mkReg(0);
    Reg#(Bit#(5)) rg_wwriadd <- mkReg(0);

/*
    method Action writew (Bit#(32) w) if ((rg_wwriadd<16) && (rg_wwritestat == 1));
        rg_wwriadd <= rg_wwriadd + 1;
        wbank.a.put(True,rg_wwriadd,w);
    endmethod

    method Action  wwritestat (Bit#(1) stat);
        rg_wwritestat <= stat;
    endmethod
    
    method wwristatreturn (Bit#(1));
        return rg_wwristat;
    endmodule

    rule rl_wwriend ((rg_wwritestat == 1) && (rg_wwritadd == 16));
        rg_wwritestat <= 0;
        rg_wwriadd <= 0;
    endrule


  */


// BRAM Y read

    Reg#(Bit#(7)) rg_yreadadd <- mkReg(0);
    Reg#(Bit#(1)) rg_yreadstat <- mkReg(0);
    Reg#(Bit#(2)) rg_yreadcase <- mkReg(0);
    Wire#(Bit#(32)) wr_youtput <- mkWire();

/*
    rule rl_yreadcase ((rg_yread == 54) && (rg_yreadstat == 1) && (rg_yreadcase != 3));
        rg_yreadcase <= rg_yreadcase + 1;
        rg_yreadadd <= 0;
    endrule

    rule rl_yreadend ((rg_yread == 54) && (rg_yreadstat == 1) && (rg_yreadcase == 3));
        rg_yreadcase <= 0;
        rg_yreadadd <= 0;
        rg_yreadstat <= 0;
    endrule

     rule rl_yreadbank1 if((rg_yread<54) && (rg_yreadstat == 1) && (rg_yreadcase == 0));
        rg_yreadadd <= rg_yreadadd + 1;
        if(rg_yreadadd>1)
        begin
            wr_output <= y1bank.a.read();
        end
    endrule

     rule rl_yreadbank2 if((rg_yread<54) && (rg_yreadstat == 1) && (rg_yreadcase == 1));
        rg_yreadadd <= rg_yreadadd + 1;
        if(rg_yreadadd>1)
        begin
            wr_output <= y2bank.a.read();
        end
    endrule

     rule rl_yreadbank3 if((rg_yread<54) && (rg_yreadstat == 1) && (rg_yreadcase == 2));
        rg_yreadadd <= rg_yreadadd + 1;
        if(rg_yreadadd>1)
        begin
            wr_output <= y3bank.a.read();
        end
    endrule

     rule rl_yreadbank4 if((rg_yread<54) && (rg_yreadstat == 1) && (rg_yreadcase == 3));
        rg_yreadadd <= rg_yreadadd + 1;
        if(rg_yreadadd>1)
        begin
            wr_output <= y4bank.a.read();
        end
    endrule
        
    method yreadstatreturn (Bit#(1));
        return rg_yreadstat;
    endmethod

    method Action yreadstat (Bit#(1) stat);
        rg_yreadstat <= stat;
    endmethod

    method yread (Bit#(32));
        return wr_youtput;
    endmethod

*/

//Signals from Processor

    Reg#(Bit#(1)) rg_XBramloaded <- mkReg(0);
    Reg#(Bit#(1)) rg_WBRAMloaded <- mkReg(0);
    

/*
    method Action XBRAM_Loaded (Bit#(1) status);
        rg_XBRAMloaded <= status;
    endmodule

    method XBRAM_Loaded_Return (Bit#(1));
        return rg_XBRAMloaded;
    endmodule
    
     method Action WBRAM_Loaded (Bit#(1) status);
        rg_WBRAMloaded <= status;
    endmodule

    method WBRAM_Loaded_Return (Bit#(1));
        return rg_WBRAMloaded;
    endmodule
   

*/


//Fifo enqueing start


/*
    rule rl_activatefifo;
        pefifo.tr_inputfifo(1);
        pefifo.tr_outfifo(1);
        pefifo.tr_weightfifo(1);
    endrule
*/

//Weight Transfer to Fifos

    Reg#(Bit#(5)) rg_wfifoadd <- mkReg(0);
    Reg#(Bit#(1)) rg_wfifoloaded <- mkReg(0);

/*
   
   rule rl_weight_tf_fifo ((rg_WBRAM_loaded == 1) && (rg_wfifoadd < 17));
        wbank.b.put(False,rg_wfifoadd,?);
        rg_wfifoadd <= rg_wfifoadd+1;
        if(rg_wfifoadd>0)
        begin
            if(rg_wfifoadd % 4 == 0)
            begin
            let wfifo4 = wbank.b.read;
            pefifo.wfifoin4(wfifo4);
            end
            if (rg_wfifoadd % 4 == 1)
            begin
            let wfifo1 = wbank.b.read;
            pefifo.wfifoin1(wfifo1);
            end
            if (rg_wfifoadd % 4 == 2)
            begin
            let wfifo2 = wbank.b.read;
            pefifo.wfifoin2(wfifo2);
            end
            if (rg_wfifoadd % 4 == 3)
            begin
            let wfifo3 = wbank.b.read;
            pefifo.wfifoin3(wfifo3);
            end
        end
    endrule

    rule rl_weight_tf_fifo_end ((rg_WBRAM_loaded == 1) && (rg_wfifoadd == 17));
        rg_WBRAM_loaded <= 0;
        rg_wfifoadd <= 0;
        rg_wfifoloaded <= 1;
    endrule

*/


//XInput Tranfer to Fifos

    Reg#(Bit#(5)) rg_xfifoadd <- mkReg(0);
    Reg#(Bit#(1)) rg_xfifosloaded <- mkReg(0);
/*
    
    rule rl_x_tf_fifo ((rg_XBRAM_loaded == 1) && (xfifoadd<14));
        x1bank.a.put(False,rg_xfifoadd,?);
        x2bank.a.put(False,rg_xfifoadd,?);
        x3bank.a.put(False,rg_xfifoadd,?);
        x4bank.a.put(False,rg_xfifoadd,?);
        x5bank.a.put(False,rg_xfifoadd,?);
        x6bank.a.put(False,rg_xfifoadd,?);
        x7bank.a.put(False,rg_xfifoadd,?);
        rg_xfifoadd <= rg_xfifoadd+1;
        if (rg_xfifoadd>1)
        begin
            let xfifoin1 = x1bank.a.read;
            pefifo.xfifoin1(xfifoin1);
            let xfifoin2 = x2bank.a.read;
            pefifo.xfifoin2(xfifoin2);            
            let xfifoin3 = x3bank.a.read;
            pefifo.xfifoin3(xfifoin3);
            let xfifoin4 = x4bank.a.read;
            pefifo.xfifoin4(xfifoin4);
            let xfifoin5 = x5bank.a.read;
            pefifo.xfifoin5(xfifoin5);
            let xfifoin6 = x6bank.a.read;
            pefifo.xfifoin6(xfifoin6);
            let xfifoin7 = x7bank.a.read;
            pefifo.xfifoin7(xfifoin7);
        end
    endrule

    rule rl_x_tf_end ((rg_XBRAM_loaded == 1) && (xfifoadd == 13));
        rg_XBRAM_loaded <= 0;
        rg_xfifoadd <= 0;
        rg_xfifosloaded <= 1;
    endrule

*/
    

//Y output Transfer Fifos

    Reg#(Bit#(2)) rg_cyclecount <- mkReg(0);
    Reg#(Bit#(7)) rg_ywriteadd <- mkReg(0);
    
/*

    rule rl_ywrite ((rg_ywriteadd < 13) && (rg_cyclecount == 4));
        rg_ywriteadd <= tg_ywriteadd + 1;
        let y1 <- pefifo.yfifoout1;
        let y2 <- pefifo.yfifoout2;
        let y3 <- pefifo.yfifoout3;
        let y4 <- pefifo.yfifoout4;
        y1bank.a.put(True,rg_ywriteadd,y1);
        y2bank.a.put(True,rg_ywriteadd,y2);
        y3bank.a.put(True,rg_ywriteadd,y3);
        y4bank.a.put(True,rg_ywriteadd,y4);
    endrule

    rule rl_ywriteend (rg_ywriteend == 13);
        rg_cyclecount <= 0;
        rg_ywriteadd <= 0;
    endrule

*/

// Scheduling Everything
    Reg#(Bit#(5)) rg_yfifoadd <- mkReg(0);
    Reg#(Bit#(1)) rg_yfifosloaded <- mkReg(0);


/*
    rule rl_yfifopopulate ((rg_cyclecount == 0) && (rg_yfifoadd < 13));
        pefifo.yfifoin1(0);
        pefifo.yfifoin2(0);
        pefifo.yfifoin3(0);
        pefifo.yfifoin4(0);
        rg_yfifoadd <= rg_yfifoadd +1;
    endrule

    rule rl_yfifopopulate_end ((rg_cyclecount < 4) && (rg_yfifoadd == 13));
        rg_cyclecount <= rg_cyclecount + 1;
        rg_yfifoadd <= 0;
        rg_yfifosloaded <= 1;
    endrule
    
    rule rl_yfifowrite ((rg_cyclecount != 4) && (rg_cyclecount != 0) && (rg_yfifoadd < 13));
        let y1 <- pefifo.yfifoout1;
        let y2 <- pefifo.yfifoout2;
        let y3 <- pefifo.yfifoout3;
        let y4 <- pefifo.yfifoout4;
        pefifo.yfifoin1(y1);
        pefifo.yfifoin2(y2);
        pefifo.yfifoin3(y3);
        pefifo.yfifoin4(y4);
        rg_yfifoadd <= rg_yfifoadd + 1;
    endrule

*/

//Weight Scheduling

    Reg#(Bit#(3)) rg_weightcounter <- mkReg(0);
/*
    rule rl_ ((wfifosloaded == 1) && () && ());
    endrule

*/


    
    


/*
    Reg#(Bit#(5)) rg_xadd <- mkReg(0);
    Reg#(Bit#(5)) rg_wadd <- mkReg(0);
    Reg#(Bit#(7)) rg_ywriadd <- mkReg(0);
    Reg#(Bit#(2)) rg_ywricase <- mkReg(0);
    Reg#(Bit#(6)) rg_ycount <- mkReg(0);
    Reg#(Bit#(7)) rg_yadd <- mkReg(0);
    Reg#(Bit#(1)) rg_wstatus <- mkReg(0);
    Reg#(Bit#(1)) rg_conv <- mkReg(0);
    Reg#(Bit#(7)) rg_convcount <- mkReg(0);

*/

    rule rl_activateinputfifo(rg_stat == 1);
        pefifo.tr_inputfifo(1);
        pefifo.tr_outfifo(1);
        pefifo.tr_weightfifo(1);
    endrule

    rule rl_xinputenq (rg_stat == 1);
        x1bank.a.put(False,rg_xadd,?);
        x2bank.a.put(False,rg_xadd,?);
        x3bank.a.put(False,rg_xadd,?);
        x4bank.a.put(False,rg_xadd,?);
        x5bank.a.put(False,rg_xadd,?);
        x6bank.a.put(False,rg_xadd,?);
        x7bank.a.put(False,rg_xadd,?);
        rg_xadd <= rg_xadd+1;
        if (rg_xadd>1)
        begin
            let xfifoin1 = x1bank.a.read;
            pefifo.xfifoin1(xfifoin1);
            let xfifoin2 = x2bank.a.read;
            pefifo.xfifoin2(xfifoin2);            
            let xfifoin3 = x3bank.a.read;
            pefifo.xfifoin3(xfifoin3);
            let xfifoin4 = x4bank.a.read;
            pefifo.xfifoin4(xfifoin4);
            let xfifoin5 = x5bank.a.read;
            pefifo.xfifoin5(xfifoin5);
            let xfifoin6 = x6bank.a.read;
            pefifo.xfifoin6(xfifoin6);
            let xfifoin7 = x7bank.a.read;
            pefifo.xfifoin7(xfifoin7);
        end
    endrule


    rule rl_weight(rg_stat == 1);
        wbank.a.put(False,rg_wadd,?);
        rg_wadd <= rg_wadd+1;
        if(rg_wadd>0)
        begin
            if(rg_wadd % 4 == 0)
            begin
            let wfifo4 = wbank.a.read;
            pefifo.wfifoin4(wfifo4);
            end
            if (rg_wadd % 4 == 1)
            begin
            let wfifo1 = wbank.a.read;
            pefifo.wfifoin1(wfifo1);
            end
            if (rg_wadd % 4 == 2)
            begin
            let wfifo2 = wbank.a.read;
            pefifo.wfifoin2(wfifo2);
            end
            if (rg_wadd % 4 == 3)
            begin
            let wfifo3 = wbank.a.read;
            pefifo.wfifoin3(wfifo3);
            end
        end
    endrule

    rule rl_fifoyenq ((rg_ycount<13) && (rg_stat == 1));
        rg_ycount <= rg_ycount + 1;
        pefifo.yfifoin1 (0);
        pefifo.yfifoin2 (0);
        pefifo.yfifoin3 (0);
        pefifo.yfifoin4 (0);
        
    endrule


    rule rl_youtputenq((rg_ycount>12) && (rg_ycount <53) && (rg_stat == 1)) ;
        rg_ycount <= rg_ycount +1;

        let y1 <- pefifo.yfifoout1;
        let y2 <- pefifo.yfifoout2;
        let y3 <- pefifo.yfifoout3;
        let y4 <- pefifo.yfifoout4;
        
        pefifo.yfifoin1(y1);
        pefifo.yfifoin2(y2);
        pefifo.yfifoin3(y3);
        pefifo.yfifoin4(y4);
        
    endrule

    rule rl_youtputwrite((rg_ycount == 53) && (rg_stat == 1));
        let y1 <- pefifo.yfifoout1;
        let y2 <- pefifo.yfifoout2;
        let y3 <- pefifo.yfifoout3;
        let y4 <- pefifo.yfifoout4;
        
        y1bank.a.put(True,rg_yadd,y1);
        y2bank.a.put(True,rg_yadd,y2);
        y3bank.a.put(True,rg_yadd,y3);
        y4bank.a.put(True,rg_yadd,y4);
    endrule



    rule rl_schedulingweightenable1 ((rg_ycount == 0) && (rg_stat == 1));
        pefifo.tr_weigh(1);
        rg_wstatus <= 1;
    endrule
       

    
    rule rl_schedulingweightdisable ((rg_wstatus ==  1) && (rg_stat == 1));
        rg_wstatus <= 0;
        pefifo.tr_weigh(0);
        pefifo.tr_conv(1);
        rg_conv <= 1;
    endrule
    
    rule rl_schedulingconv((rg_conv == 1) && (rg_stat == 1));
        rg_convcount <= rg_convcount +1;
    endrule

    rule rl_weightenable2 ((rg_convcount == 13) && (rg_ycount != 53) && (rg_stat == 1));
        rg_convcount <= 0;
        pefifo.tr_weigh(1);
        rg_wstatus <= 1;
        rg_conv <= 0;
        pefifo.tr_conv(0);
    endrule


    //BRAM Writes

    
 //X Write Rules
    rule rl_xwritestatus ((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase != 6));
        rg_xwriadd <= 0;
        rg_xwricase <= rg_xwricase +1;
    endrule


    rule rl_xwriteend((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase == 6));
        rg_xwriadd <= 0;
        rg_xwricase <= 0;
        rg_stat <= 1;
    endrule


 //Y read Rules   
    rule rl_yscheduling(rg_ywriadd == 54);
        rg_ywriadd <= 0;
        if (rg_ywricase == 3) begin
            rg_ywricase <= 0;
        end
        else begin
            rg_ywricase <= rg_ywricase + 1;
        end
    endrule
    

    rule rl_y1bankoutputput (rg_ywricase == 0); 
        rg_ywriadd <= rg_ywriadd + 1;
        y1bank.b.put(False,rg_ywriadd,?);
    endrule

    rule rl_y2bankoutputput (rg_ywricase == 1);
        rg_ywriadd <= rg_ywriadd + 1;
        y2bank.b.put(False,rg_ywriadd,?);
    endrule

    rule rl_y3bankoutputput (rg_ywricase == 2);
        rg_ywriadd <= rg_ywriadd + 1;
        y3bank.b.put(False,rg_ywriadd,?);
    endrule

    rule rl_y4bankoutput (rg_ywricase == 3);
        rg_ywriadd <= rg_ywriadd + 1;
        y4bank.b.put(False,rg_ywriadd,?);
    endrule

//Methods
// X wrire methods
    method Action xwritestat (Bit#(1) stat);
        rg_xwritestat <= stat;
    endmethod

    
    method ActionValue#(Bit#(1)) xwritestatreturn;
        return rg_xwritestat;
    endmethod


    method Action writex (Bit#(32) x) if ((rg_xwriadd<16) && (rg_xwritestat == 1));
        rg_xwriadd <= rg_xwriadd + 1;
        if(rg_xwricase == 0)
            x1bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 1)
            x2bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 2)
            x3bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 3)
            x4bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 4)
            x5bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 5)
            x6bank.a.put(True,rg_xwriadd,x);
        if(rg_xwricase == 6)
            x7bank.a.put(True,rg_xwriadd,x);
    endmethod

//Y read methods

    method ActionValue#(Bit#(32)) y1bankoutputread if((rg_ywriadd > 1) && (rg_ywricase == 0));
        let x = y1bank.b.read;
        return x;
    endmethod


    method ActionValue#(Bit#(32)) y2bankoutputread if((rg_ywriadd > 1) && (rg_ywricase == 1));
        let x = y2bank.b.read;
        return x;
    endmethod


    method ActionValue#(Bit#(32)) y3bankoutputread if((rg_ywriadd > 1) && (rg_ywricase == 2));
        let x = y3bank.b.read;
        return x;
    endmethod

    
    method ActionValue#(Bit#(32)) y4bankoutputread if((rg_ywriadd > 1) && (rg_ywricase == 3));
        let x = y4bank.b.read;
        return x;
    endmethod
endmodule

endpackage
