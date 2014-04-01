////////////////////////////////////////////////////////////////////-
// Design unit: vm_fsm (Module)
//            :
// File name  : vm_fsm.v
//            :
// Description: finite state machine for vending machine
//            :
// Limitations: None
//            : 
// System     : Verilog
//            :
// Author     : Wan Ahmad Zainie bin Wan Mohamad
//            : ME131135
//            : Fakulti Kejuruteraan Elektrik
//            : Universiti Teknologi Malaysia
//            : wanahmadzainie@gmail.com
//
// Revision   : Version 0.0 2014-04-01
////////////////////////////////////////////////////////////////////-

module vm_fsm(dummy_in, dummy_out);
	input		dummy_in;
	output	dummy_out;
	
	assign dummy_out = ~dummy_in;
endmodule