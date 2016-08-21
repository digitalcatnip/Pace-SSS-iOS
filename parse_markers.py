import re

f = open('markers.txt', 'r')
count = 1

for line in f:
    m = re.search('.position\(PaceUni(?P<position>.*)\).title\("(?P<title>.*)"\).[s|i].*nippet\(\"(?P<snippet>.*)\"\)', line)
    m2 = re.search('.BitmapDescriptorFactory.fromResource\(R.drawable.(?P<icon>[a-zA-z]*)\)', line)
    print("{0}|{1}|{2}|{3}".format(m.group('position'), m.group('title'), m.group('snippet'), m2.group('icon')))
