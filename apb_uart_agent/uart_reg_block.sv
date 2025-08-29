class uart_reg_block extends uvm_reg_block;
	rand uart_lcr_reg lcr;

	`uvm_object_utils(uart_reg_block)

	function new(string name = "uart_reg_block");
		super.new(name);//,UVM_NO_COVERGAE);
	endfunction

	function void build();
		lcr = uart_lcr_reg::type_id::create("lcr");
		lcr.build();
		lcr.configure(this);
		default_map = create_map("default_map",0,4,UVM_LITTLE_ENDIAN);
		default_map.add_reg(lcr,'h0c,"RW");
		lcr.add_hdl_path_slice("LCR",0,7);
		add_hdl_path("top.dut1.control","KTC");	
	endfunction
endclass
