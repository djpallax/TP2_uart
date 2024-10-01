module baud_rate_gen
#(
    parameter CLK_FREQ = 100000000, // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200    // Baud Rate de operación
)
(
    input wire i_clk,       // Clock del sistema
    input wire i_rst,       // Reset
    output reg baud_tick    // Tick para los módulos
);

    // Cada cierta cantidad de clk, un tick
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;
    reg [31:0] count;   // Contador de clk para un tick
    
    always @(posedge i_clk or posedge i_rst) begin
    
        // Estado de reset, todo en 0
        
        if (i_rst) begin
            count <= 0;
            baud_tick <= 0;
        end
        
        else begin
        
            // Si la cantidad de clk alcanzó al divisor, genero el tick
        
            if (count == DIVISOR -1) begin
                count <= 0;
                baud_tick <= 1;     // Probar si alcanzará con un solo ciclo de reloj para que los otros módulos actúen
            end
            
            // Si clk no alcanza al divisor, sumo
            
            else begin
                count <= count + 1;
                baud_tick <= 0;
            end
        end
    end
    
endmodule