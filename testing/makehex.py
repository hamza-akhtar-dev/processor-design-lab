import sys

binfile = sys.argv[1]

with open(binfile, "rb") as f:
    bindata = f.read()

nwords = len(bindata) // 4

for i in range(nwords):
    w = bindata[4*i : 4*i+4]
    print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]))
    