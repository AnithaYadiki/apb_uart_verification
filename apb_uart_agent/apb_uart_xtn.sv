class apb_uart_xtn extends uvm_sequence_item;
	`uvm_object_utils(apb_uart_xtn)

	//APB SIGNAL
	bit Pclk;
	bit IRQ;
	bit Presetn;
	bit Psel;
	bit Penable;
	bit [31:0] PRdata;
	bit Pready;
	bit Pslverr;
	rand bit [31:0] Paddr;
	rand bit Pwrite;
	rand bit [31:0] PWdata;
	bit data_in_thr;
	bit data_in_rbr;
	bit dl_access;
	bit [15:0] divizer;

	//UART REGISTERS
	bit [7:0] RBR[$];
	bit [7:0] THR[$];
	bit [7:0] IER;
	bit [7:0] IIR;
	bit [7:0] FCR;
	bit [7:0] LCR;
	bit [7:0] MCR;
	bit [7:0] LSR;
	bit [7:0] MSR;
	bit [7:0] DIV_MSB;
	bit [7:0] DIV_LSB;

	function new(string name = "apb_uart_xtn");

		super.new(name);
	endfunction

	function void do_print(uvm_printer printer);
		super.do_print(printer);
		printer.print_field("Pclk",		this.Pclk,	1,	UVM_DEC);
		printer.print_field("IRQ",		this.IRQ,	1,	UVM_DEC);
		printer.print_field("Presetn",		this.Presetn,	1,	UVM_DEC);
		printer.print_field("Psel",		this.Psel,	1,	UVM_DEC);
		printer.print_field("Penable",		this.Penable,	1,	UVM_DEC);
		printer.print_field("PRdata",		this.PRdata,	32,	UVM_DEC);
		printer.print_field("Pready",		this.Pready,	1,	UVM_DEC);
		printer.print_field("Pslverr",		this.Pslverr,	1,	UVM_DEC);
		printer.print_field("Paddr",		this.Paddr,	32,	UVM_HEX);
		printer.print_field("Pwrite",		this.Pwrite,	1,	UVM_BIN);
		printer.print_field("PWdata",		this.PWdata,	32,	UVM_BIN);
		printer.print_field("IER",		this.IER,	8,	UVM_DEC);
		printer.print_field("IIR",		this.IIR,	8,	UVM_DEC);
		printer.print_field("FCR",		this.FCR,	8,	UVM_DEC);
		printer.print_field("LCR",		this.LCR,	8,	UVM_DEC);
		printer.print_field("MCR",		this.MCR,	8,	UVM_DEC);
		printer.print_field("LSR",		this.LSR,	8,	UVM_DEC);
		printer.print_field("MSR",		this.MSR,	8,	UVM_DEC);
		printer.print_field("DIV_MSB",		this.DIV_MSB,	8,	UVM_DEC);
		printer.print_field("DIV_LSB",		this.DIV_LSB,	8,	UVM_DEC);
		printer.print_field("data_in_thr",	this.data_in_thr,1,	UVM_DEC);
		printer.print_field("data_in_rbr",	this.data_in_rbr,1,	UVM_DEC);
		printer.print_field("dl_access",	this.dl_access,	1,	UVM_DEC);
		printer.print_field("divizer",		this.divizer,	16,	UVM_DEC);
		foreach(RBR[i])
			printer.print_field($sformatf("RBR[%0d]",i),this.RBR[i],$bits(RBR[i]),UVM_DEC);
		foreach(THR[i])
			printer.print_field($sformatf("THR[%0d]",i),this.THR[i],$bits(THR[i]),UVM_DEC);

		

	endfunction

endclass


