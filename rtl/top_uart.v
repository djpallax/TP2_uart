module top_uart
#(
    parameter NB_DATA   = 8,            // Bits de datos de uart y cant. bits para operandos
    parameter NB_OP     = 6,            // Bits para una operación
    
    parameter CLK_FREQ  = 100000000,    // Frecuencia del reloj del sistema 100 MHz
    parameter BAUD_RATE = 115200   ,    // Baud rate establecido
        // (FLAGS DE RX A IMPLEMENTAR FUNCIONAMIENTO)
    parameter F_RX_PARITY    = 2'b00,   // 00 = sin paridad, 01 = paridad par, 10 = paridad impar
    parameter F_RX_STOP_BITS = 1'b1 ,   // 0 = sin bit de stop, 1 = con bit de stop
    parameter F_RX_SYNC      = 1'b1     // 1 = asíncrono, 0 = síncrono
)
(
    input  wire       clk      ,    // Clock interno
    input  wire       i_rst    ,    // Entrada de reset
    input  wire       i_uart_rx,    // Conexión de entrada de datos uart
    output wire       o_uart_tx,    // Conexión de salida de datos uart
    output wire [1:0] o_uart_led    // Leds de comunicación uart    (AGREGO DE ESTADOS? PARA INTERFAZ)
);

    // Instancia RX

    uart_rx #(
        .NB_DATA        (NB_DATA)       ,
        .NB_OP          (NB_OP)         ,
        .F_RX_PARITY    (F_RX_PARITY)   ,
        .F_RX_STOP_BITS (F_RX_STOP_BITS),
        .F_RX_SYNC      (F_RX_SYNC)
    )
    rx_instance (
        .i_rx(i_uart_rx)        // Pin de entrada de recepción uart
    );
    
    // ACÁ CREAR LOS REGISTROS PARA INTERCONECTAR LOS MÓDULOS
    // PARA LOS REG QUE INTERCONECTAN, USAR w_... para un wire
    
    // Instancia TX
    
//    uart_tx #(
//        .NB_DATA(NB_DATA),
//        .NB_OP  (NB_OP)
//    )
//    tx_instance (
//        .o_tx(o_uart_tx)
//    );

    // Instancia Interfaz

//    interface #(
//        .NB_DATA(NB_DATA),
//        .NB_OP  (NB_OP)
//    )
//    interface_instance (
//        .i_rx(i_uart_rx)
//    );

    // Instancia ALU
    
//    ALU #(
//        .NB_DATA(NB_DATA),
//        .NB_OP  (NB_OP)
//    )
//    alu_instance (
//        .i_rx(i_uart_rx)
//    );

    // Instancia Baud Rate Generator
    
//    baud_rate_gen #(
//        .CLK_FREQ(CLK_FREQ),
//        .BAUD_RATE(BAUD_RATE)
//    )
//    baud_rate_instance (
//        
//    );

    
        
endmodule