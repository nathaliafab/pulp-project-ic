`timescale 1ps/1ps

module coreTest;
    import cv32e40p_pkg::*;
    import cv32e40p_apu_core_pkg::*;

    // Clock and Reset
    logic       clk_i;
    logic       rst_ni;
    //logic       enable_i;
    logic       pulp_clock_en_i;    // PULP clock enable (only used if PULP_CLUSTER = 1)
    logic       scan_cg_en_i;       // Enable all clock gates for testing
    
    // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
    logic [31:0] boot_addr_i;
    logic [31:0] mtvec_addr_i;
    logic [31:0] dm_halt_addr_i;
    logic [31:0] hart_id_i;
    logic [31:0] dm_exception_addr_i;
    
    // Instruction memory interface
    logic        instr_req_o;
    logic        instr_gnt_i;
    logic        instr_rvalid_i;
    reg [31:0] instr_addr_o;
    reg [31:0] instr_rdata_i;
    
    // Data memory interface
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_rvalid_i;
    logic        data_we_o;
    logic [ 3:0] data_be_o;
    wire [31:0] data_addr_o;
    wire [31:0] data_wdata_o;
    reg [31:0] data_rdata_i;

        // apu-interconnect
    // handshake signals
    logic                              apu_req_o;
    logic                              apu_gnt_i;
    // request channel
    logic [   APU_NARGS_CPU-1:0][31:0] apu_operands_o;
    logic [     APU_WOP_CPU-1:0]       apu_op_o;
    logic [APU_NDSFLAGS_CPU-1:0]       apu_flags_o;
    // response channel
    logic                              apu_rvalid_i;
    logic [                31:0]       apu_result_i;
    logic [APU_NUSFLAGS_CPU-1:0]       apu_flags_i;

    // Interrupt inputs
    logic [31:0] irq_i;  // CLINT interrupts + CLINT extension interrupts
    logic        irq_ack_o;
    logic [ 4:0] irq_id_o;

    // Debug Interface
    logic debug_req_i;
    logic debug_havereset_o;
    logic debug_running_o;
    logic debug_halted_o;

    // CPU Control Signals
    logic fetch_enable_i;
    logic core_sleep_o;

    reg Wr;

    cv32e40p_core testCore(.*);
    Memoria32 meminst (.raddress(instr_rdata_i), .waddress(data_wdata_o), .Clk(clk_i), .Datain(data_rdata_i), .Dataout(instr_addr_o), .Wr(Wr));

    //gerador de clock e reset
    localparam CLKPERIOD = 10000;
    localparam CLKDELAY = CLKPERIOD / 2;

    initial begin
        //enable_i = 1'b1;
        pulp_clock_en_i = 1'b1;    // PULP clock enable (only used if PULP_CLUSTER = 1)
        scan_cg_en_i = 1'b1;       // Enable all clock gates for testing

        // CPU Control Signals
        //fetch_enable_i = 1'b1;

        // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
        boot_addr_i = PC_BOOT;
        mtvec_addr_i = 32'b0;
        dm_halt_addr_i = 32'b0;
        hart_id_i = 32'b0;
        dm_exception_addr_i = 32'b0;

        // apu-interconnect
        // handshake signals
        apu_gnt_i = 1'b1;
        apu_rvalid_i = 1'b1;

        // Interrupt inputs
        irq_i = 32'b0;  // CLINT interrupts + CLINT extension interrupts

        // Debug Interface
        debug_req_i = 1'b0;

        //instructions
        instr_gnt_i = 1'b1;     //flag para saber se o próximo estágio do pipeline aceitou o request do anterior
        instr_rvalid_i = 1'b1;  //é 1 quando o instr_rdata_i tem um valor válido

        //data
        data_gnt_i = 1'b1;
        data_rvalid_i = 1'b1;

        clk_i = 1'b1;
        rst_ni = 1'b1;
        #(CLKPERIOD)
        rst_ni = 1'b0;
        fetch_enable_i = 1'b1;
        #(CLKPERIOD)
        fetch_enable_i = 1'b0;
        #(CLKPERIOD)
        #(CLKPERIOD)
        #(CLKPERIOD)
        #(CLKPERIOD)
        #(CLKPERIOD)
        #(CLKPERIOD)
        rst_ni = 1'b1;
    end

    always #(CLKDELAY) clk_i = ~clk_i;

    //realiza a leitura
    always_ff @(posedge clk_i or negedge rst_ni) begin  
        
        if(rst_ni) begin
            instr_rdata_i <= 0;
            //data_rdata_i <= 0;
		end 

		else begin
            instr_rdata_i <= 32'b00000011111111000111110001111011;//addi
            data_rdata_i <= 32'b00000000000000000000000000000011;

            // if(instr_rdata_i < 64) instr_rdata_i <= instr_rdata_i + 4;
            // else begin
            //     instr_rdata_i <= 0;
            //     $stop;
            // end
        end
    end
endmodule: coreTest
