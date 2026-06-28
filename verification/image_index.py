import numpy as np
rows = 258
coloumns = 268
iimage = [[(j +(16* i)) for j in range(coloumns)] for i in range(rows)]
iimage = np.asarray(iimage)
num_windows = ((coloumns - 16) // 14) + 1
start_index = 0
end_index = 16

# i need to pad input
for i in range(num_windows):
  print(iimage[:,start_index:end_index])
  start_index = start_index + 14
  end_index = end_index + 14

start_index = 0
end_index = 16

memory = []

for i in range(num_windows):

    sub_mat = iimage[:, start_index:end_index]
    
    # Count complete words (rows with exactly 16 columns)
    num_complete_words = sub_mat.shape[0] if sub_mat.shape[1] == 16 else 0
    print(f"Vertical slice {i}: {num_complete_words} complete words (16 col)")

    submatrix_list = [sub_row for sub_row in sub_mat]

    memory = memory + submatrix_list

    start_index = start_index + 14
    end_index = end_index + 14

# Write to text file
with open("golden_model/memory_in.dat", "w") as f:

    for word in memory:
        # Format each element as an 8-bit (2-character) hexadecimal, total 32 characters (128 bits) per line
        hex_str = "".join(f"{int(elem) & 0xFF:02x}" for elem in word)
        f.write(hex_str + "\n")