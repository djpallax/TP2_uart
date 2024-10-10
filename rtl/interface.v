/*
 Interfaz para gestionar datos entre el sistema principal y los módulos UART, 
 permitiendo establecer y borrar una bandera, así como almacenar y recuperar datos en un búfer. 
 La bandera indica la disponibilidad de datos para su lectura,
 y los datos se almacenan en el búfer para su posterior recuperación.
*/

module interface_uart
#(
    parameter NB_DATA = 32
)
(
    input wire clk, reset,
    input wire clr_flag, set_flag,
    input wire [NB_DATA - 1 : 0] data_in,
    output wire flag,
    output wire [NB_DATA - 1: 0] data_out
);

    reg [NB_DATA - 1:0] buf_reg, buf_next;
    reg flag_reg, flag_next;
    
    // Lógica secuencial: Actualización del buffer y la bandera en cada flanco de reloj o reset
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            buf_reg <= 0;
            flag_reg <= 1'b0;  // Reinicio de la bandera
        end
        else
        begin
            buf_reg <= buf_next;
            flag_reg <= flag_next;
        end
    end
    
    // Lógica combinacional: Control del buffer y la bandera
    always @(*)
    begin
        // Por defecto, se mantienen los valores actuales
        buf_next = buf_reg;
        flag_next = flag_reg;

        // Si `set_flag` está activo, se almacenan los datos y se establece la bandera
        if (set_flag)
        begin
            buf_next = data_in;
            flag_next = 1'b1;  // Se indica que hay nuevos datos disponibles
        end
        // Si `clr_flag` está activo, se borra la bandera
        else if (clr_flag)
        begin
            flag_next = 1'b0;
        end
    end

    // Asignación de las salidas
    always @(posedge clk)
    begin
        data_out <= buf_reg; // Salida de datos
        flag <= flag_reg;    // Estado de la bandera
    end
    
endmodule