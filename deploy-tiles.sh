#!/bin/bash

set -e

WEEKLY_FOLDER=ftp://ftp.spb.vega.su/pub/weekly/
MPROXY_CONF=/srv/geodata/cache/mproxy_conf.shelve.yaml

if ! env curl --version &>/dev/null 
then
    echo "Для загрузки обновлений необходима утилита curl. Команда для установки: sudo apt install -y curl"
else
    echo "Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 
    REMOTE_FILE_LIST=$(curl --silent --list-only ${WEEKLY_FOLDER}) || echo "Нет подключения к серверу обновлений"

    if [[ -Z "${REMOTE_FILE_LIST}" ]] 
    then
        echo -e "Доступны для загрузки файлы \n ${REMOTE_FILE_LIST}"
        read -p "Загрузить файлы (д/н)? " enable_download

        case "${enable_download}" in
        "д")
            echo "Начинается загрузка файлов"
            for tar in ${REMOTE_FILE_LIST}
            do
                if [[ "${tar}" =~ .*tar ]]
                then
                    echo "Загружается ${WEEKLY_FOLDER}/${tar}"
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
    fi
fi

if [ -e ${MPROXY_CONF} ]
then
    echo "Найден ${MPROXY_CONF}"
    ACTUAL_FILE_LIST=*.tar
    echo -e "Найдены архивы \n ${ACTUAL_FILE_LIST}"
    read -p "Распаковать архивы (д/н)? " enable_extract
    echo ${ACTUAL_FILE_LIST}
fi