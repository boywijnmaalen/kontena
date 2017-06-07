# switch PHP version
function __switchPHPVersion() {
    php_version=$1;

    sudo update-alternatives --set php /usr/bin/php${php_version}
    sudo update-alternatives --set phpize /usr/bin/phpize${php_version}
    sudo update-alternatives --set php-config /usr/bin/php-config${php_version}
    sudo update-alternatives --set phar /usr/bin/phar${php_version}
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar${php_version}

    case ${php_version//.} in \

        56)
            phpunit_version=5
        ;;
        70)
            phpunit_version=6
        ;;
        71)
            phpunit_version=7
        ;;
        72)
            phpunit_version=7
        ;;
        *)
            phpunit_version=9
        ;;
    esac

    sudo ln -sf /usr/local/bin/phpunit${phpunit_version} /usr/local/bin/phpunit
    echo "switched to PHPUnit version: ${phpunit_version}"
}

alias switchphp='__switchPHPVersion'    # usage ex. : switchphp 7.1

# make the 'service' command available
function __service() {
    service=$1;
    action=$2;

    sudo /etc/init.d/${service} ${action}
}

alias service='__service'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
