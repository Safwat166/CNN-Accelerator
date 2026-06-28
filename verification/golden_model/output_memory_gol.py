cnt = 0

with open("golden_model/output_golden.dat", "r") as f:
    golden_lines = f.readlines()

with open("golden_model/output_memory.dat", "r") as f:
    tb_lines = f.readlines()

total_golden_lines = len(golden_lines)

for golden_line, tb_line in zip(golden_lines, tb_lines):
    golden_line = golden_line.strip()
    tb_line = tb_line.strip()

    if golden_line == tb_line:
        cnt += 1
    else:
        print(f"{golden_line} --> {tb_line} : Failed")

print(f"number of locations stored correctly: {cnt}/{total_golden_lines}")
