import os

f = open('lat_long.csv', 'r')
count = 1
data = {}


def parse_lat_long(line):
    values = line.split('|')
    key = values[2].strip()
    data[key] = {"lat": values[0], "long": values[1], "label": key}


def parse_markers(line):
    values = line.split('|')
    if values[0] in data:
        d = data[values[0]]
        d["title"] = values[1]
        d["description"] = values[2].strip()
        d["icon"] = values[3].strip()
        data[values[0]] = d

for line in f:
    if line[0] == "-":
        parse_lat_long(line)
    else:
        parse_markers(line)
keys = sorted(data)
for key in keys:
    d = data[key]
    if "title" in d:
        print("{0}|{1}|{2}|{3}|{4}|{5}".format(key, d["lat"], d["long"], d["title"], d["description"], d["icon"]))
    else:
        print("{0}|{1}|{2}".format(key, d["lat"], d["long"]))
