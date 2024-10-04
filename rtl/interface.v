module interface
#(
    parameter NB_DATA = 8,
    parameter NB_OP   = 6
)
(
    input wire i_clk,                                   // Clock del sistema
    input wire i_rst,                                   // Señal de reset
    input wire [NB_DATA-1:0] i_rx_uart_data,       // Información recibida
    input wire i_rx_uart_done,                          // Flag de trama nueva      REVISAR COMO APAGARLO, SI LE MANDO SEÑAL DE INTERFACE A RX O COMO
    output reg [NB_DATA-1:0] o_rx_uart_data,       // Comando para la ALU
    output reg update_alu       // SERIA EL VALID????
);

    localparam [1:0]
        s_WAIT_A        = 2'b00,  // Esperando el primer operando
        s_WAIT_B        = 2'b01,  // Esperando el segundo operando
        s_WAIT_OP       = 2'b10,  // Esperando el operador        CONVIENE QUE SEA OPERANDO 1, 2 Y OP, O QUE SEA 1, OP Y 2?
        s_SHOW_RES      = 2'b11;  // Envía el resultado por uart tx
        
    reg [1:0] state, next_state;    // Estado actual y próximo

    reg signed [NB_DATA - 1 : 0] data_a;   // Registro para almacenar el primer operando
    reg signed [NB_DATA - 1 : 0] data_b;   // Registro para almacenar el segundo operando
    reg        [NB_OP   - 1 : 0] op    ;   // Registro para almacenar el operador

    // Instanciación de la ALU
    ALU #(
        .NB_DATA(NB_DATA ),
        .NB_OP  (NB_OP   )
    ) alu_instance (
        .i_data_a(data_a ),
        .i_data_b(data_b ),
        .i_op    (op     ),
        .i_valid (i_valid),
        .o_result(o_led  )
    );
    
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state <= s_WAIT_A;
            next_state <= s_WAIT_A;
            data_a <= 0;        // {NB_DATA{1'b0}};
            data_b <= 0;        // {NB_DATA{1'b0}};
            op <= 0;            // {NB_OP{1'b0}};
        end
        
    end
    
    always @(posedge i_clk) begin
        state <= next_state;
        
        case(state)
        
            s_WAIT_A: begin
            
            end
            
            s_WAIT_B: begin
            
            end
            
            s_WAIT_OP: begin
            
            end
            
            s_SHOW_RES: begin
            
            end
            
            
        endcase
    end

endmodule