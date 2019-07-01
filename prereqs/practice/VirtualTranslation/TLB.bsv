import GetPut ::*;
import Connectable ::*;

//Virtual Address Packet

typedef struct {
    Bit#(32) add;
    Bit#(1) req;
} Virpack deriving (Bits, Eq, FShow);



//Physical address Packet
//Add: Physical Address, req: Request Type, acc: Request passes or fail
typedef struct {
    Bit#(32) add;
    Bit#(1) req;
    Bit#(1) acc;
} Phypack deriving (Bits, Eq, FShow);



// Interface of the main module

interface IFC_Translation;
    interface Put#(Virpack) v_in;
    interface Put#(Bit#(32)) p_in;
    interface Get#(Bit#(32)) v_out;
    interface Get#(Phypack) p_out;
endinterface

// Interface of the TLB

interface Ifc_TLB;
    interface Get#(Bit#(32)) ptlb_out;
    interface Put#(Bit#(32)) vtlb_in;
endinterface

//TLB module


module mkTLB (Ifc_TLB);
    Wire#(Bit#(32)) wr_phy <- mkWire();
    interface Get ptlb_out;
        method ActionValue#(Bit#(32)) get;
            return wr_phy;  //Returns Physical address
        endmethod
    endinterface
    interface Put vtlb_in;
        method Action put (Bit#(32) x);
            wr_phy <= x+32'h00004000;  // Gets Virtual address and adds 4000h to convert it to physical address
        endmethod
    endinterface
endmodule

//Virtual add Producer Module

module mkProd (Get#(Virpack));
    method ActionValue#(Virpack) get;
        let x = Virpack {add:32'h000000015,req:1'b0}; //Behaves as a processor sending the Virtual Address
        $display("The Virtual address is ",fshow(x)); // Displays Virtual Address 
        return x;
    endmethod
endmodule

//Physical Add Consumer Module

module mkCon (Put#(Phypack));
    method Action
        put (Phypack x);
        $display("The physical address is ", fshow(x)); //Displays Physical Address
    endmethod
endmodule


//Main Module

module mkTranslation
    (IFC_Translation);
    Wire#(Virpack) wr_virin <- mkWire(); 
    Wire#(Bit#(32)) wr_pin <- mkWire();
    let x=Phypack{add:32'h00000000,req:1'b0,acc:1'b0};
    Wire#(Phypack) wr_pout <- mkDWire(x);  


     interface Put v_in; //Takes Input from Producer(Virtual Address Packet)
        method Action put (Virpack x);
            wr_virin<=x;
        endmethod
    endinterface



    interface Put p_in; //Takes Input from TB(Physical Address)
        method Action put (Bit#(32) x);
            wr_pin<=x;
        endmethod
    endinterface



    interface Get v_out;
        method ActionValue#(Bit#(32)) get; //Gives the Virtual Address to TLB
            let x = wr_virin.add;
            return x;
        endmethod
    endinterface


    interface Get p_out;
        method ActionValue#(Phypack) get; //To check if the Access is granted
          let x=wr_pout;
        if(wr_pin<32'h00005000)
          x=Phypack{add:wr_pin,req:wr_virin.req,acc:1'b1};
      else
 x=Phypack{add:32'hffffffff,req:wr_virin.req,acc:1'b0};

          return x;  //Return the physical address packet to Consumer
        endmethod
    endinterface


endmodule


//TestBench


(* synthesize *)
module mkTop ();
    let a <- mkProd;
    let b <- mkCon;
    let c <-mkTranslation;
    let d <- mkTLB;
    mkConnection(a,c.v_in);
    mkConnection(c.v_out,d.vtlb_in);
    mkConnection(d.ptlb_out,c.p_in);
    mkConnection(c.p_out,b);
    Reg#(Bit#(10)) rg_count <- mkReg(0);
    rule rl_counter ;                       //Counter to Stop the Simpulation
        rg_count<=rg_count+1;
        if(rg_count==5)
            $finish;
    endrule
endmodule
