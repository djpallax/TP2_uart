// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)        HACER ESTO
// Example: 10 MHz Clock, 115200 baud UART                          SI LA RECEPCION ES ASINCRONA, SINO, TOMAR EN CLK, EL CLK DE SINCRONÍA
// (10000000)/(115200) = 87


module uart_rx
#(
    parameter NB_DATA_BITS   = 8,     // Cantidad de bits por paquete
    parameter FLAG_PARITY    = 2'b00, // 00 = sin paridad, 01 = paridad par, 10 = paridad impar
    parameter FLAG_STOP_BITS = 1'b0,  // 0 = sin bit de stop, 1 = con bit de stop
    parameter FLAG_SYNC      = 1'b0   // 1 = asíncrono, 0 = síncrono
)
(
    input wire clk,
    input wire i_rst,               // Boton reinicio
    input wire rx,                  // Pin para escuchar la transmisión
    input wire baud_tick,           // Tick de baud para la sincronización
    output reg [NB_DATA_BITS-1:0] rx_data_out       // Datos recibidos
);

    localparam [1:0]            // Definición de estados
        s_RX_IDLE  = 2'b00,     // Espera bit de inicio
        s_RX_START = 2'b01,     // Detecta el inicio, arranca a escuchar
        s_RX_DATA  = 2'b10,     // Escucha los datos
        s_RX_STOP  = 2'b11;     // Estado de finalización

    reg [1:0] state, next_state;    // Estado actual y próximo
    reg [7:0] shift_data;           // Registro para almacenar los datos
    reg [3:0] bit_count;            // Bit actual de la transmisión
    
    always @(posedge clk or posedge i_rst) begin
        if (i_rst) begin        // Estado de reinicio
            state <= s_RX_IDLE;
            rx_data_out <= 0;
            bit_count <= 0;
        end
        else if (baud_tick) begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        next_state = state;
        
        // Máquina de estados
        
        case (state)
        
            // IDLE: espero el bit de inicio
            
            s_RX_IDLE: begin
                if (rx == 0) begin      // Si vino un 0 arranco
                    next_state <= s_RX_START;
                end
            end
            
            // START: Configuro para empezar a escuchar
            
            s_RX_START: begin
                
            end
    end
    
endmodule