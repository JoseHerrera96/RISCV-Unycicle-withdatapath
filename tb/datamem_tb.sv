`timescale 1ns / 1ps
`include "../src/datamem.sv"

module DataMemory_tb;

    // Parámetros
    parameter CLK_PERIOD = 10; // Periodo de reloj en unidades de tiempo
    
    // Señales de entrada
    logic clk;
    logic [31:0] address;
    logic [31:0] write_data;
    logic write_enable;
    logic read_enable;
    
    // Señales de salida
    logic [31:0] read_data;
    
    // Instancia del módulo DataMemory
    DataMemory data_memory (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .read_data(read_data)
    );
    
    initial begin
        $dumpfile("DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);
    end

    // Generación de reloj
    always #((CLK_PERIOD)/2) clk = ~clk;
    
    // Testbench inicial
    initial begin
        clk = 0;
        address = 0;
        write_data = 0;
        write_enable = 0;
        read_enable = 0;

        $display(" ");
        $display("Inicializando testbench de DataMemory...");
        $display(" ");

        // Escribir datos en la memoria
        #10 write_data = 32'hDEADBEEF; // Dato 1
        write_enable = 1;
        address = 32'h00000004; // Dirección 4
        #10;
        $display("[Escritura] Direccion: %h, Dato: %h", address, write_data);

        #10 write_data = 32'hCAFEBABE; // Dato 2
        address = 32'h00000008; // Dirección 8
        #10;
        $display("[Escritura] Direccion: %h, Dato: %h", address, write_data);

        write_enable = 0;

        // Leer datos de la memoria
        #10 read_enable = 1;
        address = 32'h00000004; // Leer dirección 4
        #10;
        $display("[Lectura] Direccion: %h, Dato: %h", address, read_data);

        address = 32'h00000008; // Leer dirección 8
        #10;
        $display("[Lectura] Direccion: %h, Dato: %h", address, read_data);

        read_enable = 0;

        $display(" ");
        $display("Testbench finalizado.");
        $display(" ");
        $finish;
    end

endmodule