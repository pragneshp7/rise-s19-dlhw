import GetPut ::*;
import Connectable ::*;
typedef struct {
    Bit#(32) add;
    Bit#(1) req;
} Virpack deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(32) add;
    Bit#(1) req;
    Bit#(1) acc;
} Phypack deriving (Bits, Eq, FShow);


interface IFC_Translation;
    interface Put#(virpack) v_in;
    interface Put#(Bit#(32)) p_in;
    interface Get#(Bit#(32)) v_out;
    interface Get#(phypack) p_out;
endinterface

interface Ifc_VirProducer;
    interface Get#(virpack) vprod_out;
endinterface

interface Ifc_TLB;
    interface Get#(Bit#(32)) ptlb_out;
    interface Put#(Bit#(32)) vtlb_in;
endinterface


(* synthesize *)
module mkTop
    ();


endmodule
