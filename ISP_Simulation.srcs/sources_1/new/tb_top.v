
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2025 03:15:10
// Design Name: 
// Module Name: tb_top
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

`timescale 1ns / 1ps          // Sets the time unit (1ns) and precision (1ps) for simulation.

module tb_top;                // Declares the Testbench module entity.
    // --- Testbench Signals ---
    reg clk = 1'b0;           // Generates the clock signal (must be 'reg' as its value changes). Initialized to 0.
    reg rst = 1'b1;           // Generates the reset signal (must be 'reg'). Initialized high to start in reset state.
    wire [7:0] led_output;    // Monitors the 8-bit processed data output from the top module.
    wire tx_pin;             // Monitors the serial output pin state.
    
    // --- File Handling and Control ---
    localparam IMAGE_SIZE = 16384; // Constant: Total number of pixels to process (128*128).
    integer output_file;      // Variable (integer) to hold the file handle for writing data to the PC.
    
    // Clock Generation (100 MHz clock)
    parameter HALF_PERIOD = 5; // Constant: Half the clock period (5ns) for 100MHz (Period = 10ns).
    always #HALF_PERIOD clk = ~clk; // Continuous assignment: Toggles 'clk' every 5ns, generating the 100MHz clock.

    // Instantiate the Top Module
    top_module uut (          // Instantiates the main design module (Unit Under Test).
        .clk(clk),           // Connects the testbench clock to the module clock.
        .rst(rst),           // Connects the testbench reset to the module reset.
        .led_output(led_output), // Monitors the module's 8-bit output.
        .tx_pin(tx_pin)      // Monitors the module's serial output.
    );

    // --- Final Initial Control Block ---
    initial begin             // Block executes only once at the start of simulation (time 0).
        // 1. Open the file on simulation start
        output_file = $fopen("processed_image_data.txt", "w"); // Opens the output file for writing ('w').

        // 2. Hold reset high to initialize
        rst = 1'b1;           // Asserts the reset signal (holds the design in a known state).
        #200;                 // Waits 200 nanoseconds to ensure the reset is stable.
        
        // 3. Release reset to start the data flow
        rst = 1'b0;           // De-asserts the reset signal, allowing the circuit to begin operating.
        
        // 4. DATA DUMPING LOOP (The Solution) ---
        // Waits until the reset signal officially drops to 0 (ensures synchronization).
        wait(!rst); 
        // Wait for reset to drop. (The !rst expression evaluates to true when rst is 0).
        
        // Loop runs exactly IMAGE_SIZE times (16384 times).
        for (integer i = 0; i < IMAGE_SIZE; i = i + 1) begin
            
            // Synchronization: Waits for the rising edge of the slow clock enable pulse.
            // This ensures data is captured only when the CORDIC has finished processing the pixel.
            @(posedge uut.clock_enable_2hz); 
            
            // Write data on the pulse
            $fwrite(output_file, "%h\n", uut.led_output_reg);
            // Writes the stable output data in hexadecimal format ('%h') followed by a newline ('\n').
        end

        // 5. Cleanup
        #100; // Waits 100ns for final signal cleanup/stabilization.
        $fclose(output_file); // Closes the file handle (crucial to save data to disk).
        $display("Image dump complete. File closed."); // Prints status message to the console.
        $stop; // Halts the XSim simulator gracefully, ending the run.
    end
endmodule