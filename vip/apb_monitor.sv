`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV
class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)
	virtual apb_if vif;
	uvm_analysis_port #(apb_seq_item) item_collected_port;
	int item_collected = 0;
//Constructor
	function new(string name="apb_monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
//Build
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_collected_port = new("item_collected_port", this);
		if(!uvm_config_db #(virtual vif)::get(this, ,"vif", vif)) begin
			`uvm_fatal(get_type_id(), " >>>[ERROR MONITOR] | Can't detect virtual interface")
	endfunction : build_phase	
//Run
	virtual task run_phase(uvm_phase phase);
		apb_seq_item item;
		wait (vif.PRESETn == 1'b1);
		@(vif.cb);
			`uvm_info(get_type_id(), " >>>[MONITOR] - Ready to Run")
		//----------------------------------------
		forever begin
			@(vif.cb);
			if (vif.PRESETn && vif.PSEL && vif.PENABLE && vif.PREADY) begin
				item_collected++;
				item 			= apb_seq_item::type_id::create("item");
				item.pwrite		= vif.PWRITE ? APB_WRITE : APB_READ;
				item.data		= vif.PWRITE ? vif.PWDATA : vif.PRDATA;
				item.addr		= vif.PADDR;
				item.pstrb		= vif.PSTRB;
				item.pslverr	= vif.PSLVERR;
				//-------------------------------------------------------------
				`uvm_info(get_type_name(),
										$sformatf("[MONITOR COLLECTED #%02d] CMD=%s | Addr=0x%08h | Data=0x%08h | PSTRB=0x%01h | PSLVERR=%0b",
												                      num_collected, (item.pwrite == APB_WRITE) ? "WRITE" : "READ ",
												                                    item.addr, item.data, item.pstrb, item.pslverr), UVM_LOW)
				//Broadcast
				item_collected_port.write(item);    
			end
		end
	endtask : run_phase	
								                                    
endclass : apb_monitor
`endif						
