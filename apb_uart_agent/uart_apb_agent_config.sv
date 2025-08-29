class uart_apb_agent_config extends uvm_object;

	`uvm_object_utils(uart_apb_agent_config)

	uvm_active_passive_enum is_active;
	virtual uart_if vif;

	function new(string name = "uart_apb_agent_config");
  		super.new(name);
	endfunction: new
endclass
