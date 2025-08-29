class uart_lcr_reg extends uvm_reg;
	rand uvm_reg_field word_len; 
	rand uvm_reg_field stop_bits;
	rand uvm_reg_field parity_en;
	rand uvm_reg_field even_parity;
	rand uvm_reg_field stick_parity;
	rand uvm_reg_field break_ctrl;
	     uvm_reg_field reserved;

	`uvm_object_utils(uart_lcr_reg)
	
	function new(string name = "uart_lcr_reg");
		super.new(name,8,UVM_NO_COVERAGE);
	endfunction

	virtual function void build();
		//word_len[1:0]
		word_len = uvm_reg_field::type_id::create("word_len");
		word_len.configure(this,2,0,"RW",0,2'h3,1,0,1);
		//2-size, 0-lsb_pos, RW-access, 0-volatile, 2'h3-reset value(reset=0x03=>word_len=3=>8bits,1-has reset, 0-is_rand, 1-individually accessible
	
		//stop_bits[2]
		stop_bits = uvm_reg_field::type_id::create("stop_bits");
		stop_bits.configure(this,1,2,"RW",0,0,1,0,1);

		//parity_en[3]
		parity_en = uvm_reg_field::type_id::create("parity_en",,get_full_name());
		parity_en.configure(this,1,3,"RW",0,0,1,0,0);

		//even_parity[4]
		even_parity = uvm_reg_field::type_id::create("even_parity",,get_full_name());
		even_parity.configure(this,1,4,"RW",0,0,1,0,0);

		//stick_parity[5]
		stick_parity = uvm_reg_field::type_id::create("stick_parity",,get_full_name());
		stick_parity.configure(this,1,5,"RW",0,0,1,0,0);
		
		//break_ctrl[6]
		break_ctrl = uvm_reg_field::type_id::create("break_ctrl",,get_full_name());
		break_ctrl.configure(this,1,6,"RW",0,0,1,0,0);

		//RESERVED[7]
		reserved = uvm_reg_field::type_id::create("reserved",,get_full_name());
		reserved.configure(this,1,7,"RW",0,0,1,0,0);
	endfunction

endclass
