import shelve
import bisect
import time
import datetime
import sys

def bench(fn, *args):
    t = time.time()
    r = fn(*args)
    t = time.time() - t
    print "%d ms" % int(t * 1000)
    return r

def create_energy_db(filename, rows, nodes):
    """rows is a list of [timestamp, price_0, price_1, ...]
       nodes is a list of [node_id_0, node_id_1, ...]"""    
    shelf = shelve.open(filename, flag='n', protocol=2)

    n = len(nodes)
    nodes = [x.lower() for x in nodes]

    for row in rows:
        ts = row[0]
        prices = []
        for x in row[1:]:
            try:
                prices.append(float(x))
            except ValueError:
                prices.append(None)
        if len(prices) < n: prices.extend([None] * (n - len(prices)))
        elif len(prices) > n:  print "warning: too many columns in row: ", row            
        shelf[ts] = prices

    timeline = shelf.keys()
    timeline.sort()

    meta = {'node_keys':nodes,
            'timeline':timeline}
    
    shelf['.metadata'] = meta

    shelf.sync()
    shelf.close()

class energydb:
    def __init__(self, filename, node_id_prefix=None):
        self._shelf = shelve.open(filename, flag='r', protocol=2)
        meta = self._shelf['.metadata']
        
        self._node_keys = meta['node_keys']        
        self._timeline = meta['timeline']
        self._time_max = int(self._timeline[-1])
        self._time_min = int(self._timeline[0])

        self.filename = filename
        self._node_id_prefix = node_id_prefix

    def close(self):
        self.shelf.close()

    def get_time_max(self): return self._time_max
    def get_time_min(self): return self._time_min
    def get_timeline(self): return [int(x) for x in self._timeline]
    def get_nodes(self):
        if self._node_id_prefix:
            return set([(self._node_id_prefix + k) for k in self._node_keys])
        else:
            return set(self._node_keys)

    def _real_node_id(self, node_id):
        node_id = node_id.lower()
        if self._node_id_prefix and node_id.startswith(self._node_id_prefix):
            node_id = node_id[len(self._node_id_prefix):]
        return node_id

    def contains_node(self, node_id):
        return self._real_node_id(node_id) in self._node_keys

    def lookup_price(self, utc_time, node_id, inexact=True):
        node_id = self._real_node_id(node_id)
        if node_id in self._node_keys:
            idx = self._node_keys.index(node_id)

            # try exact lookup first...
            if str(utc_time) in self._shelf and self._shelf[str(utc_time)][idx] != None:
                return self._shelf[str(utc_time)][idx]

            if not inexact: return None

            # look for last price value, or if no last one exists, next one.
            pivot = bisect.bisect(self._timeline, str(utc_time))
            # search backward from pivot for first valid price for node_id
            i = pivot - 1
            while i > 0:
                t = self._timeline[i]
#                print "-",t
                if self._shelf[t][idx] != None:
                    return self._shelf[t][idx]
                i -= 1
                
            i = pivot
            while i < len(self._timeline):
                t = self._timeline[i]
#                print "+",t
                if self._shelf[t][idx] != None:
                    return self._shelf[t][idx]
                i += 1              
                
##            t = utc_time
##            while t >= self.time_min + 10: 
##                t -= 10
##                if str(t) in self.shelf:
##                    if self.shelf[str(t)][idx] != None:
##                        return self.shelf[str(t)][idx] # found it, return it.                
##
##            # if backward search failed, step forward, until we find a valid price
##            t = utc_time
##            while t <= self.time_max - 10:
##                t += 10
##                if str(t) in self.shelf:
##                    if self.shelf[str(t)][idx] != None:
##                        return self.shelf[str(t)][idx] # found it, return it.                                
            
        return None # no price available

def test_create_db():
    rows = [ ['1167631200', '51.75', '51.75', '51.75', '51.75'],
             ['1167634800', '44.34', '44.34', '44.34'],
             ['1167638400', '47.22', '47.22', '47.22'],
             ['1167642000', '43.47', '43.47', '43.47', '43.47'],
             ['1167645600', '51.72', '51.72', '51.72', 'none'],
             ['1167649200', '50.83', '50.83', '50.83', '50.83'],
             ['1167652800', '35.59', '35.59', '35.59'],
             ['1167656400', '36.52', '36.52', '36.52'],
             ['1167660000', '35.54', '35.54', '35.54', 'none']]
    nodes = ['houston', 'north', 'south', 'west']

    create_energy_db('test', rows, nodes)

def parse_tab_file(filename, node_keys, node_col_idx=None):
    """node_keys is a list of strings giving node identifiers.
       node_col_idx gives the column index in filename for each key in node_keys.
       if node_col_idx is omitted, this guesses, using the order from node_keys"""
    if node_col_idx==None: node_col_idx = range(1, len(node_keys)+1)

    e = 0                                                
    i = 0
    rows = []
    for line in open(filename):
        try:
            cols = line.split("\t")
            ts = int(cols[0])

            row = [cols[0].strip()]
            for idx in node_col_idx:
                v = float(cols[idx])
                row.append(cols[idx].strip())
            rows.append(row)
        except (ValueError, IndexError):
            sys.stderr.write("ignoring line %s:%d\n" % (filename, i+1))
            e += 1
        i += 1
    if e: sys.stderr.write("%d errors ignored\n" % e)
    return rows

