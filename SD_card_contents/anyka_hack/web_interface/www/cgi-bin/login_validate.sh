#!/bin/sh
#
echo "Content-type: text/html"
echo ""
creds=`echo "$QUERY_STRING" | awk '{split($0,array,"&")} END{print array[1]}' | awk '{split($0,array,"=")} END{print array[2]}'`
if [[ "$(echo '$%^/k#@>?'$creds | md5sum )" == "$(cat /etc/jffs2/webui.hash)" ]]; then
token=$RANDOM
cat <<EOT
<html>
    <head>
        <meta http-equiv="refresh" content="0; url=/cgi-bin/webui?token=$token" />
    </head>
    <body>
        <a href="/cgi-bin/webui">WebUI</a>
    </body>
</html>
EOT
echo "$token">/tmp/token.txt

else
source footer
fi
