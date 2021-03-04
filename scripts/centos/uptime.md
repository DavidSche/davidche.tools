# Site Uptime Downtime Alert Shell Script

Download the script.

Change the script permission to 777
```shell
sudo chmod 777 uptime.sh
```

Run the script with sudo.

```shell
sudo ./uptime.sh
```

Prerequisite:

Ubuntu OS or Debian

## Mail server

For gmail ssmtp mail server installation: https://github.com/shivdevops/GMAIL-SSMTP-MAIL-SERVER-INSTALLATION-SHELL-SCRIPT
Note:
Provide your mailid for mail alert by replacing "yourmailid" i.e mailid="yourmailid" in the begining of the script.

Enter the domains need to be monitored.You can add multiple domains by replacing https://your-domain i.e for site in https://your-domain https://yourdomain https://yourdomain https://yourdomain in the 6th line of the shell script.

## Add cron:
Need to automate the shell script for monitoring and alert, Add cron schedule.

## Example:

cron schedule for every minute.

*/1 * * * * sh /home/uptime.sh