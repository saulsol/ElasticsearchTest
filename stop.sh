APP_PATH="/Users/olatte/nospoon/elastic/cluster2/elasticsearch-8.1.3/bin/"
APP_PORT="9201"
APP_NAME="Elasticsearch node-2"


if [ -f ${APP_PATH}${APP_PORT}.pid ]; then
        PID=$(cat ${APP_PATH}${APP_PORT}.pid)
        kill $PID
        rm ${APP_PATH}${APP_PORT}.pid
        echo "${APP_NAME}(pid:$PID) is stopped"
else
        echo "${APP_NAME} is not running"
fi