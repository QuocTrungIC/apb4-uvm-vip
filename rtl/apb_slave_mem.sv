`timescale 1ns/1ps
import apb_pkg::*;

module apb_slave_mem#(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter STRB_WIDTH = DATA_WIDTH / 8
)(
	apb_if.DUT 			apb,
  //Internal
  	input  logic 		wait_en, 
	output logic 		wr_en, rd_en,
	output apb_state_e 	current_state
);
  	apb_state_e 		next_state;
  	logic [DATA_WIDTH-1:0] mem [0:255];
//-----------------------------------------------------------------------------
	assign apb.PSLVERR = 1'b0;		//In this exercise, this circuit don't care about Flag Slave Error
	assign wr_en = apb.PWRITE && apb.PREADY && (current_state == ACCESS);
	assign rd_en = (!apb.PWRITE)  && (current_state == SETUP);
//FSM
  //Combitional FSM
	always_comb begin
		next_state = current_state;								//Defend Latch
		unique case (current_state) 
			IDLE: begin
				if (apb.PSEL && !apb.PENABLE) 
						next_state = SETUP;
			end
			SETUP: begin
				if (apb.PENABLE) 
					next_state = ACCESS;
			end 
			ACCESS: begin
				if (apb.PREADY) begin
					if (!apb.PENABLE) begin
						if (apb.PSEL) next_state = SETUP;
						else		  next_state = IDLE;					
					end 
				end
			end 
				
			default: next_state = IDLE;
		endcase
	end : FSM_comb
  //FlipFlop FSM
	always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
		if (!apb.PRESETn) begin
			current_state <= IDLE;
			apb.PREADY	  <= 1'b0;
		end else begin
			current_state <= next_state;
			case (next_state) 
				ACCESS: apb.PREADY <= (current_state == SETUP) ? !wait_en : 1'b1;
				default: apb.PREADY <= 1'b0;
			endcase
		end
	end : FSM_ff
//DATAPATH
	always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
		if (!apb.PRESETn) begin
			apb.PRDATA <= '0;
		end else begin
			if (wr_en) begin
				for (int i = 0; i < STRB_WIDTH; i++) begin
					if (apb.PSTRB[i]) begin
						mem[apb.PADDR[9:2]][i*8 +: 8] <= apb.PWDATA[i*8 +: 8];
					end
				end
			end else if (rd_en) begin
				apb.PRDATA <= mem[apb.PADDR[9:2]];
			end
		end
	end : Datapath
			
endmodule : apb_slave_mem
