module DataMemory (
    input logic clk,
    input logic [31:0] address,
    input logic signed [31:0] write_data,
    input logic write_enable,
    input logic read_enable,
    output logic [31:0] read_data
);

// Memoria de datos
logic [31:0] memory [0:255]; // Memoria de 256 palabras de 32 bits
initial begin
        $readmemh("hex/ProyectoCorto_data.hex", memory); // Cargar instrucciones desde un archivo hexadecimal
    end
// Lógica de escritura y lectura de memoria
always @(posedge clk) begin
    if (write_enable)
        memory[address] <= write_data;
end
always @(address) begin
    if (read_enable)
        read_data <= memory[address];
end

endmodule