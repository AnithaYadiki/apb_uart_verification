/********************************************************************************************
Copyright 2024 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename                :       uart_fifo.v   

module Name             :       uart_fifo

Description             :       The UART FIFO module manage a First-In-First-Out buffer for UART transmission.

Author Name             :       Naveen

Support e-mail          :       For any queries, reach out to us on "techsupport_vm@maven-silicon.com" 

Version                 :       1.0
*********************************************************************************************/
 module uart_fifo (
  			input clk,
  			input rstn,
  			input push,
  			input pop,
  			input [7:0] data_in,
  			output reg fifo_empty,
  			output reg fifo_full,
  			output reg[4:0] count,
  			output reg[7:0] data_out
		);

   reg[3:0] ip_count;
   reg[3:0] op_count;

   reg [7:0] data_fifo[15:0];

   integer i;

   always @(posedge clk)
     begin
       if(rstn == 1'b0) 
	 begin
      	   count <= 1'b0;
      	   ip_count <= 1'b0;
      	   op_count <= 1'b0;
      	   for(i=0;i<16;i=i+1) 
	     begin
               data_fifo[i] <= 8'b0;
      	     end
    	 end
       else 
	 begin
      	   case({push, pop})
             2'b01 : 
	       begin
                 if(count > 0) 
		   begin
                     op_count <= op_count + 1;
                     count <= count - 1;
                   end
               end
             2'b10 : 
	       begin
                 if(count <= 5'hf) 
		   begin
                     ip_count <= ip_count + 1;
                     data_fifo[ip_count] <= data_in;
                     count <= count + 1;
                   end
               end
             2'b11 : 
	       begin
                 op_count <= op_count + 1;
                 ip_count <= ip_count + 1;
                 data_fifo[ip_count] <= data_in;
               end
      	   endcase
    	 end
     end

   always@(*)
     data_out = data_fifo[op_count];
   
   always@(*)
     fifo_empty = ~(|count);
   
   always@(*)
     fifo_full = (count == 5'b10000);
 
 endmodule
