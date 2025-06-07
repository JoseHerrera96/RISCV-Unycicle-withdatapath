`timescale 1ns/1ps
`include "../src/signext.sv"

module signext_tb;

    logic [31:0] instruct;
    logic signed [11:0] inm;
    logic signed [31:0] out;

    // Instancia del módulo signext
    signext dut(
        .instruct(instruct),
        .out(out)
    );

    initial begin
        $dumpfile("signext_tb.vcd");
        $dumpvars(0, signext_tb);
    end
    initial begin
        $display(" ");
        $display("Inicializando testbench de signext...");
        $display(" ");

        // Prueba de Tipo I
        // Tipo I
        instruct = 32'h00000093; // Inmediato positivo (0)
        #50;
        $display("Tipo I (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'hFFF00093; // Inmediato negativo (-1)
        #50;
        $display("Tipo I (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'h80000093; // Inmediato negativo (-2048)
        #50;
        $display("Tipo I (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'h7FF00093; // Inmediato positivo (2047)
        #50;
        $display("Tipo I (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        $display(" ");

        // Prueba de Tipo L
        // Tipo L
        instruct = 32'h00002003; // Dirección de memoria positiva (0)
        #50;
        $display("Tipo L (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'hFFF02003; // Dirección de memoria negativa (-1)
        #50;
        $display("Tipo L (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'h80002003; // Dirección de memoria negativa (-2048)
        #50;
        $display("Tipo L (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        instruct = 32'h7FF02003; // Dirección de memoria positiva (2047)
        #50;
        $display("Tipo L (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed(instruct[31:20]), out);

        $display(" ");

        // Prueba de Tipo S
        // Tipo S
        instruct = 32'h00002023; // Dirección de memoria positiva (0)
        #50;
        $display("Tipo S (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed({instruct[31], instruct[30:25], instruct[11:7]}), out);

        instruct = 32'hFFF02023; // Dirección de memoria negativa (-1)
        #50;
        $display("Tipo S (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed({instruct[31], instruct[30:25], instruct[11:7]}), out);

        instruct = 32'h80002023; // Dirección de memoria negativa (-2048)
        #50;
        $display("Tipo S (Negativo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed({instruct[31], instruct[30:25], instruct[11:7]}), out);

        instruct = 32'h7FF02023; // Dirección de memoria positiva (2047)
        #50;
        $display("Tipo S (Positivo): Instruccion = %h, Imm = %d, Extendido = %h", instruct, $signed({instruct[31], instruct[30:25], instruct[11:7]}), out);

        $display(" ");
        $display("Testbench finalizado.");
        $finish;
    end

endmodule