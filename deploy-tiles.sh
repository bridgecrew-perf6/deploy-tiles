#!/bin/bash

set -e
ERR_NEED_CURL=13
WEEKLY_FOLDER=ftp://ftp.spb.vega.su/pub/weekly/
INDEX_FILE=index.tiles
MPROXY_CONF=/srv/geodata/cache/mproxy_conf.shelve.yaml

env curl --version &>/dev/null || {
    echo "Ошибка: для работы необходима утилита curl. Команда для установки: sudo apt install -y curl"
    exit ${ERR_NEED_CURL}
}

echo "Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 
REMOTE_FILE_LIST=$(curl --silent --list-only ${WEEKLY_FOLDER}) || echo "Нет подключения к серверу обновлений"

echo "Доступны для загрузки файлы ${REMOTE_FILE_LIST}"
read -i "н" -p "Загрузить файлы (д/н)?" download_enabled

case download_enabled in
"д")
    echo "Начинается загрузка файлов"
    for tar in ${REMOTE_FILE_LIST}
    do
        if [[ "${tar}" =~ .*tar ]]
        then
            curl --remote-name --continue-at - ${WEEKLY_FOLDER}/${tar}
        fi
    done
    ;;
"н")
    echo "Отказ от загрузки."
    ;;
*)
    echo "Ни да, ни нет. Продолжаем"
    ;;
esac
