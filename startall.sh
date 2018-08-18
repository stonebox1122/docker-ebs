
########### SIGINT handler ############
function _int() {
   echo "Stopping container."
   echo "SIGINT received, shutting down database!"
   /u01/install/APPS/scripts/stopapps.sh
   /u01/install/APPS/scripts/stopdb.sh
}

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down database!"
   /u01/install/APPS/scripts/stopapps.sh
   /u01/install/APPS/scripts/stopdb.sh
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down database!"
/u01/install/APPS/12.1.0/appsutil/scripts/EBSDB_apps/addbctl.sh stop abort
EOF
}



# Check whether container has enough memory
# Github issue #219: Prevent integer overflow,
# only check if memory digits are less than 11 (single GB range and below) 
if [ `cat /sys/fs/cgroup/memory/memory.limit_in_bytes | wc -c` -lt 11 ]; then
   if [ `cat /sys/fs/cgroup/memory/memory.limit_in_bytes` -lt 2147483648 ]; then
      echo "Error: The container doesn't have enough memory allocated."
      echo "A database container needs at least 2 GB of memory."
      echo "You currently only have $((`cat /sys/fs/cgroup/memory/memory.limit_in_bytes`/1024/1024/1024)) GB allocated to the container."
      exit 1;
   fi;
fi;

# Set SIGINT handler
trap _int SIGINT

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

/u01/install/APPS/scripts/startdb.sh
/u01/install/APPS/scripts/startapps.sh

tail -f /u01/install/APPS/12.1.0/admin/EBSDB_apps/diag/rdbms/ebsdb/EBSDB/trace/alert_EBSDB.log
