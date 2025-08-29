class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)

	apb_env_config m_cfg;
	uart_apb_agent_config agt_cfg;
	apb_scoreboard sb;
	apb_agent agt[];
	int num;
	
	function new(string name = "apb_env", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(apb_env_config)::get(this,"","apb_env_config",m_cfg))
			`uvm_fatal("agent","couldn't get env config")
		
		sb = apb_scoreboard::type_id::create("sb",this);
		num = m_cfg.no_of_agents;
		agt = new[num];
		foreach(agt[i])
			agt[i] = apb_agent::type_id::create($sformatf("agt[%0d]",i),this);
	endfunction

	function void connect_phase(uvm_phase phase);
		agt[0].uart_apb_mon.mon_ap.connect(sb.sb_fifo_0.analysis_export);
		agt[1].uart_apb_mon.mon_ap.connect(sb.sb_fifo_1.analysis_export);

	endfunction 


endclass
