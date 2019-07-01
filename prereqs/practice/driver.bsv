import GetPut::*;
import Connectable::*;

typedef struct {
    Bit #(1) req_type;
    Bit #(20) pagenum;
    Bit #(12) offset;
} Req deriving (Bits, FShow, Eq);

interface Main_Ifc;
    interface Put#(Req) virtaddr;
    interface Put#(Req) phyaddr;
    interface Get#(Req) virt2phy;
    interface Get#(Bit#(2)) access;
endinterface

interface Trans_Ifc;
    interface Put#(Req) from_main;
    interface Get#(Req) to_main;

module mkMain (Main_Ifc);

    Wire#(Req) wr_virtaddr <- mkWire();
    Wire#(Req) wr_phyaddr <- mkWire();
    Wire#(Req) wr_virt2phy <- mkWire();
    Wire#(Bit#(2)) wr_access <- mkWire();

    interface Put virtaddr;
        method Action put (Req x);
            wr_virtaddr <= x; 
        endmethod
    endinterface

    interface Put phyaddr;
        method Action put (Req x);
            wr_phyaddr <= x; 
        endmethod
    endinterface

    interface Get virt_phy;
        method ActionValue#(Req) get;
            return wr_virt2phy;
        endmethod
    endinterface

    interface Get access;
        method ActionValue#(Bit#(2)) get;
            return wr_access;
        endmethod
    endinterface

endmodule

module mkProd2 (Get#(Bit#(32)));
    method ActionValue#(Bit#(32)) get;
        return 2;
    endmethod
endmodule

module mkCon (Put#(Bit#(32)));
    method Action put (Bit#(32) x);
        $display("Called with %x", x);
    endmethod
endmodule

module driver ();
    let p1 <- mkProd2;
    let p2 <- mkProd2;
    let adder <- mkAdder;
    let c <- mkCon;

    mkConnection(p1, adder.a_in);
    mkConnection(p2, adder.b_in);
    mkConnection(adder.s_out, c);
    /*
    rule rl_always_fire (True);
        let x <- p.get();
        c.put(x);
    endrule
    */
endmodule
