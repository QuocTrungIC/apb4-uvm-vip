`ifndef APB_SVA_SV
`define APB_SVA_SV
module apb_sva(
	input logic 		PCLK, PRESETn,
	input logic 		PSEL, PENABLE,
	input logic			PWRITE,
	input logic	[31:0]	PWDATA,
	input logic	[31:0]	PADDR,
	input logic	[3:0]	PSTRB,
	input logic			PREADY,
	input logic			PSLVERR
);
//Property
  //1. Setup phase
  	property p_setup_to_access;
  		@(posedge PCLK) disable iff (!PRESETn)
  		($rose(PSEL) && !PENABLE) |=> PENABLE;
  	endproperty
  //2. In Access phase: PWRITE, PWDATA, PADDR, PSTRB don't change
	property p_stable_access;
		@(posedge PCLK) disable iff (!PRESETn)
		(PSEL && PENABLE) |-> ($stable(PWRITE) && $stable(PADDR) && $stable(PWDATA) && $stable(PSTRB));
	endproperty
//Assert
	a_setup_to_access: assert property (p_setup_to_access)
		 			else $error("[SVA ERROR] - PENABLE not rise up after SETUP");
		 			
	a_stable_access: assert property (p_stable_access)
	 				else $error("[SVA ERROR] - PWRITE/PADDR/PWDATA/PSTRB changed during ACCESS phase");
//Cover
	c_apb_write: cover property(
		@(posedge PCLK) disable iff (!PRESETn)
		(PSEL && PENABLE && PWRITE && PREADY)
	);
	
	c_apb_read: cover property(
		@(posedge PCLK) disable iff (!PRESETn)
		(PSEL && PENABLE && !PWRITE && PREADY)
	);
endmodule : apb_sva
`endif
