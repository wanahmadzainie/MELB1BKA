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
//            : Version 1.0 2014-06-09 Ready for submission
//            : Version 2.0 2014-06-10 Change to behavioral
////////////////////////////////////////////////////////////////////-

module du(clk, rst, deposit, select, price, ldRdeposit, ldRselect, ldRprice,
			ldA, ldRproduct, ldRchange, ldRpurchase, ldMprice, ldMquantity,
			clrRdeposit, clrRselect, clrRprice, clrA, clrRproduct, clrRchange,
			clrRpurchase, purchase, refund, product, change);
	input	clk, rst;
	input	[9:0] deposit, price;
	input	[4:0] select;
	input	ldRdeposit, ldRselect, ldRprice, ldA, ldRproduct, ldRchange;
	input	ldRpurchase, ldMprice, ldMquantity, clrRdeposit, clrRselect;
	input	clrRprice, clrA, clrRproduct, clrRchange, clrRpurchase;
	output reg	purchase, refund;
	output reg	[4:0] product;
	output reg	[9:0] change;
	reg	[9:0] Rdeposit, Rprice, Adeposit;
	reg	[4:0] Rselect;
	reg	[15:0] mem [0:31];
	integer	i;

	initial begin
		for (i=0;i<32;i=i+1) begin
			mem[i] = 16'h2864;
		end
		mem[0] = 16'b0000_0000_0011_0010; // quantity=0, price=50(RM5)
		mem[1] = 16'b0010_1001_1001_0000; // quantity=10, price=400(RM40)
	end
	//initial begin $readmemh("default.dat", mem); end

	// Register deposit
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)			Rdeposit <= 0;
		else if (ldRdeposit)	Rdeposit <= deposit;
		else if (clrRdeposit)	Rdeposit <= 0;
	end

	// Register select
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)			Rselect <= 0;
		else if (ldRselect)		Rselect <= select;
		else if (clrRselect)	Rselect <= 0;
	end

	// Register price
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)		Rprice <= 0;
		else if (ldRprice)	Rprice <= price;
		else if (clrRprice)	Rprice <= 0;
	end

	// Accumulator accumulate deposit, and restore previous if exceed threshold
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)	Adeposit <= 0;
		else if (ldA)	Adeposit <= Adeposit + Rdeposit;
		else if (clrA)	Adeposit <= 0;
		else if (refund)	Adeposit <= Adeposit - Rdeposit;
	end

	// Comparator Adeposit > maximum accepted deposit
	always @ (Adeposit) begin
		if (Adeposit > 500)	refund = 1;
		else				refund = 0;
	end

	// Comparator Adeposit >= price, quantity > 0
	always @ (Adeposit) begin
		for (i=0; i<32;i=i+1) begin
			if (0 < mem[i][13:10] && Adeposit >= mem[i][9:0])
					mem[i][15] = 1;
			else	mem[i][15] = 0;
		end
	end

	// Logic to indicate purchase
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)				purchase <= 0;
		else if (ldRpurchase)
			if (mem[Rselect][15])	purchase <= 1;
			else					purchase <= 0;
		else if (clrRpurchase)		purchase <= 0;
	end

	// Substractor calculate change
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)			change <= 0;
		else if (ldRchange)		change <= Adeposit - mem[Rselect][9:0];
		else if (clrRchange)	change <= 0;
	end

	// Register selected product
	always @ (negedge rst or posedge clk) begin
		if (rst == 0)			product <= 0;
		else if (ldRproduct)	product <= Rselect;
		else if (clrRproduct)	product <= 0;
	end

	// Register array update price or reduce quantity by 1
	always @ (posedge clk) begin
		if (ldMquantity)	mem[Rselect][13:10]	<= mem[Rselect][13:10] - 1'b1;
		if (ldMprice)		mem[Rselect][9:0]	<= Rprice;		
	end
endmodule

