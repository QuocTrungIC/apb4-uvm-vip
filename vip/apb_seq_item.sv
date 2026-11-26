`ifndef APB_SEQ_ITEM
`define APB_SEQ_ITEM
class apb_seq_item extends uvm_sequence_item;
//Config
	rand bit [31:0]		data;
	rand bit [31:0]		addr;
	rand apb_write_e	pwrite;
	rand bit [3:0]		strb;
//Constraint
	constraint addr_align {
		addr[1:0] == 2'b00;
		addr inside {[32'h0000_0000 : 32'h0000_03FF]};
	}
//Factory
	`uvm_object_utils_begin(apb_seq_item)
		`uvm_field_int 		(addr, UVM_ALL_ON | UVM_HEX)
		`uvm_field_int 		(data, UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum 	(apb_write_e ,pwrite, UVM_ALL_ON)
		`uvm_field_int 		(strb, UVM_ALL_ON | UVM_BIN)
	`uvm_object_utils_end
//Construction
	function new(string name="apb_seq_item");
		super.new(name);
	endfunction : new
	
endclass : apb_seq_item
`endif
