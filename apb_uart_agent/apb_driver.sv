class apb_driver extends uvm_driver #(apb_uart_xtn);
	
	`uvm_component_utils(apb_driver)
	uart_apb_agent_config agt_cfg;
	virtual uart_if.DRV_MP vif;


	function new(string name = "apb_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(uart_apb_agent_config)::get(this,"","uart_apb_agent_config",agt_cfg))
			`uvm_fatal("drv","couldnt get agt config()")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif = agt_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		@(vif.drv_cb);	
		vif.drv_cb.Presetn <= 1'b0;
		@(vif.drv_cb);	
		vif.drv_cb.Presetn <= 1'b1;
		forever
			begin
				seq_item_port.get_next_item(req);
				send_to_dut(req);
				seq_item_port.item_done(req);
			end
	endtask	
	
	task send_to_dut(apb_uart_xtn req);
			@(vif.drv_cb);	
			vif.drv_cb.Paddr <= req.Paddr;
			vif.drv_cb.Pwdata <= req.PWdata;
			vif.drv_cb.Pwrite <= req.Pwrite;
			vif.drv_cb.Psel <= 1'b1;
			vif.drv_cb.Penable <=1'b0;
			@(vif.drv_cb);	
			vif.drv_cb.Penable <= 1'b1;
			while(vif.drv_cb.Pready!==1)
			@(vif.drv_cb);	
			if(req.Paddr==32'h8 && req.Pwrite==0)
				begin
					while(vif.drv_cb.IRQ!==1)
						@(vif.drv_cb);	
					req.IIR = vif.drv_cb.Prdata;
					seq_item_port.put_response(req);
				end
		//	`uvm_info("DRIVER",$sformatf("printing from driver \n %s", req.sprint()),UVM_LOW) 

	endtask						
endclass
