#!/bin/sh

. "${TEST_SCRIPTS_DIR}/unit.sh"

define_test "set persistent read-only by name"

setup_ctdbd <<EOF
NODEMAP
0       192.168.20.41   0x0     CURRENT RECMASTER
1       192.168.20.42   0x0
2       192.168.20.43   0x0

DBMAP
0x7a19d84d locking.tdb
0x4e66c2b2 brlock.tdb
0x4d2a432b g_lock.tdb
0x7132c184 secrets.tdb PERSISTENT
0x6cf2837d registry.tdb PERSISTENT 42
EOF

result_filter ()
{
	sed -e 's|^[^:]*:[0-9][0-9]* |FILE:LINE |'
}

required_result 1 <<EOF
ctdb_control error: 'Can not set READONLY on persistent db'
FILE:LINE ctdb_ctrl_set_db_readonly_recv failed  ret:22 res:-1
Unable to set db to support readonly
EOF
simple_test secrets.tdb

ok <<EOF
Number of databases:5
dbid:0x7a19d84d name:locking.tdb path:/var/run/ctdb/DB_DIR/locking.tdb.0
dbid:0x4e66c2b2 name:brlock.tdb path:/var/run/ctdb/DB_DIR/brlock.tdb.0
dbid:0x4d2a432b name:g_lock.tdb path:/var/run/ctdb/DB_DIR/g_lock.tdb.0
dbid:0x7132c184 name:secrets.tdb path:/var/lib/ctdb/persistent/secrets.tdb.0 PERSISTENT
dbid:0x6cf2837d name:registry.tdb path:/var/lib/ctdb/persistent/registry.tdb.0 PERSISTENT
EOF

simple_test_other getdbmap