`timescale 1ns/1ps
`include "../src/PC.sv"

module PC_tb;

    logic clk, reset;
    logic finish_flag;
    logic [31:0] pc_reg;

    // Instancia del módulo PC
    PC dut(
        .clk(clk),
        .reset(reset),
        .pc_reg(pc_reg),
        .finish_flag(finish_flag)
    );

    initial begin
        $dumpfile("PC_tb.vcd");
        $dumpvars(0, PC_tb);
    end
    initial begin
        // Inicialización
        clk = 0;
        reset = 0;
        reset = 1;
        finish_flag = 0;
        $display(" ");
        $display("Inicializando testbench de PC...");
        $display("Estado inicial: clk = %b, reset = %b, finish_flag = %b, PC = %h", clk, reset, finish_flag, pc_reg);
        // Desactivar reset después de un ciclo
        #10 reset = 0;
        $display(" ");
        // Esperar 50 ns para observar el comportamiento
        #50;
        // Reiniciar el PC

        $display(" ");
        reset = 1;
        #10 $display("Reset activado: reset = %b, finish_flag = %b, PC = %h", reset, finish_flag, pc_reg);
         #50;
        $display("Contador despues de 4 ciclos: reset = %b, finish_flag = %b, PC = %h", reset, finish_flag, pc_reg);
        $display(" ");
        // Activar finish_flag para detener el contador
        finish_flag = 1;
        reset = 0;
        #10 $display("Finish_flag activado: reset = %b, finish_flag = %b, PC = %h", reset, finish_flag, pc_reg);
        #50;
        $display("Contador despues de 4 ciclos: reset = %b, finish_flag = %b, PC = %h", reset, finish_flag, pc_reg);
        // Finalización del testbench
        $display(" ");
        $display("testbench finalizado");
        $display(" ");
        #10 $finish;
    end

    // Bloque para observar el comportamiento del PC en cada flanco positivo del reloj
    always @(posedge clk) begin
        if (!finish_flag && !reset) begin
            $display(" Incremento: PC = %h", pc_reg);
        end
    end

    // Generación del reloj
    always #5 clk = ~clk;

endmodule