#!/bin/bash

set -e

HOST=ftp.spb.vega.su
WEEKLY_FOLDER=ftp://${HOST}/pub/weekly/
MPROXY_CONF=/srv/geodata/cache/mproxy_conf.shelve.yaml

MSG_NEED_HOST_TOOL="Для проверки доступности узла с обновлениями используется утилита host. Команда для установки: sudo apt install -y bind9-host"
MSG_NEED_CURL="Для загрузки обновлений необходима утилита curl. Команда для установки: sudo apt install -y curl"
MSG_COULD_NOT_CONNECT="Нет подключения к серверу обновлений"
MSG_GETTING_UPDATES="Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 

if ! env host -V &>/dev/null
then
    echo ${MSG_NEED_HOST_TOOL}
else
    if host ${HOST} &>/dev/null
    then
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