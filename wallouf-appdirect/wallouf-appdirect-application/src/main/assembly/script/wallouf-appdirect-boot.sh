#!/bin/bash
# chkconfig: 45 20 80

# Source function library.
. /etc/init.d/functions

APP_DIR="/apps/wallouf-appdirect-application/"

start() {
  PID=$(ps -ef | grep -G "wallouf-appdirect-application" | grep -v grep | awk '{print $2}')
  if [ -n "$PID" ]; then
    echo "Application already started. Exit."
    exit -1
  fi
  cd ${APP_DIR}

  JAVA_OPTS="-Xmx1024m -Xms128m -XX:NewSize=32m -XX:MaxNewSize=128m -XX:PermSize=32m -XX:MaxPermSize=256m"
  CATALINA_HOME=/apps/tomcat
  CATALINA_BASE=${APP_DIR}
  export JAVA_HOME JAVA_OPTS CATALINA_HOME CATALINA_BASE

  nohup ${CATALINA_HOME}/bin/catalina.sh start &> stdout.log &
  echo "Application successfully started!"
  exit 0
}

stop() {
  PID=$(ps -ef | grep -G "wallouf-appdirect-application" | grep -v grep | awk '{print $2}')
  if [ -n "$PID" ]; then
    echo "Send SIGTERM signal to stop the application."
    kill $PID
  else
    echo "Application already stopped."
  fi
}

status() {
  PID=$(ps -ef | grep -G "wallouf-appdirect-application" | grep -v grep | awk '{print $2}')
  if [ -n "$PID" ]; then
    echo 1
  else
    echo 0
  fi
}

case "$1" in
    start)
       start
       ;;
    stop)
       stop
       ;;
    restart)
       stop
       start
       ;;
    status)
        status
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac
