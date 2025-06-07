module instmemory(addr,instruct, last_instr_flag);
    input logic [31:0] addr; // Dirección de la instrucción actual
    output logic [31:0] instruct; // Instrucción actual
    logic [31:0] file [0:31]; 
    logic [7:0] RF [0:127]; // 128 espacios de 8 bits cada uno # 32 registros de 32 bits
    logic [31:0] instruct_temp, full_RF_temp; // Instrucción actual
    output logic last_instr_flag; // Bandera para indicar la última instrucción
    logic [31:0] d = 32'd0; // Inicializar el contador d correctamente
    integer base=0;

   initial begin
        // Inicializar RF (memoria byte a byte) a 0xFF
        last_instr_flag=0;
        for (integer i = 0; i < 128; i = i + 1) begin
            RF[i] = 8'hFF;
        end
        // Inicializar file (memoria palabra a palabra) a 0xFFFFFFFF
        for (integer j = 0; j < 32; j = j + 1) begin
            file[j] = 32'hFFFFFFFF;
        end
        // Cargar instrucciones desde archivo, sobrescribiendo solo las posiciones necesarias
        $readmemh("hex/Test1.hex", file);
        if (file[0] === 32'hFFFFFFFF) begin
            $display("Error: El archivo está vacío o no tiene suficientes datos.");
            $finish;
        end
        // Copiar todas las instrucciones de file a RF (de 0 a 31)
        for (integer idx = 0; idx < 32; idx = idx + 1) begin
            base = idx * 4;
            RF[base]   = file[idx][7:0];
            RF[base+1] = file[idx][15:8];
            RF[base+2] = file[idx][23:16];
            RF[base+3] = file[idx][31:24];
        end
        // (Líneas eliminadas: no debe haber código procedural suelto aquí)

        $display("Memory initialized:");

        end
        
    /*
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("RF[%0d]: %h", i, RF[i]);
            if ((i+1)%4 == 0) begin
                $display("\n"); // Salto de línea cada 4 registros
            end
        end
*/
 

    assign instruct={RF[addr+3], RF[addr+2], RF[addr+1], RF[addr]};
    `ifdef SIMULATION
        always @(instruct) begin
            $display("[InstMemory] addr: %d, Instruccion: %h", addr, instruct);
        end
   `endif

    always @(addr) begin
        // Activar la bandera si se accede a la última posición de la memoria
        if (instruct == 32'hFFFFFFFF && addr > 0) begin
            last_instr_flag = 1;
        end
    end


endmodule