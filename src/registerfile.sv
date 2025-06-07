module registerfile(
    input reset,
    input         clock,
    input         RegWrite,
    input         finish_flag,
    input  [4:0]  Read1,
    input  [4:0]  Read2,
    input  [4:0]  addr,
    input  signed [31:0] WriteData,
    output [31:0] Data1,
    output [31:0] Data2
);
    // Registros del banco de registros
    reg [31:0] registers [0:31];
    reg [4:0] RDTemp;
    reg RegWriteTemp;
    
    // Inicialización de registros
    integer i;
/*
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'd0;
        end
    end
*/
    initial begin
        // Valores iniciales específicos
        registers[0] = 32'd0;   // x0
        registers[1] = 32'd0;   // x1
        registers[2] = 32'd4;   // x2 (sp)
        registers[3] = 32'd2;   // x3
        registers[4] = 32'd2;   // x4
        registers[5] = 32'd2;   // x5
        registers[6] = 32'd5;   // x6
        registers[7] = 32'd0;   // x7
        registers[8] = 32'd0;   // x8
        registers[9] = 32'd0;   // x9
        registers[10] = 32'd1;  // x10 (a0)
        registers[11] = 32'd0;  // x11
        registers[12] = 32'd0;  // x12
        registers[13] = 32'd0;  // x13
        registers[14] = 32'd0;  // x14
        registers[15] = 32'd0;  // x15
        registers[16] = 32'd0;  // x16
        registers[17] = 32'd0;  // x17
        registers[18] = 32'd0;  // x18
        registers[19] = 32'd0;  // x19
        registers[20] = 32'd0;  // x20
        registers[21] = 32'd0;  // x21
        registers[22] = 32'd0;  // x22
        registers[23] = 32'd0;  // x23
        registers[24] = 32'd0;  // x24
        registers[25] = 32'd0;  // x25
        registers[26] = 32'd0;  // x26
        registers[27] = 32'd0;  // x27
        registers[28] = 32'd0;  // x28
        registers[29] = 32'd0;  // x29
        registers[30] = 32'd0;  // x30
        registers[31] = 32'd0;  // x31
        
        
    end
    
    // Asignaciones continuas para las salidas
    assign Data1 = (Read1 != 0) ? registers[Read1] : 32'd0;  // x0 siempre es 0
    assign Data2 = (Read2 != 0) ? registers[Read2] : 32'd0;  // x0 siempre es 0
    
    // Lógica de escritura síncrona
    always @(posedge reset) begin
        if (reset) begin
            /*
            for (i = 0; i < 32; i = i + 1)
                RF[i] <= 32'b0;
            */
        end 
    end

    always @(posedge clock) begin
        if (reset) begin
            // Reset opcional si lo deseas
        end else if (RegWrite && !finish_flag) begin
            if (addr != 0)
                registers[addr] <= WriteData;
            `ifdef SIMULATION
            $display("[RegisterFile] Escritura: x%0d = %d", addr, WriteData);
            `endif
        end
    end

    
    // Mostrar lecturas de registros
    
    
    `ifdef SIMULATION
        always @(Data1 or Data2) begin
            if (!reset && !finish_flag) begin
                $display("[RegisterFile] Read1: x%0d = %d, Read2: x%0d = %d", 
                Read1, Data1, 
                Read2, Data2);
            end
        end
    `endif

endmodule
