from PIL import Image
im=Image.open("spinner5.bmp")
pix=im.load()
string='''spinner:
db '''
print im.width, im.height
for y in range(0,im.height):
    for x in range(0,im.width,2):
        print x, y, string[-5:]
        string+="0x"+hex(pix[x+1,y])[2:]+hex(pix[x,y])[2:]+", "
f=open("spinner.asm","w")
f.write(string[:-2])
f.close()
