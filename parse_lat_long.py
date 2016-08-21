import os

f = open('lat_long.txt', 'r')
count = 1
cur_lat = ''

for line in f:
    split = line.split()
    names = split[3].split('_')
    label = "{0}_{1}".format(names[1], names[2])
    if len(names) > 4:
        label = "{0}_{1}_{2}".format(names[1], names[2], names[3])
    if count % 2 == 0:
        print("{0}|{1}|{2}".format(cur_lat, split[5][:-1], label))
    else:
        cur_lat = split[5][:-1]
    count = count + 1
