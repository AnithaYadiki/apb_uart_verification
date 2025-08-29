class apb_uart_seqs extends uvm_sequence #(apb_uart_xtn);
	`uvm_object_utils(apb_uart_seqs)
	apb_uart_xtn req;
	
	function new(string name = "apb_uart_seqs");
		super.new(name);
	endfunction
endclass

class full_duplex_seq1 extends apb_uart_seqs;
	`uvm_object_utils(full_duplex_seq1)

	function new(string name = "full_duplex_seq1");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd54;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//THR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h00;PWdata inside {[1:255]};})
		finish_item(req);

		//IIR
		start_item(req);
		assert(req.randomize with {Pwrite==0;Paddr==32'h08;})
		finish_item(req);
		get_response(req);
	
		if(req.IIR[3:0]==6) begin//0X6 is code for recieve line status[interrupt type] & interrupt source of parity,overrun or framing errors or break detected
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h14;})//14 is address for LSR
			finish_item(req);
		end
			
		if(req.IIR[3:0]==4) begin//0x4 is code for recieve data available[interrupt typr] &interrupt source is RX FIFO trigger level reached
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h00;})//00 is addres RBR
			finish_item(req);
		end



	endtask
endclass

class full_duplex_seq2 extends apb_uart_seqs;
	`uvm_object_utils(full_duplex_seq2)

	function new(string name = "full_duplex_seq2");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd27;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//THR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h00;PWdata inside {[1:255]};})
		finish_item(req);
		
		//IIR
		start_item(req);
		assert(req.randomize with {Pwrite==0;Paddr==32'h08;})
		finish_item(req);
		get_response(req);
	
		if(req.IIR[3:0]==6) begin//0X6 is code for recieve line status[interrupt type] & interrupt source of parity,overrun or framing errors or break detected
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h14;})//14 is address for LSR
			finish_item(req);
		end
			
		if(req.IIR[3:0]==4) begin//0x4 is code for recieve data available[interrupt type] &interrupt source is RX FIFO trigger level reached
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h00;})//00 is addres RBR
			finish_item(req);
		end

	endtask

endclass


class half_duplex_seq1 extends apb_uart_seqs;
	`uvm_object_utils(half_duplex_seq1)

	function new(string name = "half_duplex_seq1");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd54;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//THR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h00;PWdata inside {[1:255]};})
		finish_item(req);
	
	endtask

endclass

class half_duplex_seq2 extends apb_uart_seqs;
	`uvm_object_utils(half_duplex_seq2)

	function new(string name = "half_duplex_seq2");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd27;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//IIR
		start_item(req);
		assert(req.randomize with {Pwrite==0;Paddr==32'h08;})
		finish_item(req);
		get_response(req);
	
		if(req.IIR[3:0]==4) begin//0x4 is code for interrupt source of type RX FIFO trigger level 
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h00;})//00 is addres FCR
			finish_item(req);
		end

		if(req.IIR[3:0]==6) begin//0X6 is code for interrupt source of type recieve line status
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h14;})//14 is address for LSR
			finish_item(req);
		end

	endtask

endclass

class loopback_seq1 extends apb_uart_seqs;
	`uvm_object_utils(loopback_seq1)

	function new(string name = "loopback_seq1");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd54;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h10;PWdata==8'd00010000;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//THR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h00;PWdata inside {[1:255]};})
		finish_item(req);

		//IIR
		start_item(req);
		assert(req.randomize with {Pwrite==0;Paddr==32'h08;})
		finish_item(req);
		get_response(req);
	
		if(req.IIR[3:0]==6) begin//0X6 is code for recieve line status[interrupt type] & interrupt source of parity,overrun or framing errors or break detected
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h14;})//14 is address for LSR
			finish_item(req);
		end
			
		if(req.IIR[3:0]==4) begin//0x4 is code for recieve data available[interrupt typr] &interrupt source is RX FIFO trigger level reached
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h00;})//00 is addres RBR
			finish_item(req);
		end



	endtask
endclass


class loopback_seq2 extends apb_uart_seqs;
	`uvm_object_utils(loopback_seq2)

	function new(string name = "loopback_seq2");
		super.new(name);
	endfunction
	
	task body();
		req = apb_uart_xtn::type_id::create("req");

		//DIV-MSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h20;PWdata==8'd0;})
		finish_item(req);

		//DIV-LSB
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h1c;PWdata==8'd27;})
		finish_item(req);

		//LCR (NORMAL-MODE)
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h0c;PWdata==8'b00000011;})
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h08;PWdata==8'b00000110;})
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h10;PWdata==8'd00010000;})
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h04;PWdata==8'b00000101;})
		finish_item(req);

		//THR
		start_item(req);
		assert(req.randomize with {Pwrite==1;Paddr==32'h00;PWdata inside {[1:255]};})
		finish_item(req);
		
		//IIR
		start_item(req);
		assert(req.randomize with {Pwrite==0;Paddr==32'h08;})
		finish_item(req);
		get_response(req);
	
		if(req.IIR[3:0]==6) begin//0X6 is code for recieve line status[interrupt type] & interrupt source of parity,overrun or framing errors or break detected
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h14;})//14 is address for LSR
			finish_item(req);
		end
			
		if(req.IIR[3:0]==4) begin//0x4 is code for recieve data available[interrupt type] &interrupt source is RX FIFO trigger level reached
			start_item(req);
			assert(req.randomize with {Pwrite==0;Paddr==32'h00;})//00 is addres RBR
			finish_item(req);
		end

	endtask

endclass

