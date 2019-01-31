#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/opt/cl6/logs/setup_exec.log 2>&1
#set -x
#set +x

OSOS=$(</opt/cl6/info/os.info)
OSVER=$(</opt/cl6/info/ver.info)
INSTALLVER=$(</opt/cl6/info/cl6v.info)
SERVERNUM=$(</opt/cl6/info/servernum.info)
SERVERIP=$(</opt/cl6/info/serverip.info)
USERROOTPASSWD=$(</opt/cl6/vault/cl6-passwd.vault)
USERCL6PASSWD=$(</opt/cl6/vault/root-passwd.vault)

curl -s -X POST "https://discordapp.com/api/webhooks/540485981564960768/dUFXcmnKquZxcWx4SmoSTbupdJ-bWZzBn8zO-yPIjo6ozbLUm-Cfa6e4HY0TLSwvzOm3" \
  -H "Content-Type: application/json" \
  --data '{
  "content": "embeds",
  "username": "CL6 Bot",
  "embeds": [
	{
      "title": "**CL6 Web Company **- *Automation Script Update*",
      "description": "A new server has just been setup, see below for more information:",
      "color": 15680559,
      "footer": {
        "text": "install completed using '"$INSTALLVER"' CL6 install script"
      },
      "thumbnail": {
        "url": "https://i.imgur.com/yvkJ2un.png"
      },
      "fields": [
        {
          "name": "Server Name & Info:",
          "value": " **[CL6.US Server #'"$SERVERNUM"'](https://s'"$SERVERNUM"'.cl6.us)**\n\n`https://S'"$SERVERNUM"'.CL6.US` or `https://S'"$SERVERNUM"'.CL6WEB.COM`\n"
        },
        {
          "name": "OS & Version:",
          "value": "OS: `'"$OSOS"'`\nVER: `'"$OSVER"'`",
          "inline": true
        },
        {
          "name": "System Specs:",
          "value": "CPU:\nMEM:\nSSD:",
          "inline": true
        },
        {
          "name": "Network Info:",
          "value": "IP: `'"$SERVERIP"'`\nU:\nD:\nP:",
          "inline": true
        },
        {
          "name": "SSH Access:",
          "value": "URL: `S'"$SERVERNUM"'.CL6.US`\nPORT: `42806`\n\n`ssh user@s'"$SERVERNUM"'.cl6.us -p 42806`",
          "inline": true
        },
        {
          "name": "Database Info:",
          "value": "PHPMyAdmin: [LINK](https://S'"$SERVERNUM"'.CL6WEB.COM)\nUsers:\nroot - '"$USERROOTPASSWD"'",
          "inline": true
        },
        {
          "name": "Setup Info:",
          "value": "Setup Ver: `'"$INSTALLVER"'`\nDuration: `2h 15m`\nHostname: `S'"$SERVERNUM"'`",
          "inline": true
        }
      ]
    }
  ]
}'
sleep 3s
exit