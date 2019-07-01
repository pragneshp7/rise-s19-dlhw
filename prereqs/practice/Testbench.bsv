package Testbench;

import DeepThought :: *;

(* synthesize *)
module mkTestbench (Empty);

	DeepThought_IFC deepThought <- mkDeepThought;

	rule r1_print_answer;
		let x<- deepThought.getAnswer;
		$display("Deep Thought says: Hello, World! The answer is %0d",x);
		$finish;
	endrule
endmodule

endpackage
