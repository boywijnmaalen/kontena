#!/usr/bin/env bash

# set working directory
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../ && pwd )"

# load config
source ${ROOT_DIR}/backup.conf

#############################
# Send backup summary email #
#############################

mail+=("mail")

echo ""
echo ""
echo -e "\033[1;42m +---------------------------+ \033[0m"
echo -e "\033[1;42m | Send backup summary email | \033[0m"
echo -e "\033[1;42m +---------------------------+ \033[0m"
echo ""

# start building backup summary email

(
echo "To: ${email_to}"
echo "Subject: ${email_subject}"
echo "Content-Type: text/html"
echo
echo "<html>
<head>
<style>
html, body {
    color: #333;
}
table, th, td {
    border: 1px solid #7C7C7C;
    border-collapse: collapse;
}
th, td {
    padding: 5px;
}
tr.header {
    color: #1b1e21;
    background-color: #d6d8d9;
}

.margin-reset {
    margin: 0;
}

.info {
    color: #004085;
    background-color: #cce5ff;
}
.ok {
    color: #155724;
    background-color: #d4edda;
}
.warning {
    color: #856404;
    background-color: #fff3cd;
}
.error {
    color: #721c24;
    background-color: #f8d7da;
}
</style>
</head>
<body>

<h2>&nbsp;&nbsp;Backup summary</h2>

<table style='width: 100%'>
<tr class='header'>
    <th class='header'>&nbsp;</th>
    <th>Warnings</th>
    <th>Errors</th>
</tr>"

oIFS="${IFS}"; IFS=';'
for stat in "${stats[@]}"; do

    echo "<tr>"

    read script warnings errors <<< "${stat}"

    class="ok"
    if [ "${warnings}" -gt 0 ]; then

        class="warning"
    fi

    if [ "${errors}" -gt 0 ]; then

        class="error"
    fi

    echo "<td valign='top' class='${class}'>${script}</td>"
    echo "<td valign='top' align='center' class='${class}'><b>${warnings}</b></td>"
    echo "<td valign='top' align='center' class='${class}'><b>${errors}</b></td>"

    echo "</tr>"
done
IFS="${oIFS}"

echo "</table><br /><br />"

echo $(printf '%s<br />' "${mail[@]}")

echo "</body>
</html>"

) | /usr/sbin/sendmail -t
