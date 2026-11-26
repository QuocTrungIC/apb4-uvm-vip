`ifndef APB_SEQUENCER_SV
`define APB_SEQUENCER_SV
class apb_sequencer extends uvm_sequencer #(apb_seq_item);
//Factory
	`uvm_component_utils(apb_sequencer)
//Constructor
	function new(string name ="apb_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
endclass : apb_sequencer
`endif
