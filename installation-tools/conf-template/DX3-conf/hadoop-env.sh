# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
# export JAVA_HOME=/usr/lib/j2sdk1.5-sun
[ -n "$HADOOP_ENV_INTEPRETED" ] && return
export HADOOP_ENV_INTEPRETED=1

export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64

# Extra Java CLASSPATH elements.  Optional.
# export HADOOP_CLASSPATH="<extra_entries>:$HADOOP_CLASSPATH"

# The maximum amount of heap to use, in MB. Default is 1000.
# export HADOOP_HEAPSIZE=2000

# Extra Java runtime options.  Empty by default.
# export HADOOP_OPTS=-server
#export HADOOP_OPTS="-Dfile.encoding=utf-8 -Duser.language=zh"
HADOOP_SERVERS_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseConcMarkSweepGC -XX:+DoEscapeAnalysis -XX:+UseCompressedOops "

### JMX settings
export JMX_OPTS=" -Dcom.sun.management.jmxremote.authenticate=false \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.port"

CURR_DATE=`date +%Y%m%d-%H%M%S`

# Command specific options appended to HADOOP_OPTS when specified
export HADOOP_NAMENODE_OPTS="$JMX_OPTS=10201 -Dcom.sun.management.jmxremote -Xmx100m $HADOOP_NAMENODE_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-namenode.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8002,server=y,suspend=n"
export HADOOP_SECONDARYNAMENODE_OPTS="$JMX_OPTS=10202 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_SECONDARYNAMENODE_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-secondarynamenode.${CURR_DATE}.log"
export HADOOP_DATANODE_OPTS="$JMX_OPTS=10203 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_DATANODE_OPTS $HADOOP_SERVERS_OPTS  -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HADOOP_LOG_DIR/ -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-datanode.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8003,server=y,suspend=n"
export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-balancer.${CURR_DATE}.log"
export HADOOP_JOBTRACKER_OPTS="$JMX_OPTS=10204 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_JOBTRACKER_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-jobtracker.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8004,server=y,suspend=n"
export HADOOP_TASKTRACKER_OPTS="$JMX_OPTS=10205"

export HADOOP_JOB_HISTORYSERVER_OPTS="$JMX_OPTS=10206 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_JOB_HISTORYSERVER_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-jobhistoryserver.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8005,server=y,suspend=n"

export HADOOP_ZKFC_OPTS="$JMX_OPTS=10208 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_ZKFC_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-zkfc.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8007,server=y,suspend=n"

export HADOOP_JOURNALNODE_OPTS="$JMX_OPTS=10207 -Dcom.sun.management.jmxremote -Xmx50m $HADOOP_JOURNALNODE_OPTS $HADOOP_SERVERS_OPTS -Xloggc:$HADOOP_LOG_DIR/gc-hadoop-journalnode.${CURR_DATE}.log -agentlib:jdwp=transport=dt_socket,address=8006,server=y,suspend=n"

# export HADOOP_TASKTRACKER_OPTS=
# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

# Where log files are stored.  $HADOOP_LOG_DIR by default.
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
# export HADOOP_PID_DIR=/var/hadoop/pids

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10
#export LANG=zh_CN.UTF-8
