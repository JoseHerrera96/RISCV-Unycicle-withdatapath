`timescale 1ns / 1ps
// `include "../src/RISCVunicycle.sv" // No es necesario si compilas todos los .sv juntos

module RISCVunicycle_tb;

    parameter CLK_PERIOD = 10; // Periodo del reloj 

    logic clock;
    logic rst;
    logic tb_finish_flag; // Renombrada y declarada explícitamente

    // Instancia del DUT (Device Under Test)
    RISCVunicycle dut (
        .clock(clock),
        .rst(rst),
        .finish_flag(tb_finish_flag) // Conectada a la señal del TB
    );
    initial begin
        $dumpfile("RISCVunicycle_tb.vcd");
        $dumpvars(0, RISCVunicycle_tb); // Dumpea todas las señales en el TB y el DUT
    end

    // Generación de Reloj
    initial begin
        clock = 1'b0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Secuencia de Reset y Finalización de Simulación
    initial begin
        // Inicializar señales
        rst = 1'b1; // Iniciar en reset
     
        
        // Mantener reset por 10 ciclos
        $display("[%0t] INFO: Reset Asserted.", $time);
        #(2*CLK_PERIOD);      
        
        // Liberar reset
        clock = 1'b0;    
        rst = 1'b0;
        
        $display("[%0t] INFO: Reset De-asserted.", $time);
        
        // Esperar a que se active la bandera de finalización
        wait (tb_finish_flag === 1'b1);
        $display("[%0t] INFO: Finish flag detected. Simulation completed successfully.", $time);
        $display(" ");
        
        // Esperar un poco más para asegurar que todo se estabilice
        #(CLK_PERIOD);
        $finish;
        
        // Timeout de Simulación (como respaldo)
        #(CLK_PERIOD * 20);
        $display("[%0t] ERROR: Simulation TIMEOUT. tb_finish_flag never asserted.", $time);
        $display(" ");
        $finish;
    end

    // Lógica de Verificación y Finalización del Test
    always @(posedge tb_finish_flag) begin
        // Declaraciones de variables al inicio del bloque
        logic [31:0] expected_x10;
        logic [31:0] actual_x10;
        logic [31:0] expected_mem_val;
        logic [31:0] actual_mem_val;
        logic [31:0] mem_address_to_check;

        // Esperar unos ciclos para asegurar que las escrituras finales se completen
        #(3 * CLK_PERIOD); 
        $display("[%0t] INFO: tb_finish_flag asserted. Starting verification.", $time);

        // --- INICIO DE VERIFICACIÓN ---
        // Ejemplo: Verificar el valor del registro x10 (decimal 10)
        expected_x10 = 32'd1;  // x10 is initialized to 1 and not changed by FinalT.hex
        actual_x10 = dut.dp_inst.modregfile.registers[10]; 

        if (actual_x10 == expected_x10) begin
            $display("[%0t] SUCCESS: Register x10. Expected:    %h,     Got:    %h", $time, expected_x10, actual_x10);
        end else begin
            $display("[%0t] FAILURE: Register x10. Expected:    %h,     Got:    %h", $time, expected_x10, actual_x10);
        end

        // Ejemplo: Verificar el valor de una posición de memoria (dirección 0x100)
        expected_mem_val = 32'hxxxxxxxx; // Valor esperado para memoria no inicializada
        mem_address_to_check = 32'h100; // Dirección de memoria (byte address)

        // Asegúrate de que la dirección es accesible y está alineada si es necesario
        // La memoria en tu datamem.sv `logic [31:0] memory [0:255];` es un array de 256 palabras.
        // Se accede por índice de palabra (0 a 255).
        if (mem_address_to_check < (256*4) && (mem_address_to_check % 4 == 0)) begin // Verifica límites y alineación
            actual_mem_val = dut.dp_inst.modmemory.memory[mem_address_to_check / 4];

            if (actual_mem_val === expected_mem_val) begin
                $display("[%0t] SUCCESS: Memory @%h. Expected:    %h,     Got:    %h", $time, mem_address_to_check, expected_mem_val, actual_mem_val);
            end else begin
                $display("[%0t] FAILURE: Memory @%h. Expected:    %h,     Got:    %h", $time, mem_address_to_check, expected_mem_val, actual_mem_val);
            end
        end else begin
            $display("[%0t] WARNING: Memory address     %h     is out of bounds or misaligned for verification.", $time, mem_address_to_check);
        end

        // Añade más verificaciones según sea necesario para otros registros y posiciones de memoria
        // --- FIN DE VERIFICACIÓN ---

        $display("[%0t] INFO: Test bench finished successfully.", $time);
        $finish;
    end

endmodule
