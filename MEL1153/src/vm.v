////////////////////////////////////////////////////////////////////-
// Design unit: vm (All In One)
//            :
// File name  : vm.v
//            :
// Description: RTL Design of Vending Machine
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
// Revision   : Version 0.1 2014-06-01
//            : Version 1.0 2014-06-09 Ready for submission
//            : Version 2.0 2014-06-10 Change to behavioral
////////////////////////////////////////////////////////////////////-

module vm(clk, rst, deposit, deposited, select, selected, price, cancel, maintenance,
			refund, refundall, depositall, product, change, state);
	input 	clk, rst;
	input	[9:0] deposit, price;
	input	[4:0] select;
	input	deposited, selected, cancel, maintenance;
	output	refund, refundall, depositall;
	output	[4:0] product;
	output	[9:0] change;
	output	[2:0] state;
	wire	ldRdeposit, ldRselect, ldRprice, ldA, ldRproduct, ldRchange;
	wire	ldRpurchase, ldMprice, ldMquantity, clrRdeposit, clrRselect;
	wire	clrRprice, clrA, clrRproduct, clrRchange, clrRpurchase, purchase;

	du myDU(clk, rst, deposit, select, price, ldRdeposit, ldRselect, ldRprice,
			ldA, ldRproduct, ldRchange, ldRpurchase, ldMprice, ldMquantity,
			clrRdeposit, clrRselect, clrRprice, clrA, clrRproduct, clrRchange,
			clrRpurchase, purchase, refund, product, change);

	cu myCU(clk, rst, deposited, selected, cancel, maintenance, purchase,
			ldRdeposit, ldRselect, ldRprice, ldA, ldRproduct, ldRchange,
			ldRpurchase, ldMprice, ldMquantity, clrRdeposit, clrRselect,
			clrRprice, clrA, clrRproduct, clrRchange, clrRpurchase,
			refundall, depositall, state);
endmodule
