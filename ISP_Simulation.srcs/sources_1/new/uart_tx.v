`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2025 02:19:32
// Design Name: 
// Module Name: uart_tx
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


module uart_tx (
    input clk,             // [Input] The 100MHz system clock signal. Used for all timing.
    input rst,             // [Input] The system reset signal (e.g., from the reset button).
    input [7:0] tx_data,   // [Input] The 8-bit parallel data (the processed pixel value) to be sent.
    input tx_start,        // [Input] Command pulse from top_module to begin transmission.
    output tx_busy,        // [Output] Flag that is HIGH when data is being transmitted.
    output reg tx_out      // [Output] The actual physical serial output line (TX pin).
);

    // --- Baud Rate Configuration for 115200 on 100MHz clock ---
    localparam CLKS_PER_BIT = 868; // Constant: Number of clock cycles (100MHz) required for one bit (1/115200 sec).
    localparam STATE_IDLE = 3'b000;    // State: Waiting for a tx_start command.
    localparam STATE_START = 3'b001;   // State: Transmitting the mandatory START bit (Logic 0).
    localparam STATE_DATA = 3'b010;    // State: Transmitting the 8 data bits.
    localparam STATE_STOP = 3'b011;    // State: Transmitting the mandatory STOP bit (Logic 1).
    
    // --- Internal Registers and Counters ---
    reg [9:0] clk_counter = 0; // Counter that counts up to 868 (CLKS_PER_BIT). 10 bits wide (2^10=1024).
    reg [2:0] tx_state = STATE_IDLE;   // 3-bit register holding the current state of the UART FSM (Finite State Machine).
    reg [3:0] bit_count = 0;   // 4-bit counter (0 to 7) to track which data bit is currently being sent.
    reg [7:0] tx_register = 0; // 8-bit register to temporarily hold the data being sent (tx_data).
    
    // --- Combinational Output (tx_busy flag) ---
    // Assert tx_busy HIGH whenever the FSM is not in the STATE_IDLE.
    assign tx_busy = (tx_state != STATE_IDLE);

    // --- Initial State for Synthesis ---
    // Sets the pin to HIGH logic level, which is the standard UART IDLE state.
    initial tx_out = 1'b1; 

    // --- Main Sequential Logic Block (Runs on every rising clock edge) ---
    always @(posedge clk) begin
        // --- Reset Logic (Asynchronous Reset) ---
        if (rst) begin
            tx_state <= STATE_IDLE; // Reset FSM to safe IDLE state.
            tx_out <= 1'b1;         // Force output pin HIGH (IDLE).
            clk_counter <= 0;       // Reset timing counter.
            bit_count <= 0;         // Reset bit position counter.
        end
        
        // --- UART Finite State Machine (FSM) ---
        // Determines the next action based on the current state and timing.
        case (tx_state)
            
            // --- STATE 0: IDLE ---
            STATE_IDLE: begin
                tx_out <= 1'b1;         // Keep output pin HIGH.
                if (tx_start) begin     // Check if top_module sent the start command.
                    tx_state <= STATE_START; // Transition to START bit state.
                    tx_register <= tx_data;  // Capture the pixel data into the local register.
                    bit_count <= 0;          // Reset bit counter for the new transmission.
                end
            end

            // --- STATE 1: START BIT (Logic 0) ---
            STATE_START: begin
                tx_out <= 1'b0;                 // Pull output pin LOW for the duration of the bit.
                clk_counter <= clk_counter + 1; // Increment timing counter.
                
                // Check if the full bit time (868 cycles) has elapsed.
                if (clk_counter == CLKS_PER_BIT - 1) begin
                    clk_counter <= 0;           // Reset the timing counter.
                    tx_state <= STATE_DATA;     // Transition to the DATA transmission state.
                end
            end

            // --- STATE 2: DATA BITS (LSB first) ---
            STATE_DATA: begin
                tx_out <= tx_register[bit_count]; // Output the current bit value (0 or 1).
                clk_counter <= clk_counter + 1;     // Increment timing counter.
                
                // Check if the full bit time has elapsed.
                if (clk_counter == CLKS_PER_BIT - 1) begin
                    clk_counter <= 0;               // Reset the timing counter.
                    
                    // Check if all 8 bits have been sent (bit_count 0 through 7).
                    if (bit_count == 7) begin
                        tx_state <= STATE_STOP;     // If yes, move to STOP state.
                    end else begin
                        bit_count <= bit_count + 1; // If no, move to the next bit (LSB first).
                    end
                end
            end
            
            // --- STATE 3: STOP BIT (Logic 1) ---
            STATE_STOP: begin
                tx_out <= 1'b1;                 // Pull output pin HIGH for the duration of the bit.
                clk_counter <= clk_counter + 1; // Increment timing counter.
                
                // Check if the full bit time has elapsed.
                if (clk_counter == CLKS_PER_BIT - 1) begin
                    clk_counter <= 0;           // Reset the timing counter.
                    tx_state <= STATE_IDLE;     // Return to IDLE, completing the transmission cycle.
                end
            end

            // --- Default Fallback ---
            default: tx_state <= STATE_IDLE; // Should not happen, but a safe fallback.
        endcase
    end
endmodule