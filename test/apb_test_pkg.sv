package apb_test_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"
	
//	`include "source_xtn.sv"
//	`include "router_source_agent_config.sv"
//	`include "router_dest_agent_config.sv"

	`include "apb_uart_xtn.sv"
	`include "uart_apb_agent_config.sv" 
	`include "apb_env_config.sv"

	`include "apb_driver.sv"
	`include "apb_monitor.sv"
	`include "apb_sequencer.sv"
	`include "apb_agent.sv"
//	`include "source_agent_top.sv"
	`include "apb_uart_seqs.sv"

//	`include "dest_xtn.sv"
//	`include "dest_driver.sv"
//	`include "dest_monitor.sv"
//	`include "dest_sequencer.sv"
//	`include "dest_agent.sv"
//	`include "dest_agent_top.sv"
//	`include "dest_sequence.sv"

	`include "uart_reg.sv"
	`include "uart_reg_block.sv"
	`include "apb_scoreboard.sv"

	`include "apb_env.sv"

	`include "apb_test.sv"
endpackage


