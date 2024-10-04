module uart_rx
#(
    parameter NB_DATA   = 8,     // Cantidad de bits por paquete
    parameter FLAG_PARITY    = 2'b00, // 00 = sin paridad, 01 = paridad par, 10 = paridad impar
    parameter FLAG_STOP_BITS = 1'b1,  // 0 = sin bit de stop, 1 = con bit de stop
    parameter FLAG_SYNC      = 1'b1,   // 1 = asíncrono, 0 = síncrono
    
    parameter CLK_FREQ = 100000000, // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200    // Baud Rate de operación
)
(
    input wire clk,                 // Clock que viene del generador de baudios (EL GENERADOR DEBE DETERMINAR SINCRONO O ASINCRONO)
    input wire i_rst,               // Boton reinicio
    input wire i_rx,                  // Pin para escuchar la transmisión
    input wire baud_tick,           // Tick de baud para la sincronización
    output reg [NB_DATA-1:0] rx_data_out,      // Datos recibidos
    output reg rx_done,             // Flag para indicar fin de la recepción
    output reg o_valid              // Señal para que el generador de baudios comience
);

    localparam [1:0]            // Definición de estados
        s_RX_IDLE  = 2'b00,     // Espera bit de inicio
        s_RX_START = 2'b01,     // Detecta el inicio, arranca a escuchar
        s_RX_DATA  = 2'b10,     // Escucha los datos
        s_RX_STOP  = 2'b11;     // Estado de finalización
        
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;

    reg [1:0] state, next_state;    // Estado actual y próximo
    reg [7:0] shift_data;           // Registro para almacenar los datos
    reg [3:0] bit_count;            // Bit actual de la transmisión
    reg [31:0] clock_count;         // Contador de clk para dar inicio al generador de baudios
    reg baud_tick_last;             // Para almacenar el valor anterior de baud_tick
    
    
    
    always @(posedge clk or posedge i_rst) begin
        if (i_rst) begin        // Estado de reinicio
            state <= s_RX_IDLE;
            next_state <= s_RX_IDLE;
            rx_data_out <= 0;
            bit_count <= 0;
            rx_done <= 0;
            clock_count <= 0;
            baud_tick_last <= 0;
            o_valid <= 0;
        end
        else begin
            baud_tick_last <= baud_tick;    // Almacena el valor anterior del baud_tick
        
            if (baud_tick && !baud_tick_last) begin     // Detecta flanco de subida de baud_tick
                state <= next_state;
            end
        end
    end
    
    
    
    always @(posedge clk) begin
        state <= next_state;
        
        // Máquina de estados
        
        case (state)
        
    // IDLE: espero el bit de inicio
            
            s_RX_IDLE: begin
                if (i_rx == 0) begin      // Si vino un 0 arranco
                    next_state <= s_RX_START;
                    clock_count <= 0;
                    o_valid <= 0;
                end
            end
            
    // START: Configuro para empezar a escuchar
            
            s_RX_START: begin
                if (clock_count == (DIVISOR - 1)/2) begin 
                    next_state <= s_RX_DATA;
                    bit_count <= 0;         // Preparo el contador de bits
                    o_valid <= 1;       // Inicio el generador de ticks
                end
                
                else begin
                    clock_count <= clock_count + 1;
                end
            end
            
    // DATA: Escucho la transmisión
            
            s_RX_DATA: begin
                o_valid <= 1;
                if (baud_tick && !baud_tick_last) begin // Solo actúa cuando llega un flanco de subida de baud_tick
                    if (bit_count < NB_DATA) begin
                        shift_data[bit_count] <= i_rx;    // Recibe el bit de datos
                        bit_count <= bit_count + 1;
                    end
                    
                    else begin
                        next_state <= s_RX_STOP;        // Llenaron los NB_DATA (probablemente 8), entonces termino
                    end
                end
            end
            
    // STOP: Detecto el fin de la transmisión y reinicio
            
            s_RX_STOP: begin
                if (i_rx == 1) begin  // Se detecta bit de parada después de NB_DATA bits de datos (Y PARIDAD???)
                    rx_done <= 1;               // Aviso que hay un paquete nuevo
                    rx_data_out <= shift_data;  // Este es el paquete
                    o_valid <= 0;               // Ahorro energía (Apago el generador de ticks)
                    bit_count <= 0;
                    next_state <= s_RX_IDLE;    // Vuelve a IDLE
                end
                
                else begin      // En caso de que llegue otra cosa que no sea bit de parada, error (IMPLEMENTAR BIT DE PARIDAD)
                    // Ignoro el paquete y reinicio (ESTÁ BIEN???)
                    rx_done <= 0;               // Info ta mal así que nada para leer
                    rx_data_out <= {NB_DATA{1'b0}};    // Vacío el buffer 
                    o_valid <= 0;               // Apago el generador
                    bit_count <= 0;
                    next_state <= s_RX_IDLE;    // Vuelve a IDLE
                end
            end
            
        endcase
        
    end
    
endmodule