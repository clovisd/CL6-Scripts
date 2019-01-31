#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/opt/cl6/logs/setup_exec.log 2>&1
#set -x
#set +x

OS-OS=$(</opt/cl6/info/os.info)
OS-VER=$(</opt/cl6/info/ver.info)
INSTALL-VER=$(</opt/cl6/info/cl6v.info)
SERVER-NUM=$(</opt/cl6/info/servernum.info)
SERVER-IP=$(</opt/cl6/info/serverip.info)
USER-ROOT-PASSWD=$(</opt/cl6/vault/cl6-passwd.vault)
USER-CL6-PASSWD=$(</opt/cl6/vault/root-passwd.vault)

curl -s -X POST "https://discordapp.com/api/webhooks/540485981564960768/dUFXcmnKquZxcWx4SmoSTbupdJ-bWZzBn8zO-yPIjo6ozbLUm-Cfa6e4HY0TLSwvzOm3" \
  --data '{
  "username": "CL6 Bot",
  "embeds": [
    {
      "title": "**CL6 Web Company **- *Automation Script Update*",
      "description": "A new server has just been setup, see below for more information:",
      "color": 15680559,
      "footer": {
        "text": "install completed using '"$INSTALL-VER"' CL6 install script"
      },
      "thumbnail": {
        "url": "https://i.imgur.com/yvkJ2un.png"
      },
      "fields": [
        {
          "name": "Server Name & Info:",
          "value": " **[CL6.US Server #'"$SERVER-NUM"'](https://s'"$SERVER-NUM"'.cl6.us)**\n\n`https://S'"$SERVER-NUM"'.CL6.US` or `https://S'"$SERVER-NUM"'.CL6WEB.COM`\n"
        },
        {
          "name": "OS & Version:",
          "value": "OS: `'"$OS-OS"'`\nVER: `'"$OS-VER"'`",
          "inline": true
        },
        {
          "name": "System Specs:",
          "value": "CPU:\nMEM:\nSSD:",
          "inline": true
        },
        {
          "name": "Network Info:",
          "value": "IP: `'"$SERVER-IP"'`\nU:\nD:\nP:",
          "inline": true
        },
        {
          "name": "SSH Access:",
          "value": "URL: `S'"$SERVER-NUM"'.CL6.US`\nPORT: `42806`\n\n`ssh user@s'"$SERVER-NUM"'.cl6.us -p 42806`",
          "inline": true
        },
        {
          "name": "Database Info:",
          "value": "**Users**:\n - root \ `'"USER-ROOT-PASSWD"'`",
          "inline": true
        },
        {
          "name": "Setup Info:",
          "value": "Setup Ver: `'"$INSTALL-VER"'`\nDuration: `2h 15m`\nHostname: `S'"$SERVER-NUM"'`",
          "inline": true
        }
      ]
    }
  ]
}' >> ${logfile} 2>&1
  
sleep 3s
exit