`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV
class apb_driver extends uvm_driver #(apb_seq_item);
	`uvm_component_utils(apb_driver)
	virtual apb_vif vif;
//Constructor
	function new(string name="apb_driver", uvm_component parent = null);
		super.build(name, parent);
	endfunction : new
//Build
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual vif)::get::(this, , "vif", vif) begin
			`uvm_fatal(get_type_id(), "[ERROR - DRIVER] | Can't detect virtual interface in Driver ")
		end
	endfunction : build_phase
//Run
	virtual task run_phase(uvm_phase phase);
	  //Config
		vif.PSEL	<= 1'b0; 		//IDLE
		vif.PENABLE <= 1'b0;
		vif.PWRITE  <= 1'b0;
		vif.PWDATA	<= '0;
		vif.PADDR	<= '0;
		vif.STRB	<= '0;

		wait(vif.PRESETn == 1'b1);
		`uvm_info(get_type_id(), " >>>[DRIVER READY] - APB4 Driver ready<<<", UVM_LOW)
			forever begin
				seq_item_port.get_next_item(req);
				drive_transfer(req);
				seq_item_port.finish_item(req);
			end
	endtask : run_phase
//Transfer data
	virtual task drive_transfer(apb_seq_item item);
	  //Setup
	  	vif.PSEL	<= 1'b1;		
	  	vif.PENABLE <= 1'b0;
	  	vif.PWRITE  <= (item.pwrite == APB_WRITE) ? 1'b1 : 1'b0;
	  	vif.PWDATA	<= (item.pwrite == APB_WRITE) ? item.data : '0;
	  	vif.PADDR	<= item.addr;
	  	vif.STRB	<= item.pstrb;	
	  //Access
	  	@(vif.cb);		
	  	vif.PENABLE <= 1'b1;
	  	while (!vif.PREADY) begin
	  		@(vif.cb);
	  	end
	  //Read
	  	if (vif.PWRITE == APB_READ)		item.data <= vif.PRDATA;
	  	`uvm_info(get_type_name(), 
	  						$sformatf("[ACCESS DONE] CMD=%s | Addr=0x%08h | Data=0x%08h | PSLVERR=%0b",
	  						                            (item.pwrite == APB_WRITE) ? "WRITE" : "READ ",
	  						                            item.addr, item.data, item.pslverr), UVM_LOW)
	  //End
	  	@(vif.cb);
	  		vif.PSEL 	<= 1'b0;
	  		vif.PENABLE <= 1'b0;
	endtask : drive_transfer
endclass : apb_driver
`endif
	  		
