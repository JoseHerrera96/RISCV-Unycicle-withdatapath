module signext(instruct, out);

    input logic [31:0] instruct;
    logic [6:0] typ;
    output logic signed [31:0] out = 0; // Inicializar a 0

    always @(instruct) begin
        typ= instruct[6:0]; // Obtener el tipo de instrucción
        
        case (typ)
            7'b0010011: begin // Tipo I
                out = {{20{instruct[31]}}, instruct[31:20]};
                $display("Inm ext mod side: %h", out);
            end
            7'b0000011: begin // Tipo L
                out = {{20{instruct[31]}}, instruct[31:20]};
            end
            7'b0100011: begin // Tipo S
                out = {{20{instruct[31]}}, instruct[31:25], instruct[11:7]};
            end
            7'b1100011: begin // Tipo B (BEQ)
                out = {{19{instruct[31]}}, instruct[31], instruct[7], instruct[30:25], instruct[11:8],1'b0}; // Extensión de signo y alineación
                $display("Inm ext mod side: %h", out);
            end
            
            7'b1101111: begin // Tipo J (JAL)
                out = {{11{instruct[31]}}, instruct[31], instruct[19:12], instruct[20], instruct[31:21], 1'b0}; // Extensión de signo y alineación
                $display("Inm ext mod side: %h", out);
            end
            7'b1100111: begin // Tipo J (JALR)
                out = {{19{instruct[31]}}, instruct[31:21], 1'b0};
                $display("Inm ext mod side: %h", out);
            end
        
            default:
                out = 32'b0; // Valor por defecto
        endcase
    end

endmodule