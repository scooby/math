""" Test how evenly distributed a base is over many values.

Pushing them into bins, a simple linear regression finds no
bias. Should probably do a chi^2 test.
"""

base = 1627
top = 1 << 32

bins = 1024
vals = [0 for _ in range(0, bins)]

num = 655360
for p in range(num):
    vals[pow(base, p, top) >> 22] += 1

count = sum(vals)
assert count == num
avg = count / bins

for i, c in enumerate(vals):
    print("%d\t%d\t%d" % (i, c - avg, c))
