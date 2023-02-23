`timescale 10ps/1ps

module coreTest;
    import cv32e40p_pkg::*;
    import cv32e40p_apu_core_pkg::*;

    // Clock and Reset
    logic       clk_i;
    logic       rst_ni;
    logic       enable_i;
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
    logic [31:0] instr_addr_o;
    logic [31:0] instr_rdata_i;
    
    // Data memory interface
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_rvalid_i;
    logic        data_we_o;
    logic [ 3:0] data_be_o;
    logic [31:0] data_addr_o;
    logic [31:0] data_wdata_o;
    logic [31:0] data_rdata_i;

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

    cv32e40p_core testCore(.*);

    //gerador de clock e reset
    localparam CLKPERIOD = 10000;
    localparam CLKDELAY = CLKPERIOD / 2;

    initial begin
        clk_i = 1'b1;
        rst_ni = 1'b1;
        #(CLKPERIOD)
        #(CLKPERIOD)
        #(CLKPERIOD)
        rst_ni = 1'b0;
    end

    always #(CLKDELAY) clk_i = ~clk_i;

    always_ff @(posedge clk_i or posedge rst_ni) begin  
        //Initial values
        data_rdata_i = 32'b00000000_00000001_01001001_00001000;
        instr_rdata_i = 32'b00000000_00110001_00000011_10110011;

        enable_i = 1'b1;
        pulp_clock_en_i = 1'b0;    // PULP clock enable (only used if PULP_CLUSTER = 1)
        scan_cg_en_i = 1'b1;       // Enable all clock gates for testing

        // CPU Control Signals
        fetch_enable_i = 1'b1;

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
        debug_req_i = 1'b1;

        //instructions
        instr_gnt_i = 1'b1;     //flag para saber se o próximo estágio do pipeline aceitou o request do anterior
        instr_rvalid_i = 1'b1;  //é 1 quando o instr_rdata_i tem um valor válido

        //data
        data_gnt_i = 1'b1;
        data_rvalid_i = 1'b1;

        //if (data_wdata_o == 32'b1111100010101010) begin
        //    $display("Read after write Passed");
        //end else begin
        //    $display("Read after write  Failed");
        //end

        $monitor($time,"\ninstr_addr_o = %b | data_rdata_i = %b\ndata_wdata_o = %b | data_addr_o = %b", instr_addr_o, data_rdata_i, data_wdata_o, data_addr_o);
    end
endmodule: coreTest
