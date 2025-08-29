class apb_test extends uvm_test;

	`uvm_component_utils(apb_test)
	apb_env env;
	apb_env_config m_cfg;
	uart_apb_agent_config agt_cfg[];
	virtual uart_if vif;
	int no_of_agents = 2;
	bit has_scoreboard = 1;
//	uart_reg_block regmodel;

	function new(string name = "apb_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_cfg=apb_env_config::type_id::create("m_cfg");
		uvm_config_db #(apb_env_config)::set(this,"*","apb_env_config",m_cfg);		
		
		env = apb_env::type_id::create("env",this);

		agt_cfg = new[no_of_agents];
		foreach(agt_cfg[i]) begin
			agt_cfg[i] = uart_apb_agent_config::type_id::create($sformatf("agt_cfg[%0d]",i));
				agt_cfg[i].is_active = UVM_ACTIVE;
				if(!uvm_config_db #(virtual uart_if)::get(this,"",$sformatf("in%0d",i),agt_cfg[i].vif))
					`uvm_fatal("test","coudnt not get interface")
				uvm_config_db #(uart_apb_agent_config)::set(this,$sformatf("env.agt[%0d]*",i),"uart_apb_agent_config",agt_cfg[i]);
			end
		m_cfg.agt_cfg = agt_cfg;
		m_cfg.no_of_agents = no_of_agents;
		m_cfg.has_scoreboard = has_scoreboard;

		//regmodel = uart_reg_block::type_id::create("regmodel");
	//	regmodel.build();
		//m_cfg.regmodel = regmodel;
				
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction: end_of_elaboration_phase

endclass

class full_duplex_test extends apb_test;
	`uvm_component_utils(full_duplex_test)

	full_duplex_seq1 seq1;
	full_duplex_seq2 seq2;

	function new(string name = "full_duplex_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
            super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq1 = full_duplex_seq1::type_id::create("seq1");		
		seq2 = full_duplex_seq2::type_id::create("seq2");	
		fork				
			begin
				seq1.start(env.agt[0].uart_apb_seqr);
			end
			begin
				seq2.start(env.agt[1].uart_apb_seqr);
			end			
		join
		phase.drop_objection(this);
	endtask
endclass 

class half_duplex_test extends apb_test;
	`uvm_component_utils(half_duplex_test)

	half_duplex_seq1 seq1;
	half_duplex_seq2 seq2;

	function new(string name = "half_duplex_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
            super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq1 = half_duplex_seq1::type_id::create("seq1");		
		seq2 = half_duplex_seq2::type_id::create("seq2");	
		fork				
			begin
				seq1.start(env.agt[0].uart_apb_seqr);
			end
			begin
				seq2.start(env.agt[1].uart_apb_seqr);
			end			
		join
		#100;
		phase.drop_objection(this);
	endtask
endclass 


class loopback_test extends apb_test;
	`uvm_component_utils(loopback_test)

	loopback_seq1 seq1;
	loopback_seq2 seq2;

	function new(string name = "loopback_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
            super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq1 = loopback_seq1::type_id::create("seq1");		
		seq2 = loopback_seq2::type_id::create("seq2");	
		fork				
			begin
				seq1.start(env.agt[0].uart_apb_seqr);
			end
			begin
				seq2.start(env.agt[1].uart_apb_seqr);
			end			
		join
	//	#100;
		phase.drop_objection(this);
	endtask
endclass 

