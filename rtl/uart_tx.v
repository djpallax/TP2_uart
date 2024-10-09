module uart_tx
#(
    parameter NB_DATA        = 8    ,   // Cantidad de bits por paquete
    parameter F_TX_PARITY    = 2'b00,   // 00 = sin paridad, 01 = paridad par, 10 = paridad impar
    parameter F_TX_STOP_BITS = 1'b1 ,   // 0 = sin bit de stop, 1 = con bit de stop
    parameter F_TX_SYNC      = 1'b1 ,   // 1 = asíncrono, 0 = síncrono
    parameter CLK_FREQ  = 100000000,    // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200        // Baud Rate de operación
)
(
    input wire               clk         , // Reloj de sistema
    input wire               i_rst       , // Botón de reinicio
    input wire [NB_DATA-1:0] i_tx_data   , // Datos a transmitir
    input wire               i_start     , // Señal de inicio de transmisión
    input wire               i_baud_tick , // Tick de baud para sincronización
    output reg               o_tx        , // Salida para transmitir datos
    output reg               o_tx_done   , // Señal que indica fin de transmisión
    output wire              o_valid       // Señal de habilitación del generador de baudios
);

    localparam [1:0]           // Definición de estados
        S_TX_IDLE  = 2'b00,    // Espera a que se inicie la transmisión
        S_TX_START = 2'b01,    // Transmite el bit de inicio
        S_TX_DATA  = 2'b10,    // Transmite los bits de datos
        S_TX_STOP  = 2'b11;    // Transmite el bit de stop
        
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;

    reg [1:0] r_state, r_next_state;      // Estado actual y próximo
    reg [3:0] r_bit_count;                // Contador de bits de datos
    reg [NB_DATA-1:0] r_shift_data;       // Registro de desplazamiento para transmitir los datos
    reg [31:0] r_clock_count;             // Contador para generar los ticks de baud
    reg        r_baud_tick_last;          // Estado anterior del baud tick
    
    reg        f_valid;                   // Señal de habilitación para el generador de baudios
    
    // Lógica para máquina de estados
    always @(posedge clk or posedge i_rst) begin
        if (i_rst) begin
            r_state <= S_TX_IDLE;
            o_tx <= 1'b1;  // Línea inactiva
            r_bit_count <= 0;
            o_tx_done <= 0;
            r_baud_tick_last <= 0;
            f_valid <= 0;
        end else begin
            r_baud_tick_last <= i_baud_tick;
            
            // Estado de transición
            if (i_baud_tick && !r_baud_tick_last) begin
                r_state <= r_next_state;
            end
        end
    end
    
    always @(posedge clk) begin
        case (r_state)
        
        // IDLE: Espera hasta que se inicie una nueva transmisión
        S_TX_IDLE: begin
            o_tx_done <= 0;
            if (i_start) begin
                r_shift_data <= i_tx_data;
                r_bit_count <= 0;
                r_next_state <= S_TX_START;
            end
        end
        
        // START: Transmite el bit de inicio (0)
        S_TX_START: begin
            o_tx <= 1'b0;  // Bit de inicio
            f_valid <= 1;  // Habilita el generador de baudios
            r_next_state <= S_TX_DATA;
        end
        
        // DATA: Transmite los bits de datos
        S_TX_DATA: begin
            if (i_baud_tick && !r_baud_tick_last) begin
                if (r_bit_count < NB_DATA) begin
                    o_tx <= r_shift_data[r_bit_count];  // Transmite el bit actual
                    r_bit_count <= r_bit_count + 1;
                end else begin
                    r_next_state <= S_TX_STOP;  // Se han transmitido todos los bits de datos
                end
            end
        end
        
        // STOP: Transmite el bit de stop y finaliza
        S_TX_STOP: begin
            o_tx <= 1'b1;  // Bit de stop
            f_valid <= 0;  // Deshabilita el generador de baudios
            o_tx_done <= 1'b1;  // Señal de fin de transmisión
            r_next_state <= S_TX_IDLE;
        end
        
        endcase
    end
    
    // Asignaciones para las salidas
    assign o_valid = f_valid;
    
endmodule