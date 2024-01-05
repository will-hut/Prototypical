from PIL import Image

im = Image.open("testimg.bmp")

width, height = im.size

print(f"Width: {width}\t Height: {height}")

with open("image.mem", "w") as mem:
    for y in range(height):
        for x in range(width):
            r, g, b = im.getpixel((x, y))
            data = ((r >> 1) << 13) | ((g >> 1) << 6) | (b >> 2)
            mem.write(f"{data:x}\n")

            

