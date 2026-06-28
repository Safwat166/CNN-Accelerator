import sys
import os

# Output file is always placed in the same directory as this script (golden_model/)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PATH = os.path.join(SCRIPT_DIR, "addresses.dat")

def write_addresses_fs3(ifm_width, ifm_height, out_file, max_address):
    """
    Generates addresses for filter size 3.
    Reads 1 row at a time, moving in steps of 2 columns (reading 4 elements per window).
    Each address in the chunk is written on its own line.
    """
    print(f"--- Generating addresses for filter size 3 (IFM {ifm_width}x{ifm_height}) ---")
    for row in range(ifm_height):
        base_addr = row * ifm_width
        start_col = 0
        while start_col + 3 < ifm_width:
            # Pre-check: ensure all addresses in this window are valid
            if base_addr + start_col + 3 > max_address:
                return

            # Write each address in the 4-element window individually
            for i in range(4):
                print(base_addr + start_col + i, file=out_file)

            # Step by 2: next window starts at last_pos - 1
            start_col += 2

def write_addresses_fs6(ifm_width, ifm_height, out_file, max_address):
    """
    Generates addresses for filter size 6.
    Reads 2 rows at a time (window row + reuse row), moving in steps of 4 columns.
    Each address is written on its own line: window addresses first, then reuse addresses.
    """
    print(f"--- Generating addresses for filter size 6 (IFM {ifm_width}x{ifm_height}) ---")
    for row in range(ifm_height - 1):
        base_addr_1 = row * ifm_width          # window row
        base_addr_2 = (row + 1) * ifm_width    # reuse row

        start_col = 0
        while start_col + 6 < ifm_width:
            # Pre-check: ensure all addresses in this window position are valid
            if base_addr_2 + start_col + 7 > max_address:
                return

            # --- First chunk of 4 ---
            # Write window row addresses
            for i in range(4):
                print(base_addr_1 + start_col + i, file=out_file)
            # Write reuse row addresses
            for i in range(4):
                print(base_addr_2 + start_col + i, file=out_file)

            # --- Second chunk of 4 ---
            # Write window row addresses
            for i in range(4):
                print(base_addr_1 + start_col + 4 + i, file=out_file)
            # Write reuse row addresses
            for i in range(4):
                print(base_addr_2 + start_col + 4 + i, file=out_file)

            # Step by 2: next sliding window starts 2 columns over
            start_col += 2

def write_addresses_fs9(ifm_width, ifm_height, out_file, max_address):
    """
    Generates addresses for filter size 9.
    The 9x9 filter is decomposed into 9 sub-filters (3x3 arrangement):
        a b c
        d e f
        g h i
    Reads 3 rows at a time, 3 chunks of 4 elements per row-group.
    Each address is written on its own line.
    """
    print(f"--- Generating addresses for filter size 9 (IFM {ifm_width}x{ifm_height}) ---")
    for row in range(ifm_height - 2):
        base_addr_1 = row * ifm_width
        base_addr_2 = (row + 1) * ifm_width
        base_addr_3 = (row + 2) * ifm_width

        start_col = 0
        while start_col + 9 < ifm_width:
            # Pre-check: ensure all addresses in this window position are valid
            if base_addr_3 + start_col + 11 > max_address:
                return

            # --- First chunk of 4 (sub-filters a, d, g) ---
            for i in range(4):
                print(base_addr_1 + start_col + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + i, file=out_file)

            # --- Second chunk of 4 (sub-filters b, e, h) ---
            for i in range(4):
                print(base_addr_1 + start_col + 4 + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + 4 + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + 4 + i, file=out_file)

            # --- Third chunk of 4 (sub-filters c, f, i) ---
            for i in range(4):
                print(base_addr_1 + start_col + 8 + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + 8 + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + 8 + i, file=out_file)

            # Step by 2: next sliding window starts 2 columns over
            start_col += 2

def write_addresses_fs12(ifm_width, ifm_height, out_file, max_address):
    """
    Generates addresses for filter size 12.
    The 12x12 filter is decomposed into 16 sub-filters (4x4 arrangement):
        a  b  c  d
        e  f  g  h
        i  j  k  l
        m  n  o  p
    Reads 4 rows at a time, 4 chunks of 4 elements per row-group.
    Each address is written on its own line.
    """
    print(f"--- Generating addresses for filter size 12 (IFM {ifm_width}x{ifm_height}) ---")
    for row in range(ifm_height - 3):
        base_addr_1 = row * ifm_width
        base_addr_2 = (row + 1) * ifm_width
        base_addr_3 = (row + 2) * ifm_width
        base_addr_4 = (row + 3) * ifm_width

        start_col = 0
        while start_col + 12 < ifm_width:
            # Pre-check: ensure all addresses in this window position are valid
            if base_addr_4 + start_col + 15 > max_address:
                return

            # --- First chunk of 4 (sub-filters a, e, i, m) ---
            for i in range(4):
                print(base_addr_1 + start_col + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + i, file=out_file)
            for i in range(4):
                print(base_addr_4 + start_col + i, file=out_file)

            # --- Second chunk of 4 (sub-filters b, f, j, n) ---
            for i in range(4):
                print(base_addr_1 + start_col + 4 + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + 4 + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + 4 + i, file=out_file)
            for i in range(4):
                print(base_addr_4 + start_col + 4 + i, file=out_file)

            # --- Third chunk of 4 (sub-filters c, g, k, o) ---
            for i in range(4):
                print(base_addr_1 + start_col + 8 + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + 8 + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + 8 + i, file=out_file)
            for i in range(4):
                print(base_addr_4 + start_col + 8 + i, file=out_file)

            # --- Fourth chunk of 4 (sub-filters d, h, l, p) ---
            for i in range(4):
                print(base_addr_1 + start_col + 12 + i, file=out_file)
            for i in range(4):
                print(base_addr_2 + start_col + 12 + i, file=out_file)
            for i in range(4):
                print(base_addr_3 + start_col + 12 + i, file=out_file)
            for i in range(4):
                print(base_addr_4 + start_col + 12 + i, file=out_file)

            # Step by 2: next sliding window starts 2 columns over
            start_col += 2

def main():
    print("========================================")
    print("   CNN Accelerator Address Generation   ")
    print("========================================")

    try:
        filter_size = int(input("Enter filter size (3, 6, 9, or 12): "))
        ifm_width   = int(input("Enter IFM width  (e.g., 256): "))
        ifm_height  = int(input("Enter IFM height (e.g., 256): "))
        max_address = int(input("Enter max address (e.g., 4607): "))
    except ValueError:
        print("Invalid input! Exiting...")
        sys.exit(1)

    print("")  # spacing

    with open(OUTPUT_PATH, "w") as f:
        if filter_size == 3:
            write_addresses_fs3(ifm_width, ifm_height, f, max_address)
        elif filter_size == 6:
            write_addresses_fs6(ifm_width, ifm_height, f, max_address)
        elif filter_size == 9:
            write_addresses_fs9(ifm_width, ifm_height, f, max_address)
        elif filter_size == 12:
            write_addresses_fs12(ifm_width, ifm_height, f, max_address)
        else:
            print(f"Filter size {filter_size} is not supported. Please use 3, 6, 9, or 12.")
            sys.exit(1)

    print(f"Addresses successfully written to:\n  {OUTPUT_PATH}")

if __name__ == "__main__":
    main()
