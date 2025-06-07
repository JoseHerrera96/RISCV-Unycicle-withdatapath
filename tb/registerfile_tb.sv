`timescale 1ns/1ps
`include "../src/registerfile.sv"

module registerfile_tb;

    parameter CLK_PERIOD = 10; // Periodo del reloj

    logic [4:0] Read1, Read2, WriteReg;
    logic [31:0] WriteData;
    logic RegWrite, clock;
    logic [31:0] Data1, Data2;
    logic finish_flag;

    // Instancia del módulo registerfile
    registerfile uut(
        .Read1(Read1),
        .Read2(Read2),
        .RD(WriteReg),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .clock(clock),
        .Data1(Data1),
        .Data2(Data2),
        .finish_flag(finish_flag)
    );

    initial begin
        $dumpfile("registerfile_tb.vcd");
        $dumpvars(0, registerfile_tb);
    end
    initial begin
        // Inicialización
        clock = 0;
        RegWrite = 0;
        WriteReg = 0;
        WriteData = 0;
        finish_flag = 0;
        $display(" ");
        $display("Inicializando testbench de registerfile...");
        $display(" ");
        #50;
    end

    // Generación del reloj
    always #(CLK_PERIOD / 2) clock = ~clock;

    // Bloque para realizar las operaciones de escritura y lectura
    initial begin
        // Escribir en el registro 3
        RegWrite = 1;
        WriteReg = 5'd3;
        WriteData = 32'hABCDEFFF;
        $display("[Escritura] Registro: %d, Dato: %d", WriteReg, WriteData);
        #50;
        // Escribir en el registro 5
        WriteReg = 5'd5;
        WriteData = 32'hFBCDE111;
        $display(" ");
        $display("[Escritura] Registro: %d, Dato: %d", WriteReg, WriteData);
        #1000;
        // Desactivar escritura
        RegWrite = 0;
        $display(" ");
        // Leer de los registros 3 y 5
        Read1 = 5'd3;
        Read2 = 5'd5;
        #50;
        $display(" ");
        $display("[Lectura] Registro: %d, Dato: %d | Registro: %d, Dato: %d", Read1, Data1, Read2, Data2);
        $display(" ");
        #50;
        // Leer de registros no inicializados (7 y 10)
        Read1 = 5'd7;
        Read2 = 5'd10;
        #50;
        $display("[Lectura] Registro: %d, Dato: %d | Registro: %d, Dato: %d", Read1, Data1, Read2, Data2);
        $display(" ");
        #50;
        // Finalización del testbench
        $display(" ");
        $display("Testbench finalizado.");
        $display(" ");
        $finish;
    end

    // Bloque para mostrar los datos leídos en cada ciclo


endmodule