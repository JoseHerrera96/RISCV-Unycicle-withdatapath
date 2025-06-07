`timescale 1ns / 1ps

module alu_control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic rst,
    input  logic last_instr_flag_in,
    output logic [3:0] alu_op
);

    // Lógica combinacional para la operación ALU
    always_comb begin
        // Default to a safe/known operation or indicate error if necessary
        
        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, etc.)
                case (funct3)
                    3'b000: begin // ADD, SUB
                        if (funct7 == 7'b0000000)      alu_op = 4'b0010; // ADD
                        else if (funct7 == 7'b0100000) alu_op = 4'b0110; // SUB
                        else                           alu_op = 4'bxxxx; // Undefined R-type for this funct3/funct7
                    end
                    3'b111: alu_op = 4'b0000; // AND
                    3'b110: alu_op = 4'b0001; // OR
                    // TODO: Add other R-type funct3 if supported by your ALU (e.g., SLT, XOR, SLL, SRL, SRA)
                    default: alu_op = 4'bxxxx;
                endcase
            end
            7'b0010011: begin // I-type (ADDI, ANDI, ORI, etc.)
                case (funct3)
                    3'b000: alu_op = 4'b0010; // ADDI
                    3'b111: alu_op = 4'b0000; // ANDI
                    3'b110: alu_op = 4'b0001; // ORI
                    // TODO: Add other I-type funct3 if supported (e.g., SLTI, XORI, SLLI, SRLI, SRAI)
                    default: alu_op = 4'b0011;
                endcase
            end
            7'b0000011: begin // I-type (Load instructions - LB, LH, LW)
                alu_op = 4'b0010; // ADD for address calculation (base + offset)
            end
            7'b0100011: begin // S-type (Store instructions - SB, SH, SW)
                alu_op = 4'b0010; // ADD for address calculation (base + offset)
            end
            7'b1100011: begin // B-type (Branch instructions - BEQ, BNE, etc.)
                // For branches, ALU is typically used for comparison (e.g., A-B for BEQ/BNE)
                // The 'zero' flag from this operation is then used by control logic.
                alu_op = 4'b0110; // SUB (used for A-B, then check zero flag for BEQ/BNE)
                // If other comparisons like BLT are needed, this might change or use SLT (op 7 in your ALU)
            end
            // U-type (LUI, AUIPC) and J-type (JAL) might not use the ALU in the same way or are handled differently.
            // LUI: typically no ALU op, immediate loaded directly.
            // AUIPC: ADD (PC + immediate)
            // JAL: PC-relative jump, handled by PC logic, not ALU.
            7'b1101111: begin // J-type (JAL)
                alu_op = 4'b0010; // ADD for address calculation (base + offset)
            end
            7'b1100111: begin // J-type (JALR)
                alu_op = 4'b0010; // ADD for address calculation (base + offset)
            end
            default: 
                alu_op = 4'b0011; // Default for undefined opcodes
        endcase
    end
    
    // Bloque solo para depuración
    `ifdef SIMULATION
    always @* begin

        if(!rst && !last_instr_flag_in)begin
            //$display("[ALU_Control] Opcode: %b, Funct3: %b, Funct7: %b", opcode, funct3, funct7);
            if (opcode === 7'bxxxxxxx) begin
                $display("[ALU_Control] Opcode no reconocido: %b", opcode);
            end
            if (opcode === 7'b0110011 && funct3 === 3'bxxx) begin
                $display("[ALU_Control] Función R-type no soportada: funct3=%b, funct7=%b", funct3, funct7);
            end
            $display("[ALU_Control] ALU_Op resultante: %b", alu_op);
        end
    end
    `endif

endmodule
