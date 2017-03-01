find /var/www/sites/ "$@" \( -name "\.DS_Store" -or -name "\.TemporaryItems" -or -name "\.Trashes" -or -name "\._*" \) -exec rm -rf "{}" \; -prune
find /home/admin/ "$@" \( -name "\.DS_Store" -or -name "\.TemporaryItems" -or -name "\.Trashes" -or -name "\._*" \) -exec rm -rf "{}" \; -prune

