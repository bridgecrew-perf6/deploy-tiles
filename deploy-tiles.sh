#!/bin/bash

set -e
ERR_NEED_CURL=13
WEEKLY_FOLDER=ftp://ftp.spb.vega.su/pub/weekly/
INDEX_FILE=index.tiles

env curl --version &>/dev/null || {
    echo "Ошибка: для работы необходима утилита curl. Команда для установки: sudo apt install -y curl"
    exit ${ERR_NEED_CURL}
}

echo "Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 
REMOTE_FILE_LIST=$(curl --silent --list-only ${WEEKLY_FOLDER}) || echo "Нет подключения к серверу обновлений"

for tar in ${REMOTE_FILE_LIST}
do
    if [[ "${tar}" =~ .*tar ]]
    then
        echo curl --remote-name --continue-at - ${WEEKLY_FOLDER}/${tar}
    fi
done
