package TestModule;

import BRAMCore ::*;

interface Ifc_SysArray#(numeric type opsize);
    method Bit#(1) convstatus ();
    method  Bit#(1) weighttfend ();
    method Action weighttfstart (Bit#(1) x);
    method Bit#(1) youtput2procreturn ();
    method Bit#(1) wBRAM_Loaded_Return ();
     method Action wBRAM_Loaded (Bit#(1) status);
     method Bit#(1) xBRAM_Loaded_Return ();
    method Action xBRAM_Loaded (Bit#(1) status);
    method ActionValue#(Bit#(opsize)) yread();
    method Action yreadstat (Bit#(1) stat);
    method  Bit#(1) yreadstatreturn ();
    method  Bit#(1) wwristatreturn ();
    method Action  wwritestat (Bit#(1) stat);
    method Action writew (Bit#(opsize) w);
    method Action writex (Bit#(opsize) x);
    method ActionValue#(Bit#(1)) xwritestatreturn;
    method Action xwritestat (Bit#(1) stat);
    method Bit#(opsize) convpefifo;
    method Action reset (Bit#(1) r);
endinterface

interface Ifc_PEArray#(numeric type opsize);
    method Action xinput1 (Bit#(opsize) x);
    method Action xinput2 (Bit#(opsize) x);
    method Action xinput3 (Bit#(opsize) x);
    method Action xinput4 (Bit#(opsize) x);
    method Action xinput5 (Bit#(opsize) x);
    method Action xinput6 (Bit#(opsize) x);
    method Action xinput7 (Bit#(opsize) x);
    
    method Action yinput1 (Bit#(opsize) x);
    method Action yinput2 (Bit#(opsize) x);
    method Action yinput3 (Bit#(opsize) x);
    method Action yinput4 (Bit#(opsize) x);
    method Action winput1 (Bit#(opsize) x); 
    method Action winput2 (Bit#(opsize) x); 
    method Action winput3 (Bit#(opsize) x);
    method Action winput4 (Bit#(opsize) x); 

    method Bit#(opsize) youtput1();
    method Bit#(opsize) youtput2();
    method Bit#(opsize) youtput3();
    method Bit#(opsize) youtput4();

    method Action weighttran (Bit#(opsize) x);
    method Action convs (Bit#(opsize) x);
    method Action reset (Bit#(1) r);
endinterface

interface Ifc_PEFifo#(numeric type opsize);
    method Action xfifoin1 (Bit#(opsize) x);
    method Action xfifoin2 (Bit#(opsize) x);
    method Action xfifoin3 (Bit#(opsize) x);
    method Action xfifoin4 (Bit#(opsize) x);
    method Action xfifoin5 (Bit#(opsize) x);
    method Action xfifoin6 (Bit#(opsize) x);
    method Action xfifoin7 (Bit#(opsize) x);

    method Action yfifoin1 (Bit#(opsize) x);
    method Action yfifoin2 (Bit#(opsize) x);
    method Action yfifoin3 (Bit#(opsize) x);
    method Action yfifoin4 (Bit#(opsize) x);
    
    method ActionValue #(Bit#(opsize)) yfifoout1;
    method ActionValue #(Bit#(opsize)) yfifoout2;
    method ActionValue #(Bit#(opsize)) yfifoout3;
    method ActionValue #(Bit#(opsize)) yfifoout4;
   
    method Action wfifoin1 (Bit#(opsize) x);
    method Action wfifoin2 (Bit#(opsize) x);
    method Action wfifoin3 (Bit#(opsize) x);
    method Action wfifoin4 (Bit#(opsize) x);

    method Action tr_inputfifo (Bit#(opsize) x);
    method Action tr_weightdeq (Bit#(opsize) x);
    method Action tr_outfifo (Bit#(opsize) x);
    method Action tr_weightfifo (Bit#(opsize) x);
    method Action tr_weigh (Bit#(opsize) x);
    method Action tr_conv (Bit#(opsize) x);
    method Bit#(opsize) tr_convout ();
    method Action reset (Bit#(1) r);

    interface Ifc_PEArray#(opsize) pearray;
endinterface


interface Ifc_PE#(numeric type opsize);
    method Bit#(opsize) rightoutput();
    method Action upinput(Bit#(opsize) y);
    method Bit#(opsize) downoutput();
    method Action leftinput(Bit#(opsize) x);
    method Action weightinp (Bit#(opsize) w);
    method Bit#(opsize) weightoutput();
endinterface

module mkPE (Ifc_PE#(opsize));
    
    //Register Initialisation

    Reg#(Bit#(opsize)) rg_pixel <- mkReg(0);   
    Reg#(Bit#(opsize)) rg_weight <- mkReg(0);
    Reg#(Bit#(opsize)) rg_psumi <- mkReg(0);
    Wire#(Bit#(opsize)) wr_psumo <- mkDWire(0);


    rule rl_psum;
         wr_psumo  <= rg_psumi + rg_weight * rg_pixel;      
    endrule 

    //Weight setting Stage
    //weightoutput can only called one clock cycle after weightinp
 
    method Action weightinp (Bit#(opsize) w);
//$display("%t weightinp: %0d fired",$time,w);

        rg_weight <= w;
    endmethod
    method Bit#(opsize) weightoutput();
        return rg_weight;
    endmethod

    //Left right pixel input stage

    method Action leftinput (Bit#(opsize) x);
        rg_pixel <= x;
    endmethod
    method Bit#(opsize) rightoutput();
        return rg_pixel;
    endmethod

    //Diagnal input output
    method Action upinput (Bit#(opsize) y);
        rg_psumi <= y;
    endmethod
    method Bit#(opsize) downoutput();
        return wr_psumo;
    endmethod
endmodule

import StmtFSM ::*;
import Vector ::*;

module mkPEArray (Ifc_PEArray#(opsize)); 
 
    Vector#(4,Ifc_PE#(opsize)) col0 <- replicateM(mkPE);
    Vector#(4,Ifc_PE#(opsize)) col1 <- replicateM(mkPE);
    Vector#(4,Ifc_PE#(opsize)) col2 <- replicateM(mkPE);
    Vector#(4,Ifc_PE#(opsize)) col3 <- replicateM(mkPE);
    Vector#(4,Vector#(4,Ifc_PE#(opsize))) array = newVector;
    Reg#(Bit#(10)) rg_counterPE <- mkReg(0);
    array[0]=col0;
    array[1]=col1;
    array[2]=col2;
    array[3]=col3;

    Vector#(6,Reg#(Bit#(opsize))) delay <- replicateM(mkRegU);
        Reg#(Bit#(opsize)) weighttrans <- mkReg(0);
        Reg#(Bit#(opsize)) conv <- mkReg(0);

    rule rl_xconnect2 (weighttrans == 0 && conv == 1);
               let x = array[1][0].rightoutput;
               array[0][1].leftinput(x);
               rg_counterPE <= rg_counterPE + 1;
$display("%t: X inputcount: %0d input[1,1]: %0d",$time,rg_counterPE,x);
    endrule

    rule rl_xconnect3 (weighttrans == 0 && conv == 1);
               let x = array[2][0].rightoutput;
               array[1][1].leftinput(x);
               let y = array[1][1].rightoutput;
               array[0][2].leftinput(y);
//$display("%t xcon3 x:%0d array[1][1]: %0d",$time,x, array[1][1].rightoutput);
$display("%t: d array[0][2]: %0d",$time,y, array[0][2].rightoutput);
    endrule

    rule rl_xconnect4 (weighttrans == 0 && conv == 1);
               let x = array[3][0].rightoutput;
               array[2][1].leftinput(x);
               let y = array[2][1].rightoutput;
               array[1][2].leftinput(y);
               let z = array[1][2].rightoutput;
               array[0][3].leftinput(z);
//$display("%t xcon4 x:%0d array[2][1]: %0d",$time,x, array[2][1].rightoutput);
//$display("%t xcon4 y:%0d array[1][2]: %0d",$time,y, array[1][2].rightoutput);
//$display("%t xcon4 z:%0d array[0][3]: %0d",$time,z, array[0][3].rightoutput);
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
//$display("%t wcon x:%0d array[1][0]: %0d",$time,x, array[1][0].weightoutput);

        let y = array[1][0].weightoutput;
                array[2][0].weightinp(y);
//$display("%t wcon y:%0d array[2][0]: %0d",$time,y, array[2][0].weightoutput);


                let z = array[2][0].weightoutput;
                array[3][0].weightinp(z); 
//$display("%t wcon z:%0d array[3][0]: %0d",$time,z, array[3][0].weightoutput);


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
//$display("%t: Y inputcount: %d input is: %d",$time,rg_counterPE,x);
//$display("%t ycon1 y:%0d array[0][2]: %0d",$time,y, array[0][2].downoutput); 
//$display("%t ycon1 z:%0d array[0][3]: %0d",$time,z, array[0][3].downoutput); 
    endrule

    rule rl_yconnect2 (weighttrans == 0 && conv == 1);
        let x = array[1][0].downoutput;
                array[1][1].upinput(x); 
        let y = array[1][1].downoutput;
                array[1][2].upinput(y);
        let z = array[1][2].downoutput;
                array[1][3].upinput(z); 
//$display("%t ycon2 x:%0d array[1][1]: %0d",$time,x, array[1][1].downoutput);
//$display("%t ycon2 y:%0d array[1][2]: %0d",$time,y, array[1][2].downoutput); 
//$display("%t ycon2 z:%0d array[1][3]: %0d",$time,z, array[1][3].downoutput); 
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
/*
    rule rl_Debugger(weighttrans == 0 && conv == 1);
       rg_counterPE <= rg_counterPE + 1;
        $display("%t: Y outputcount: %d is %d",$time,rg_counterPE,array[0][3].downoutput);
    endrule
*/
    method Action weighttran (Bit#(opsize) x);
        if (x == 1) weighttrans <= 1;
        else weighttrans <= 0;
    endmethod
    
    method Action convs (Bit#(opsize) x);
        if (x == 1) conv <= 1;
        else conv <= 0;
    endmethod 

    method Action xinput1 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        //$display(" xinput1: %0d",$time, x);
        array[0][0].leftinput(x);
    endmethod
    method Action xinput2 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        //$display("%t xinput2: %0d",$time, x);
        array[1][0].leftinput(x);
    endmethod
    method Action xinput3 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        //$display("%t xinput3: %0d",$time, x);
        array[2][0].leftinput(x);
    endmethod
    method Action xinput4 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        array[3][0].leftinput(x);
    endmethod
    method Action xinput5 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        delay[0] <= x;
    endmethod
    method Action xinput6 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        delay[1] <= x;
    endmethod
    method Action xinput7 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        delay[3] <= x;
    endmethod
    method Action yinput1 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        array[0][0].upinput(x);
    endmethod
    method Action yinput2 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        array[1][0].upinput(x);
    endmethod
    method Action yinput3 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        array[2][0].upinput(x);
    endmethod
    method Action yinput4 (Bit#(opsize) x) if (weighttrans == 0 && conv == 1);
        array[3][0].upinput(x);
    endmethod

    method Bit#(opsize) youtput1 if (weighttrans == 0 && conv == 1);
        let x = array[0][3].downoutput;
        return x;
    endmethod
    method Bit#(opsize) youtput2 if (weighttrans == 0 && conv == 1);
        let x = array[1][3].downoutput;
        return x;
    endmethod
    method Bit#(opsize) youtput3 if (weighttrans == 0 && conv == 1);
        let x = array[2][3].downoutput;
        return x;
    endmethod
    method Bit#(opsize) youtput4 if (weighttrans == 0 && conv == 1);
        let x = array[3][3].downoutput;
        return x;
    endmethod
    method Action winput1 (Bit#(opsize) x) if (weighttrans == 1 && conv == 0);
        array[0][0].weightinp(x);
    endmethod
    method Action winput2 (Bit#(opsize) x) if (weighttrans == 1 && conv == 0);
        array[0][1].weightinp(x);
    endmethod
    method Action winput3 (Bit#(opsize) x) if (weighttrans == 1 && conv == 0);
        array[0][2].weightinp(x);
    endmethod
    method Action winput4 (Bit#(opsize) x) if (weighttrans == 1 && conv == 0);
        array[0][3].weightinp(x);
    endmethod
    method Action reset (Bit#(1) r);
if(r == 1)begin
 	weighttrans <= 0;
	conv <= 0;
 	rg_counterPE <= 0;
end
    endmethod

endmodule

import FIFOF ::*;
module mkPEFifo (Ifc_PEFifo#(opsize));

    Ifc_PEArray#(opsize) pearr <- mkPEArray;
   
    Reg#(Bit#(10)) rg_inputcounter <- mkReg(0);
    Reg#(Bit#(10)) rg_outputcounter <- mkReg(0);
    Reg #(Bit#(opsize)) inputfifo <- mkReg(0);
    Reg #(Bit#(opsize)) weightfifo <- mkReg(0);
    Reg #(Bit#(opsize)) outfifo <- mkReg(0);
    Reg #(Bit#(opsize)) conout <- mkReg(0);
    Reg #(Bit#(opsize)) con <- mkReg(0);
    Reg#(Bit#(3)) rg_cyclecount <- mkReg(0);
    Reg #(Bit#(opsize)) weigh <- mkReg(0);
    Reg #(Bit#(opsize)) counter <- mkReg(0); //for initialising conout
    Reg #(Bit#(opsize)) counter2 <- mkReg(0);
    Reg#(Bit#(opsize)) weightdeq <- mkReg(0);
    Reg#(Bit#(1)) rg_deqxfifo <- mkReg(0);
    Reg#(Bit#(5)) rg_deqxfifocounter <- mkReg(0);
    Reg#(Bit#(1)) rg_deqyfifo <- mkReg(0);
    Reg#(Bit#(5)) rg_deqyfifocounter <- mkReg(0);

    FIFOF #(Bit#(opsize)) fifox1 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox2 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox3 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox4 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox5 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox6 <- mkSizedFIFOF(32);
    FIFOF #(Bit#(opsize)) fifox7 <- mkSizedFIFOF(32);
 
    FIFOF #(Bit#(opsize)) fifoyin1 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoyin2 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoyin3 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoyin4 <- mkSizedFIFOF(14);   

    FIFOF #(Bit#(opsize)) fifow1 <- mkSizedFIFOF(5);
    FIFOF #(Bit#(opsize)) fifow2 <- mkSizedFIFOF(5);
    FIFOF #(Bit#(opsize)) fifow3 <- mkSizedFIFOF(5);
    FIFOF #(Bit#(opsize)) fifow4 <- mkSizedFIFOF(5);
    
    FIFOF #(Bit#(opsize)) fifoy1 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoy2 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoy3 <- mkSizedFIFOF(14);
    FIFOF #(Bit#(opsize)) fifoy4 <- mkSizedFIFOF(14);

    rule rl_counter (con == 1 && weigh == 0);
        counter <= counter + 1;
        //$display("%t: counter1: %d ",$time,counter);
    endrule
    rule rl_counter2 ((conout == 1) && (counter2<12));
        counter2 <= counter2 +1;
        //$display("%t: counter2: %d",$time,counter2);
    endrule
   
    rule rl_conout_start (counter == 3);
        conout <= 1;
        //$display("%t: conout 1 next cycle",$time);
    endrule

    rule rl_conout_end (counter2 == 12);
    //$display("%t: Counout 0 next cycle ",$time);
    rg_cyclecount <= rg_cyclecount + 1;
	conout <= 0;
        counter <= 0;
        counter2 <= 0;
	con <= 0;
	pearr.convs(0);
    endrule

    rule rl_deqend (rg_deqxfifocounter == 11);
        rg_deqxfifocounter <= 0;
        rg_deqxfifo <= 0;
        $display("Rule fired");
    endrule

    rule rl_deqyend (rg_deqxfifo == 1 && rg_deqxfifocounter == 1);
        rg_deqxfifocounter <= 0;
        rg_deqxfifo <= 0;
    endrule

    rule rl_deqyfifo (rg_deqxfifo == 1);
        rg_deqxfifocounter <= rg_deqxfifocounter + 1;
        //$display("This rule is firing! counter: %d status: %d",rg_deqxfifocounter,rg_deqxfifo);
        fifoy2.clear;
        //fifoy1.deq;
        fifoy3.clear;
        fifoy4.clear;
    endrule

    rule rl_xinput1 (con == 1 && weigh == 0 && counter <13);// && fifox1.notEmpty); //conv same as convs in PEArray
        let x = fifox1.first;
        pearr.xinput1(x);
        fifox1.deq;
       // $display("%t: rl_xinput1 value: %0d",$time,x);
    endrule
    rule rl_xinput2 (con == 1 && weigh == 0 && counter <13);// && fifox2.notEmpty); 
        let x = fifox2.first;
        pearr.xinput2(x);
       //  $display("%t rl_xinput1 fired",$time);
        fifox2.deq;
    endrule
    rule rl_xinput3 (con == 1 && weigh == 0 && counter <13);// && fifox3.notEmpty); 
        let x = fifox3.first;
        pearr.xinput3(x);
        fifox3.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput4 (con == 1 && weigh == 0 && counter <13);// && fifox4.notEmpty); 
        let x = fifox4.first;
        pearr.xinput4(x);
        fifox4.deq;
 //$display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput5 (con == 1 && weigh == 0 && counter <13);// && fifox5.notEmpty); 
        let x = fifox5.first;
        pearr.xinput5(x);
        fifox5.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
rule rl_xinput6 (con == 1 && weigh == 0 && counter <13);// && fifox6.notEmpty); 
        let x = fifox6.first;
        pearr.xinput6(x);
        fifox6.deq;
// $display("%t rl_xinput1 fired",$time);
    endrule
    rule rl_xinput7 (con == 1 && weigh == 0 && counter <13);// && fifox7.notEmpty); 
        let x = fifox7.first;
        pearr.xinput7(x);
        fifox7.deq;
  //       $display("%t rl_xinput1 fired",$time);
    endrule
    
    rule rl_yinput1 (con == 1 && weigh == 0 && counter <13 );//&& fifoyin1.notEmpty); //conv same as convs in PEArray
        let x = fifoyin1.first;
        pearr.yinput1(x);
        fifoyin1.deq;
        rg_inputcounter <= rg_inputcounter + 1;
       // $display("%t rl_yinput1 counter:%0d value: %0d",$time,rg_inputcounter,x);
    endrule
    rule rl_yinput2 (con == 1 && weigh == 0 && counter <13);// && fifoyin2.notEmpty); 
        let x = fifoyin2.first;
        pearr.yinput2(x);
        fifoyin2.deq;
    endrule
    rule rl_yinput3 (con == 1 && weigh == 0 && counter <13);// && fifoyin3.notEmpty); 
        let x = fifoyin3.first;
        pearr.yinput3(x);
        fifoyin3.deq;
    endrule
    rule rl_yinput4 (con == 1 && weigh == 0 && counter <13);// && fifoyin4.notEmpty); 
        let x = fifoyin4.first;
        pearr.yinput4(x);
        fifoyin4.deq;
    endrule
    
    rule rl_winput1 (weightdeq == 1 && con == 0);// && fifow1.notEmpty);
        let f = fifow1.first;
        pearr.winput1(f);
        fifow1.deq;
// $display("%t rl_winput1 fired w: %0d",$time, f);
    endrule
    rule rl_winput2 (weightdeq == 1 && con == 0);// && fifow2.notEmpty);
        let m = fifow2.first;
        pearr.winput2(m);
        fifow2.deq;
// $display("%t rl_winput2 fired",$time);
    endrule
    rule rl_winput3 (weightdeq == 1 && con == 0);// && fifow3.notEmpty);
        let k = fifow3.first;
        pearr.winput3(k);
        fifow3.deq; 
  //       $display("%t rl_winput3 fired",$time);
    endrule
    rule rl_winput4 (weightdeq == 1 && con == 0);// && fifow4.notEmpty);
        let l = fifow4.first;
        pearr.winput4(l);
        fifow4.deq;
 //$display("%t rl_winput4 fired",$time);
    endrule

    rule rl_youtput1 (conout == 1 && weigh == 0);// && fifoy1.notFull);
        fifoy1.enq(pearr.youtput1);
        rg_outputcounter <= rg_outputcounter + 1;
  // $display("%t rl_youtput1counter = %0d fired enq value: %0d",$time,rg_outputcounter,pearr.youtput1);

    endrule
    rule rl_youtput2 (conout == 1 && weigh == 0);// && fifoy2.notFull);
//$display("%t rl_youtput2 fired enq value: %0d",$time, pearr.youtput2);
    fifoy2.enq(pearr.youtput2);
    endrule
    rule rl_youtput3 (conout == 1 && weigh == 0);// && fifoy3.notFull);
        fifoy3.enq(pearr.youtput3);
    endrule
    rule rl_youtput4 (conout == 1 && weigh == 0);// && fifoy4.notFull);
        fifoy4.enq(pearr.youtput4);
    endrule
 
    method Action xfifoin1 (Bit#(opsize) x) if (inputfifo == 1);// && fifox1.notFull);
        fifox1.enq(x);
//$display("%t xfifoin1 fired",$time);
    endmethod
    method Action xfifoin2 (Bit#(opsize) x) if (inputfifo == 1);// && fifox2.notFull);
        fifox2.enq(x);
    endmethod
    method Action xfifoin3 (Bit#(opsize) x) if (inputfifo == 1);// && fifox3.notFull);
        fifox3.enq(x);
    endmethod
    method Action xfifoin4 (Bit#(opsize) x) if (inputfifo == 1);// && fifox4.notFull);
        fifox4.enq(x);
    endmethod
    method Action xfifoin5 (Bit#(opsize) x) if (inputfifo == 1);// && fifox5.notFull);
        fifox5.enq(x);
    endmethod
    method Action xfifoin6 (Bit#(opsize) x) if (inputfifo == 1);// && fifox6.notFull);
        fifox6.enq(x);
    endmethod
    method Action xfifoin7 (Bit#(opsize) x) if (inputfifo == 1);// && fifox7.notFull);
        fifox7.enq(x);
    endmethod

    method Action wfifoin1 (Bit#(opsize) x) if (weightfifo == 1);// && fifow1.notFull);
        fifow1.enq(x);
    endmethod
    method Action wfifoin2 (Bit#(opsize) x) if (weightfifo == 1);// && fifow2.notFull);
        fifow2.enq(x);
    endmethod
    method Action wfifoin3 (Bit#(opsize) x) if (weightfifo == 1);// && fifow3.notFull);
        fifow3.enq(x);
    endmethod
    method Action wfifoin4 (Bit#(opsize) x) if (weightfifo == 1);// && fifow4.notFull);
        fifow4.enq(x);
    endmethod

    method Action yfifoin1 (Bit#(opsize) x) if (inputfifo == 1);// && fifoyin1.notFull);
   //     $display("%t yfifoin1 fired",$time);
        fifoyin1.enq(x);
    endmethod
    method Action yfifoin2 (Bit#(opsize) x) if (inputfifo == 1);// && fifoyin2.notFull);
        fifoyin2.enq(x);
    endmethod
    method Action yfifoin3 (Bit#(opsize) x) if (inputfifo == 1);// && fifoyin3.notFull);
        fifoyin3.enq(x);
    endmethod
    method Action yfifoin4 (Bit#(opsize) x) if (inputfifo == 1);// && fifoyin4.notFull);
        fifoyin4.enq(x);
    endmethod
 
    method ActionValue #(Bit#(opsize)) yfifoout1 if (outfifo == 1);// && fifoy1.notEmpty);
        let r = fifoy1.first;
        fifoy1.deq;
//$display("%t yfifoout1 x = %0d",$time,r); 
        return r;

    endmethod

    method ActionValue #(Bit#(opsize)) yfifoout2 if (outfifo == 1);// && fifoy2.notEmpty);
        let t = fifoy2.first;
        fifoy2.deq;
     //   $display("%t yfifoout2 x = %0d",$time,t); 
        return t;
    endmethod

    method ActionValue #(Bit#(opsize)) yfifoout3 if (outfifo == 1);// && fifoy3.notEmpty);
        let u = fifoy3.first;
        fifoy3.deq;
//$display("%t yfifoout3 x = %0d",$time,u); 
        return u;
    endmethod

    method ActionValue #(Bit#(opsize)) yfifoout4 if (outfifo == 1);// && fifoy4.notEmpty);
        let o = fifoy4.first;
        fifoy4.deq;
//$display("%t yfifoout4 x = %0d",$time,o); 
        return o;
    endmethod

    method Action tr_weigh (Bit#(opsize) x);
        if (x == 1) weigh <= 1;
        else weigh <= 0;
    endmethod

    method Action tr_weightdeq (Bit#(opsize) x);
        if (x == 1) weightdeq <= 1;
        else weightdeq <= 0;
    endmethod
    
    method Action tr_conv (Bit#(opsize) x);
        if (x == 1)begin 
            con <= 1;
            
        end
        else con <= 0;
    endmethod

    method Bit#(opsize) tr_convout();
        return conout;
    endmethod

    method Action tr_inputfifo (Bit#(opsize) x);
        if (x == 1) inputfifo <= 1;
        else inputfifo <= 0;
    endmethod
    
    method Action tr_outfifo (Bit#(opsize) x);
        if (x == 1) outfifo <= 1;
        else outfifo <= 0;
    endmethod

    method Action tr_weightfifo (Bit#(opsize) x);
        if (x == 1) weightfifo <= 1;
        else weightfifo <= 0;
    endmethod

    method Action reset (Bit#(1) r);
if(r == 1)begin
 rg_inputcounter <= 0;
rg_outputcounter <= 0;
 inputfifo <= 0;
 weightfifo <= 0;
 outfifo <= 0;
 conout <= 0;
 con <= 0;
rg_cyclecount <= 0;
 weigh <= 0;
 counter <= 0; //for initialising conout
counter2 <= 0;
 weightdeq <= 0;
pearr.reset(1);
rg_deqxfifo <= 1;
rg_deqxfifocounter <= 0;
rg_deqyfifo <= 1;
rg_deqyfifocounter <= 0;
end
    endmethod
    interface pearray = pearr;
endmodule

/*

interface Ifc_PEFifo;
    method Action xfifoin1 (Bit#(opsize) x);
    method Action xfifoin2 (Bit#(opsize) x);
    method Action xfifoin3 (Bit#(opsize) x);
    method Action xfifoin4 (Bit#(opsize) x);
    method Action xfifoin5 (Bit#(opsize) x);
    method Action xfifoin6 (Bit#(opsize) x);
    method Action xfifoin7 (Bit#(opsize) x);

    method Action yfifoin1 (Bit#(opsize) x);
    method Action yfifoin2 (Bit#(opsize) x);
    method Action yfifoin3 (Bit#(opsize) x);
    method Action yfifoin4 (Bit#(opsize) x);
    
    method ActionValue #(Bit#(opsize)) yfifoout1;
    method ActionValue #(Bit#(opsize)) yfifoout2;
    method ActionValue #(Bit#(opsize)) yfifoout3;
    method ActionValue #(Bit#(opsize)) yfifoout4;
   
    method Action wfifoin1 (Bit#(opsize) x);
    method Action wfifoin2 (Bit#(opsize) x);
    method Action wfifoin3 (Bit#(opsize) x);
    method Action wfifoin4 (Bit#(opsize) x);

    method Action tr_inputfifo (Bit#(opsize) x); Activates X and Y fifosin
    method Action tr_outfifo (Bit#(opsize) x); Activates deq of Y fifoout 
    method Action tr_weightfifo (Bit#(opsize) x); Enq W fifo
    method Action tr_weigh (Bit#(opsize) x); Activates weight tranfer
    method Action tr_conv (Bit#(opsize) x); Activates deq of input fifo
    interface Ifc_PEArray pearray;
endinterface

*/


module mkSysArray (Ifc_SysArray#(opsize));


    Ifc_PEFifo#(opsize) pefifo <- mkPEFifo;


    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x1bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x2bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x3bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x4bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x5bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x6bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) x7bank <- mkBRAMCore2(32,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(opsize)) y1bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(opsize)) y2bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(opsize)) y3bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(7), Bit#(opsize)) y4bank <- mkBRAMCore2(128,True);
    BRAM_DUAL_PORT#(Bit#(5), Bit#(opsize)) wbank <- mkBRAMCore2(32,False);
    
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


    method Action writex (Bit#(opsize) x) if ((rg_xwriadd<16) && (rg_xwritestat == 1));
        rg_xwriadd <= rg_xwriadd + 1;
        if(rg_xwricase == 0)
            x1bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 1 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 1)
            x2bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 2 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 2)
            x3bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 3 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 3)
            x4bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 4 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 4)
            x5bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 5 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 5)
            x6bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 6 at address %d is %d",$time,rg_xwriadd,x);
        if(rg_xwricase == 6)
            x7bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 7 at address %d is %d",$time,rg_xwriadd,x);
    endmethod

        rule rl_xwritestatus ((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase != 6));
        rg_xwriadd <= 0;
        rg_xwricase <= rg_xwricase +1;
    endrule


    rule rl_xwriteend((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase == 6));
        rg_xwriadd <= 0;
        rg_xwricase <= 0;
        rg_xwritestat <= 0;
        $display("Xbanks have loaded");
    endrule
*/
   

//BRAM W write
    Reg#(Bit#(1)) rg_wwritestat <- mkReg(0);
    Reg#(Bit#(5)) rg_wwriadd <- mkReg(0);

/*
    method Action writew (Bit#(opsize) w) if ((rg_wwriadd<16) && (rg_wwritestat == 1));
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

    Reg#(Bit#(1)) rg_yreadstat <- mkReg(0);
    Reg#(Bit#(2)) rg_yreadcase <- mkReg(0);

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

    method Action yreadstat (Bit#(1) stat) if(rg_youtput2proc == 1);
        rg_yreadstat <= stat;
        if(stat == 0)
            rg_youtput2proc <= 0;
    endmethod

    method yread (Bit#(opsize));
        return wr_youtput;
    endmethod

*/

//Signals from Processor

    Reg#(Bit#(1)) rg_XBRAMloaded <- mkReg(0);
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

    rule rl_weight_tf_fifo_end ((rg_WBRAMloaded == 1) && (rg_wfifoadd == 17));
        rg_WBRAMloaded <= 0;
        rg_wfifoadd <= 0;
        rg_wfifoloaded <= 1;
    endrule

*/


//XInput Tranfer to Fifos

    Reg#(Bit#(5)) rg_xfifoadd <- mkReg(0);
    Reg#(Bit#(1)) rg_xfifosloaded <- mkReg(0);
    Reg#(Bit#(2)) rg_xfifocase <- mkReg(0);
    Reg#(Bit#(8)) rg_xreadfinish <- mkReg(0);
/*
    
    rule rl_x_tf_fifo1 ((rg_XBRAM_loaded == 1) && (xfifoadd<13) && (rg_xfifocase == 0));
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

    rule rl_x_tf_fifo2 ((rg_XBRAM_loaded == 1) && (xfifoadd<14) && (rg_xfifocase == 1));
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

    rule rl_x_tf_fifo3 ((rg_XBRAM_loaded == 1) && (xfifoadd<15) && (rg_xfifocase == 2));
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

    rule rl_x_tf_fifo4 ((rg_XBRAM_loaded == 1) && (xfifoadd<16) && (rg_xfifocase == 3));
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

    rule rl_x_tf_end1 ((rg_XBRAM_loaded == 1) && (xfifoadd == 13) && (rg_xfifocase == 0));
        rg_xfifocase <= 1;
        rg_xfifoadd <= 1;
        rg_xfifosloaded <= 1;
        //$display("%t: This rule is Flawed",$time);

    endrule

    rule rl_x_tf_end2 ((rg_XBRAM_loaded == 1) && (xfifoadd == 14) && (rg_xfifocase == 1));
        rg_xfifocase <= 2;
        rg_xfifoadd <= 2;
        rg_xfifosloaded <= 1;
        //$display("This rule fired");
    endrule
    rule rl_x_tf_end3 ((rg_XBRAM_loaded == 1) && (xfifoadd == 15) && (rg_xfifocase == 2));
        rg_xfifocase <= 3;
        rg_xfifoadd <= 3;
        rg_xfifosloaded <= 1;
    endrule
    rule rl_x_tf_end4 ((rg_XBRAM_loaded == 1) && (xfifoadd == 16) && (rg_xfifocase == 3));
        rg_xfifocase <= 0;
        rg_xfifoadd <= 0;
        rg_xfifosloaded <= 0;
        rg_XBRAM_loaded <= 0;
    endrule


*/
    

//Y output Transfer Fifos

    Reg#(Bit#(3)) rg_cyclecount <- mkReg(0);
    Reg#(Bit#(7)) rg_ywriteadd <- mkReg(0);
    Reg#(Bit#(3)) rg_ywritecase <- mkReg(0);
    Reg#(Bit#(1)) rg_youtput2proc <- mkReg(0);
    
/*

    rule rl_ywrite ((rg_ywriteadd < 52) && (rg_cyclecount == 4));
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

    rule rl_ywriteend1 ((rg_ywriteadd == 13) && (rg_ywritecase != 4));
        rg_cyclecount <= 0;
        rg_ywritecase <= rg_ywritecase +1;
    endrule

    rule rl_ywriteend2 ((rg_ywriteadd == 26) && (rg_ywritecase != 4));
        rg_cyclecount <= 0;
        rg_ywritecase <= rg_ywritecase +1;
    endrule

    rule rl_ywriteend3 ((rg_ywriteadd == 39) && (rg_ywritecase != 4));
        rg_cyclecount <= 0;
        rg_ywritecase <= rg_ywritecase +1;
    endrule

    rule rl_ywriteend4 ((rg_ywriteadd == 52) && (rg_ywritecase == 4));
        rg_cyclecount <= 0;
        rg_ywritecase <= 0;
        rg_ywriteadd <= 0;
        rg_youtput2proc <= 1;
    endrule

    method youtput2procreturn (Bit#(1));
        return rg_youtput2proc;
    endrule
*/

// Scheduling Everything
    Reg#(Bit#(5)) rg_yfifoadd <- mkReg(0);
    Reg#(Bit#(1)) rg_yfifosloaded <- mkReg(0);
    
    FIFOF #(Bit#(opsize)) fifoout <- mkFIFOF();


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
        $display("%t: The output %d of bank 1 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y1);
        let y2 <- pefifo.yfifoout2;
        $display("%t: The output %d of bank 2 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y2);
        let y3 <- pefifo.yfifoout3;
        $display("%t: The output %d of bank 3 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y3);
        let y4 <- pefifo.yfifoout4;
        $display("%t: The output %d of bank 4 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y4);
        pefifo.yfifoin1(y1);
        pefifo.yfifoin2(y2);
        pefifo.yfifoin3(y3);
        pefifo.yfifoin4(y4);
        rg_yfifoadd <= rg_yfifoadd + 1;
    endrule

*/


//Weight Scheduling

    Reg#(Bit#(3)) rg_weightcounter <- mkReg(0);
    Reg#(Bit#(3)) rg_weightcase <- mkReg(0);
    Reg#(Bit#(1)) rg_weighttf <- mkReg(0);
    Reg#(Bit#(1)) rg_weightloaded <- mkReg(0);

/*
    rule rl_weightstart ((rg_wfifosloaded == 1) && (rg_weighttf == 1));
        pefifo.tr_weightdeq(1);
        pefifo.pearray.weighttrans(1);
        rg_weightcounter <= rg_weightcounter + 1;
    endrule

    rule rl_weightend ((rg_wfifosloaded == 1) && (rg_weighttf == 1) && (rg_weightcounter == 1));
        pefifo.tr_weightdeq(0);
        rg_weightcounter <= rg_weightcounter + 1;
        rg_weighttf <= 0;
    endrule

    rule rl_weighend2 (rg_weightcounter > 1);
    if (rg_weightcounter == 5) begin
    rg_weightcounter <= 0;
    rg_weightloaded <= 1;
    pefifo.pearray.weighttrans(0);
    end
    else begin
    rg_weightcounter <= rg_weightcounter + 1;
    end
    endrule

    method Action Weighttfstart (Bit#(1) x) if(rg_wfifosloaded == 1);
        rg_weighttf <= x;
    endmethod

    method Weighttfend (Bit#(1));
        return rg_weightloaded;
    endmethod
*/

//Convolution start
    
    Reg#(Bit#(1)) rg_xinputstart <- mkReg(0);
    Reg#(Bit#(5)) rg_convcounter <- mkReg(0);
    Reg#(Bit#(1)) rg_convfinish <- mkReg(0);
    Reg#(Bit#(3)) rg_convcycle <- mkReg(0);
    Reg#(Bit#(8)) rg_convolutiononcount <- mkReg(0);
    Wire#(Bit#(opsize)) wr_dough <- mkWire();
    Wire#(Bit#(opsize)) wr_y <- mkWire();
    Wire#(Bit#(1)) wr_yreadcalled <- mkDWire(0);
    Reg#(Bit#(opsize)) rg_maincounter <- mkReg(0);
    Reg#(Bit#(1)) rg_maincounteractivate <- mkReg(0);
/*
    rule rl_inputstart ((rg_xfifosloaded == 1) && (rg_weightloaded == 1) && (rg_yfifosloaded == 1));
        pefifo.tr_conv(1);
        rg_xinputstart <= 1; 
    endrule

    rule rl_convcount ((rg_xinputstart == 1) && (rg_convcounter <16));
        rg_convcounter <= rg_convcounter +1;
    endrule

    rule rl_convend ((rg_convcounter == 16) && (rg_xinputstart == 1));
        rg_convcounter <= 0;
        rg_xinputstart <= 0;
        rg_weightloaded <= 0;
        if (rg_convcycle < 4 ) begin
            rg_convcycle <= rg_convcycle + 1;
        end
    endrule

    method convstatus (Bit#(1));
        return rg_xinputstart;
    endmethod
    
    */


    Reg#(Bit#(opsize)) rg_debugcounter <- mkReg(0);
//All Rules

    rule rl_xwritestatus ((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase != 6));
        rg_xwriadd <= 0;
        rg_xwricase <= rg_xwricase +1;
    endrule


    rule rl_xwriteend((rg_xwritestat == 1) && (rg_xwriadd == 16) && (rg_xwricase == 6));
        rg_xwriadd <= 0;
        rg_xwricase <= 0;
        rg_xwritestat <= 0;
        $display("%t: xbanks have loaded",$time);

    endrule
    rule rl_wwriend ((rg_wwritestat == 1) && (rg_wwriadd == 16));
        rg_wwritestat <= 0;
        rg_wwriadd <= 0;
        $display("%t: wbank has loaded",$time);
    endrule


    rule rl_yreadcase (rg_ywriteadd == 13);
        if (rg_yreadcase <3 ) begin
            rg_yreadcase <= rg_yreadcase + 1; 
            rg_ywriteadd <= 0;
        end
        else begin
            rg_yreadcase <= 0;
            rg_ywriteadd <= 0;
        end
    endrule

    rule rl_fifooutwrite1 (rg_ywriteadd < 13 && rg_yreadcase == 0  && rg_cyclecount == 4);
        rg_ywriteadd <= rg_ywriteadd + 1;
            let y <- pefifo.yfifoout1;
            fifoout.enq(y);
    endrule
    rule rl_fifooutwrite2 (rg_ywriteadd < 13 && rg_yreadcase == 1);
        rg_ywriteadd <= rg_ywriteadd + 1;
            let y <- pefifo.yfifoout2;
            fifoout.enq(y);      
    endrule
    rule rl_fifooutwrite3 (rg_ywriteadd < 13 && rg_yreadcase == 2);
        rg_ywriteadd <= rg_ywriteadd + 1;
            let y <- pefifo.yfifoout3;
            fifoout.enq(y); 
    endrule
    rule rl_fifooutwrite4 (rg_ywriteadd < 13 && rg_yreadcase == 3);
        rg_ywriteadd <= rg_ywriteadd + 1;
            let y <- pefifo.yfifoout4;
            fifoout.enq(y); 
    endrule





    rule rl_activatefifo;
        pefifo.tr_inputfifo(1);
        pefifo.tr_outfifo(1);
        pefifo.tr_weightfifo(1);

    endrule

   rule rl_weight_tf_fifo ((rg_WBRAMloaded == 1) && (rg_wfifoadd < 16));
        wbank.b.put(False,rg_wfifoadd,?);
        rg_wfifoadd <= rg_wfifoadd+1;
    endrule

    rule rl_weightbankread ((rg_wfifoadd>0) && (rg_WBRAMloaded == 1));
            if(rg_wfifoadd % 4 == 0)
            begin
            let wfifo4 = wbank.b.read;
            pefifo.wfifoin4(wfifo4);
            //$display("%t: Value in wFifo 4 is %d",$time,wfifo4);
            end
            if (rg_wfifoadd % 4 == 1)
            begin
            let wfifo1 = wbank.b.read;
            pefifo.wfifoin1(wfifo1);
            //$display("%t: Value in wFifo 1 is %d",$time,wfifo1);
            end
            if (rg_wfifoadd % 4 == 2)
            begin
            let wfifo2 = wbank.b.read;
            pefifo.wfifoin2(wfifo2);
            //$display("%t: Value in wFifo 2 is %d",$time,wfifo2);
            end
            if (rg_wfifoadd % 4 == 3)
            begin
            let wfifo3 = wbank.b.read;
            pefifo.wfifoin3(wfifo3);
            //$display("%t: Value in wFifo 3 is %d",$time,wfifo3);
            end
    endrule

    rule rl_weight_tf_fifo_end ((rg_WBRAMloaded == 1) && (rg_wfifoadd == 16));
        rg_WBRAMloaded <= 0;
        rg_wfifoadd <= 0;
        rg_wfifoloaded <= 1;
        $display("%t: W Fifos have been loaded",$time);
    endrule

    rule rl_x_tf_fifo1 ((rg_XBRAMloaded == 1) && (rg_xfifoadd<13) && (rg_xfifocase == 0));
        x1bank.b.put(False,rg_xfifoadd,?);
        x2bank.b.put(False,rg_xfifoadd,?);
        x3bank.b.put(False,rg_xfifoadd,?);
        x4bank.b.put(False,rg_xfifoadd,?);
        x5bank.b.put(False,rg_xfifoadd,?);
        x6bank.b.put(False,rg_xfifoadd,?);
        x7bank.b.put(False,rg_xfifoadd,?);
        rg_xfifoadd <= rg_xfifoadd+1;
    endrule

 /*   rule rl_debugger(rg_debugcounter < 800);
        $display("%t: rg_xfifoadd:%d rg_XBRAMloaded:%d xfifocase: %d xreadfinish: %d",$time,rg_xfifoadd,rg_XBRAMloaded,rg_xfifocase,rg_xreadfinish);
        rg_debugcounter <= rg_debugcounter + 1;
    endrule*/

    rule rl_x_tf_fiforead1((rg_xfifoadd>1) && (rg_XBRAMloaded == 1)  && (rg_xfifocase == 0) && (rg_xreadfinish<13) && (rg_xfifoadd<14));
        begin
            rg_xreadfinish <= rg_xreadfinish + 1;
            let xfifoin1 = x1bank.b.read;
            pefifo.xfifoin1(xfifoin1);
            $display("%t: The Value going in xFIFO 1 in cycle 1 is %d",$time,xfifoin1);
            let xfifoin2 = x2bank.b.read;
            pefifo.xfifoin2(xfifoin2); 
            //$display("%t: The Value going in xFIFO 2 is %d",$time,xfifoin2);           
            let xfifoin3 = x3bank.b.read;
            pefifo.xfifoin3(xfifoin3);
            //$display("%t: The Value going in xFIFO 3 is %d",$time,xfifoin3);
            let xfifoin4 = x4bank.b.read;
            pefifo.xfifoin4(xfifoin4);
            //$display("%t: The Value going in xFIFO 4 is %d",$time,xfifoin4);
            let xfifoin5 = x5bank.b.read;
            pefifo.xfifoin5(xfifoin5);
            //$display("%t: The Value going in xFIFO 5 is %d",$time,xfifoin5);
            let xfifoin6 = x6bank.b.read;
            pefifo.xfifoin6(xfifoin6);
            //$display("%t: The Value going in xFIFO 6 is %d ",$time,xfifoin6);
            let xfifoin7 = x7bank.b.read;
            pefifo.xfifoin7(xfifoin7);
            //$display("%t: The Value going in xFIFO 7 is %d",$time,xfifoin7);
        end
    endrule

    rule rl_x_tf_fifo2 ((rg_XBRAMloaded == 1) && (rg_xfifoadd<14) && (rg_xfifocase == 1));
        x1bank.b.put(False,rg_xfifoadd,?);
        x2bank.b.put(False,rg_xfifoadd,?);
        x3bank.b.put(False,rg_xfifoadd,?);
        x4bank.b.put(False,rg_xfifoadd,?);
        x5bank.b.put(False,rg_xfifoadd,?);
        x6bank.b.put(False,rg_xfifoadd,?);
        x7bank.b.put(False,rg_xfifoadd,?);
        rg_xfifoadd <= rg_xfifoadd+1;
      //  $display("When is this rule firing?");
    endrule

    rule rl_x_tf_fiforead2((rg_XBRAMloaded == 1) && (rg_xfifocase == 1) && (rg_xfifoadd>2) && (rg_xreadfinish<13));
        begin
            rg_xreadfinish <= rg_xreadfinish + 1;
            let xfifoin1 = x1bank.b.read;
            pefifo.xfifoin1(xfifoin1);
            $display(" The Value going in xFIFO 1 is in cycle 2 %d address: %0d",xfifoin1,rg_xfifoadd);
            let xfifoin2 = x2bank.b.read;
            pefifo.xfifoin2(xfifoin2); 
           //$display(" The Value going in xFIFO 2 is %d",xfifoin2);           
            let xfifoin3 = x3bank.b.read;
            pefifo.xfifoin3(xfifoin3);
           //$display(" The Value going in xFIFO 3 is %d",xfifoin3);
            let xfifoin4 = x4bank.b.read;
            pefifo.xfifoin4(xfifoin4);
           //$display(" The Value going in xFIFO 4 is %d",xfifoin4);
            let xfifoin5 = x5bank.b.read;
            pefifo.xfifoin5(xfifoin5);
           //$display(" The Value going in xFIFO 5 is %d",xfifoin5);
            let xfifoin6 = x6bank.b.read;
            pefifo.xfifoin6(xfifoin6);
           //$display(" The Value going in xFIFO 6 is %d",xfifoin6);
            let xfifoin7 = x7bank.b.read;
            pefifo.xfifoin7(xfifoin7);
           //$display(" The Value going in xFIFO 7 is %d and read counter is %d address: %d",xfifoin7,rg_xreadfinish,rg_xfifoadd);
        end
    endrule

    rule rl_x_tf_fifo3 ((rg_XBRAMloaded == 1) && (rg_xfifoadd<15) && (rg_xfifocase == 2));
        x1bank.b.put(False,rg_xfifoadd,?);
        x2bank.b.put(False,rg_xfifoadd,?);
        x3bank.b.put(False,rg_xfifoadd,?);
        x4bank.b.put(False,rg_xfifoadd,?);
        x5bank.b.put(False,rg_xfifoadd,?);
        x6bank.b.put(False,rg_xfifoadd,?);
        x7bank.b.put(False,rg_xfifoadd,?);
        rg_xfifoadd <= rg_xfifoadd+1;
    endrule
    rule rl_x_tf_fiforead3 ((rg_XBRAMloaded == 1) && (rg_xfifocase == 2) && (rg_xfifoadd>3) && (rg_xreadfinish<13));
        begin
            rg_xreadfinish <= rg_xreadfinish + 1;
            let xfifoin1 = x1bank.b.read;
            pefifo.xfifoin1(xfifoin1);
            $display("%t: The Value going in xFIFO 1 in cycle 3 is %d",$time,xfifoin1);
            let xfifoin2 = x2bank.b.read;
            pefifo.xfifoin2(xfifoin2); 
            //$display("%t: The Value going in xFIFO 2 is %d",$time,xfifoin2);           
            let xfifoin3 = x3bank.b.read;
            pefifo.xfifoin3(xfifoin3);
            //$display("%t: The Value going in xFIFO 3 is %d",$time,xfifoin3);
            let xfifoin4 = x4bank.b.read;
            pefifo.xfifoin4(xfifoin4);
            //$display("%t: The Value going in xFIFO 4 is %d",$time,xfifoin4);
            let xfifoin5 = x5bank.b.read;
            pefifo.xfifoin5(xfifoin5);
            //$display("%t: The Value going in xFIFO 5 is %d",$time,xfifoin5);
            let xfifoin6 = x6bank.b.read;
            pefifo.xfifoin6(xfifoin6);
            //$display("%t: The Value going in xFIFO 6 is %d",$time,xfifoin6);
            let xfifoin7 = x7bank.b.read;
            pefifo.xfifoin7(xfifoin7);
            //$display("%t: The Value going in xFIFO 7 is %d",$time,xfifoin7);
        end
    endrule

    rule rl_x_tf_fifo4 ((rg_XBRAMloaded == 1) && (rg_xfifoadd<16) && (rg_xfifocase == 3));
        x1bank.b.put(False,rg_xfifoadd,?);
        x2bank.b.put(False,rg_xfifoadd,?);
        x3bank.b.put(False,rg_xfifoadd,?);
        x4bank.b.put(False,rg_xfifoadd,?);
        x5bank.b.put(False,rg_xfifoadd,?);
        x6bank.b.put(False,rg_xfifoadd,?);
        x7bank.b.put(False,rg_xfifoadd,?);
        rg_xfifoadd <= rg_xfifoadd+1;
    endrule
    rule rl_x_tf_fiforead4 ((rg_XBRAMloaded == 1) && (rg_xfifocase == 3) && (rg_xfifoadd>4) && (rg_xreadfinish<13));

        begin
            rg_xreadfinish <= rg_xreadfinish + 1;
            let xfifoin1 = x1bank.b.read;
            pefifo.xfifoin1(xfifoin1);
            $display("%t: The Value going in xFIFO in cycle 4 is %d",$time,xfifoin1);
            let xfifoin2 = x2bank.b.read;
            pefifo.xfifoin2(xfifoin2); 
            //$display("%t: The Value going in xFIFO 2 is %d",$time,xfifoin2);           
            let xfifoin3 = x3bank.b.read;
            pefifo.xfifoin3(xfifoin3);
            //$display("%t: The Value going in xFIFO 3 is %d",$time,xfifoin3);
            let xfifoin4 = x4bank.b.read;
            pefifo.xfifoin4(xfifoin4);
            //$display("%t: The Value going in xFIFO 4 is %d",$time,xfifoin4);
            let xfifoin5 = x5bank.b.read;
            pefifo.xfifoin5(xfifoin5);
            //$display("%t: The Value going in xFIFO 5 is %d",$time,xfifoin5);
            let xfifoin6 = x6bank.b.read;
            pefifo.xfifoin6(xfifoin6);
            //$display("%t: The Value going in xFIFO 6 is %d",$time,xfifoin6);
            let xfifoin7 = x7bank.b.read;
            pefifo.xfifoin7(xfifoin7);
            //$display("%t: The Value going in xFIFO 7 is %d",$time,xfifoin7);
        end
    endrule

    rule rl_x_tf_end1 ((rg_XBRAMloaded == 1) && (rg_xreadfinish == 13) && (rg_xfifocase == 0));
        rg_xfifocase <= 1;
        rg_xreadfinish <= 0;
rg_xfifoadd <= 1;
        rg_xfifosloaded <= 1;
    endrule

    rule rl_x_tf_end2 ((rg_XBRAMloaded == 1) && (rg_xreadfinish == 13) && (rg_xfifocase == 1));
        rg_xfifocase <= 2;
        rg_xfifoadd <= 2;
        rg_xreadfinish <= 0;
        rg_xfifosloaded <= 1;
        //$display("%t: The X fifos are ready",$time);
    endrule
    rule rl_x_tf_end3 ((rg_XBRAMloaded == 1) && (rg_xreadfinish == 13) && (rg_xfifocase == 2));
        rg_xfifocase <= 3;
        rg_xfifoadd <= 3;
        rg_xreadfinish <= 0;
        rg_xfifosloaded <= 1;
        //$display("%t: The X fifos are ready",$time);
    endrule
    rule rl_x_tf_end4 ((rg_XBRAMloaded == 1) && (rg_xreadfinish == 13) && (rg_xfifocase == 3));
        rg_xfifocase <= 0;
        rg_xreadfinish <= 0;
        rg_xfifoadd <= 0;
        rg_xfifosloaded <= 1;
        rg_XBRAMloaded <= 0;
       // $display("%t: The X fifos have exhausted",$time);
    endrule


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
        //$display("This rule fired");
    endrule
    
    rule rl_yfifowrite ((rg_cyclecount != 4) && (rg_cyclecount != 0) && (rg_yfifoadd < 13));
        let y1 <- pefifo.yfifoout1;
      $display("%t: The output %d of bank 1 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y1);
        let y2 <- pefifo.yfifoout2;
     //   $display("%t: The output %d of bank 2 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y2);
        let y3 <- pefifo.yfifoout3;
       // $display("%t: The output %d of bank 3 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y3);
        let y4 <- pefifo.yfifoout4;
        //$display("%t: The output %d of bank 4 of cycle:%d is %d ",$time,rg_yfifoadd,rg_cyclecount,y4);
        pefifo.yfifoin1(y1);
        pefifo.yfifoin2(y2);
        pefifo.yfifoin3(y3);
        pefifo.yfifoin4(y4);
        rg_yfifoadd <= rg_yfifoadd + 1;
    endrule

    rule rl_proc2 (rg_cyclecount == 4);
        rg_youtput2proc <= 1;    
        //$display("%t: This rule fired once",$time);
    endrule
    rule rl_weightstart ((rg_wfifoloaded == 1) && (rg_weighttf == 1) && (rg_weightcounter == 0));
        pefifo.tr_weightdeq(1);
    pefifo.pearray.weighttran(1);
        rg_weightcounter <= rg_weightcounter + 1;
    endrule

    rule rl_weightend ((rg_wfifoloaded == 1) && (rg_weighttf == 1) && (rg_weightcounter == 1));
        pefifo.tr_weightdeq(0);
        rg_weightcounter <= rg_weightcounter + 1;
        rg_weighttf <= 0;
    endrule

    rule rl_weighend2 (rg_weightcounter > 1);
    if (rg_weightcounter == 5) begin
    rg_weightcounter <= 0;
    rg_weightloaded <= 1;
    pefifo.pearray.weighttran(0);
    end
    else begin
    rg_weightcounter <= rg_weightcounter + 1;
    end
    endrule

    rule rl_inputstart ((rg_xfifosloaded == 1) && (rg_weightloaded == 1) && (rg_yfifosloaded == 1) && (rg_convolutiononcount == 0) && (rg_convcycle<4));
        pefifo.tr_conv(1);
        pefifo.pearray.convs(1);
        rg_convolutiononcount <= 1;
        rg_xinputstart <= 1;
        //$display("%t: The convolution has started",$time);
    endrule

    rule rl_convcount ((rg_xinputstart == 1) && (rg_convcounter <16));
        rg_convcounter <= rg_convcounter +1;
        //$display("%t: Convcounter: %d",$time,rg_convcounter);
    endrule

    rule rl_convend ((rg_convcounter == 16) && (rg_xinputstart == 1));
        rg_xinputstart <= 0;
        rg_weightloaded <= 0;
        rg_convolutiononcount <= 0;
        if (rg_convcycle < 4 ) begin
            rg_convcycle <= rg_convcycle + 1;

        rg_convcounter <= 0;
           // $display("%d",rg_convcycle);
        end
        else
        begin
            rg_convcounter <= 1;
        end
    endrule

    rule rl_pefifo;
        wr_dough <= pefifo.tr_convout;
    endrule



rule rl_maincounterincrement (rg_maincounteractivate == 1 && rg_maincounter < 1);
        rg_maincounter <= rg_maincounter + 1;
        rg_weighttf <= 1;
    endrule

    rule rl_maincounter1start(rg_maincounteractivate == 1 && (rg_maincounter != 30) && (rg_maincounter != 60) && (rg_maincounter != 90));
        if(rg_maincounter>0)begin
            if(rg_maincounter<30)begin
            rg_maincounter <= rg_maincounter + 1;
        end end
         if(rg_maincounter>30)begin
            if(rg_maincounter<60)
            rg_maincounter <= rg_maincounter + 1;
        end
          if(rg_maincounter>60)begin
            if(rg_maincounter<90)
            rg_maincounter <= rg_maincounter + 1;
        end 
 endrule

 rule rl_maincounter2 ((rg_maincounter == 30 || rg_maincounter == 60 || rg_maincounter == 90)  && rg_xfifosloaded == 1 && rg_wfifoloaded == 1 && rg_maincounteractivate == 1);
     rg_weighttf <= 1;
     rg_maincounter <= rg_maincounter + 1;
 endrule






















    //Methods
    method Action xwritestat (Bit#(1) stat);
        rg_xwritestat <= stat;
        $display("%t: Systolic Accelerator is ready to accept X Values ",$time);
    endmethod

    
    method ActionValue#(Bit#(1)) xwritestatreturn;
        return rg_xwritestat;
    endmethod


    method Action writex (Bit#(opsize) x) if ((rg_xwriadd<16) && (rg_xwritestat == 1));
        rg_xwriadd <= rg_xwriadd + 1;
        if(rg_xwricase == 0)begin
            x1bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 1 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 1) begin
            x2bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 2 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 2)begin
            x3bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 3 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 3)begin
            x4bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 4 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 4)begin
            x5bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 5 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 5)begin
            x6bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 6 at address %d is %d",$time,rg_xwriadd,x);
        end
        if(rg_xwricase == 6)begin
            x7bank.a.put(True,rg_xwriadd,x);
            $display("%t: Value in bank 7 at address %d is %d",$time,rg_xwriadd,x);
        end
    endmethod

    method Action writew (Bit#(opsize) w) if ((rg_wwriadd<16) && (rg_wwritestat == 1));
        rg_wwriadd <= rg_wwriadd + 1;
        wbank.a.put(True,rg_wwriadd,w);
        $display("%t: Value in bank w at address %d is %d",$time,rg_wwriadd,w);
    endmethod

    method Action  wwritestat (Bit#(1) stat);
        rg_wwritestat <= stat;
        $display("%t: Systolic accelerator is ready to accept W values",$time);
    endmethod
    
    method  Bit#(1) wwristatreturn;
        return rg_wwritestat;
    endmethod

    method  Bit#(1) yreadstatreturn;
        return rg_yreadstat;
    endmethod

    method Action yreadstat (Bit#(1) stat) ;
        rg_yreadstat <= stat;
        $display("%t Yread called",$time);
    endmethod

    method ActionValue#(Bit#(opsize)) yread;       
        let y = fifoout.first;
        fifoout.deq;
        return y;
    endmethod

    method Action xBRAM_Loaded (Bit#(1) status);
        rg_XBRAMloaded <= status;
        $display("%t xbram method",$time);
    endmethod

    method  Bit#(1)xBRAM_Loaded_Return;
        return rg_XBRAMloaded;
    endmethod
    
     method Action wBRAM_Loaded (Bit#(1) status);
        rg_WBRAMloaded <= status;
        $display("%t wbram method",$time);
    endmethod

    method  Bit#(1)wBRAM_Loaded_Return;
        return rg_WBRAMloaded;
    endmethod

    method  Bit#(1) youtput2procreturn;
        return rg_youtput2proc;
    endmethod

    method Action weighttfstart (Bit#(1) x) if(rg_wfifoloaded == 1 && rg_xfifosloaded == 1);
        rg_maincounteractivate <= x;
       // $display("This rule is firing %d",rg_maincounter);
    endmethod

    method  Bit#(1) weighttfend;
        return rg_weightloaded;
    endmethod

    method  Bit#(1) convstatus;
        return rg_xinputstart;
    endmethod

    method Bit#(opsize) convpefifo;
        return wr_dough;
    endmethod

    method Action reset (Bit#(1) x);    
    if(x == 1)begin
 rg_xwriadd <= 0; 
 rg_xwricase <= 0;
 rg_xwritestat <= 0;
 rg_wwritestat <= 0;
 rg_wwriadd <= 0;
 rg_yreadstat <= 0;
 rg_yreadcase <= 0;
 rg_XBRAMloaded <= 0;
 rg_WBRAMloaded <= 0;
 rg_wfifoadd <= 0;
 rg_wfifoloaded <= 0;
 rg_xfifoadd <= 0;
 rg_xfifosloaded <= 0;
 rg_xfifocase <= 0;
 rg_xreadfinish <= 0;
 rg_cyclecount <= 0;
 rg_ywriteadd <= 0;
 rg_ywritecase <= 0;
 rg_youtput2proc <= 0;
 rg_yfifoadd <= 0;
 rg_yfifosloaded <= 0;
 rg_weightcounter <= 0;
 rg_weightcase <= 0;
 rg_weighttf <= 0;
 rg_weightloaded <= 0;
 rg_maincounter <= 0;
 rg_maincounteractivate <= 0;
 rg_xinputstart <= 0;
 rg_convcounter <= 0;
 rg_convfinish <= 0;
 rg_convcycle <= 0;
 rg_convolutiononcount <= 0;
pefifo.reset(1);
fifoout.clear;
            end
endmethod
endmodule

(* synthesize *)
module mkTop (Empty);
    Ifc_SysArray#(64) sysarray <- mkSysArray;
    Reg#(Bit#(64)) rg_i <- mkRegA(0);
Reg#(Bit#(64)) rg_k <- mkRegA(0);
    Stmt test=
    (seq
            action
                sysarray.xwritestat(1);//Method to tell accelerator that you're starting X input
            endaction

            for(rg_i <= 0; rg_i < 112; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i+1);//Gives X input
                endaction

           
            action
                sysarray.wwritestat(1);//Method to tell accelerator that you're starting W input
            endaction
            for(rg_i <= 0; rg_i < 16; rg_i <= rg_i +1)
                action
                    sysarray.writew(1);//Writes W input
                endaction

                action
                    sysarray.wBRAM_Loaded(1);//
                endaction
              //  for(rg_i <= 0; rg_i < 16; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.xBRAM_Loaded(1);//Indicates X BRAM Loaded
                endaction
                //for(rg_i <= 0; rg_i < 8; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.weighttfstart(1);//Starts conv part 1
                endaction
                //for(rg_i <= 0; rg_i < 50; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.yreadstat(1);//Enables Y read
                endaction
                for(rg_i <= 0; rg_i <12;rg_i <= rg_i +1)
                action
                    let x = sysarray.yread;//Y read
                    $display("%t: The %0d th output is %0d",$time,rg_i,x);
                endaction
            action
                sysarray.reset(1);
            endaction
            action
            endaction
            action
            endaction
            action
            endaction
            action
                sysarray.xwritestat(1);//Method to tell accelerator that you're starting X input
            endaction
            for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i+1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i+1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i + 1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i + 1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i + 1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i + 1);//Gives X input
                endaction
             for(rg_i <= 0; rg_i < 16; rg_i <= rg_i+1)
                action 
                    sysarray.writex(rg_i + 1);//Gives X input
                endaction
            action
                sysarray.wwritestat(1);//Method to tell accelerator that you're starting W input
            endaction
            for(rg_i <= 0; rg_i < 16; rg_i <= rg_i +1)
                action
                    sysarray.writew(1);//Writes W input
                endaction

                action
                    sysarray.wBRAM_Loaded(1);//
                endaction
              //  for(rg_i <= 0; rg_i < 16; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.xBRAM_Loaded(1);//Indicates X BRAM Loaded
                endaction
                //for(rg_i <= 0; rg_i < 8; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.weighttfstart(1);//Starts conv part 1
                    $display("Weight tf called");
                endaction
                //for(rg_i <= 0; rg_i < 50; rg_i <= rg_i +1)
                    action
                    endaction
                action
                    sysarray.yreadstat(1);//Enables Y read
                endaction
                for(rg_i <= 0; rg_i <52;rg_i <= rg_i +1)
                action
                    let x = sysarray.yread;//Y read
                    $display("%t: The %0d the output is %0d",$time,rg_i,x);
                endaction 
    endseq
    );
    mkAutoFSM(test);

endmodule


endpackage
