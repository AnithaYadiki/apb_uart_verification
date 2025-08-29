module apb_top;
	
	import uvm_pkg::*;
	import apb_test_pkg::*;
	`include "uvm_macros.svh"
	
	bit clk1;
	always #5 clk1 = ~clk1;

	bit clk2;
	always #10 clk2 = ~clk2;

	uart_if in0(clk1);
	uart_if in1(clk2);
	wire TXD, RXD;

	uart_16550 DUV1 (.PCLK(clk1),
  			.PRESETn(in0.Presetn),
  			.PADDR(in0.Paddr),
  			.PWDATA(in0.Pwdata),
  			.PRDATA(in0.Prdata),
  			.PWRITE(in0.Pwrite),
  			.PENABLE(in0.Penable),
  			.PSEL(in0.Psel),
  			.PREADY(in0.Pready),
  			.PSLVERR(in0.Pslverr),
  			.IRQ(in0.IRQ),
  			.TXD(TXD),
  			.RXD(RXD),
  			.baud_o(in0.baud_o)
  		);

	uart_16550 DUV2 (.PCLK(clk2),
  			.PRESETn(in1.Presetn),
  			.PADDR(in1.Paddr),
  			.PWDATA(in1.Pwdata),
  			.PRDATA(in1.Prdata),
  			.PWRITE(in1.Pwrite),
  			.PENABLE(in1.Penable),
  			.PSEL(in1.Psel),
  			.PREADY(in1.Pready),
  			.PSLVERR(in1.Pslverr),
	  		.IRQ(in1.IRQ),
  			.TXD(RXD),
  			.RXD(TXD),
  			.baud_o(in1.baud_o)
  		);

	
	initial
		begin	

			`ifdef VCS
         		$fsdbDumpvars(0, apb_top);
        		`endif
						
			uvm_config_db #(virtual uart_if)::set(null,"*","in0",in0);
			uvm_config_db #(virtual uart_if)::set(null,"*","in1",in1);
			run_test();
		end
endmodule
	
