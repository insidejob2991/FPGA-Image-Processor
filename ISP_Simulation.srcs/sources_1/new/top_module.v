`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2025 00:38:08
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(                     // Declares the top-level entity (the FPGA boundary).
    input clk,            // [Input] The 100MHz system clock signal. All operations are synchronized to this.
    input rst,            // [Input] The system reset signal.
    output [7:0] led_output, // [Output] 8-bit output port for local LED display verification.
    output tx_pin          // [Output] Single pin for serial UART transmission to PC.
    );

    // --- Signals Exposed for Testbench Access (Internal State Registers) ---
    reg clock_enable_2hz = 0; // The 1-bit signal that pulses high to trigger data movement (the slow clock).
    reg [13:0] addr = 0;       // 14-bit Address Register: Points to the current pixel being read from BRAM.
    reg [7:0] led_output_reg = 8'd0; // Final Output Register: Holds the stable 8-bit value sent to LEDs/UART.

    // --- Internal Signals and Wires ---
    localparam SIM_DIVISOR = 100; // Constant: The count limit for the clock divider (set low for fast simulation).
    reg [24:0] clk_counter = 0;     // Counter: Runs off the fast clock to generate the slow clock_enable_2hz pulse.
    wire [7:0] pixel_data;          // Output of the BRAM: Carries the 8-bit raw pixel value read from memory.
    wire [15:0] gaussian_result = 16'd512; // Input Data Link to CORDIC IP (Placeholder in this debug state).
    reg input_valid = 1'b1;          // Signal: Held high to indicate the CORDIC input data is always ready.
    wire [15:0] cordic_out;          // Output: Result of the CORDIC's Square Root operation.
    wire cordic_valid;              // Output: Handshake signal indicating CORDIC output is stable.
    wire tx_start;                  // Wire: Command signal to start UART transmission.
    wire tx_busy;                   // Wire: Status signal from UART, high when transmitting data.
    
    // Output assignment
    assign led_output = led_output_reg; // Continuous assignment: Maps the stable register value to the external pin.
    
    // --- CLOCK ENABLE LOGIC ---
    always @(posedge clk) begin       // Sequential block: Logic executes on every rising edge of 'clk'.
        if (rst) begin                 // Reset condition has highest priority.
            clk_counter <= 0;          // Reset the counter.
            clock_enable_2hz <= 1'b0;  // Force the enable pulse LOW.
        end else begin
            if (clk_counter == SIM_DIVISOR) begin // Check if the counter reached the limit (100 cycles).
                clk_counter <= 0;            // If limit reached, reset the counter to 0.
                clock_enable_2hz <= 1'b1;    // Pulse the enable signal HIGH for one clock cycle.
            end else begin
                clk_counter <= clk_counter + 1; // If not reached, increment the counter by 1.
                clock_enable_2hz <= 1'b0;    // Keep the enable signal LOW.
            end
        end
    end
    
    // --- MAIN DATA FLOW & ADDRESS CONTROL ---
    always @(posedge clk) begin       // Sequential block: Controls data sequencing and processing.
        if (rst) begin                 // Reset condition: Logic here executes only if rst is HIGH.
            // ... reset logic            // (This block needs explicit reset code, or it defaults to the outer rst logic)
        end else if (clock_enable_2hz) begin // Execution trigger: Executes only when the slow pulse is HIGH.
            addr <= addr + 1;            // Advances the BRAM address to the next pixel location.
            
            // *** DEBUG BYPASS LINE ***
            led_output_reg <= pixel_data; // DEBUG: Captures the raw BRAM output (pixel_data) directly to the output register.
            
            // The final line should be: led_output_reg <= cordic_out[7:0]; 
        end
    end
    
    // --- IP INSTANTIATION ---
    // BRAM Instantiation (Block Memory Generator)
    blk_mem_gen_0 your_image_rom (    // Instantiates the BRAM IP core.
        .clka (clk), .ena (1'b1), .wea (4'b0000), // Connects clock, enables read, disables write (ROM mode).
        .addra (addr), .dina (8'd0), .douta (pixel_data)     // Connects address pointer and reads data onto 'pixel_data'.
    );

    // CORDIC Instantiation (Square Root Processor)
    cordic_1 math_unit (              // Instantiates the CORDIC IP core.
        .aclk (clk), .s_axis_cartesian_tvalid (input_valid), // Connects fast clock and input valid signal.
        .s_axis_cartesian_tdata (gaussian_result),            // Connects the input data link (16-bit) to the CORDIC.
        .m_axis_dout_tvalid (cordic_valid), .m_axis_dout_tdata (cordic_out)     // Reads the result and the valid signal.
    );
    
    // UART TX Control & Instantiation
    assign tx_start = (clock_enable_2hz && !tx_busy) ? 1'b1 : 1'b0; // Command to start UART only when clock enable is high AND UART is not busy.
    
    uart_tx uart_unit (              // Instantiates the serial communication module.
        .clk(clk), .rst(rst), .tx_data(led_output_reg), // Feeds the stable output data.
        .tx_start(tx_start), .tx_busy(tx_busy), .tx_out(tx_pin) // Handshake connections.
    );
endmodule