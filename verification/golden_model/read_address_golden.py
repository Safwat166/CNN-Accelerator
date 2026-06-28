cnt = 0

golden_address = open("golden_model/addresses.dat", "r")
address = open("golden_model/read_address_input.dat", "r")

for golden_line, address_line in zip(golden_address, address):
    golden_line = golden_line.strip()
    address_line = address_line.strip()

    if golden_line == address_line:
        cnt += 1
    else:
        print(f"{golden_line} --> {address_line} : Failed")

golden_address.close()
address.close()

print(f"number of Generation address passed: {cnt}")
