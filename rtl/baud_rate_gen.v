module baud_rate_gen
#(
    parameter CLK_FREQ = 100000000, // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200    // Baud Rate de operación
)
(
    input wire i_clk,       // Clock del sistema
    input wire i_valid,     // Le da comienzo a generar ticks
    output reg baud_tick    // Tick para los módulos
);

    // Cada cierta cantidad de clk, un tick
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;
    reg [31:0] count;   // Contador de clk para un tick
    reg delay_for_tick; // Delay para un tick, para que llegue a operar bien la lógica
    
    always @(posedge i_clk or posedge i_valid) begin
    
        // Habilitado a generar ticks
        
        if (i_valid) begin
            
            // Si la cantidad de clk alcanzó al divisor, genero el tick
        
            if (count == DIVISOR -1) begin
                count <= 0;
                baud_tick <= 1;     // Probar si alcanzará con un solo ciclo de reloj para que los otros módulos actúen
                delay_for_tick <= 4'b1111;
            end
            
            // Si clk no alcanza al divisor, sumo
            
            else begin
                count <= count + 1;
                if (delay_for_tick == 0) begin          // Si el delay llegó a 0, bajo el tick
                    baud_tick <= 0;
                end
                else begin
                    delay_for_tick <= delay_for_tick - 1;   // Decremento el delay
                end
            end
            
        end
        
        // Estado de reset, todo en 0
        
        else begin
            count <= 0;
            baud_tick <= 0;
        end
    end
    
endmodule