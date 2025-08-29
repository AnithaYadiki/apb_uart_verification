interface uart_if(input bit clk);

	logic Presetn;
	logic [31:0] Paddr;
	bit Psel;
	bit Pwrite;
	bit Penable;
	logic [31:0] Pwdata;
	logic [31:0] Prdata;
	logic Pready;
	logic Pslverr;
	bit IRQ;
//	logic TXD;
//	logic RXD;
	logic baud_o;
	
	clocking drv_cb @(posedge clk);
		default input #1 output #1;
		output Presetn;
		output Paddr;
		output Psel;
		output Pwrite;
		output Penable;
		output Pwdata;
		input Pready;
		input Pslverr;
		input Prdata;
		input IRQ;
		input baud_o;
	//	output RXD;
	endclocking

	clocking mon_cb @(posedge clk);
		default input #1 output #1;
		input Presetn;
		input Paddr;
		input Psel;
		input Pwrite;
		input Penable;
		input Pwdata;
		input Pready;
		input Pslverr;
		input Prdata;
	//	input TXD;
		input baud_o;
		input IRQ;
	endclocking

	modport DRV_MP(clocking drv_cb);
	modport MON_MP(clocking mon_cb);

endinterface
