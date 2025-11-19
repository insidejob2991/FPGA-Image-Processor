from PIL import Image
import numpy as np
import os

# --- Configuration (Must match Verilog setup) ---
DATA_FILENAME = "processed_image_data.txt"
OUTPUT_FILENAME = "simulated_output_image.png"
IMAGE_WIDTH = 128
IMAGE_HEIGHT = 128
# ---------------------

def reconstruct_from_text(data_file, width, height, output_file):
    """Reads hexadecimal data from a text file and saves it as a grayscale image."""
    
    if not os.path.exists(data_file):
        print(f"ERROR: Data file not found at: {data_file}. Ensure the simulation ran until $stop.")
        return

    print(f"Reading hexadecimal pixel data from {data_file}...")
    pixel_values = []
    
    # Read and parse hexadecimal values
    try:
        with open(data_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    # Convert hex string (e.g., '54') to integer (e.g., 84)
                    pixel_values.append(int(line, 16))
    except Exception as e:
        print(f"Error parsing file: {e}")
        return

    expected_size = width * height
    actual_size = len(pixel_values)
    
    if actual_size < expected_size:
        print(f"Warning: Only found {actual_size} pixels. Image may be truncated.")
    
    # Use NumPy to reshape the 1D data into a 2D array
    np_data = np.array(pixel_values[:expected_size], dtype=np.uint8)
    
    # If the simulation stopped early, pad the array with zeros
    if actual_size < expected_size:
        padding = np.zeros(expected_size - actual_size, dtype=np.uint8)
        np_data = np.concatenate((np_data, padding))
    
    # Reshape the 1D array into the 2D image dimension
    img_array = np_data.reshape((height, width))
    
    # Create the grayscale image ('L' mode)
    img = Image.fromarray(img_array, mode='L')
    img.save(output_file)
    
    print(f"\nSuccessfully reconstructed image and saved to {output_file}.")

if __name__ == "__main__":
    reconstruct_from_text(DATA_FILENAME, IMAGE_WIDTH, IMAGE_HEIGHT, OUTPUT_FILENAME)