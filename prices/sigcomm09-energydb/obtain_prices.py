import energydb
import datetime
#from datetime import datetime

ONE_HOUR = 3600

energydb.open_all()

# node_id = "ca.np15"

# node_id = "ca.sp15"
# node_id = "ca.zp26"

# node_id = "ne.bos"
# node_id = "ne.mn"
# node_id = "ne.nh"
# node_id = "ne.vt"

# node_id = "ny.nyc"
# node_id = "ny.capitl"
# node_id = "ny.north"
# node_id = "ny.nyc"
# node_id = "ny.pjm"
# node_id = "ny.west"

# node_id = "pjm.aep"
# node_id = "pjm.chi"

# node_id = "pjm.dom"
# node_id = "pjm.east"
# node_id = "pjm.n_il"

# node_id = "pjm.nj"
# node_id = "pjm.ohio"

# node_id = "miso.cin"
# node_id = "miso.minn"
# node_id = "miso.cin"
# node_id = "miso.cin"
# node_id = "miso.cin"
# node_id = "miso.cin"

# node_id = "tx.houston"
# node_id = "tx.north"
# node_id = "tx.south"
node_id = "tx.west"
              




time_min = energydb.get_time_min(node_id)
#print HOUR
#print datetime.datetime.fromtimestamp(time_min+ONE_HOUR).strftime('%Y-%m-%d %H:%M:%S')
#rint energydb.lookup_price(energydb.get_time_min(node_id)+ONE_HOUR, node_id)

duration =  365*24 # hours
time_start = energydb.get_time_min(node_id)
time_end = energydb.get_time_max(node_id)

lat = round(energydb.get_lat_lon(node_id)[0],2)
lon = round(energydb.get_lat_lon(node_id)[1],2)

current_time = time_start;
path = "C:/Users/NhatTan/Google Drive/shared/prices/sigcomm09-energydb/data/"
out = open(path+"price_"+"{:07.2f}".format(lat)+"_"+"{:07.2f}".format(lon)+"_"+node_id+'.csv', 'w')
#out = open('out.csv', 'w')
while (current_time <= time_end):
    current_time = current_time+ONE_HOUR
    out.write(datetime.datetime.fromtimestamp(current_time).strftime('%Y-%m-%d %H:%M:%S')+",");        
    out.write(str(energydb.lookup_price(current_time, node_id))+',');   
    out.write('\n')    
out.close()