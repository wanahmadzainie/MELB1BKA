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
//            : Version 1.0 2014-06-09 Ready for submission
////////////////////////////////////////////////////////////////////-

module cu(clk, rst, deposited, selected, cancel, maintenance, drop,
			ldRdeposit, ldRselect, ldRprice, ldRout, ldA, ldM,
			clrR, clrA, clrRout, refundall, depositall, state);
	input	clk, rst;
	input	deposited, selected, cancel, maintenance, drop;
	output	ldRdeposit, ldRselect, ldRprice, ldRout;
	output	ldA, ldM, clrR, clrA, clrRout, refundall, depositall;
	output	[2:0] state;
	reg		[2:0] pstate, nstate;
	reg		[8:0] cv;
	parameter	S_init = 3'b000, S_wait = 3'b001, S_deposit = 3'b010, 
				S_cancel = 3'b011, S_select = 3'b100, S_drop = 3'b101, 
				S_maintenance = 3'b110;

	// state register submodule
	always @ (negedge clk or negedge rst) begin
		if (rst == 0)	pstate <= S_init;
		else			pstate <= nstate;
	end

	// next state logic, output logic
	always @ (pstate or cancel or maintenance or deposited or selected or drop) begin
		case (pstate)
			S_init: begin
				nstate = S_wait;
				cv = 9'b0_0000_0111;
			end
			S_wait: begin
				if (maintenance)	nstate = S_maintenance;
				else if (deposited)	nstate = S_deposit;
				else if (selected)	nstate = S_select;
				else if (cancel)	nstate = S_cancel;
				else if (drop)		nstate = S_drop;
				else				nstate = S_wait;
			end
			S_deposit: begin
				if (deposited) begin	nstate = S_deposit; cv = 9'b0_1000_1001; end
				else begin				nstate = S_wait; cv = 9'b0_0000_0001; end
			end
			S_cancel: begin
				nstate = S_wait; cv = 9'b0_0000_0111;
			end
			S_select: begin
				if (drop) begin	nstate = S_drop; cv = 9'b0_0001_0000; end
				else begin		nstate = S_wait; cv = 9'b0_0100_0001; end
			end
			S_drop: begin
				nstate = S_wait; cv = 9'b0_0000_0111;
			end
			S_maintenance: begin
				if (maintenance) begin
					nstate = S_maintenance;
					if (selected)	cv = 9'b1_0110_0011;
					else			cv = 9'b0_0000_0001;
				end
				else begin	nstate = S_wait; cv = 9'b0_0000_0111; end
			end
		endcase
	end

	assign state = pstate;
	assign ldM			= cv[8];
	assign ldRdeposit	= cv[7];
	assign ldRselect	= cv[6];
	assign ldRprice		= cv[5];
	assign ldRout		= cv[4];
	assign ldA			= cv[3];
	assign clrR			= cv[2];
	assign clrA			= cv[1];
	assign clrRout		= cv[0];
	assign refundall	= (state == S_cancel) ? 1'b1 : 1'b0;
	assign depositall	= (state == S_drop)   ? 1'b1 : 1'b0;
endmodule
