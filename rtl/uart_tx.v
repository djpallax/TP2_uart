module uart_tx
#(
    parameter NB_DATA        = 8    ,   // Cantidad de bits por paquete
        // (FLAGS DE RX A IMPLEMENTAR FUNCIONAMIENTO)
    parameter F_RX_PARITY    = 2'b00,   // 00 = sin paridad, 01 = paridad par, 10 = paridad impar
    parameter F_RX_STOP_BITS = 1'b1 ,   // 0 = sin bit de stop, 1 = con bit de stop
    parameter F_RX_SYNC      = 1'b1 ,   // 1 = asíncrono, 0 = síncrono
    
    parameter CLK_FREQ  = 100000000,    // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200        // Baud Rate de operación
)
(
    input  wire               clk         , // Clock del sistema (EL GENERADOR DEBE DETERMINAR SINCRONO O ASINCRONO)
    input  wire               i_rst       , // Boton reinicio
    input  wire [NB_DATA-1:0] o_rx_data   , // Datos a transmitir
    output wire               o_tx        , // Salida para transmitir
    output wire               o_tx_done   , // Bit de transmisión finalizada
    output wire               o_valid       // Señal para que el generador de baudios comience

);

//    localparam [1:0]            // Definición de estados
//        S_RX_IDLE  = 2'b00,     // Espera bit de inicio
//        S_RX_START = 2'b01,     // Detecta el inicio, inicia el baud rate
//        S_RX_DATA  = 2'b10,     // Escucha los datos
//        S_RX_STOP  = 2'b11;     // Valida la trama

    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;

    reg  [1:0] r_state, r_next_state ;   // Estado actual y próximo
    reg  [7:0] r_shift_data          ;   // Registro para almacenar los datos
    reg  [3:0] r_bit_count           ;   // Bit actual de la transmisión
    reg [31:0] r_clock_count         ;   // Contador de clk para dar inicio al generador de baudios
    reg        r_baud_tick_last      ;   // Para almacenar el estado anterior de baud tick
    
    //wire       w_baud_tick           ;   // Cable para conectar con el generador    (FIJATE CON EL CLK DE ARRIBA, ESTE SERÍA EL CLK DE TICKS)
    wire       i_baud_tick;
    
    reg               f_rx_done ;
    reg               f_valid   ;
    
    // Instancia de baud_rate_gen
    baud_rate_gen #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )
    rx_baud_rate_gen (
        .i_clk      (clk)       ,
        .i_valid    (f_valid)   ,
        .o_baud_tick(i_baud_tick)   // Tick generado
    );
    
    always @(posedge clk or posedge i_rst) begin
    
    end
    
    always @(posedge clk) begin
        r_state <= r_next_state;
        
        
    end
    
endmodule