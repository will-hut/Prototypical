# was this a waste of time? maybe.


def genTable(sig_name, bit_in, bit_out, gamma):
    print()
    print(f"always @({sig_name}_in) begin")
    print(f"\tcase ({sig_name}_in)")

    max_in = 2**bit_in -1
    max_out = 2**bit_out -1


    for i in range(2**bit_in):
        val = int(pow((i/max_in), gamma) * max_out + 0.5)
        print(f"\t\t{bit_in}'d{i}:\t{sig_name}_out = {bit_out}'d{val};")

    print(f"\tendcase")
    print(f"end")
    print()


red_name = "red"
green_name = "green"
blue_name = "blue"

red_bit_in = 7
green_bit_in = 7
blue_bit_in = 6

red_bit_out = 8
green_bit_out = 8
blue_bit_out = 8

gamma = 2.8

print(f"module gamma_correction(")
print(f"\tinput [{red_bit_in-1}:0] {red_name}_in,")
print(f"\tinput [{green_bit_in-1}:0] {green_name}_in,")
print(f"\tinput [{blue_bit_in-1}:0] {blue_name}_in,")

print(f"\toutput reg [{red_bit_out-1}:0] {red_name}_out,")
print(f"\toutput reg [{green_bit_out-1}:0] {green_name}_out,")
print(f"\toutput reg [{blue_bit_out-1}:0] {blue_name}_out")
print(f");")

genTable(red_name, red_bit_in, red_bit_out, gamma)
genTable(green_name, green_bit_in, green_bit_out, gamma)
genTable(blue_name, blue_bit_in, blue_bit_out, gamma)

print(f"endmodule")