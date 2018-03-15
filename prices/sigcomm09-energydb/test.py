import energydb
energydb.open_all()

node_id = "ca.np15"

print energydb.get_lat_lon(node_id)[0]
print energydb.get_lat_lon(node_id)[1]

print round(energydb.get_lat_lon(node_id)[0],2)
print round(energydb.get_lat_lon(node_id)[1],2)