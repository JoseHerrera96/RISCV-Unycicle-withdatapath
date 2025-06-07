Este repositorio contiene la implementación de un procesador uniciclo basado en la arquitectura RISC-V (rv32i) para el curso EL3310 - Diseño de Sistemas Digitales, TEC.

## Descripción General
El objetivo de este proyecto es diseñar, implementar y simular un procesador RISC-V de un solo ciclo (uniciclo) utilizando SystemVerilog. El procesador es capaz de ejecutar instrucciones básicas del conjunto rv32i y se valida mediante testbenches y programas de prueba.

## Estructura del Proyecto
- **src/**: Archivos fuente SystemVerilog de los módulos principales:
  - ALU (`RISCVALU.sv`)
  - Memoria de datos (`datamem.sv`)
  - Memoria de instrucciones (`Instmemory.sv`)
  - Banco de registros (`registerfile.sv`)
  - Program Counter (`PC.sv`)
  - Extensor de signo (`signext.sv`)
  - Top module (`RISCVunicycle.sv`)
- **tb/**: Testbenches y archivos de simulación para cada módulo y el procesador completo. Incluye archivos `.vvp` y `.vcd` generados tras la simulación.
- **hex/**: Archivos de memoria en formato `.hex` para cargar instrucciones y datos en la simulación. Ejemplos: `ProyectoCorto_instructions.hex`, `FinalT.hex`.
- **RISC-V-Single-Cycle-Processor/** y **RISC-V-Unicycle-Processor/**: Carpetas adicionales con Makefiles para automatizar compilación/simulación (opcional).

## Requisitos
- [Icarus Verilog](http://iverilog.icarus.com/) (recomendado para compilar y simular en Windows)
- Visualizador de ondas como GTKWave (opcional, para archivos `.vcd`)

## Instrucciones de Compilación y Simulación
1. Abre una terminal en la carpeta raíz del proyecto.
2. Para compilar y simular un módulo, por ejemplo `datamem`:
   ```sh
   iverilog -o tb/datamem_tb.vvp src/datamem.sv tb/datamem_tb.sv
   vvp tb/datamem_tb.vvp
   ```
3. Para ver las señales en GTKWave:
   ```sh
   gtkwave tb/datamem_tb.vcd
   ```
4. Para simular el procesador completo:
   ```sh
   iverilog -o tb/RISCVunicycle_tb.vvp src/*.sv tb/RISCVunicycle_tb.sv
   vvp tb/RISCVunicycle_tb.vvp
   gtkwave tb/RISCVunicycle_tb.vcd
   ```

## Uso de Archivos .hex
Los archivos `.hex` contienen instrucciones o datos que se cargan en las memorias durante la simulación. Puedes modificar o agregar nuevos archivos `.hex` en la carpeta `hex/` según los programas de prueba que desees ejecutar.

## Agregar Nuevos Módulos o Testbenches
- Crea el archivo fuente en `src/` y su testbench en `tb/`.
- Sigue la convención de nombres: `<modulo>.sv` y `<modulo>_tb.sv`.
- Actualiza los comandos de compilación según corresponda.

## Créditos
Proyecto realizado para el curso EL3310 - Diseño de Sistemas Digitales, TEC.

---



