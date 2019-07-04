package TestModule;

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
    rule rl_conout_end (counter2==13);
            conout <= 0;
            counter <= 0;
            counter2 <= 0;
    endrule

    rule rl_xinput1 (con == 1 && weigh == 0);// && fifox1.notEmpty); //conv same as convs in PEArray
        let x = fifox1.first;
        pearr.xinput1(x);
        fifox1.deq;
        $display("%t rl_xinput1 fired",$time);
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
$display("%t rl_yinput1 fired",$time);

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
 $display("%t rl_winput1 fired w: %0d",$time, f);
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
$display("%t rl_youtput1 fired enq value: %0d",$time, pearr.youtput1);

    endrule
    rule rl_youtput2 (conout == 1 && weigh == 0);// && fifoy2.notFull);
$display("%t rl_youtput2 fired enq value: %0d",$time, pearr.youtput2);
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
$display("%t xfifoin1 fired",$time);

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
        $display("%t yfifoin1 fired",$time);
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
$display("%t yfifoout1 x = %0d",$time,r); 
        return r;

    endmethod

    method ActionValue #(Bit#(32)) yfifoout2 if (outfifo == 1);// && fifoy2.notEmpty);
        let t = fifoy2.first;
        fifoy2.deq;
        $display("%t yfifoout2 x = %0d",$time,t); 
        return t;
    endmethod

    method ActionValue #(Bit#(32)) yfifoout3 if (outfifo == 1);// && fifoy3.notEmpty);
        let u = fifoy3.first;
        fifoy3.deq;
$display("%t yfifoout3 x = %0d",$time,u); 
        return u;
    endmethod

    method ActionValue #(Bit#(32)) yfifoout4 if (outfifo == 1);// && fifoy4.notEmpty);
        let o = fifoy4.first;
        fifoy4.deq;
$display("%t yfifoout4 x = %0d",$time,o); 
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

(* synthesize *)
module mkTop (Empty); 

    Ifc_PEFifo fif <- mkPEFifo;
    Stmt test=
    (seq
            action
                $display("%t blah", $time);
            endaction

            action
                fif.pearray.weighttran(1);
                fif.tr_weightfifo(1);
                fif.tr_weigh(1);
                $display("%t Weight Transfer to Fifo", $time);
            endaction

            action
                fif.wfifoin1(1);
                fif.wfifoin2(1);
                fif.wfifoin3(1);
                fif.wfifoin4(1);
                $display("%t Weight transfer to PEArray",$time);
            endaction

            action
                $display ("%t Weight transfer 1", $time);
            endaction

            action
                $display ("%t Weight transfer 2", $time);
            endaction
            
            action
                $display ("%t Weight transfer 3", $time);
            endaction
	    action
                $display ("%t Weight transfer 4", $time);
            endaction
            action
                fif.pearray.weighttran(0);
                fif.pearray.convs(1);
                fif.tr_weightfifo(0);
                fif.tr_weigh(0);
                fif.tr_inputfifo(1);
                fif.tr_outfifo(1);
                fif.tr_conv(1);
            $display ("%t Weight transfer ended", $time);
            endaction

            action    
                fif.xfifoin1(1);
                fif.xfifoin2(1);
                fif.xfifoin3(1);
                fif.xfifoin4(1);
                fif.xfifoin5(1);
                fif.xfifoin6(1);
                fif.xfifoin7(1);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0); 
                $display("%t Conv fifo started",$time);
            endaction

            action
                fif.xfifoin1(2);
                fif.xfifoin2(2);
                fif.xfifoin3(2);
                fif.xfifoin4(2);
                fif.xfifoin5(2);
                fif.xfifoin6(2);
                fif.xfifoin7(2);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
               $display("%t Conv cycle 1",$time);
            endaction

            action
                fif.xfifoin1(3);
                fif.xfifoin2(3);
                fif.xfifoin3(3);
                fif.xfifoin4(3);
                fif.xfifoin5(3);
                fif.xfifoin6(3);
                fif.xfifoin7(3);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
                $display("%t Conv cycle 2",$time);
            endaction
                      
            action
                fif.xfifoin1(4);
                fif.xfifoin2(4);
                fif.xfifoin3(4);
                fif.xfifoin4(4);
                fif.xfifoin5(4);
                fif.xfifoin6(4);
                fif.xfifoin7(4);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
                let x = fif.tr_convout; //conout == 0 here
                $display("%t Conv cycle 3 %0d",$time,x); 
            endaction

            action
                fif.xfifoin1(5);
                fif.xfifoin2(5);
                fif.xfifoin3(5);
                fif.xfifoin4(5);
                fif.xfifoin5(5);
                fif.xfifoin6(5);
                fif.xfifoin7(5);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
                let x = fif.tr_convout; 
                $display("%t Conv cycle 4 %0d",$time,x); 
                // conout == 1 here
            endaction
            action
                fif.xfifoin1(6);
                fif.xfifoin2(6);
                fif.xfifoin3(6);
                fif.xfifoin4(6);
                fif.xfifoin5(6);
                fif.xfifoin6(6);
                fif.xfifoin7(6);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a); 
            endaction
 action
                fif.xfifoin1(7);
                fif.xfifoin2(7);
                fif.xfifoin3(7);
                fif.xfifoin4(7);
                fif.xfifoin5(7);
                fif.xfifoin6(7);
                fif.xfifoin7(7);
                fif.yfifoin1(0);
                fif.yfifoin2(0);
                fif.yfifoin3(0);
                fif.yfifoin4(0);
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a); 
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction

            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
            action
                let x = fif.yfifoout1;
                $display("%t y11 = %0d", $time, x); 
                let y = fif.yfifoout2;
                $display("%t y12 = %0d", $time, y);
                let z = fif.yfifoout3;
                $display("%t y13 = %0d", $time, z);
                let a = fif.yfifoout4;
                $display("%t y14 = %0d", $time, a);
            endaction
        endseq
    );
    mkAutoFSM(test);
endmodule

endpackage	 
