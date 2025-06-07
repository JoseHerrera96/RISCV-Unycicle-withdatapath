`timescale 1ns/1ps
`include "../src/Instmemory.sv"
`include "../src/PC.sv"

module Instmemory_tb;

    logic clk, reset;
    logic [31:0] pc_reg; // Salida del módulo PC
    logic [31:0] instruct; // Instrucción actual
    logic last_instr_flag; // Bandera de última instrucción

    // Instancia del módulo PC
    PC pc_counter(
        .clk(clk),
        .reset(reset),
        .pc_reg(pc_reg),
        .finish_flag(last_instr_flag) // Detener el PC cuando se alcance la última instrucción
    );

    // Instancia del módulo Instmemory
    instmemory dut(
        .addr(pc_reg), // Dirección de la instrucción actual
        .instruct(instruct),
        .last_instr_flag(last_instr_flag)
    );

    initial begin
        $dumpfile("Instmemory_tb.vcd");
        $dumpvars(0, Instmemory_tb);

        // Inicialización
        clk = 0;
        reset = 1;
        $display(" ");
        $display("Inicializando testbench de Instmemory...");
        $display(" ");
        $display("Estado inicial: reset = %b, PC = %h, instruccion = %h, last_instr_flag = %b", reset, pc_reg, instruct, last_instr_flag);
        $display(" ");
        // Desactivar reset después de un ciclo
        #10 reset = 0;
        $display("Reset desactivado");
        $display(" ");
        // Esperar a que se alcance la última instrucción
        wait (last_instr_flag == 1);
        $display(" ");
        $display("Ultima instruccion alcanzada: PC = %h, instruccion = %h, last_instr_flag = %b", pc_reg, instruct, last_instr_flag);
        $display(" ");
        // Finalización del testbench
        $display("testbench finalizado");
        $display(" ");
        $finish;
    end

    // Bloque para observar el comportamiento en cada flanco positivo del reloj
    always @(posedge clk) begin
        $display("PC = %h, instruccion = %h, last_instr_flag = %b", pc_reg, instruct, last_instr_flag);
    end

    // Generación del reloj
    always #5 clk = ~clk;

endmodule

