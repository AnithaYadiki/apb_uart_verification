class apb_scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(apb_scoreboard)

	uvm_tlm_analysis_fifo #(apb_uart_xtn) sb_fifo_0; 
	uvm_tlm_analysis_fifo #(apb_uart_xtn) sb_fifo_1; 
	apb_uart_xtn xtn0;
	apb_uart_xtn xtn1;
	uvm_status_e status;
	bit [7:0] reg_lcr;

	function new(string name = "apb_scoreboard", uvm_component parent);
		super.new(name,parent);
		sb_fifo_0 = new("sb_fifo_0");
		sb_fifo_1 = new("sb_fifo_1");
	endfunction

	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		xtn0 = apb_uart_xtn::type_id::create("xtn0");
		xtn1 = apb_uart_xtn::type_id::create("xtn1");
	endfunction
		
	
	task run_phase(uvm_phase phase);
		forever 
			fork
				begin 
					sb_fifo_0.get(xtn0);
				//	`uvm_info("SCOREBOARD","Printing from SEQ1",UVM_LOW);
				//	xtn0.print();
				end
				begin 
					sb_fifo_1.get(xtn1);
				//	`uvm_info("SCOREBOARD","Printing from SEQ2",UVM_LOW);
				//	xtn1.print();
				end
			join

	endtask
	
	function void check_phase(uvm_phase phase);
		$display("uart1 THR size : %d",xtn0.THR.size);
		$display("uart2 THR size : %d",xtn1.THR.size);

		$display("uart1 RBR size : %d",xtn0.RBR.size);
		$display("uart2 RBR size : %d",xtn1.RBR.size);

		$display("uart1 THR : %p",xtn0.THR);
		$display("uart2 THR : %p",xtn1.THR);

		$display("uart1 RBR : %p",xtn0.RBR);
		$display("uart2 RBR : %p",xtn1.RBR);
		
		if((xtn0.IIR[3:0] == 4'b0100) || (xtn1.IIR[3:0] == 4'b0100))
			begin 
				if((xtn0.MCR[4] == 0) || (xtn1.MCR[4] == 0))
					begin 
						if(((xtn0.THR.size == 0) || (xtn1.THR.size == 0)) && ((xtn0.RBR.size == 0) || (xtn1.RBR.size == 0)))
							begin 
								if((xtn0.THR == xtn1.RBR) || (xtn1.THR == xtn0.RBR))
									begin 
										`uvm_info(get_type_name(),"\n COMPARISION PASSED FOR HALF DUPLEX",UVM_LOW);
									end
								else
									begin 
										`uvm_info(get_type_name(),"\n COMPARISION FAILED FOR HALF DUPLEX",UVM_LOW);
									end
							end
						else 
							begin
								if((xtn0.THR == xtn1.RBR) && (xtn1.THR == xtn0.RBR))
									begin
										`uvm_info(get_type_name(),"\n COMPARISION PASSED FOR FULL DUPLEX",UVM_LOW);
									end
								else
									begin
										`uvm_info(get_type_name(),"\n COMPARISION FAILED FOR FULL DUPLEX",UVM_LOW);
									end

							end
					end
				else
					begin
						if((xtn0.THR == xtn0.RBR) || (xtn1.THR == xtn1.RBR))
							begin
								`uvm_info(get_type_name(),"\n COMPARISION PASSED FOR LOOPBACK",UVM_LOW);
							end
						else
							begin
								`uvm_info(get_type_name(),"\n COMPARISION FAILED FOR LOOPBACK",UVM_LOW);
							end
					end



			end
		else
			begin 
				`uvm_info(get_type_name(),"\n COMPARISION DID NOT HAPPEND",UVM_LOW);
			end

	endfunction 

endclass
