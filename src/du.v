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
////////////////////////////////////////////////////////////////////-

module du(clk, rst, deposit, select, price, ldRdeposit, ldRselect, ldRprice,
			ldRout, clrR, clrA, clrRout, ldA, ldM, drop, refund, product, balance);
	input	clk, rst;
	input	[9:0] deposit, price;
	input	[4:0] select;
	input	ldRdeposit, ldRselect, ldRprice, ldRout;
	input	clrR, clrA, clrRout, ldA, ldM;
	output	drop, refund;
	output	[4:0] product;
	output	[9:0] balance;
	wire	[4:0] wSelect;
	wire	[9:0] wDeposit, wBalance, wPrice, wAout;
	wire	[3:0] wNewBalance;
	wire	[15:0] datainM, dataoutM;
	wire	wRefund, wSelPrice, wSelBalance;

	// Registers
	regN regDeposit(clk, rst, clrR, ldRdeposit, deposit, wDeposit);
	defparam regDeposit.N = 10;
	regN regSelect(clk, rst, clrR, ldRselect, select, wSelect);
	defparam regSelect.N = 5;
	regN regPrice(clk, rst, clrR, ldRprice, price, wPrice);
	defparam regPrice.N = 10;
	regN regProduct(clk, rst, clrRout, ldRout, wSelect, product);
	defparam regProduct.N = 5;
	regN regBalance(clk, rst, clrRout, ldRout, wBalance, balance);
	defparam regBalance.N = 10;
	regN regRefund(clk, rst, clrRout, ldRdeposit, wRefund, refund);
	defparam regRefund.N = 1;

	// Accumulator
	accN accDeposit(clk, rst, clrA, ldA, wDeposit, wAout);
	defparam accDeposit.N = 10;

	// Comparator
	compN compSelectedPrice(wAout, dataoutM[9:0], wSelPrice);
	defparam compSelectedPrice.N = 10;
	compN compSelectedBalance(dataoutM[13:10], 4'b1, wSelBalance);
	defparam compSelectedBalance.N = 4;
	compN compDeposit(wAout, 501, wRefund);
	defparam compDeposit.N = 10;

	//
	subN subDeposit(wAout, dataoutM[9:0], wBalance);
	defparam subDeposit.N = 10;
	subN subSelBalance(dataoutM[13:10], 4'b1, wNewBalance);
	defparam subSelBalance.N = 4;

	//
	ram Mproduct(clk, wSelect, ldM, datainM, dataoutM);

	assign datainM[9:0]		= (drop) ? dataoutM[9:0] : wPrice;
	assign datainM[13:10]	= (drop) ? wNewBalance : dataoutM[13:10];
	assign drop = (wSelPrice & wSelBalance) ? 1'b1 : 1'b0;
endmodule

// Register
module regN(clk, rst, clr, load, D, Q);
	parameter	N = 8;
	input	clk, rst, clr, load;
	input	[N-1:0] D;
	output reg	[N-1:0] Q;

	always @ (negedge rst or posedge clk)
		if (!rst)		Q <= 0;
		else if (clr)	Q <= 0;
		else if (load)	Q <= D;
		else			Q <= Q;
endmodule

// Accumulator
module accN(clk, rst, clr, load, D, Q);
	parameter	N = 8;
	input	clk, rst, clr, load;
	input	[N-1:0] D;
	output reg	[N-1:0] Q;

	always @ (negedge rst or posedge clk)
		if (!rst)		Q <= 0;
		else if (clr)	Q <= 0;
		else if (load)	Q <= Q + D;
		else			Q <= Q;
 endmodule

// Comparator
module compN(a, b, out);
	parameter N = 8;
	input	[N-1:0] a, b;
	output	out;

	assign out = (a >= b) ? 1'b1 : 1'b0;
endmodule

// Substractor
module subN(a, b, out);
	parameter	N = 8;
	input	[N-1:0] a, b;
	output	[N-1:0] out;

	assign out = a - b;
endmodule

// RAM
module ram(clk, addr, we, datain, dataout);
	input	clk,  we;
	input	[4:0] addr;
	input	[15:0] datain;
	output	[15:0] dataout;
	wire	high;

	assign high = 1;
	lpm_ram_dq myRAM
		(.q(dataout), .data(datain), .address(addr), .we(we), .inclock(clk), .outclock(high));
		defparam myRAM.lpm_width	= 16;
		defparam myRAM.lpm_widthad	= 5;
		defparam myRAM.lpm_indata	= "REGISTERED";
		defparam myRAM.lpm_outdata	= "UNREGISTERED";
		defparam myRAM.lpm_file		= "default.mif";
endmodule

