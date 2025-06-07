`timescale 1ns / 1ps

`include "PC.sv"
`include "instmemory.sv"
`include "registerfile.sv"
`include "RISCVALU.sv"
`include "datamem.sv"
`include "signext.sv"

module datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic        jal_active,
    input  logic        jalr_active,

    // Control Signals from Control Unit
    input  logic        reg_write_en,    // Enable writing to register file
    input  logic        mem_read_en,     // Enable reading from data memory
    input  logic        mem_write_en,    // Enable writing to data memory
    input  logic        alu_src_b,       // Selects ALU's second operand (0: RegData2, 1: SignExtendedImm)
    input  logic [1:0]  mem_to_reg_sel,  // Selects data for WriteBack (00: ALUOut, 01: MemReadData, 10: PC+4 for JAL)
    input  logic        branch_en,       // Enable branching (modifies PC)
    input  logic [3:0]  alu_op_ctrl,     // ALU operation control from alu_control module
    input  logic        zero_test_signal,

    input  logic        pc_write_en,     // Enable writing to PC (for jumps/branches)
    input  logic [1:0]  pc_sel,          // Selects PC source (0: PC+4/BranchAddr, 1: JumpAddr from ALU for JALR)

    // Outputs to Control Unit
    output logic [31:0] instruction_out, // Current instruction
    output logic        alu_zero_flag,   // Zero flag from ALU
    output logic        last_instr_flag_out, // From instruction memory

    // Outputs for top-level (if any, e.g. for testing)
    output logic [31:0] current_pc_out
);

    // Internal Wires
    logic signed [31:0] pc_current_val;
    logic signed [31:0] pc_plus_4_val;
    logic signed [31:0] pc_target_branch_val;
    logic signed [31:0] next_pc_val;
    logic signed [31:0] branch_addr_val;
    logic signed [31:0] jump_addr_val;
    logic signed [31:0] jumpR_addr_val;

    logic [31:0] instr_fetched;

    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic signed [31:0] reg_data_1, reg_data_2;
    logic signed [31:0] sign_extended_imm;

    logic signed [31:0] alu_input_a, alu_input_b;
    logic signed [31:0] alu_result;

    logic [31:0] mem_address;
    logic signed [31:0] mem_write_data;
    logic signed [31:0] mem_read_data_out;

    logic signed [31:0] data_to_reg_write;

    logic is_jalr, is_jal;

    // Assign instruction fields (assuming instruction_out is available)

    // --- Nueva lógica de PC ---
    // Señales para selección de próximo PC

    // MUX de selección de próximo PC

    PC modPC (
        .clk(clk),
        .reset(rst),
        .finish_flag(last_instr_flag_out),
        .next_pc(next_pc_val),
        .pc_reg(pc_current_val)
    );
    assign current_pc_out = pc_current_val;
    // --- Fin nueva lógica de PC ---

    // Instruction Memory
    instmemory modInstm (
        .addr(pc_current_val),
        .instruct(instr_fetched),
        .last_instr_flag(last_instr_flag_out)
    );
    assign instruction_out = instr_fetched;
    assign rs1_addr = instr_fetched[19:15];
    assign rs2_addr = instr_fetched[24:20];
    assign rd_addr  = instr_fetched[11:7];

    // Register File
    registerfile modregfile (
        .Read1(rs1_addr),
        .Read2(rs2_addr),
        .Data1(reg_data_1),
        .Data2(reg_data_2),
        .addr(rd_addr),
        .clock(clk), // Should be clk for synchronous write
        .RegWrite(reg_write_en),
        .WriteData(data_to_reg_write),
        .reset(rst),
        .finish_flag(last_instr_flag_out)
    );
/*
    `ifdef SIMULATION
        always @(reg_data_1 or reg_data_2) begin
            if (!rst && !last_instr_flag_out) begin
                $display("[RegisterFile] Read1: x%0d = %d, Read2: x%0d = %d", 
                rs1_addr, reg_data_1, 
                rs2_addr, reg_data_2);
            end
        end
    `endif
*/
    // Sign Extender
    signext extensorS (
        .instruct(instr_fetched),
        .out(sign_extended_imm)
    );

        // Detectar tipo de salto usando opcode
    


    // Selección de operandos para la ALU
    // Para JAL: A = pc_current_val, B = sign_extended_imm
    // Para JALR: A = reg_data_1, B = sign_extended_imm
    // Para otras instrucciones, como antes
    always_comb begin
        if (jal_active && !jalr_active) begin
            alu_input_a = pc_current_val;
            alu_input_b = sign_extended_imm;
        end 
        else if (!jal_active && jalr_active) begin
            alu_input_a = reg_data_1;
            alu_input_b = sign_extended_imm;
        end 
        else begin
            alu_input_a = reg_data_1;
            alu_input_b = alu_src_b ? sign_extended_imm : reg_data_2;
        end
    end
    // ALU
    RISCVALU modalu (
        .ALUctl(alu_op_ctrl),
        .A(alu_input_a),
        .B(alu_input_b),
        .zero_test(zero_test_signal),
        .ALUout(alu_result),
        .reset(rst),
        .last_instr_flag_in(last_instr_flag_out),
        .zero(alu_zero_flag)
    );

    assign pc_plus_4_val   = pc_current_val + 4;
    assign branch_addr_val = pc_current_val + sign_extended_imm; // Para branch
    // Dirección de salto para JAL y JALR
    assign jump_addr_val = alu_result;
    always_comb begin
        case (pc_sel)
            2'b00: next_pc_val = pc_plus_4_val;
            2'b01: begin
                if (alu_zero_flag) begin
                    next_pc_val = branch_addr_val;
                end
                else begin
                    next_pc_val = pc_plus_4_val;
                end
            end
            2'b10: next_pc_val = alu_result;
            default: next_pc_val = pc_plus_4_val;
        endcase
    end

    

   `ifdef SIMULATION
        always @(posedge clk) begin
            if (!rst && !last_instr_flag_out && alu_op_ctrl != 3) begin
                $display("[ALU] ALUctl = %b", alu_op_ctrl);
                case (alu_op_ctrl)
                    0:   $display("[ALU] Funcion: AND");
                    1:   $display("[ALU] Funcion: OR");
                    2:   $display("[ALU] Funcion: ADD");
                    6:   $display("[ALU] Funcion: SUB");
                    7:   $display("[ALU] Funcion: SLT");
                    12:  $display("[ALU] Funcion: NOR");
                    default: $display("[ALU] Funcion desconocida");
                endcase
                $display("[ALU] A = %d", alu_input_a);
                $display("[ALU] B = %d", alu_input_b);
                $display("[ALU] ALUout = %d", alu_result);
                $display("[ALU] zero = %d", (alu_op_ctrl == 6) && (alu_result == 0));
            end
        end

    `endif

    // Data Memory
    // Address for data memory is typically ALU result for LW/SW
    assign mem_address = alu_result;
    assign mem_write_data = reg_data_2; // Data to write to memory is from rs2 (RegData2)

    DataMemory modmemory (
        .clk(clk),
        .write_enable(mem_write_en),
        .read_enable(mem_read_en),
        .address(mem_address),
        .write_data(mem_write_data),
        .read_data(mem_read_data_out)
    );

    // Write Back to Register File MUX
    // mem_to_reg_sel: 00 = ALUResult, 01 = MemReadData, 10 = PC+4 (for JAL)
    always_comb begin
        case (mem_to_reg_sel)
            2'b00:  data_to_reg_write = alu_result;
            2'b01:  data_to_reg_write = mem_read_data_out;
            2'b10:  data_to_reg_write = pc_plus_4_val; // For JAL, JALR might use ALU result differently
            default: data_to_reg_write = alu_result; // Default to ALU result
        endcase
    end

    // Note: The original PC module had its own branch logic.
    // For a cleaner separation, the main PC update logic (muxing between PC+4, branch target, jump target)
    // should ideally be driven by control signals feeding a MUX whose output goes to PC's *next_value* input.
    // The current PC module is kept as is, but its 'branch' and 'branch_offset' inputs are driven by datapath/control.

endmodule
