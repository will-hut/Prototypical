from PIL import Image

im = Image.open("testimg.png")

width, height = im.size

with open("image.mem", "w") as mem:
    for y in range(height//4):
        for x in range(width):
            r, g, b = im.getpixel((x, y))
            data = ((r >> 1) << 13) | ((g >> 1) << 6) | (b >> 2)
            mem.write(f"{data:x}\n")

            r, g, b = im.getpixel((x, y + (height//4)))
            data = ((r >> 1) << 13) | ((g >> 1) << 6) | (b >> 2)
            mem.write(f"{data:x}\n")

            r, g, b = im.getpixel((x, y + (height//4 * 2)))
            data = ((r >> 1) << 13) | ((g >> 1) << 6) | (b >> 2)
            mem.write(f"{data:x}\n")

            r, g, b = im.getpixel((x, y + (height//4 * 3)))
            data = ((r >> 1) << 13) | ((g >> 1) << 6) | (b >> 2)
            mem.write(f"{data:x}\n")

            

