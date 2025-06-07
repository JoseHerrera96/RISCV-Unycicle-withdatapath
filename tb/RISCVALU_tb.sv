`timescale 1ns/1ps
`include "../src/RISCVALU.sv"

module RISCVALU_tb;

    logic [3:0] ALUctl;
    logic [31:0] A, B;
    logic [31:0] ALUout;
    logic zero;

    // Instancia del módulo RISCVALU
    RISCVALU dut(
        .ALUctl(ALUctl),
        .A(A),
        .B(B),
        .ALUout(ALUout),
        .zero(zero)
    );

    initial begin
        $dumpfile("RISCVALU_tb.vcd");
        $dumpvars(0, RISCVALU_tb);

        $display(" ");
        $display("Inicializando testbench de RISCVALU...");
        $display(" ");

        // Prueba de AND
        A = 32'h0000000F; B = 32'h0000000A; ALUctl = 4'b0000; // A & B
        #10;
        $display("AND: A = %b, B = %b, Resultado = %b, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de OR
        A = 32'h00000000; B = 32'h0000000A; ALUctl = 4'b0001; // A | B
        #10;
        $display("OR: A = %b, B = %b, Resultado = %b, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de ADD
        A = 9; B = 1; ALUctl = 4'b0010; // A + B
        #10;
        $display("ADD: A =%d,    B =%d,     Resultado = %d, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de SUB
        A = 8; B = 2; ALUctl = 4'b0110; // A - B
        #10;
        $display("SUB: A =%d,   B =%d,      Resultado = %d, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de SLT (Set Less Than)
        A = 32'h00000008; B = 32'h00000009; ALUctl = 4'b0111; // A < B
        #10;
        $display("SLT: A = %h, B = %h, Resultado = %h, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de SLT (Set Less Than) con A > B
        A = 32'h0000000A; B = 32'h00000009; ALUctl = 4'b0111; // A < B
        #10;
        $display("SLT: A = %b, B = %b, Resultado = %b, Zero_Flag = %b", A, B, ALUout, zero);
        $display(" ");

        // Prueba de NOR
        A = 32'h00000000; B = 32'h0000000A; ALUctl = 4'b1100; // ~(A | B)
        #10;
        $display("NOR: A = %b, B = %b, Resultado = %b, Zero_Flag = %b", A, B, ALUout, zero);

        $display(" ");
        $display("Testbench finalizado.");
        $display(" ");
        $finish;
    end

endmodule