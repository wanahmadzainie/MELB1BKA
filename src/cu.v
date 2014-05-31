////////////////////////////////////////////////////////////////////-
// Design unit: Control Unit (Module)
//            :
// File name  : cu.v
//            :
// Description: Control Unit of Vending Machine
//            :
// Limitations: None
//            :
// System     : Verilog
//            :
// Author     : 1. Wan Ahmad Zainie bin Wan Mohamad (ME131135)
//            :    wanahmadzainie@gmail.com
//            : 2. Azfar 'Aizat bin Mohd Isa (ME131032)
//            :    aaizat5@gmail.com
//
// Revision   : Version 0.1 2014-05-30 Initial
////////////////////////////////////////////////////////////////////-

module cu(clk, rst, maintenance, cancel, inserted, selected,
			ldPayment, ldSelect, ldPrice, refund);
	input	clk, rst;
	input	maintenance, cancel, inserted, selected;
	output	ldPayment, ldSelect, ldPrice;
	output	refund;
	reg		[2:0] state, nstate;

	parameter	S_init = 0, S_wait = 1, S_payment = 2,
				S_refund = 3, S_release = 4, S_maintenance = 5;

	// state register submodule
	always @ (negedge clk or posedge rst) begin
		if (rst)	state <= S_init;
		else		state <= nstate;
	end

	// next state logic submodule
	always @ (state or maintenance or cancel or inserted or selected) begin
		case (state)
			S_init:
				nstate = S_wait;
			S_wait:
				if (maintenance)	nstate = S_maintenance;
				else if (inserted)	nstate = S_payment;
				else				nstate = S_wait;
			S_maintenance:
				nstate = S_init;
			S_payment:
				if (maintenance)	nstate = S_refund;
				else if (cancel)	nstate = S_refund;
				else if (selected)	nstate = S_release;
				else				nstate = S_payment;
			S_release:
				nstate = S_wait;
			S_refund:
				nstate = S_wait;

		endcase
	end

	// output logic submodule
	assign ldPrice = (state == S_init) ? 1 : 0;
	assign ldPayment = (state == S_payment) ? 1 : 0;
	assign ldSelect = (state == S_release) ? 1 : 0;
	assign refund = (state == S_refund) ? 1 : 0;
endmodule
