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
////////////////////////////////////////////////////////////////////-

module vm(clk, rst, deposit, deposited, select, selected, price, cancel,
			maintenance, refund, refundall, depositall, product, balance, state);
	input 	clk, rst;
	input	[9:0] deposit, price;
	input	[4:0] select;
	input	deposited, selected, cancel, maintenance;
	output	refund, refundall, depositall;
	output	[4:0] product;
	output	[9:0] balance;
	output	[2:0] state;
	wire	ldRdeposit, ldRselect, ldRprice, ldRout;
	wire	clrR, clrA, clrRout, ldA, ldM;
	wire	drop;

	du myDU(clk, rst, deposit, select, price, ldRdeposit, ldRselect, ldRprice,
			ldRout, clrR, clrA, clrRout, ldA, ldM, drop, refund, product, balance);

	cu myCU(clk, rst, deposited, selected, cancel, maintenance, drop,
			ldRdeposit, ldRselect, ldRprice, ldRout, ldA, ldM,
			clrR, clrA, clrRout, refundall, depositall, state);
endmodule
