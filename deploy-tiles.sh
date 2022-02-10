#!/bin/bash

set -e

ERR_DETECT_DIR_AMBIGQUITY_DIR=13

HOST=ftp.spb.vega.su
WEEKLY_FOLDER=ftp://${HOST}/pub/weekly/
MPROXY_CONF=/srv/geodata/cache/mproxy_conf.yaml

MSG_NEED_CURL="Для загрузки обновлений необходима утилита curl. Команда для установки: sudo apt install -y curl"
MSG_COULD_NOT_CONNECT="Нет подключения к серверу обновлений"
MSG_GETTING_UPDATES="Получение списка файлов с сервера обновлений ${WEEKLY_FOLDER}" 

download() {
if ! env curl --version &>/dev/null 
then
    echo ${MSG_NEED_CURL}
else
    echo ${MSG_GETTING_UPDATES}
    REMOTE_FILE_LIST=$(curl --silent --list-only ${WEEKLY_FOLDER}) || echo ${MSG_COULD_NOT_CONNECT}

    if [[ -n "${REMOTE_FILE_LIST}" ]] 
    then
        echo -e "Доступны для загрузки файлы \n " ${REMOTE_FILE_LIST}
        read -p "Загрузить (д/н|y/n)? " enable_download

        case "${enable_download}" in
        д|да|y|yes)
            for tar in ${REMOTE_FILE_LIST}
            do
                if [[ "${tar}" =~ .*tar ]]
                then
                    echo "Загружается ${WEEKLY_FOLDER}/${tar}"
                    curl --remote-name --continue-at - ${WEEKLY_FOLDER}/${tar}
                fi
            done
            ;;
        н|n)
            echo "Отказ от загрузки"
            ;;
        *)
            :
            ;;
        esac
    fi
fi
}

extract(){

if [ -e ${MPROXY_CONF} ]
then
    echo "Найден конфигурационный файл Mapproxy ${MPROXY_CONF}"

    google_epsg900913_cache_dir=$(grep -iE  directory:.*google.*epsg900913 $MPROXY_CONF|cut -d: -f2)
    google_epsg900913_cache_dir_count=$(echo $google_epsg900913_cache_dir | wc --words)
    if [[ ${google_epsg900913_cache_dir_count} -ne 1 ]]
    then
        echo "Для автоматической распаковки архивов необходимо наличие только одного целевого каталога"
        echo "Текущее количество каталогов ${google_epsg900913_cache_dir_count}"
        echo "Обнаружены каталоги ${google_epsg900913_cache_dir}"
        echo "Возможна только ручная распаковка"
        exit ${ERR_DETECT_DIR_AMBIGQUITY_DIR}
    else
        echo "Каталог для распаковки Google epsg900913:${google_epsg900913_cache_dir}" 
    fi

    osm_epsg900913_cache_dir=$(grep -iE  directory:.*osm.*epsg900913 $MPROXY_CONF|cut -d: -f2)
    osm_epsg900913_cache_dir_count=$(echo $osm_epsg900913_cache_dir | wc --words)
    if [[ ${osm_epsg900913_cache_dir_count} -ne 1 ]]
    then
        echo "Для автоматической распаковки архивов необходимо наличие только одного целевого каталога"
        echo "Текущее количество каталогов ${osm_epsg900913_cache_dir_count}"
        echo "Обнаружены каталоги ${osm_epsg900913_cache_dir}"
        echo "Возможна только ручная распаковка"
        exit ${ERR_DETECT_DIR_AMBIGQUITY_DIR}
    else
        echo "Каталог для распаковки OSM epsg900913:${osm_epsg900913_cache_dir}" 
    fi

    echo -e "Поиск tar архивов в текущем каталоге"
    ACTUAL_FILE_LIST=$(ls *.tar 2>/dev/null)
    [[ -z "${ACTUAL_FILE_LIST}" ]] && {
        echo "Архивы не найдены"
        exit 0
    }
    echo -e "Архивы в текущем каталоге: \n ${ACTUAL_FILE_LIST}"
    read -p "Распаковать архивы (д/н|y/n)? " enable_extract

    case "${enable_extract}" in
        д|да|y|yes)
            mkdir -p extracted

            for tar in ${ACTUAL_FILE_LIST}
            do
                if [ -f ${tar} ]
                then
                    case ${tar} in
                    *google*epsg900913*)
                        if touch ${google_epsg900913_cache_dir}/test_rw &>/dev/null
                        then
                            tar --extract --verbose --file "./${tar}" -C ${google_epsg900913_cache_dir} && mv "./${tar}" ./extracted
                        else
                            echo "У пользователя ${USER} нет прав на запись в ${google_epsg900913_cache_dir}"
                        fi
                        ;;
                    *)
                        echo "Необходимо вручную распаковать ${tar}. Невозможно классифицровать архив"
                        ;;
                    esac
                fi
            done
            ;;
        н|n)
            echo "Отказ от распаковки"
            ;;
        *)
            :
            ;;
        esac
fi

}

download
extract