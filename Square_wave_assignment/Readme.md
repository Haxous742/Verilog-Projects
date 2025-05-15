# Square Wave Generator in Verilog

## Overview
This project implements a Verilog module `square_wave_gen` that generates two square waves with a 90-degree phase difference, along with a testbench `tb_square_wave_gen` to simulate and verify its behavior. The square waves are generated using a 2-bit counter driven by a clock signal, and an active-high reset signal ensures initialization. The output frequency of the square waves is 1 MHz when driven by a 4 MHz clock.

## Files
- `square_wave_gen.v`: The main module that generates two square waves.
- `tb_square_wave_gen.v`: The testbench module to simulate and verify the functionality of `square_wave_gen`.
- `square_wave.vcd`: The output waveform file generated during simulation (used for visualization in GTKWave).

## Functionality of `square_wave_gen.v`
The `square_wave_gen` module generates two square wave signals (`out1` and `out2`) with a 90-degree phase difference. It operates as follows:

### Inputs and Outputs
- **Inputs**:
  - `clk`: The input clock signal (4 MHz in the testbench).
  - `reset`: Active-high reset signal to initialize the counter and outputs to 0.
- **Outputs**:
  - `out1`: The first square wave, high for the first half of the period.
  - `out2`: The second square wave, high for the second and third quarters of the period (90-degree phase shift relative to `out1`).

### Internal Logic
- A 2-bit counter (`counter`) increments from 0 to 3 on each positive clock edge when `reset = 0`.
- When `reset = 1`, the counter resets to 0, and both outputs are set to 0.
- The outputs are defined using combinational logic in an `always @(*)` block:
  - `out1` is high when `counter < 2` (i.e., `counter = 0` or `1`).
  - `out2` is high when `counter == 1 || counter == 2`.
- The counter creates a 4-cycle period (since it counts from 0 to 3), and the outputs have a 50% duty cycle (high for 2 cycles, low for 2 cycles).

### Why the Output Frequency is 1 MHz
- The testbench provides a 4 MHz clock (period = 250 ns, as defined by `forever #125 clk = ~clk`).
- The 2-bit counter completes one full cycle (0 to 3) in 4 clock cycles:
  - Total period = $4 \times 250 \, \mathrm{ns} = 1000 \, \mathrm{ns} = 1 \, \mathrm{\mu s}$.
- The frequency of the square waves is the inverse of the period:
  - Frequency = $\frac{1}{1 \, \mathrm{\mu s}} = 1 \, \mathrm{MHz}$.
- Thus, both `out1` and `out2` have a frequency of 1 MHz, with `out2` lagging `out1` by one clock cycle (250 ns), which is a 90-degree phase shift ($\frac{1}{4} \times 360^\circ = 90^\circ$).

### Code Snippet
```verilog
module square_wave_gen (
    input clk,          
    input reset,        
    output reg out1,    
    output reg out2    
);

    reg [1:0] counter;  

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end 
        else begin
            counter <= counter + 1; 
        end
    end

    always @(*) begin
        if (reset) begin
            out1 = 0;
            out2 = 0;
        end 
        else begin
            out1 = (counter == 0 || counter == 1); // High for counter = 0,1
            out2 = (counter == 1 || counter == 2); // High for counter = 1,2
        end
    end

endmodule
```

## Functionality of `tb_square_wave_gen.v`
The testbench `tb_square_wave_gen` simulates the `square_wave_gen` module by providing clock and reset stimuli and generating a waveform file for verification.

### Key Features
- **Clock Generation**:
  - Generates a 4 MHz clock (250 ns period) by toggling `clk` every 125 ns (`forever #125 clk = ~clk`).
- **Reset Sequence**:
  - 0–500 ns: `reset = 1` (initial reset).
  - 500–4500 ns: `reset = 0` (observe 4 periods of square waves).
  - 4500–5500 ns: `reset = 1` (second reset).
  - 5500–9500 ns: `reset = 0` (observe another 4 periods).
  - 9500 ns: Simulation ends (`$finish`).
- **Waveform Dumping**:
  - Dumps all signals to `square_wave.vcd` using `$dumpfile` and `$dumpvars` for visualization in GTKWave.

### Code Snippet
```verilog
module tb_square_wave_gen;
    reg clk;            
    reg reset;          
    wire out1; 
    wire out2;        

    square_wave_gen uut (
        .clk(clk),
        .reset(reset),
        .out1(out1),
        .out2(out2)
    );

    initial begin
        $dumpfile("square_wave.vcd"); 
        $dumpvars(0, tb_square_wave_gen); 
    end

    initial begin
        clk = 0;
        forever #125 clk = ~clk;  //4 Mhz clock
    end

    initial begin
        reset = 1;        
        #500 reset = 0;    
        #4000 reset = 1;  
        #1000 reset = 0;    
        #4000 $finish;    
    end

endmodule
```

## Simulation Instructions
To simulate the design and view the waveforms, follow these steps in a terminal:

1. **Compile the Verilog files**:
   ```
   iverilog -o testbench tb_square_wave_gen.v square_wave_gen.v
   ```

2. **Run the simulation**:
   ```
   vvp testbench
   ```

3. **View the waveforms**:
   ```
   gtkwave square_wave.vcd
   ```

## Waveform Analysis
In GTKWave, you’ll observe:
- **Clock (`clk`)**: 4 MHz (250 ns period).
- **Counter**: Increments from 0 to 3 every 4 clock cycles (1000 ns period).
- **out1**: High for `counter = 0, 1` (500 ns), low for `counter = 2, 3` (500 ns), frequency = 1 MHz.
- **out2**: High for `counter = 1, 2` (500 ns, shifted by 250 ns), low for `counter = 0, 3`, frequency = 1 MHz.
- **Reset Behavior**: Outputs are 0 and counter resets to 0 when `reset = 1`.
