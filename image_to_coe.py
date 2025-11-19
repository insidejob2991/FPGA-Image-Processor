import cv2

# 1. Settings
input_image = "image1.jpg"  # Put your image name here
output_coe = "image1.coe"
width = 128   # Keep it small for Basys 3 BRAM (e.g., 100x100 or 128x128)
height = 128

# 2. Read and Process
img = cv2.imread(input_image)
img = cv2.resize(img, (width, height))
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) # Convert to 8-bit grayscale

# 3. Write .COE file
with open(output_coe, 'w') as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    
    # Flatten the image and write hex values
    count = 0
    total_pixels = width * height
    for i in range(height):
        for j in range(width):
            pixel_val = img_gray[i, j]
            # Write hex value (e.g., FF)
            if count == total_pixels - 1:
                f.write(f"{pixel_val:02X};") # End with semicolon
            else:
                f.write(f"{pixel_val:02X},") # Separate with comma
            count += 1
            
            if count % 16 == 0: # Newline for readability
                f.write("\n")

print(f"Success! {output_coe} generated with resolution {width}x{height}.")