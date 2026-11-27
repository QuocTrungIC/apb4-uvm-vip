`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV
class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)

	uvm_tlm_analysis_fifo #(apb_seq_item) fifo;
//Config
	bit [31:0] mem [0:255];
	int write_trans	= 0;
	int read_trans 	= 0;
	int match		= 0;
	int mismatch	= 0;
	int total_trans = 0;
//Constructor
	function new(string name ="apb_scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
//Buid
	virtual function void build_phase(uvm_phase phase);	
		super.build_phase(phase);
		fifo = new("fifo", this);
	endfunction : build_phase
//Run
	virtual task run_phase(uvm_phase phase);
		apb_seq_item item;
		forever begin
			fifo.get(item);
			check_transaction(item);
		end
	endfunction : run_phase
//Report
	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(), " ===== SCOREBOARD REPORT =====", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Total Transactions	:	%0d", total_trans), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Match Transactions	:	%0d", match		 ), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Mismatch Transactions	:	%0d", mismatch	 ), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Write Transactions	:	%0d", write_trans), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Read Transactions		:	%0d", read_trans ), UVM_LOW)
		if (mismatch== 0  && match==500 && total_trans== 500)
			`uvm_info(get_type_name(), " ======>[PASSED] ", UVM_LOW)
		else 
			`uvm_error(get_type_name(), " ======>[FAILED]")		
	endfunction : report_phase
//Check
	virtual function void check_transaction(apb_seq_item item);		
		total_trans++;
	    //Write
	  	if (item.pwrite == APB_WRITE) begin
	  		if(!mem.exist(item.addr)) 
	  			mem[item.addr] = 32'd0;
	  		write_trans++;
	  	  //Strobe
	  	  	for (int i = 0; i < 4; i++) begin
	  	  		if (item.pstrb[i] == 1)
	  	  			mem[item.addr][i*8 +: 8] = item.addr[i*8 +: 8];
	  	  		else 
	  	  			mem[item.addr] = item.data;
	  	  	end
	  	end		  		
	  //Read
	  	if (item.pwrite == APB_READ) begin
	  		read_trans++;
	  		if(!mem.exist(item.addr)) 
	  			mem[item.addr] = 32'd0;
	  		if (item.data == mem[item.addr]) 	
	  			match++;
	  		else begin
	  			mismatch++;
	  			`uvm_error(get_type_name(), $sformatf("[SCB READ MISMATCH] || Addr=0x%08h| Expected=0x%08h, Actual=0x%08h", 
	  				  												item.addr, mem[item.addr], item.data))
	  		end	  		
	  	end 	
	endfunction : check_transaction
endmodule : apb_scoreboard
`endif
