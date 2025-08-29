/********************************************************************************************
Copyright 2024 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename                :       uart_register_file.v   

module Name             :       uart_register_file

Description             :       UART register file interfaced with an APB (Advanced Peripheral Bus). 
	                        It manages control and status registers, handles data transmission 
				and reception, and generates interrupts for various UART events.

Author Name             :       Naveen

Support e-mail          :       For any queries, reach out to us on "techsupport_vm@maven-silicon.com" 

Version                 :       1.0
*********************************************************************************************/
 module uart_register_file (
			   input PCLK,
                           input PRESETn,
                           input PSEL,
                           input PWRITE,
                           input PENABLE,
                           input[4:0] PADDR,
                           input [31:0] PWDATA,
                           output reg[31:0] PRDATA,
                           output reg PREADY,
                           output reg PSLVERR,
                           output reg[7:0] LCR,
                           // Transmitter related signals
                           output reg tx_fifo_we,
                           output tx_enable,
                           input[4:0] tx_fifo_count,
                           input tx_fifo_empty,
                           input tx_fifo_full,
                           input tx_busy,
                           // Receiver related signals
                           input [7:0] rx_data_out,
                           input rx_idle,
                           input rx_overrun,
                           input parity_error,
                           input framing_error,
                           input break_error,
			   input time_out,
                           input[4:0] rx_fifo_count,
                           input rx_fifo_empty,
                           input rx_fifo_full,
                           input push_rx_fifo,
                           output rx_enable,
                           output reg rx_fifo_re,
                           // Modem interface related signals
                           output loopback,
                           output reg irq,
                           output baud_o
                          );

   // Include defines for addresses and offsets

   `define DR 5'h0
   `define IER 5'h1
   `define IIR 5'h2
   `define FCR 5'h2
   `define LCR 5'h3
   `define MCR 5'h4
   `define LSR 5'h5
   `define MSR 5'h6
   `define DIV1 5'h7
   `define DIV2 5'h8

   parameter IDLE=2'b00;
   parameter SETUP=2'b01;
   parameter ACCESS=2'b10;
   
   reg we;
   reg re;
   
   // RX FIFO over its threshold:
   reg rx_fifo_over_threshold;
   
   // UART Registers:
   reg[3:0] IER;
   reg[3:0] IIR;
   reg[7:0] FCR;
   reg[4:0] MCR;
   reg[7:0] MSR;
   reg[3:0] LSR;
   reg[15:0] DIVISOR;
   
   // Baudrate counter
   reg[15:0] dlc;
   reg enable;
   reg start_dlc;
   
   reg tx_int;
   reg rx_int;
   
   reg ls_int;
   
   reg last_tx_fifo_empty;
   
   // APB Bus interface FSM:
   
   reg[1:0] fsm_state;
   
   always @(posedge PCLK)
     begin
       if(PRESETn == 1'b0)
         begin
           we <= 1'b0;
	   re <= 1'b0;
	   PREADY <= 1'b0;
	   fsm_state <= IDLE;
         end
       else
	 case (fsm_state)
           IDLE: 
             begin
	       we <= 1'b0;
	       re <= 1'b0;
	       PREADY <= 1'b0;
               if(PSEL)
		 fsm_state <= SETUP;
             end
           SETUP: 
             begin
               re <= 1'b0;
               if(PSEL && PENABLE)
                 begin
                   fsm_state <= ACCESS;
                   if(PWRITE)
                     we <= 1'b1;
                 end
               else
		 begin
                   fsm_state <= IDLE;
		   we<=1'b0;
		 end
             end
           ACCESS: 
	     begin
               PREADY <= 1'b1;
               we <= 1'b0;
               if(PWRITE == 1'b0)
                 re <= 1'b1;
               fsm_state <= IDLE;
             end
           default: fsm_state <= IDLE;
      	 endcase
     end

   //One clock pulse per enable
   assign baud_o = ~PCLK && enable;

   // Interrupt line
   always @(posedge PCLK)
     begin
       if(PRESETn == 1'b0) 
	 begin
           irq <= 1'b0;
         end
       else if((re == 1'b1) && (PADDR == `IIR)) 
         begin
	   irq <= 1'b0;
    	 end
       else 
	 begin
      	   irq <= (IER[0] & rx_int) | (IER[1] & tx_int) | (IER[2] & ls_int) | time_out;  // (IER[3] & ms_int)
    	 end
     end
  // Loopback:
  assign loopback = MCR[4];

  // The register implementations:
  // TX Data register strobe
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
        begin
          tx_fifo_we <= 1'b0;
        end
      else 
	begin
	  if((we == 1'b1) && (PADDR == `DR)) 
	    begin
              tx_fifo_we <= 1'b1;
      	    end
      	  else 
	    begin
              tx_fifo_we <= 1'b0;
      	    end
    	end
    end

  // DIVISOR - baud rate divider

  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
        begin
          DIVISOR <= 1'b0;
      	  start_dlc <= 1'b0;
        end
      else 
        begin
      	  if(we == 1'b1) 
	    begin
              case(PADDR)
          	`DIV1: 
		   begin
                     DIVISOR[7:0] <= PWDATA[7:0];
                     start_dlc <= 1'b1;
                   end
                `DIV2: 
		   begin
                     DIVISOR[15:8] <= PWDATA[7:0];
                   end
              endcase
      	    end
      	  else 
	    begin
              start_dlc <= 1'b0;
      	    end
    	end
    end

  // LCR - Line control register
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
        begin
          LCR <= 1'b0;
    	end
      else 
	begin
      	  if((we == 1'b1) && (PADDR == `LCR)) 
	    begin
              LCR <= PWDATA[7:0];
      	    end
    	end
    end

  // MCR - Control register
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
      	  MCR <= 1'b0;
        end
      else 
	begin
      	  if((we == 1'b1) && (PADDR == `MCR)) 
	    begin
              MCR <= PWDATA[4:0];
      	    end
    	end
    end

  // FCR - FIFO Control Register:
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
      	  FCR <= 8'hc0;
    	end
      else 
	begin
      	  if((we == 1'b1) && (PADDR == `FCR)) 
	    begin
              FCR <= PWDATA[7:0];
      	    end
    	end
    end

  // IER - Interrupt Masks:
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
      	  IER <= 1'b0;
    	end
      else 
	begin
      	  if((we == 1'b1) && (PADDR == `IER)) 
	    begin
              IER <= PWDATA[3:0];
      	    end
    	end
    end

  // Read back path:
  always@(*) 
    begin
      PSLVERR = 1'b0;
      case(PADDR)
      	`DR	: PRDATA = {24'h0, rx_data_out};
      	`IER	: PRDATA = {28'h0, IER};
      	`IIR	: PRDATA = {28'hc, IIR};
      	`LCR	: PRDATA = {24'h0, LCR};
      	`MCR	: PRDATA = {28'h0, MCR};
      	`LSR	: PRDATA = {24'h0, (parity_error | framing_error | break_error) , (tx_fifo_empty & ~tx_busy), tx_fifo_empty, LSR, ~rx_fifo_empty};
      	`MSR	: PRDATA = {24'h0, MSR};
      	`DIV1	: PRDATA = {24'h0, DIVISOR[7:0]};
      	`DIV2	: PRDATA = {24'h0, DIVISOR[15:8]};
      	default	: 
	  begin
            PRDATA = 32'h0;
	    PSLVERR = 1'b1;
          end
      endcase
    end
  
  // Read pulse to pop the Rx Data FIFO
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0)
    	rx_fifo_re <= 1'b0;
      else
  	if(rx_fifo_re) // restore the signal to 0 after one clock cycle
          rx_fifo_re <= 1'b0;
  	else
  	  if((re) && (PADDR == `DR ))
    	    rx_fifo_re <= 1'b1; // advance read pointer
    end

  // LSR RX error bits
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
        begin
    	  ls_int <= 1'b0;
    	  LSR <= 1'b0;
  	end
      else 
	begin
    	  if((PADDR == `LSR) && (re == 1'b1)) 
	    begin
      	      LSR <= 1'b0;
      	      ls_int <= 1'b0;
    	    end
    	  else if(re == 1'b1) 
	    begin
              LSR<={break_error,framing_error,parity_error,rx_overrun};
              ls_int<=|{break_error,framing_error,parity_error,rx_overrun};	      
    	    end
    	  else 
	    begin
      	      ls_int <= |LSR;
	      LSR<=LSR;
    	    end
  	end
    end

  // Interrupt Identification register
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
    	  IIR <= 4'h1;
  	end
      else 
        begin
    	  if((ls_int == 2'b1) && (IER[2] == 1'b1)) 
	    begin
      	      IIR <= 4'h6;
    	    end
    	  else if((rx_int == 1'b1) && (IER[0] == 1'b1)) 
	    begin
      	      IIR <= 4'h4;
    	    end
	  else if(time_out == 1'b1)
            begin
	      IIR <= 4'hc;
	    end
    	  else if((tx_int == 1'b1) && (IER[1] == 1'b1)) 
	    begin
      	      IIR <= 4'h2;
    	    end
    	  else 
	    begin
      	      IIR <= 4'h1;
    	    end
  	end
    end

  // Baud rate generator:
  // Frequency divider
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0)
        dlc <= #1 0;
      else
        if(start_dlc | ~ (|dlc))
          dlc <= DIVISOR - 1;               // preset counter
        else
      	  dlc <= dlc - 1;              // decrement counter
    end

  // Enable signal generation logic
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0)
    	enable <= 1'b0;
      else
    	if(|DIVISOR & ~(|dlc))     // dl>0 & dlc==0
      	  enable <= 1'b1;
   	else
      	  enable <= 1'b0;
    end

  assign tx_enable = enable;

  assign rx_enable = enable;

  // Interrupts
  // TX Interrupt - Triggered when TX FIFO contents below threshold
  //                Cleared by a write to the interrupt clear bit
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
      	  tx_int <= 1'b0;
      	  last_tx_fifo_empty <= 1'b0;
        end
      else 
	begin
      	  last_tx_fifo_empty <= tx_fifo_empty;
      	  if((re == 1) && (PADDR == `IIR) && (PRDATA[3:0] == 4'h2)) 
	    begin
              tx_int <= 1'b0;
      	    end
      	  else 
	    begin
              tx_int <= (tx_fifo_empty & ~last_tx_fifo_empty) | tx_int;
      	    end
        end
    end

  // RX Interrupt - Triggered when RX FIFO contents above threshold
  //                Cleared by a write to the interrupt clear bit
  always @(posedge PCLK)
    begin
      if(PRESETn == 1'b0) 
	begin
      	  rx_int <= 1'b0;
    	end
      else 
	begin
      	  rx_int <= rx_fifo_over_threshold;
    	end
    end

  // RX FIFO over its threshold
  always@(*)
    case(FCR[7:6])
      2'h0	: rx_fifo_over_threshold = (rx_fifo_count >= 1);
      2'h1	: rx_fifo_over_threshold = (rx_fifo_count >= 4);
      2'h2	: rx_fifo_over_threshold = (rx_fifo_count >= 8);
      2'h3	: rx_fifo_over_threshold = (rx_fifo_count >= 14);
      default	: rx_fifo_over_threshold = 0;
    endcase

 endmodule
