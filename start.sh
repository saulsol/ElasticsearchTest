APP_PATH="/Users/olatte/nospoon/elastic/cluster2/elasticsearch-8.1.3/bin/"
APP_PORT="9201"
APP_NAME="Elasticsearch node-2"


if [ -f ${APP_PATH}${APP_PORT}.pid ]; then
        PID=$(cat ${APP_PATH}${APP_PORT}.pid)
        echo "${APP_NAME}(pid:$PID) is running"
else
        nohup ${APP_PATH}elasticsearch > ${APP_PATH}${APP_PORT}.log 2>&1 & echo $! > ${APP_PATH}${APP_PORT}.pid
        PID=$(cat ${APP_PATH}${APP_PORT}.pid)
        echo "${APP_NAME}(pid:$PID) is start"
fi