import math
# import numpy as np
#import energydb

LATLON_HUB = {"ca.np15":(37.342163,-121.905216), # California
              "ca.sp15":(33.973514,-118.245171),
              "ca.zp26":(34.918187,-120.232206),
              
              "ne.bos":(42.35892, -71.05781), # New England
              "ne.mn":(43.65467,-70.262434),
              "ne.nh":(43.231366,-71.559716),              
              "ne.vt":(44.262739,-72.571606),
              
              "ny.capitl":(42.651725,-73.755093),
              "ny.north":(44.541417,-73.624878),
              "ny.nyc":(40.751668, -73.997191),
              "ny.pjm":(40.519924,-74.415894),
              "ny.west":(42.892657,-78.888357),
              
              "pjm.aep":(39.94119,-83.309326),  # columbus, oh
              "pjm.chi":(41.851014,-87.626953), # chicago, il
              "pjm.dom":(37.559675,-77.4646),   # richmond, va
              "pjm.east":(39.101789,-75.61615),
              "pjm.n_il": (41.766942,-89.121094),
              "pjm.nj":(40.542469,-74.399414),
              "pjm.ohio":(39.658289,-82.007446),
              "pjm.west": (40.519785,-82.142029),

              'miso.cin':(39.226651,-85.411835),
              'miso.fe':(41.454804,-81.694336),
              'miso.il':(40.626183,-89.560547),
              'miso.mich':(42.98429,-85.627441),
              'miso.minn':(44.962725,-93.164062),
              
              "tx.houston":(29.759956,-95.362534),
              "tx.north":(33.095837,-96.712646),
              "tx.south":(29.663871,-98.382568),
              "tx.west":(32.021739,-101.810303)
              }

def closest_location(node, nodes):
	nodes = np.asarray(nodes)
	dist = np.sum((nodes - node)**2, axis=1)
	result = np.argmin(dist) 
	return nodes[result]

#organize LATLON_HUB 
location = (2,-101)
a = []
keys =[]
for x in LATLON_HUB:
	i = LATLON_HUB[x]
	a.append((i[0],i[1]))
	keys.append(i)
print closest_location(location, a)

#  find key
for y in LATLON_HUB:
       k = list(LATLON_HUB.keys())
       location_key = LATLON_HUB[y]
       if closest_location(location, a)[0] == location_key[0] and closest_location(location, a)[1] == location_key[1]:
		print y