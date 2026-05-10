import numpy as np
iimage = [[(j +(16* i)) for j in range(256)] for i in range(256)]
iimage = np.asarray(iimage)
num_windows = ((256 - 16) // 14) + 1
col_index = 0
row_index = 16

# i need to pad input
for i in range(num_windows):
  print(iimage[:,col_index:row_index])
  col_index = col_index + 14
  row_index = row_index + 14

start_index = 0
end_index = 16

memory = []

for i in range(num_windows):

    sub_mat = iimage[:, start_index:end_index]

    submatrix_list = [sub_row for sub_row in sub_mat]

    memory = memory + submatrix_list

    start_index = start_index + 14
    end_index = end_index + 14

# Write to text file
with open("memory_in.dat", "w") as f:

    for word in memory:
        # Format each element as an 8-bit (2-character) hexadecimal, total 32 characters (128 bits) per line
        hex_str = "".join(f"{int(elem) & 0xFF:02x}" for elem in word)
        f.write(hex_str + "\n")