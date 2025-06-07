`timescale 1ns / 1ps

`include "alu_control.sv"

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3, // Needed for ALU control and some instruction differentiation
    input  logic [6:0] funct7, // Needed for ALU control for R-types
    input  logic       alu_zero_flag_in, // From datapath (ALU)
    input  logic       last_instr_flag_in, // From datapath (Inst Memory)
    input  logic       clk, // For sequential control if needed
    input  logic       rst, // For resetting control FSM if needed
    input  logic [31:0] current_pc_in,
    output logic       zero_test_out,
    output logic       jal_active_out,
    output logic       jalr_active_out,

    // Control Signals to Datapath
    output logic       reg_write_en_out,
    output logic       mem_read_en_out,
    output logic       mem_write_en_out,
    output logic       alu_src_b_out,       // 0: RegData2, 1: SignExtendedImm
    output logic [1:0] mem_to_reg_sel_out,  // 00: ALUOut, 01: MemReadData, 10: PC+4
    output logic       branch_en_out,       // Combined with alu_zero_flag in datapath for PC update
    output logic [1:0] pc_src_out,

    // Control Signal to ALU Control
    output logic [3:0] alu_op_out
);



    // Instantiate ALU Control
    alu_control alu_ctrl_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rst(rst),
        .last_instr_flag_in(last_instr_flag_in),
        .alu_op(alu_op_out) // This is the alu_op that goes to the datapath's ALU
    );

    // Main Control Logic (combinational for now)
    // This will set control signals based on the opcode.
    // The more complex FSM logic from RISCVunicycle.sv needs careful integration here if exact behavior is to be replicated.

    // Lógica combinacional para las señales de control
    always_comb begin
        // Default values for control signals (typically to 'do nothing' or safe state)
        reg_write_en_out   = 1'b0;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        alu_src_b_out      = 1'b0; // Default to RegData2 for ALU B input
        mem_to_reg_sel_out = 2'b00; // Default to ALUOut for write-back
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00; // Default PC+4
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
        if (rst) begin
            zero_test_out = 1'b0;
        end
        if (!last_instr_flag_in && !rst && current_pc_in != 32'hFFFFFFFC) begin
            case (opcode)
    7'b0110011: begin // R-type (ADD, SUB, AND, OR, etc.)
        reg_write_en_out   = 1'b1;
        alu_src_b_out      = 1'b0;
        mem_to_reg_sel_out = 2'b00;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
    7'b0010011: begin // I-type (ADDI, ANDI, ORI, SLTI etc.)
        reg_write_en_out   = 1'b1;
        alu_src_b_out      = 1'b1;
        mem_to_reg_sel_out = 2'b00;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
    7'b0000011: begin // I-type Load (LW, LB, LH)
        reg_write_en_out   = 1'b1;
        alu_src_b_out      = 1'b1;
        mem_to_reg_sel_out = 2'b01;
        mem_read_en_out    = 1'b1;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
    7'b0100011: begin // S-type Store (SW, SB, SH)
        reg_write_en_out   = 1'b0;
        alu_src_b_out      = 1'b1;
        mem_to_reg_sel_out = 2'b00;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b1;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
    7'b1100011: begin // B-type Branch (BEQ, BNE, etc.)
        reg_write_en_out   = 1'b0;
        alu_src_b_out      = 1'b0;
        mem_to_reg_sel_out = 2'b00;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b1;
        pc_src_out         = 2'b01;
        zero_test_out      = (funct3 == 3'b000) ? 1'b1 : 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
    7'b1101111: begin // J-type (JAL)
        reg_write_en_out   = 1'b1;
        alu_src_b_out      = 1'b1;
        mem_to_reg_sel_out = 2'b10;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b10;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b1;
        jalr_active_out    = 1'b0;
    end
    7'b1100111: begin // JALR-type (JALR)
        reg_write_en_out   = 1'b1;
        alu_src_b_out      = 1'b1;
        mem_to_reg_sel_out = 2'b10;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b10;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b1;
    end
    default: begin
        reg_write_en_out   = 1'b0;
        alu_src_b_out      = 1'b0;
        mem_to_reg_sel_out = 2'b00;
        mem_read_en_out    = 1'b0;
        mem_write_en_out   = 1'b0;
        branch_en_out      = 1'b0;
        pc_src_out         = 2'b00;
        zero_test_out      = 1'b0;
        jal_active_out     = 1'b0;
        jalr_active_out    = 1'b0;
    end
endcase
        end
    end
    // Bloque solo para depuración
    `ifdef SIMULATION
    always @(posedge clk) begin
        if(!last_instr_flag_in && !rst)begin
            $display("[Control] Opcode: %b, Funct3: %b, Funct7: %b, ALU_Zero: %b", opcode, funct3, funct7, alu_zero_flag_in);
            // Decodificación del nombre de la instrucción
            case (opcode)
                7'b0110011: begin // R-type
                    case (funct3)
                        3'b000: begin
                            if (funct7 == 7'b0000000)
                                $display("[Control] INSTRUCCION: ADD");
                            else if (funct7 == 7'b0100000)
                                $display("[Control] INSTRUCCION: SUB");
                            else
                                $display("[Control] INSTRUCCION: R-type desconocida funct7=%b", funct7);
                        end
                        3'b111: $display("[Control] INSTRUCCION: AND");
                        3'b110: $display("[Control] INSTRUCCION: OR");
                        default: $display("[Control] INSTRUCCION: R-type funct3=%b", funct3);
                    endcase
                end
                7'b0010011: begin // I-type
                    case (funct3)
                        3'b000: $display("[Control] INSTRUCCION: ADDI");
                        3'b111: $display("[Control] INSTRUCCION: ANDI");
                        3'b110: $display("[Control] INSTRUCCION: ORI");
                        default: $display("[Control] INSTRUCCION: I-type funct3=%b", funct3);
                    endcase
                end
                7'b0000011: begin // Load word
                    case (funct3)
                        3'b010: $display("[Control] INSTRUCCION: LW");
                        default: $display("[Control] INSTRUCCION: Load word funct3=%b", funct3);
                    endcase
                end
                7'b0100011: begin // Store word
                    case (funct3)
                        3'b010: $display("[Control] INSTRUCCION: SW");
                        default: $display("[Control] INSTRUCCION: Store word funct3=%b", funct3);
                    endcase
                end
                7'b1100011: begin // B-type
                    case (funct3)
                        3'b000: $display("[Control] INSTRUCCION: BEQ");
                        3'b001: $display("[Control] INSTRUCCION: BNE");
                        default: $display("[Control] INSTRUCCION: B-type funct3=%b", funct3);
                    endcase
                end
                7'b1100111: $display("[Control] INSTRUCCION: JALR");
                7'b1101111: $display("[Control] INSTRUCCION: JAL");
                default: $display("[Control] INSTRUCCION: opcode desconocido: %b", opcode);
            endcase
            if (opcode === 7'bxxxxxxx) begin
                $display("[Control] Opcode no reconocido: %b", opcode);
            end
            $display("[Control] reg_we=%b", reg_write_en_out);
            $display("[Control] mem_rd=%b", mem_read_en_out);
            $display("[Control] mem_we=%b", mem_write_en_out);
            $display("[Control] alu_src_b=%b", alu_src_b_out);
            $display("[Control] mem_to_reg=%b", mem_to_reg_sel_out);
            $display("[Control] branch=%b", branch_en_out);
            $display("[Control] pc_src=%b", pc_src_out);   
            $display("[Control] jal_active=%b", jal_active_out);
            $display("[Control] jalr_active=%b", jalr_active_out);
        end
    end


    `endif



endmodule
