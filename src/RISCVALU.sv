module RISCVALU (
    input logic [3:0] ALUctl,
    input logic [31:0] A, B,
    input logic zero_test,
    output logic signed [31:0] ALUout,
    output logic zero,
    input logic reset,
    input logic last_instr_flag_in
);

    logic result_ALU=0;

    // La salida zero ahora es combinacional y no se almacena como registro
    // Se activa solo para operaciones SUB (ALUctl==6) y cuando el resultado es cero

    // Lógica combinacional para la operación ALU

    always_comb begin
        if (reset) begin
            ALUout = 32'b0;
            result_ALU = 0;
        end 
        else begin
            zero = 0;
            case(ALUctl)
                0: begin
                    ALUout = A & B;  // AND
                    result_ALU = 1;
                end
                1: begin
                    ALUout = A | B;  // OR
                    result_ALU = 1;
                end
                2: begin
                    ALUout = A + B;  // ADD
                    result_ALU = 1;
                end
                6: begin
                    ALUout = A - B;  // SUB
                    result_ALU = 1;
                    if (zero_test && ALUout==0) begin
                        zero = 1;
                         `ifdef SIMULATION
                        $display("[ALU] BRANCH zero = %b", zero);
                        `endif
                    end
                end
                7: begin
                    ALUout = (A < B) ? 1 : 0;  // SLT
                    result_ALU = 1;
                end
                12: begin
                    ALUout = ~(A | B);  // NOR
                    result_ALU = 1;
                end
                default: begin 
                    ALUout = 0;
                    result_ALU = 0;
                end
            endcase
        end
    end
    /*
    // Bloque solo para depuración
    `ifdef SIMULATION
        always @(result_ALU) begin
            if (!reset && !last_instr_flag_in && ALUctl != 3 && result_ALU==1) begin
                result_ALU = 0;
                $display("[ALU] ALUctl = %b", ALUctl);
                case (ALUctl)
                    0:   $display("[ALU] Funcion: AND");
                    1:   $display("[ALU] Funcion: OR");
                    2:   $display("[ALU] Funcion: ADD");
                    6:   $display("[ALU] Funcion: SUB");
                    7:   $display("[ALU] Funcion: SLT");
                    12:  $display("[ALU] Funcion: NOR");
                    default: $display("[ALU] Funcion desconocida");
                endcase
                $display("[ALU] A = %h", A);
                $display("[ALU] B = %h", B);
                $display("[ALU] ALUout = %h", ALUout);
                $display("[ALU] zero = %b", (ALUctl == 6) && (ALUout == 0));
            end
        end

    `endif
*/
    // La bandera zero solo se activa si zero_test está en alto y el resultado es cero
    //assign zero = (zero_test && ALUout == 1 && ALUctl==6) ? 1 : 0;

   // assign zero = zero_test && (ALUout == 0) && result_ALU==1 ? 1 : 0;

    `ifdef SIMULATION
        always @(posedge zero) begin
            if (!reset && !last_instr_flag_in && zero_test && ALUout==0) begin
                $display("[ALU] BRANCHED!");
            end
        end
    `endif

endmodule