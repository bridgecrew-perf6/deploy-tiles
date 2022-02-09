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

    echo -e "Доступны для загрузки файлы \n ${REMOTE_FILE_LIST}"
    read -i "н" -p "Загрузить файлы (д/н)? " download_enabled

    case "${download_enabled}" in
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

echo "Поиск конфигурационного файла mapproxy"
if [ -e ${MPROXY_CONF} ]
then
    echo "Найден ${MPROXY_CONF}"
    
    ACTUAL_FILE_LIST=*.tar
    echo "Распаковать архивы?"
    echo ${ACTUAL_FILE_LIST}
    
fi