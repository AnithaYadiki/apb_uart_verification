class apb_env_config extends uvm_object;

	`uvm_object_utils(apb_env_config)

	uart_apb_agent_config agt_cfg[];
	int no_of_agents;
	bit has_scoreboard;
	uvm_active_passive_enum is_active;
//	uart_reg_block regmodel;

	function new(string name = "apb_env_config");
		super.new(name);
	endfunction
	
endclass
