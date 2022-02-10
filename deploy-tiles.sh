#!/bin/bash

set -e

HOST=ftp.spb.vega.su
WEEKLY_FOLDER=ftp://${HOST}/pub/weekly/
MPROXY_CONF=/srv/geodata/cache/mproxy_conf.shelve.yaml

MSG_NEED_CURL="Для загрузки обновлений необходима утилита curl. Команда для установки: sudo apt install -y curl"
MSG_COULD_NOT_CONNECT="Нет подключения к серверу обновлений"
MSG_GETTING_UPDATES="Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 

if ! env curl --version &>/dev/null 
then
    echo ${MSG_NEED_CURL}
else
    echo ${MSG_GETTING_UPDATES}
    REMOTE_FILE_LIST=$(curl --silent --list-only ${WEEKLY_FOLDER}) || echo ${MSG_COULD_NOT_CONNECT}

    if [[ -n "${REMOTE_FILE_LIST}" ]] 
    then
        echo -e "Доступны для загрузки файлы \n " ${REMOTE_FILE_LIST}
        read -p "Загрузить файлы (д/н)? " enable_download

        case "${enable_download}" in
        "д|да|y|yes")
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
    echo -e "Поиск tar архивов в текущем каталоге"
    ACTUAL_FILE_LIST=$(ls *.tar)
    echo ${ACTUAL_FILE_LIST}
    read -p "Распаковать архивы (д/н)? " enable_extract

    case "${enable_extract}" in
        "д|да|y|yes")
            for tar in ${ACTUAL_FILE_LIST}
            do
                if [ -f ${tar} ]
                then
                    echo ${tar}
                fi
            done
            ;;
        "н")
            echo "Отказ от распаковки."
            ;;
        *)
            :
            ;;
        esac






fi
