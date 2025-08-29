class apb_monitor extends uvm_monitor;
	
	`uvm_component_utils(apb_monitor)
	uart_apb_agent_config agt_cfg;
	virtual uart_if.MON_MP vif;
	apb_uart_xtn xtn;
	uvm_analysis_port #(apb_uart_xtn) mon_ap;

	function new(string name = "apb_monitor", uvm_component parent);
		super.new(name,parent);
		mon_ap = new("mon_ap",this);
	
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(uart_apb_agent_config)::get(this,"","uart_apb_agent_config",agt_cfg))
			`uvm_fatal("drv","couldnt get agt config()")
		xtn = apb_uart_xtn::type_id::create("xtn");
	
	endfunction

	function void connect_phase(uvm_phase phase);
		vif = agt_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);	
		forever
			begin
				collect_data(xtn);
			end
	endtask

	task collect_data(apb_uart_xtn xtn);
		@(vif.mon_cb);	
		while(vif.mon_cb.Psel!==1)
		@(vif.mon_cb);
	//	begin
			while(vif.mon_cb.Pready!==1)
			@(vif.mon_cb);
			xtn.Presetn = vif.mon_cb.Presetn;
			xtn.Paddr   = vif.mon_cb.Paddr;
			xtn.Pwrite  = vif.mon_cb.Pwrite;
			xtn.PWdata  = vif.mon_cb.Pwdata;
			xtn.PRdata  = vif.mon_cb.Prdata;
			xtn.Pslverr = vif.mon_cb.Pslverr;
			xtn.Psel    = vif.mon_cb.Psel;
			xtn.Penable = vif.mon_cb.Penable;
			xtn.IRQ     = vif.mon_cb.IRQ;
	
		//	@(vif.mon_cb);
		
			//updating LCR
			if(xtn.Paddr == 32'h0c && xtn.Pwrite == 1'b1) begin
				xtn.LCR = xtn.PWdata;
				$display("LCR DATA",xtn.LCR);
			end
			//updating IER
			if(xtn.Paddr == 32'h04 && xtn.Pwrite == 1'b1) begin
				xtn.IER = xtn.PWdata;
				$display("IER DATA",xtn.IER);
			end

			//updating FCR
			if(xtn.Paddr == 32'h08 && xtn.Pwrite == 1'b1) begin
				xtn.FCR = xtn.PWdata;
				$display("FCR DATA",xtn.FCR);
			end

			//updating IIR
			if(xtn.Paddr == 32'h08 && xtn.Pwrite == 1'b0)
				begin
					while(vif.mon_cb.IRQ !== 1)
					@(vif.mon_cb);
					xtn.IIR = vif.mon_cb.Prdata;
					$display("IIR DATA",xtn.IIR);
				end
	
			//updating MCR
			if(xtn.Paddr == 32'h10 && xtn.Pwrite == 1'b1) begin
				xtn.MCR = xtn.PWdata;
				$display("MCR DATA",xtn.MCR);
			end

			//updating LSR
			if(xtn.Paddr == 32'h14 && xtn.Pwrite == 1'b0) begin
				xtn.LSR = xtn.PRdata;
				$display("LSR DATA",xtn.LSR);
			end

			//updating DIV LSB
			if(xtn.Paddr == 32'h1c && xtn.Pwrite == 1'b1)
				begin
					xtn.divizer[7:0] = xtn.PWdata;		
					xtn.dl_access = 1'b1;
					$display("DIV LSB DATA",xtn.divizer[7:0]);

				end		

			//updating DIV MSB
			if(xtn.Paddr == 32'h20 && xtn.Pwrite == 1'b1)
				begin
					xtn.divizer[15:8] = xtn.PWdata;		
					xtn.dl_access = 1'b1;
					$display("DIV MSB DATA",xtn.divizer[15:8]);
					
				end	
		

			//updating THR
			if(xtn.Paddr == 32'h0 && xtn.Pwrite == 1'b1)
				begin
					xtn.data_in_thr=1'b1;
					if(xtn.PWdata!=0)					
					xtn.THR.push_back(xtn.PWdata);
					$display("THR DATA",xtn.THR);

				end

			//updating RBR
			if(xtn.Paddr == 32'h0 && xtn.Pwrite == 1'b0)
				begin
					xtn.data_in_rbr=1'b1;
					if(vif.mon_cb.Prdata !=0)	
					xtn.RBR.push_back(xtn.PRdata);
					$display("RBR DATA",xtn.RBR);

				end
	//	end	
	//	`uvm_info("MONITOR",$sformatf("printing from monitor \n %s", xtn.sprint()),UVM_LOW) 
		mon_ap.write(xtn);
		
	endtask		
endclass
