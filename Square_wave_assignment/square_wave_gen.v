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