module pwm_dimmer(
    input        clk,         // 27 MHz clock from Tang Nano 9K
    output reg [5:0] led      // 6 LEDs, active LOW (0 = on, 1 = off)
);

    reg [7:0]  pwm_cnt  = 8'd0;   // counts 0-255, controls PWM frequency
    reg [7:0]  duty     = 8'd0;   // brightness level 0-255 (0 = dark, 255 = full)
    reg        fade_dir = 1'd0;   // 0 = getting brighter, 1 = getting dimmer
    reg [19:0] fade_cnt = 20'd0;  // slow counter to control fade speed

    // 27 MHz / 1,048,576 ≈ 25.7 Hz  →  ~39 ms per brightness step
    localparam FADE_MAX = 20'd1048575;

    always @(posedge clk) begin
        // PWM counter: rolls over every 256 clocks = 105.5 kHz
        // this is fast enough that human eye sees no flicker
        pwm_cnt <= pwm_cnt + 8'd1;

        // --- FADE LOGIC: runs once every ~39 ms ---
        if (fade_cnt == FADE_MAX) begin
            fade_cnt <= 20'd0;  // reset slow counter

            // FADE IN: increase brightness
            if (fade_dir == 1'd0) begin
                if (duty == 8'd255)
                    fade_dir <= 1'd1;    // hit max brightness, start dimming
                else
                    duty <= duty + 8'd1; // get brighter
            end
            // FADE OUT: decrease brightness
            else begin
                if (duty == 8'd0)
                    fade_dir <= 1'd0;    // hit min brightness, start brightening
                else
                    duty <= duty - 8'd1; // get dimmer
            end
        end
        else begin
            fade_cnt <= fade_cnt + 20'd1; // keep counting
        end

        // --- PWM OUTPUT: compare counter to duty cycle ---
        // if counter is below duty value, LED stays ON longer = brighter
        if (pwm_cnt < duty)
            led <= 6'd0;     // 0 = 000000 = all LEDs ON
        else
            led <= 6'd63;    // 63 = 111111 = all LEDs OFF
    end

endmodule