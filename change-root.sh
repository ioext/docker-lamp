#!/bin/bash
#https://stackoverflow.com/questions/38578190/change-document-root-with-command-lines

replace_string () {
    while :; do
        case $1 in
               file=?*) local    file=${1#*=} ;;
            replace=?*) local replace=${1#*=} ;;
               with=?*) local    with=${1#*=} ;;
                     *) break                 ;;
        esac
        shift
    done

    sed -i -- "s/$replace/$with/ig" $file
}

replace_string    file='/etc/apache2/sites-enabled/000-default.conf' \
               replace='.*DocumentRoot.*' \
                  with='DocumentRoot /var/www/html/public'


#replace_string    file='/etc/apache2/apache2.conf' \
#               replace='.*DocumentRoot.*' \
#                  with='DocumentRoot "path-to-your-document-root"'

service apache2 reload
