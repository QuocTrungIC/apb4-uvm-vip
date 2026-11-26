`timescale 1ns/1ps
interface apb_if #(
	parameter	DATA_WIDTH = 32,
	parameter	ADDR_WIDTH = 32,
	parameter	STRB_WIDTH = DATA_WIDTH / 8
)(
	logic	PCLK
)
	logic					PRESETn;
	logic					PSEL, PENABLE;
	logic					PWRITE;
	logic					PREADY;
	logic [ADDR_WIDTH-1:0] 	PADDR;
	logic [DATA_WIDTH-1:0] 	PWDATA;
	logic [DATA_WIDTH-1:0] 	PRDATA;
	logic [STRB_WIDTH-1:0] 	PSTRB;
	logic					PSLVERR;
//Clocking Block for testbench
	clocking cb_master @(posedge PCLK);
		default input #1ns output #1ns;
		output PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
		input  PREADY, PRDATA, PSLVERR;
	endclocking
//MODPORT
  //DUT
	modport DUT (
		input	PCLK, PRESETn, PSEL, PENABLE, PWRITE,  PADDR, PWDATA, PSTRB,
		output	PREADY, PRDATA, PSLVERR
	);
  //Driver
	modport drv (
		clocking cb_master,
		input 	 PRESETn;
	);
  //Monitor
  	modport mon(
  		input PCLK, PRESETn, PSEL, PENABLE, PWRITE,  PADDR, PWDATA, 
  			  PSTRB, PREADY, PRDATA, PSLVERR
  	); 
  	
 endinterface : apb_if
