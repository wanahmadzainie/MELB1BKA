////////////////////////////////////////////////////////////////////-
// Design unit: Data Path Unit (Module)
//            :
// File name  : du.v
//            :
// Description: Data Path Unit for Vending Machine
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

module du(clk, rst, payment, select, ldPayment, ldSelect, ldPrice,
			inserted, selected, overpaid, change, drop, deposit);
	input	clk, rst;
	input	ldPayment, ldSelect, ldPrice;
	input	[12:0] payment;
	input	[ 4:0]  select;
	output 	inserted, selected, overpaid;
	output reg deposit;
	output reg	[12:0] change;
	output reg	[ 4:0] drop;
	reg		[12:0] paid;
	reg		[15:0] item [0:31]; /* 15: validity 14-10: quantity 9-0: price */
	integer	i;

	// Initialize to default values.
	initial begin
		for (i=0;i<32;i=i+1) begin
			item[i] = 0;
		end
	end

	// Accumulate total money inserted.
	always @ (posedge clk or posedge rst) begin
		if (rst)			paid <= 0;
		else if (ldPayment)	paid <= paid + payment;
		else if (ldSelect)	paid <= 0;
		else				paid <= paid;
	end

	// Update valid selection based on available quantity and inserted money.
	always @ (paid) begin
		for (i=0;i<32;i=i+1) begin
			item[i][15] = 0;
			if (0 < item[i][14:10])
				if (paid >= item[i][9:0])
					item[i][15] = 1;
		end
	end

	// Drop selected item, update its quantity, and calculate the change.
	always @ (posedge clk or posedge rst) begin
		if (rst)	begin	drop <= 0; change <= 0; deposit <= 0; end
		else if (ldSelect) begin
			drop <= select;
			item[select][14:10] <= item[select][14:10] - 1;
			change <= paid - item[select][9:0];
			deposit <= 1;
		end
		else		begin drop <= 0; change <= 0; deposit <= 0; end
	end

	// Output flag for control unit.
	assign inserted = (payment > 0) ? 1'b1 : 1'b0;
	assign selected = (item[select][15]) ? 1'b1 : 1'b0;
	assign overpaid = (paid > 5000) ? 1'b1 : 1'b0;

endmodule
