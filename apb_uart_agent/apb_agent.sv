class apb_agent extends uvm_agent;
	
	`uvm_component_utils(apb_agent)

	uart_apb_agent_config agt_cfg;

	apb_driver uart_apb_drv;
	apb_monitor uart_apb_mon;
	apb_sequencer uart_apb_seqr;

	function new(string name = "apb_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(uart_apb_agent_config)::get(this,"","uart_apb_agent_config",agt_cfg))
			`uvm_fatal("agent","couldn't get uart_apb_agent_config")
		uart_apb_drv = apb_driver::type_id::create("uart_apb_drv",this);
		if(agt_cfg.is_active)
			begin
				uart_apb_mon = apb_monitor::type_id::create("uart_apb_mon",this);
				uart_apb_seqr = apb_sequencer::type_id::create("uart_apb_seqr",this);
			end
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(agt_cfg.is_active)
			uart_apb_drv.seq_item_port.connect(uart_apb_seqr.seq_item_export);
	endfunction
endclass
