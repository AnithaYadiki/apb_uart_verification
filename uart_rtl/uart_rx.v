/********************************************************************************************
Copyright 2024 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename                :       uart_rx.v   

module Name             :       uart_rx

Description             :       uart_rx module is designed to receive serial data using UART protocol.

Author Name             :       Naveen

Support e-mail          :       For any queries, reach out to us on "techsupport_vm@maven-silicon.com" 

Version                 :       1.0
*********************************************************************************************/
 module uart_rx(
  		input PCLK,
  		input PRESETn,
  		input RXD,
  		input pop_rx_fifo,
  		input enable,
  		input[7:0] LCR,
  		output reg rx_idle,
  		output[7:0] rx_fifo_out,
  		output[4:0] rx_fifo_count,
  		output reg push_rx_fifo,
  		output rx_fifo_empty,
  		output rx_fifo_full,
  		output reg rx_overrun,
  		output reg parity_error,
  		output reg framing_error,
  		output break_error,
		output time_out
	);

   parameter IDLE=4'b0000;
   parameter START=4'b0001;
   parameter BIT0=4'b0010;
   parameter BIT1=4'b0011;
   parameter BIT2=4'b0100;
   parameter BIT3=4'b0101;
   parameter BIT4=4'b0110;
   parameter BIT5=4'b0111;
   parameter BIT6=4'b1000;
   parameter BIT7=4'b1001;
   parameter PARITY=4'b1010;
   parameter STOP1=4'b1011;
   parameter STOP2=4'b1100;	
   
   reg[3:0] rx_state;
   
   reg parity_bit;
   reg framing_error_temp;
	
   reg[3:0] bit_counter;
   reg[7:0] rx_buffer;

   reg[2:0] filter;
   reg filtered_rxd;

   wire [7:0] brc_value; // value to be set to break counter
   reg [9:0] toc_value; // value to be set to timeout counter

   reg [7:0] counter_b;
   reg [9:0]counter_t;
   
   assign break_error = (counter_b == 0);
   
   assign time_out = (counter_t == 0);
   // RX_FIFO
   uart_fifo  rx_fifo (
                      		.clk(PCLK),
                      		.rstn(PRESETn),
                      		.push(push_rx_fifo),
                      		.pop(pop_rx_fifo),
                      		.data_in(rx_buffer),
                      		.fifo_empty(rx_fifo_empty),
                      		.fifo_full(rx_fifo_full),
                      		.count(rx_fifo_count),
                      		.data_out(rx_fifo_out)
			);

   // RX FSM:

   always @(posedge PCLK) 
     begin
       if(PRESETn == 0) 
	 begin
           rx_state <= IDLE;
           bit_counter <= 0;
           push_rx_fifo <= 0;
           rx_buffer <= 0;
           rx_overrun <= 0;
           parity_error <= 0;
           framing_error <= 0;
           rx_idle <= 1;
         end
       else 
         begin
           case(rx_state)
             IDLE : 
               begin
                 push_rx_fifo <= 0;
                 rx_buffer <= 0;
                 bit_counter <= 0;
                 if(RXD==1'b0 && ~break_error)
                   begin
                     rx_state <= START;
                     rx_idle <= 0;
                   end
                 else 
                   begin
                     rx_idle <= 1;
                   end
               end
             START : 	
               begin
                 if(enable == 1) 
                   begin
		     if((RXD==1'b0) && (bit_counter == 4'hf))     
                       begin
                         rx_state <= BIT0;
                         bit_counter <= 0;
                       end
                     else 
                       begin
		         if(RXD==1'b1)
                           begin
                             rx_state <= IDLE;
                           end
                         else 
                           begin
                             bit_counter <= bit_counter + 1;
                           end
                       end
                   end
               end
             BIT0 : 
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_state <= BIT1;
                     rx_buffer[0] <= RXD;
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             BIT1 : 	
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[1] <= RXD;
                     rx_state <= BIT2;
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             BIT2 : 
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_state <= BIT3;
                     rx_buffer[2] <= RXD;
                   end
                if(enable == 1) 
                  begin
                    bit_counter <= bit_counter + 1;
                  end
               end
             BIT3 : 	
	       begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[3] <= RXD;
                     rx_state <= BIT4;
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             BIT4 : 
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[4] <= RXD;
                     if(LCR[1:0] != 0) 
                       begin
                         rx_state <= BIT5;
                       end
                     else 
                       begin
                         if(LCR[3] == 1) 
                           begin
                             rx_state <= PARITY;
                           end
                         else 
                           begin
                             rx_state <= STOP1;
                           end
                       end
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             BIT5 : 	
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[5] <= RXD;
                     if(LCR[1:0] > 2'b01) 
                       begin
                         rx_state <= BIT6;
                         rx_buffer[5] <= RXD;
                       end
                     else 
                       begin
                         if(LCR[3] == 1) 
                           begin
                             rx_state <= PARITY;
                           end
                         else 
                           begin
                             rx_state <= STOP1;
                           end
                       end
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
      	     BIT6 : 	
               begin
	 	if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[6] <= RXD;
                     if(LCR[1:0] == 2'b11) 
                       begin
                         rx_state <= BIT7;
                       end
                     else 
                       begin
                         if(LCR[3] == 1) 
                           begin
                             rx_state <= PARITY;
                           end
                         else 
                           begin
                             rx_state <= STOP1;
                           end
                       end
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             BIT7 : 	
               begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_buffer[7] <= RXD;
                     if(LCR[3] == 1) 
                       begin
                         rx_state <= PARITY;
                       end
                     else 
                       begin
                         rx_state <= STOP1;
                       end
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             PARITY : 	
	       begin
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_state <= STOP1;
                     parity_bit<=^({rx_buffer,RXD});
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
             STOP1 : 	
               begin
      		 framing_error_temp <= ~RXD;
                 if((enable == 1) && (bit_counter == 4'hf)) 
                   begin
                     rx_state <= STOP2;           
                     case(LCR[5:3])
                       3'b001	: parity_error <= ~parity_bit;
                       3'b011	: parity_error <= parity_bit;
                       3'b101	: parity_error <= 1'b1; // Stick 1
                       3'b111	: parity_error <= 1'b0; // Stick 0
                       default	: parity_error <= 0;
                     endcase	   	     
                   end
                 if(enable == 1) 
                   begin
                     bit_counter <= bit_counter + 1;		     
	           end
               end
             STOP2 : 
               begin
                 push_rx_fifo <= 1;
		 if(break_error)
	           framing_error<=1'b0;
	         else
		   framing_error<=framing_error_temp;
                 rx_state <= IDLE;
                 if(rx_fifo_count == 4'hf) 
                   begin
                     rx_overrun <= 1;
                   end
                 else 
                   begin
                     rx_overrun <= 0;
                   end
               end
             default : rx_state <= IDLE;
     	   endcase
         end
     end

 // Works in conjuction with the receiver state machine

   always @(LCR)
     case(LCR[3:0])
       4'b0000 : toc_value = 10'd447; // 7 bits
       4'b0100 : toc_value = 10'd479; // 7.5 bits
       4'b0001, 4'b1000 : toc_value = 10'd511; // 8 bits
       4'b1100 : toc_value = 10'd543; // 8.5 bits
       4'b0010, 4'b0101, 4'b1001 : toc_value = 10'd575; // 9 bits
       4'b0011, 4'b0110, 4'b1010, 4'b1101 : toc_value = 10'd639; // 10 bits
       4'b0111, 4'b1011, 4'b1110 : toc_value = 10'd703; // 11 bits
       4'b1111 : toc_value = 10'd767; // 12 bits
     endcase 

   assign brc_value = toc_value[9:2]; // the same as timeout but 1 insead of 4 character times

   always @(posedge PCLK) 
     begin
       if(PRESETn==1'b0)
         counter_b <= 8'd159;
       else if (RXD)
         counter_b <= brc_value; // character time length - 1
       else if((enable==1'b1) && (counter_b != 8'b0))            // only work on enable times  break not reached.
         counter_b <= counter_b - 1'b1;  // decrement break counter
     end 

   always @(posedge PCLK)
     begin
       if(PRESETn==1'b0)
         counter_t <= 10'd639; // 10 bits for the default 8N1
       else 
	 if(push_rx_fifo || pop_rx_fifo || rx_fifo_count == 0) // counter is reset when RX FIFO is empty, accessed or above trigger level
           counter_t <= toc_value;
         else 
	   if(enable && counter_t != 10'b0)  // we don't want to underflow
             counter_t <= counter_t - 1;		
     end

 endmodule
