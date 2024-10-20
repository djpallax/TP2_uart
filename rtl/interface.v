module interface
#(
    parameter NB_DATA = 8,
    parameter NB_OP   = 6
)
(
    input  wire clk,                                    // Clock del sistema
    input  wire i_rst,                                  // Señal de reset
    input  wire [NB_DATA-1:0] i_rx_uart_data,           // Información recibida de UART RX
    input  wire i_rx_uart_done,                         // Flag de trama nueva      REVISAR COMO APAGARLO, SI LE MANDO SEÑAL DE INTERFACE A RX O COMO
    output wire [NB_DATA-1:0] o_data_a,                 // Valor 1 para la ALU
    output wire [NB_DATA-1:0] o_data_b,                 // Valor 2 para la ALU
    output wire [NB_DATA-1:0] o_op,                     // Operador para la ALU
    output wire [2:0]         o_leds,                   // Leds de estado
    output wire o_update_alu       // SERIA EL VALID????
);

    localparam [1:0]
        S_WAIT_A        = 2'b00,  // Esperando el primer operando
        S_WAIT_B        = 2'b01,  // Esperando el segundo operando
        S_WAIT_OP       = 2'b10,  // Esperando el operador        CONVIENE QUE SEA OPERANDO 1, 2 Y OP, O QUE SEA 1, OP Y 2? USAR LEDS PARA MOSTRAR ESTADO
        S_SHOW_RES      = 2'b11;  // Envía el resultado por uart tx
        
    reg [1:0] r_state, r_next_state;    // Estado actual y próximo

    reg signed [NB_DATA - 1 : 0] data_a;   // Registro para almacenar el primer operando
    reg signed [NB_DATA - 1 : 0] data_b;   // Registro para almacenar el segundo operando
    reg        [NB_OP   - 1 : 0] op    ;   // Registro para almacenar el operador
    
    reg f_show_rx;      // Flag para alternar el valid en la alu
    reg f_last_rx;      // Estado anterior de rx_done
    reg [2:0] leds;     // Estado de leds
//    // Instanciación de la ALU
//    ALU #(
//        .NB_DATA(NB_DATA ),
//        .NB_OP  (NB_OP   )
//    ) alu_instance (
//        .i_data_a(data_a ),
//        .i_data_b(data_b ),
//        .i_op    (op     ),
//        .i_valid (i_valid),
//        .o_result(o_led  )
//    );
    
    always @(posedge clk or posedge i_rst) begin
        if (i_rst) begin
            r_state <= S_WAIT_A;
            r_next_state <= S_WAIT_A;
            data_a <= 0;        // {NB_DATA{1'b0}};
            data_b <= 0;        // {NB_DATA{1'b0}};
            op <= 0;            // {NB_OP{1'b0}};
            leds <= 0;
        end
        
        else begin
            if (i_rx_uart_done && !f_last_rx) begin     // Detecta flanco de subida de recepción
                r_state <= r_next_state;                // Permito el cambio de estado
            end
            
            f_last_rx <= i_rx_uart_done;    // Almacena el estado anterior de recepción
        end
        
    end
    
    
    
    always @(posedge clk) begin
        r_state <= r_next_state;
        
        case(r_state)
        
        // Esperando el primer operando
            S_WAIT_A: begin
                f_show_rx <= 0;     // Valid deshabilitado
                leds <= 3'b001;
                // Implementar métodos de verificación de valores correctos (en op mas que nada)
                if (i_rx_uart_done && !f_last_rx) begin     // Vino flanco de subida de recepción lista
                    data_a <= i_rx_uart_data;               // La info va al primer valor
                    r_next_state <= S_WAIT_B;                    // Paso al siguiente
                end
            end
           
        // Esperando el segundo operando
            S_WAIT_B: begin
                f_show_rx <= 0;     // Valid deshabilitado
                leds <= 3'b010;
                if (i_rx_uart_done && !f_last_rx) begin     // Vino flanco de subida de recepción lista
                    data_b <= i_rx_uart_data;               // La info va al primer valor
                    r_next_state <= S_WAIT_OP;                   // Paso al siguiente
                end
            end
            
        // Esperando la operación
            S_WAIT_OP: begin
                f_show_rx <= 0;     // Valid deshabilitado
                leds <= 3'b100;
                if (i_rx_uart_done && !f_last_rx) begin     // Vino flanco de subida de recepción lista
                    op <= i_rx_uart_data;
                    r_next_state <= S_SHOW_RES;
                end
            end
            
        // Cargo los valores a la ALU
            S_SHOW_RES: begin
                f_show_rx <= 1;     // Habilito el valid para que cargue el resultado
                leds <= 3'b000;
                
                // Aca tengo que ver si le doy un delay o algo
                
                r_next_state <= S_WAIT_A;   // Reinicio

            end
            
            
        endcase
    end

assign o_update_alu = f_show_rx ? 1 : 0;    // Si está habilitado, manda a la ALU a operar
assign o_data_a = data_a;       // Los datos serán constantes, el flag de valid manda a operar
assign o_data_b = data_b;
assign o_op = op;
assign o_leds = leds;


endmodule