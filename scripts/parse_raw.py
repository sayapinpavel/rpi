
from glob import glob

FILE_NUM = 1000
IMG_WIDTH = 640
IMG_HEIGHT = 512

pathToRaw = './files/'

files = glob(pathToRaw + '*.raw')
frame = 0

#Generate pattern
zeroPattern = bytearray(IMG_WIDTH)
dataPattern = bytearray()
data = 0;

for k in range((int) (IMG_WIDTH/2)):
    dataPattern.append((k % 256))
    dataPattern.append(((k + 1) % 256))

for i in range(FILE_NUM):
    file = f'./files/o_{i:05d}'

    rawFile = open(file, "rb")
    rawData = bytearray(rawFile.read(IMG_WIDTH * IMG_HEIGHT))

    frameError = 0
    for line in range(IMG_HEIGHT):
        rawLine = rawData[(IMG_WIDTH * line):(IMG_WIDTH * line + IMG_WIDTH)]

        if(line == (frame % IMG_HEIGHT)):
            if(rawLine != zeroPattern):
                print(f'File {file}: Zero line error for frame #{frame + 1} and line #{line}')
                print(rawLine.hex())
                print(zeroPattern.hex())
                frameError = 1
                break
        else:
            for k in range(IMG_WIDTH):
                if(rawLine[k] != dataPattern[k]):
                    print(f'File {file}: Pattern error for frame #{frame + 1}, sample #{k}, line #{line}')
                    print(f'Data = {rawLine[k]}')
                    print(f'Pattern = {dataPattern[k]}')
                    frameError = 1
                    break

    if(frameError):
        frameError = 0
        print(f'Processing file: {file} ERROR')
    else:
        print(f'Processing file: {file} SUCCEESS')

    frame = frame + 1
