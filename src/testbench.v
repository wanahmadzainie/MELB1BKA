////////////////////////////////////////////////////////////////////-
// Design unit: testbench (Module)
//            :
// File name  : testbench.v
//            :
// Description: Test Bench for RTL Vending Machine
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

`timescale 100ns / 1ns

module testbench();
	// inputs
	reg	clk, rst;
	reg	[9:0] deposit, price;
	reg	[4:0] select;
	reg	deposited, selected, cancel, maintenance;

	// outputs
	wire	refund, refundall, depositall;
	wire	[4:0] product;
	wire	[9:0] balance;
	wire	[2:0] state;

	// instantiation
	vm myVM(
		.clk(clk),
		.rst(rst),
		.deposit(deposit),
		.deposited(deposited),
		.select(select),
		.selected(selected),
		.price(price),
		.cancel(cancel),
		.maintenance(maintenance),
		.refund(refund),
		.refundall(refundall),
		.depositall(depositall),
		.product(product),
		.balance(balance),
		.state(state)
	);

	initial begin
		clk= 0;
		#5;
		forever #5 clk = ~clk;
	end

	initial begin
		rst= 0;
		#10;
		#10		rst= 1;
		#10		maintenance= 1;
		#10		selected= 1; select =  0; price= 100;
		#10		selected= 1; select = 31; price= 100;
		#10		selected= 1; select =  1; price= 150;
		#10		selected= 1; select =  2; price= 100;
		#10		selected= 1; select =  3; price= 200;
		#10		selected= 1; select =  4; price= 100;
		#10		selected= 1; select =  5; price= 150;
		#10		selected= 1; select =  6; price= 150;
		#10		selected= 1; select =  7; price= 150;
		#10		selected= 1; select =  8; price= 100;
		#10		selected= 1; select =  9; price= 100;
		#10		selected= 1; select = 10; price= 100;
		#10		selected= 1; select = 11; price= 100;
		#10		selected= 1; select = 12; price= 100;
		#10		selected= 1; select = 13; price= 100;
		#10		selected= 1; select = 14; price= 100;
		#10		selected= 1; select = 15; price= 100;
		#10		selected= 1; select = 16; price= 100;
		#10		selected= 1; select = 17; price= 100;
		#10		selected= 1; select = 18; price= 100;
		#10		selected= 1; select = 19; price= 100;
		#10		selected= 1; select = 20; price= 100;
		#10		selected= 1; select = 21; price= 100;
		#10		selected= 1; select = 22; price= 100;
		#10		selected= 1; select = 23; price= 100;
		#10		selected= 1; select = 24; price= 100;
		#10		selected= 1; select = 25; price= 100;
		#10		selected= 1; select = 26; price= 100;
		#10		selected= 1; select = 27; price= 100;
		#10		selected= 1; select = 28; price= 200;
		#10		selected= 1; select = 29; price= 200;
		#10		selected= 1; select = 30; price= 200;
		#10		selected= 1; select = 31; price= 200;
		#10		selected= 0; maintenance = 0;
		#20;
		#10		deposited= 1; deposit= 100;
		#10		deposited= 0;
		#10		deposited= 1; deposit= 500;
		#10		deposited= 0;
	end

endmodule
