import random
import os

def generate_memory_in(filename="memory_in.dat", num_lines=256):
    """
    Generates a file with random 128-bit hexadecimal values.
    Each line contains 16 bytes (128 bits) represented as 32 hex characters.
    """
    with open(filename, 'w') as f:
        for _ in range(num_lines):
            # Generate 16 random bytes (0-255)
            line_bytes = [random.randint(0, 255) for _ in range(16)]
            # Format each byte as 2-character hex and join them
            # 'x' for lowercase hex, 'X' for uppercase
            hex_str = "".join(f"{b:02x}" for b in line_bytes)
            f.write(hex_str + "\n")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "memory_in.dat")
    generate_memory_in(output_path, num_lines=1024)
    print(f"Successfully generated {output_path}")
