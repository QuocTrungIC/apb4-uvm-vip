`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV
class apb_driver extends uvm_driver #(apb_seq_item);
	`uvm_component_utils(apb_driver)
	virtual apb_if vif;
//Constructor
	function new(string name="apb_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
//Build
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "[ERROR - DRIVER] | Can't detect virtual interface in Driver ")
		end
	endfunction : build_phase
//Run
	virtual task run_phase(uvm_phase phase);
	  //Config
		vif.cb_drv.PSEL	<= 1'b0; 		//IDLE
		vif.cb_drv.PENABLE <= 1'b0;
		vif.cb_drv.PWRITE  <= 1'b0;
		vif.cb_drv.PWDATA	<= '0;
		vif.cb_drv.PADDR	<= '0;
		vif.cb_drv.PSTRB	<= '0;

		wait(vif.PRESETn == 1'b1);
		`uvm_info(get_type_name(), " >>>[DRIVER READY] - APB4 Driver ready<<<", UVM_LOW)
			forever begin
				seq_item_port.get_next_item(req);
				drive_transfer(req);
				seq_item_port.item_done();
			end
	endtask : run_phase
//Transfer data
	virtual task drive_transfer(apb_seq_item item);
	  //Setup
	  	@(vif.cb_drv);
	  	vif.cb_drv.PSEL		<= 1'b1;		
	  	vif.cb_drv.PENABLE 	<= 1'b0;
	  	vif.cb_drv.PWRITE  	<= (item.pwrite == APB_WRITE) ? 1'b1 : 1'b0;
	  	vif.cb_drv.PWDATA	<= (item.pwrite == APB_WRITE) ? item.data : '0;
	  	vif.cb_drv.PADDR	<= item.addr;
	  	vif.cb_drv.PSTRB	<= item.pstrb;	
	  //Access
	  	@(vif.cb_drv);		
	  	vif.cb_drv.PENABLE <= 1'b1;
	  	do begin
	  		@(vif.cb_drv);
	  	end while(!vif.cb_drv.PREADY);
	  //Read
	  	if (item.pwrite == APB_READ)		item.data = vif.cb_drv.PRDATA;
	  	item.PSLVERR = vif.cb_drv.PSLVERR;
	  	`uvm_info(get_type_name(), 
	  						$sformatf("[ACCESS DONE] CMD=%s | Addr=0x%08h | Data=0x%08h | PSLVERR=%0b",
	  						                            (item.pwrite == APB_WRITE) ? "WRITE" : "READ ",
	  						                            item.addr, item.data, item.pslverr), UVM_LOW)
	  //End
	  	vif.cb_drv.PSEL 	<= 1'b0;
	  	vif.cb_drv.PENABLE <= 1'b0;
	endtask : drive_transfer
endclass : apb_driver
`endif
	  		