def _proto_create_db(node_keys, base_dir, out_file):
    r2006 = parse_tab_file(base_dir + '/edb2006', node_keys)
    r2007 = parse_tab_file(base_dir + '/edb2007', node_keys)
    r2008 = parse_tab_file(base_dir + '/edb2008', node_keys)
    r2009 = parse_tab_file(base_dir + '/edb2009', node_keys)

    rows = r2006
    rows.extend(r2007)
    rows.extend(r2008)
    rows.extend(r2009)

    create_energy_db(out_file, rows, node_keys)
    
    
def create_db_texas():
    node_keys = ['houston', 'north', 'south', 'west']
    base_dir = '../edata/ercot/'
    out_file = 'energydb/texas.energydb'

    r2006 = parse_tab_file(base_dir + '/edb2006', node_keys, [2, 3, 4, 5])
    r2007 = parse_tab_file(base_dir + '/edb2007', node_keys)
    r2008 = parse_tab_file(base_dir + '/edb2008', node_keys)
    r2009 = parse_tab_file(base_dir + '/edb2009', node_keys)

    rows = r2006
    rows.extend(r2007)
    rows.extend(r2008)
    rows.extend(r2009)

    create_energy_db(out_file, rows, node_keys)

def create_db_isone():
    node_keys = ['bos', 'mn', 'nh', 'vt']
    base_dir = '../edata/isone/'
    out_file = 'energydb/isone.energydb'
    _proto_create_db(node_keys, base_dir, out_file)

def create_db_pjm():
    node_keys = ['aep', 'chi', 'dom', 'east', 'n_il', 'nj', 'ohio', 'west']
    base_dir = '../edata/pjm2/'
    out_file = 'energydb/pjm.energydb'
    _proto_create_db(node_keys, base_dir, out_file)

def create_db_miso():
    node_keys = ['cin', 'fe', 'il', 'mich', 'minn']
    base_dir = '../edata/miso/rt_lmp/'
    out_file = 'energydb/miso.energydb'
    _proto_create_db(node_keys, base_dir, out_file)

def create_db_nyiso():
    node_keys = ['nyc', 'west', 'north', 'capitl', 'pjm']
    base_dir = '../edata/nyiso/'
    out_file = 'energydb/nyiso.energydb'
    _proto_create_db(node_keys, base_dir, out_file)

def create_db_caiso():
    node_keys = ['sp15', 'np15', 'zp26']
    base_dir = '../edata/caiso/'
    out_file = 'energydb/caiso.energydb'
    _proto_create_db(node_keys, base_dir, out_file)

def create_db_all():
    create_db_texas()
    create_db_pjm()
    create_db_nyiso()
    create_db_caiso()
    create_db_isone()
    create_db_miso()

#test_create_db()
#edb = energydb('test')

open_db_list = []
def open_db(filename, node_id_prefix=None):
    edb = energydb(filename, node_id_prefix)
    open_db_list.append(edb)

def close_db(filename):
    for i in range(len(open_db_list)):
        if open_db_list[i].filename == filename:
            open_db_list[i].close()
            del open_db_list[i]
            break

def lookup_price(utc_time, node_id, inexact=True):
    if type(utc_time) is datetime.datetime:
        utc_time = time.mktime(utc_time.timetuple())
        
    for db in open_db_list:
        if db.contains_node(node_id):
            p = db.lookup_price(utc_time, node_id, inexact)
            if p != None: return p
    return None

def get_time_max(node_id):
    for db in open_db_list:
        if db.contains_node(node_id):
            return db.get_time_max()

def get_time_min(node_id):
    for db in open_db_list:
        if db.contains_node(node_id):
            return db.get_time_min()

def get_timeline(node_id):
    for db in open_db_list:
        if db.contains_node(node_id):
            return db.get_timeline()

def open_all():
    open_db("energydb/caiso.energydb", "ca.")
    open_db("energydb/isone.energydb", "ne.")
    open_db("energydb/nyiso.energydb", "ny.")
    open_db("energydb/pjm.energydb", "pjm.")
    open_db("energydb/miso.energydb", "miso.")
    open_db("energydb/texas.energydb", "tx.")

def get_nodes():
    nodes = set()
    for edb in open_db_list:
        nodes.update(edb.get_nodes())
    nodes = list(nodes)
    nodes.sort()
    return nodes
    
#timestamp = datetime.datetime.strptime("2008/12/01 12:00", "%Y/%m/%d %H:%M")
#lookup_price(time.mktime(timestamp.timetuple()), 'nyc')

# Tan N. Le Stony Brook University

def get_lat_lon(node_id):
    LATLON_HUB = {"ca.np15":(37.342163,-121.905216), # San jose CA
              "ca.sp15":(33.973514,-118.245171), # Los Angeles, CA 90001
              "ca.zp26":(34.918187,-120.232206), # Santa Barbara county, CA
              "ne.bos":(42.35892, -71.05781), # Boston, MA
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
    
    return LATLON_HUB.get(node_id)