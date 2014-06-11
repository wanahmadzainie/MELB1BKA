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
//            : Version 2.0 2014-06-10 Change to behavioral - more simulation
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
	wire	[9:0] change;
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
		.change(change),
		.state(state)
	);

// for future use
//	initial begin
//		$display("time: rst, clk");
//		$monitor(" %0d:  %b,  %b", $time, rst, clk);
//	end

	initial begin
		clk= 0;
		#5;
		forever #5 clk = ~clk;
	end

	initial begin
		rst= 0;
		deposited= 0; deposit= 0; selected= 0; select= 'bx; price= 0;
		cancel= 0; maintenance= 0;
		#10;
		#10		rst= 1;
// simulate overflow, insert payment more than threshold value
		#20		deposited= 1; deposit= 100;
		#20		deposited= 1; deposit= 200;
		#20		deposited= 1; deposit= 200;
		#20		deposited= 1; deposit=   1;
		#20		deposited= 0;
		#20;
// simulate cancel
		#20		cancel= 1;
		#20		cancel= 0;
		#20;
// simulate purchase
		#20		deposited= 1; deposit=  10;
		#20		deposited= 1; deposit= 100;
		#20		deposited= 1; deposit=  20;
		#10		deposited= 0;
		#20		selected= 1; select= 10;
		#20		selected= 0; select= 'bx;
		#20;
// simulate maintenance changing price
		#20		maintenance= 1;
		#20		selected= 1; select =  0; price=  10;
		#20		selected= 1; select = 31; price=  10;
		#20		selected= 1; select =  1; price=  15;
		#20		selected= 1; select =  2; price=  10;
		#20		selected= 1; select =  3; price=  20;
		#20		selected= 1; select =  4; price=  10;
		#20		selected= 1; select =  5; price=  15;
		#20		selected= 1; select =  6; price=  15;
		#20		selected= 1; select =  7; price=  15;
		#20		selected= 1; select =  8; price=  10;
		#20		selected= 1; select =  9; price=  10;
		#20		selected= 1; select = 10; price=  10;
		#20		selected= 1; select = 11; price=  10;
		#20		selected= 1; select = 12; price=  10;
		#20		selected= 1; select = 13; price=  10;
		#20		selected= 1; select = 14; price=  10;
		#20		selected= 1; select = 15; price=  10;
		#20		selected= 1; select = 16; price=  10;
		#20		selected= 1; select = 17; price=  10;
		#20		selected= 1; select = 18; price=  10;
		#20		selected= 1; select = 19; price=  10;
		#20		selected= 1; select = 20; price=  10;
		#20		selected= 1; select = 21; price=  10;
		#20		selected= 1; select = 22; price=  10;
		#20		selected= 1; select = 23; price=  10;
		#20		selected= 1; select = 24; price=  10;
		#20		selected= 1; select = 25; price=  10;
		#20		selected= 1; select = 26; price=  10;
		#20		selected= 1; select = 27; price=  10;
		#20		selected= 1; select = 28; price=  20;
		#20		selected= 1; select = 29; price=  20;
		#20		selected= 1; select = 30; price=  20;
		#20		selected= 1; select = 31; price=  99;
		#20		selected= 0; select= 'bx; maintenance = 0;
		#20;
// simulate purchase after changing price, item 30, from RM10 to RM2 (balance RM28)
		#20		deposited= 1; deposit= 200;
		#20		deposited= 1; deposit= 500;
		#20		deposited= 1; deposit= 100;
		#20		deposited= 0;
		#20		selected= 1; select= 30;
		#20		selected= 0; select= 'bx;
		#20		selected= 1; select= 3;
		#20		selected= 0; select= 'bx;
		#200	$stop;
	end

endmodule
