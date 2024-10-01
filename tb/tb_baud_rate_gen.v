module tb_baud_rate_gen;

    reg i_clk;
    reg i_rst;
    wire baud_tick;
    
    baud_rate_gen
    #(
        .CLK_FREQ(100000000),   // 100 MHZ
        .BAUD_RATE(115200)      // 115200 bps
    )
    uut
    (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .baud_tick(baud_tick)
    );
    
    always #5 i_clk = ~i_clk; // Cada 5 ns se genera un ciclo de reloj (100 MHz)
    
    initial begin
        i_clk = 0;
        i_rst = 1;
        
        #20 
        
        i_rst = 0;
        
        
        #1000000 $finish;
    end

endmodule