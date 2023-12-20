# this proved that 20bpp (due to bram constraints) is not an issue in the slightest
# 7 bits for red, 7 bits for green, 6 bits for blue

from PIL import Image

im = Image.open("granger.png")

oldData = []
newData = []

for color in im.getdata():
    red = color[0]
    green = color[1]
    blue = color[2]

    oldData.append((red, green, blue))

    red = (red//2) * 2
    green = (green//2) * 2
    blue = (blue//4) * 4

    newData.append((red, green, blue))

oldIm = Image.new(im.mode, im.size)
oldIm.putdata(oldData)

oldIm.show()



newIm = Image.new(im.mode, im.size)
newIm.putdata(newData)

newIm.show()
