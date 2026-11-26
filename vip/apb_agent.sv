`ifndef APB_AGENT_SV
`define APB_AGENT_SV
class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)
	virtual apb_if	vif;
	apb_sequencer 	seqr;
	apb_driver		drv;
	apb_monitor		mon;

	uvm_analysis_port #(apb_seq_item) ap;
//Constructor
	function new(string name ="apb_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
//Build
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ap = new("ap", this);
		if (!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_id(), "[ERROR AGENT] - Can't detect virtual interface")
		//--------------------------------------------------------
		uvm_config_db #(virtual apb_if)::set(this, "mon", "vif", vif);
		mon = apb_monitor::type_id::create("mon", this);
		if (get_is_active() == UVM_ACTIVE) begin
			`uvm_info(get_type_id(), " >>>[AGENT ACTIVE] | Sequencer + Driver + Monitor active")
			//--------------------------------------------------------------------------------------
			uvm_config_db #(virtual apb_if)::set(this, "drv", "vif", vif);
			drv = apb_driver::type_id::create("drv", this);

			seqr = apb_sequencer::type_id::create("seqr", this);
		else begin
			`uvm_info(get_type_id(), " >>>[AGENT PASSIVE] | Only Monitor active", UVM_LOW)
		end
	endfunction : build_phase		
//Connect
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mon.item_collected_port.connect(this.ap);
		//Active mode
		if (get_is_active() == UVM_ACTIVE) begin
			drv.seq_item_port.connect(seqr.seq_item_export);
			`uvm_info(get_type_id(), ">>>[AGENT SUCCESS] - Active | Connect Successfully", UVM_LOW)`
		end
	endfunction : connect_phase
endclass : apb_agent
`endif
