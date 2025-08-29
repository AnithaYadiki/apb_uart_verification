/********************************************************************************************
Copyright 2024 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename                :       uart_tx.v   

module Name             :       uart_tx

Description             :       uart_tx module is designed to manage UART data transmission, 
	                        utilizing a FIFO buffer for data storage and a Finite State Machine
				to handle serial transmission.

Author Name             :       Naveen

Support e-mail          :       For any queries, reach out to us on "techsupport_vm@maven-silicon.com" 

Version                 :       1.0
*********************************************************************************************/

 module uart_tx (
  		input PCLK,
  		input PRESETn,
  		input[7:0] PWDATA,
  		input tx_fifo_push,
  		input[7:0] LCR,
  		input enable,
  		output tx_fifo_empty,
  		output tx_fifo_full,
  		output[4:0] tx_fifo_count,
  		output reg busy,
  		output TXD
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
   
   reg [3:0] tx_state;

   reg[3:0] bit_counter;
   reg[7:0] tx_buffer;
   wire[7:0] tx_fifo_out;
   reg pop_tx_fifo;
   reg TXD_tmp;

   // TX FIFO:
   uart_fifo  tx_fifo (
                      		.clk(PCLK),
                      		.rstn(PRESETn),
                      		.push(tx_fifo_push),
                      		.pop(pop_tx_fifo),
                      		.data_in(PWDATA),
                      		.fifo_empty(tx_fifo_empty),
                      		.fifo_full(tx_fifo_full),
                      		.count(tx_fifo_count),
                      		.data_out(tx_fifo_out)
			);

   // TX FSM:
   always @(posedge PCLK) 
     begin
       if(PRESETn == 1'b0) 
	 begin
    	   tx_state <= IDLE;
    	   bit_counter <= 1'b0;
    	   tx_buffer <= 1'b0;
    	   TXD_tmp <= 1'b1;
    	   pop_tx_fifo <= 1'b0;
    	   busy <= 1'b0;
  	 end
       else 
	 begin
    	   case(tx_state)
      	     IDLE : 
	       begin
              	 if((tx_fifo_empty == 0) && (enable == 1)) 
		   begin
                     tx_state <= START;
                     pop_tx_fifo <= 1'b1;
                     tx_buffer <= tx_fifo_out;
                     busy <= 1'b1;
                     bit_counter <= 4'b0;
              	   end
              	 else 
		   begin
                     busy <= 1'b0;
              	   end
               end
     	     START : 
	       begin
               	 pop_tx_fifo <= 1'b0;
               	 TXD_tmp <= 1'b0;
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= BIT0;
                   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1'b1;
               	   end
               end
      	     BIT0 :	
	       begin
              	 TXD_tmp <= tx_buffer[0];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= BIT1;
               	   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
              	   end
               end
      	     BIT1 : 
	       begin
              	 TXD_tmp <= tx_buffer[1];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= BIT2;
               	   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
               	   end
               end
      	     BIT2 : 
	       begin
                 TXD_tmp <= tx_buffer[2];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= BIT3;
              	   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
               	   end
               end
      	     BIT3 : 
	       begin
              	 TXD_tmp <= tx_buffer[3];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= BIT4;
              	   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
               	   end
               end
      	     BIT4 : 
	       begin
              	 TXD_tmp <= tx_buffer[4];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     if(LCR[1:0] != 0) 
		       begin
                   	 tx_state <= BIT5;
                       end
                     else 
		       begin
                         if(LCR[3] == 1) 
			   begin
                     	     tx_buffer[7:5] <= 0;
                     	     tx_state <= PARITY;
                   	   end
                   	 else 
			   begin
                     	     tx_state <= STOP1;
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
              	 TXD_tmp <= tx_buffer[5];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     if(LCR[1:0] > 2'b01) 
		       begin
                   	 tx_state <= BIT6;
                       end
                     else 
	               begin
                         if(LCR[3] == 1) 
			   begin
                     	     tx_buffer[7:6] <= 0;
                     	     tx_state <= PARITY;
                   	   end
                   	 else 
			   begin
                     	     tx_state <= STOP1;
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
              	 TXD_tmp <= tx_buffer[6];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     if(LCR[1:0] == 2'b11) 
		       begin
                   	 tx_state <= BIT7;
                       end
                     else 
		       begin
                   	 if(LCR[3] == 1) 
			   begin
                     	     tx_buffer[7] <= 0;
                     	     tx_state <= PARITY;
                   	   end
                  	 else 
			   begin
                     	     tx_state <= STOP1;
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
                 TXD_tmp <= tx_buffer[7];
               	 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     if(LCR[3] == 1) 
		       begin
                   	 tx_state <= PARITY;
                       end
                     else 
		       begin
                   	 tx_state <= STOP1;
                       end
               	   end
               	 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
               	   end
               end
      	     PARITY : 
	       begin
                 case(LCR[5:3])
                   3'b001 : TXD_tmp <= ~(^tx_buffer);
                   3'b011 : TXD_tmp <= ^tx_buffer;
                   3'b101 : TXD_tmp <= 1;
                   3'b111 : TXD_tmp <= 0;
                   default : TXD_tmp <= 0;
                 endcase
                 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= STOP1;
                   end
                 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
       	     STOP1 : 
	       begin
                 TXD_tmp <=1'b1;
                 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     if(LCR[2] == 1) 
		       begin
                    	 tx_state <= STOP2;
                       end
                     else 
		       begin
                      	 tx_state <= IDLE;
                       end
                   end
                 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
       	     STOP2 : 
	       begin
                 TXD_tmp <= 1'b1;
                 if((enable == 1) && (bit_counter == 4'hf)) 
		   begin
                     tx_state <= IDLE;
                   end
                 if(enable == 1) 
		   begin
                     bit_counter <= bit_counter + 1;
                   end
               end
       	     default : tx_state <= IDLE;
     	  endcase
        end
     end

   assign TXD=LCR[6]?1'b0:TXD_tmp; //break condition
   
 endmodule
