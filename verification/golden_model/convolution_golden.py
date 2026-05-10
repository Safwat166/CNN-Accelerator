"""
Convolution Golden Model - Interactive
======================================
Enter filter size, then for each subfilter enter:
  - Register A, B, C, D (hex)
  - Subfilter weights (hex)

The model accumulates across subfilters and outputs the 728-bit hex result.
"""
import numpy as np


def parse_register(hex_str):
    s = hex_str.strip().zfill(32)
    return [int(s[j:j+2], 16) for j in range(0, 32, 2)]


def parse_filter(hex_str):
    s = hex_str.strip().zfill(18)
    bytes_list = [int(s[j:j+2], 16) for j in range(16, -2, -2)]
    return np.array(bytes_list, dtype=object).reshape(3, 3)


def conv_2x14(rows, filt):
    w = np.array(rows, dtype=object)
    f = np.array(filt, dtype=object)
    result = np.zeros((2, 14), dtype=object)
    for r in range(2):
        for c in range(14):
            result[r, c] = int(np.sum(w[r:r+3, c:c+3] * f))
    return result


def pack_784bit(result):
    packed = 0
    ordered_vals = []
    # RTL pe_out has Row 1 at MSB (bits 783:392) and Row 0 at LSB (bits 391:0).
    # Within each row, pixel 0 is at MSB and pixel 13 is at LSB.
    for r in (1, 0):
        for c in range(14):
            ordered_vals.append(result[r, c])
            
    # Each value is 28 bits
    for val in ordered_vals:
        packed = (packed << 28) | (int(val) & 0xFFFFFFF)
        
    # Split into 8 chunks to match pe_stream_buffer.v (output_memory.dat format)
    lines = []
    lines.append( (packed & ((1<<128)-1)) )
    lines.append( ((packed >> 128) & ((1<<128)-1)) )
    lines.append( ((packed >> 256) & ((1<<128)-1)) )
    lines.append( ((packed >> 384) & ((1<<8)-1)) )
    lines.append( ((packed >> 392) & ((1<<128)-1)) )
    lines.append( ((packed >> 520) & ((1<<128)-1)) )
    lines.append( ((packed >> 648) & ((1<<128)-1)) )
    lines.append( ((packed >> 776) & ((1<<8)-1)) )
    
    stream_out = "\n".join(hex(l)[2:].zfill(32) for l in lines)
    raw_784 = hex(packed)[2:].zfill(196)
    
    return stream_out, raw_784


def compare_outputs():
    try:
        with open("golden_model/pe_out.dat", "r") as f1, open("golden_model/output_golden_raw.dat", "r") as f2:
            pe_out_lines = [l.strip() for l in f1.readlines() if l.strip()]
            golden_lines = [l.strip() for l in f2.readlines() if l.strip()]

        if len(pe_out_lines) != len(golden_lines):
            print(f"Failed: Line count mismatch (pe_out.dat has {len(pe_out_lines)}, output_golden_raw.dat has {len(golden_lines)})")
            return

        all_passed = True
        for i, (out_val, gold_val) in enumerate(zip(pe_out_lines, golden_lines)):
            print(f"--- Window {i+1} ---")
            if out_val == gold_val:
                print("passed")
            else:
                print("failed")
                all_passed = False
                
            print(f"golden value:\n{gold_val}")
            print(f"output value:\n{out_val}")
            
            if not all_passed:
                print("Stopping comparison on first failure.")
                break
                
        if all_passed:
            print("\nAll windows matched successfully!")
            
    except FileNotFoundError as e:
        print(f"\nComparison skipped: {e}")

def main():
    try:
        with open("golden_model/filter_size.dat", "r") as f:
            K = int(f.read().strip(), 16)
    except FileNotFoundError:
        print("filter_size.dat not found, defaulting to 3")
        K = 3

    num_sub = (K // 3) ** 2
    print(f"Filter {K}x{K} -> {num_sub} subfilter(s)")

    try:
        with open("golden_model/filter_in.dat", "r") as f:
            filters = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print("Error: filter_in.dat not found.")
        return

    if len(filters) < num_sub:
        print(f"Error: filter_in.dat has only {len(filters)} lines, need {num_sub}.")
        return

    parsed_filters = [parse_filter(f) for f in filters[:num_sub]]

    try:
        with open("golden_model/windows.dat", "r") as f:
            windows = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print("Error: windows.dat not found.")
        return

    if len(windows) % 4 != 0:
        print(f"Warning: windows.dat lines ({len(windows)}) not a multiple of 4")

    parsed_windows = []
    for i in range(0, len(windows), 4):
        if i + 3 < len(windows):
            parsed_windows.append([
                parse_register(windows[i]),
                parse_register(windows[i+1]),
                parse_register(windows[i+2]),
                parse_register(windows[i+3])
            ])

    print(f"Total complete windows found: {len(parsed_windows)}")

    with open("golden_model/output_golden.dat", "w") as out_file, open("golden_model/output_golden_raw.dat", "w") as raw_file:
        for i in range(0, len(parsed_windows), num_sub):
            if i + num_sub > len(parsed_windows):
                print(f"Skipping trailing {len(parsed_windows) - i} windows (not a full group of {num_sub})")
                break
            
            accum = np.zeros((2, 14), dtype=object)
            
            for s in range(num_sub):
                rA, rB, rC, rD = parsed_windows[i + s]
                f3 = parsed_filters[s]
                
                partial = conv_2x14([rA, rB, rC, rD], f3)
                accum += partial
                
            stream_out, raw_out = pack_784bit(accum)
            out_file.write(stream_out + "\n")
            raw_file.write(raw_out + "\n")

    print("Successfully generated output_golden.dat and output_golden_raw.dat")
    
    # Run the comparison
    compare_outputs()

if __name__ == "__main__":
    main()