# switch PHP version
function __switchPHPVersion() {
    php_version=$1;

    sudo update-alternatives --set php /usr/bin/php${php_version}
    sudo update-alternatives --set phar /usr/bin/phar${php_version}
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar${php_version}

    exploded_php_version=(${php_version//./ });
    case ${exploded_php_version[0]} in \

        5)
            phpunit_version=5
        ;;
        *)
            phpunit_version=6
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
