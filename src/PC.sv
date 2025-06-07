module PC (
    input  logic        clk,
    input  logic        reset,
    input  logic        finish_flag,
    input  logic [31:0] next_pc,
    output logic [31:0] pc_reg = 32'hFFFFFFFC // Inicializar a -4
);

    // Lógica del PC
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            pc_reg <= 32'hFFFFFFFC; // Reiniciar a -4 en reset
            `ifdef SIMULATION
            $display("[%0t] [PC] Reset: PC = %h", $time, pc_reg);
            `endif
        end 
        else if (!finish_flag && !reset) begin
            // Solo actualizar el PC si no se ha alcanzado la última instrucción
            // Verificar que next_pc sea una dirección válida (no todo 1's)
            pc_reg <= next_pc;
            
        end
        // Si finish_flag está activo, mantener el valor actual de pc_reg
    end

    `ifdef SIMULATION
        always @(pc_reg) begin
            $display(" ");
            if(pc_reg != 32'hFFFFFFFC) begin
                $display("[PC] PC actualizado: %d", pc_reg);
            end

            else begin
                `ifdef SIMULATION
                $display("[%0t] [PC] Intento de actualización a dirección inválida: %d", $time, next_pc);
                `endif
            end
        end
    `endif

endmodule
