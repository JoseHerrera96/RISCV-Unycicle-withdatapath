`timescale 1us/1ns
`include "datapath.sv"
`include "control_unit.sv"

module RISCVunicycle( // Top-level module
    input logic clock,
    input logic rst,
    output logic finish_flag // This will be driven by last_instr_flag from datapath via control unit or directly
);

    // Registro para sincronizar la señal de finish

    // Wires to connect Control Unit and Datapath
    logic [6:0] opcode_from_instr;
    logic [2:0] funct3_from_instr;
    logic [6:0] funct7_from_instr;
    logic [31:0] instruction_to_control;
    logic [31:0] current_pc_out;
    logic        alu_zero_to_control;
    logic        last_instr_to_control;
    logic        zero_test;
    logic        zero_test_out;

    // Control signals from Control Unit to Datapath
    logic        reg_write_en_ctrl;
    logic        mem_read_en_ctrl;
    logic        mem_write_en_ctrl;
    logic        alu_src_b_ctrl;
    logic [1:0]  mem_to_reg_sel_ctrl;
    logic        branch_en_ctrl;
    logic [3:0]  alu_op_to_datapath; // This comes from alu_control via control_unit

    logic [1:0]  pc_src_ctrl; // NUEVO: wire para pc_src

    // Extract fields from instruction for Control Unit
    // These assignments will be based on 'instruction_to_control' from datapath

    // Instantiate Control Unit
    control_unit ctrl_inst (
        .opcode(opcode_from_instr),
        .funct3(funct3_from_instr),
        .funct7(funct7_from_instr),
        .alu_zero_flag_in(alu_zero_to_control),
        .last_instr_flag_in(last_instr_to_control),
        .clk(clock), // Pass clock and reset if FSM is implemented in control_unit
        .rst(rst),
        .zero_test_out(zero_test),

        .reg_write_en_out(reg_write_en_ctrl),
        .mem_read_en_out(mem_read_en_ctrl),
        .mem_write_en_out(mem_write_en_ctrl),
        .alu_src_b_out(alu_src_b_ctrl),
        .mem_to_reg_sel_out(mem_to_reg_sel_ctrl),
        .branch_en_out(branch_en_ctrl),
        
        .alu_op_out(alu_op_to_datapath),
        .current_pc_in(current_pc_out),
        .pc_src_out(pc_src_ctrl),
        .jal_active_out(jal_active_out),
        .jalr_active_out(jalr_active_out)
    );

    // Lógica para manejar el finish_flag
    always @(posedge clock) begin
        if (last_instr_to_control) begin
            `ifdef SIMULATION
            $display("[%0t] [RISCVunicycle] Ultima instruccion detectada, terminando ejecucion", $time);
            `endif
        end
    end

    assign finish_flag = last_instr_to_control; // Asegurar que se active inmediatamente

    // Instantiate Datapath
    datapath dp_inst (
        .clk(clock),
        .rst(rst),
        .jal_active(jal_active_out),
        .jalr_active(jalr_active_out),

        .reg_write_en(reg_write_en_ctrl),
        .mem_read_en(mem_read_en_ctrl),
        .mem_write_en(mem_write_en_ctrl),
        .alu_src_b(alu_src_b_ctrl),
        .mem_to_reg_sel(mem_to_reg_sel_ctrl),
        .branch_en(branch_en_ctrl),
        .alu_op_ctrl(alu_op_to_datapath),
        
        .pc_write_en(1'b1),  // Siempre permitir escritura en PC
        .pc_sel(pc_src_ctrl),        // Por defecto, no usar salto indirecto
        .zero_test_signal(zero_test_out),

        .instruction_out(instruction_to_control),
        .alu_zero_flag(alu_zero_to_control),
        .last_instr_flag_out(last_instr_to_control),
        .current_pc_out(current_pc_out)
    );
    assign opcode_from_instr = instruction_to_control[6:0];
    assign funct3_from_instr = instruction_to_control[14:12];
    assign funct7_from_instr = instruction_to_control[31:25];
    assign zero_test_out = zero_test;

    // finish_flag ya está asignado desde finish_flag_reg
    // No necesitamos la asignación duplicada
    
    // All the original logic for decoding, signal generation, and state management
    // (e.g., 'always @ (posedge decode_begin)', 'always @(posedge decode_done)', 'busy' signal)
    // has been removed from this top-level file.
    // That logic would need to be implemented within 'control_unit.sv',
    // likely as a Finite State Machine (FSM), if the exact original sequential behavior is required.

endmodule