
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