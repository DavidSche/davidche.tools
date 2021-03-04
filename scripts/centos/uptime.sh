#!/bin/bash

# provide mailid id for mail alert
mailid="yourmailid"

# provide the domain with https for monitoring
for site in  https://your-domain https://yourdomain https://yourdomain https://yourdomain

do

	down=$(curl -I -s  $site | head -n 1 | cut -d " " -f 2)

case $down in

	401)

		echo "$site is down.statuss Code: Unauthorized Error." | mail -s 'Alert Site Down' $mailid

		;;

       403)

                echo "$site is down.Status Code: Forbidden Error" | mail -s 'Alert Site Down' $mailid

                ;;

       404)

                echo "$site is down.Status Code: Page Not Found" | mail -s 'Alert Site Down' $mailid

                ;;


       501)

                echo "$site is down.Status Code: Not Implemented" | mail -s 'Alert Site Down' $mailid

                ;;


       502)

                echo "$site is down.Status Code: Bad Gateway." | mail -s 'Alert Site Down' $mailid

                ;;


       503)

                echo "$site is down.Status Code: Service unavailable." | mail -s 'Alert Site Down' $mailid

                ;;


       504)

                echo "$site is down.Status Code: Gateway Timeout." | mail -s 'Alert Site Down' $mailid

                ;;


       495)

                echo "$site is down.SSL Certificate Error." | mail -s 'Alert Site Down' $mailid

                ;;

       520)

                echo "$site is down.Web Server Returned an Unknown Error." | mail -s 'Alert Site Down' $mailid

                ;;


       521)

                echo "$site is down.Web Server Is Down." | mail -s 'Alert Site Down' $mailid

                ;;

        522)

                echo "$site is down.Connection Timed Out." | mail -s 'Alert Site Down' $mailid

                ;;

        523)

                echo "$site is down.Origin Is Unreachable." | mail -s 'Alert Site Down' $mailid

                ;;


       524)

                echo "$site is down.A Timeout Occurred." | mail -s 'Alert Site Down' $mailid

                ;;

       525)

                echo "$site is down.SSL Handshake Failed." | mail -s 'Alert Site Down' $mailid

                ;;

       526)

                echo "$site is down.Invalid SSL Certificate." | mail -s 'Alert Site Down' $mailid

                ;;

       527)

                echo "$site is down.Railgun Error." | mail -s 'Alert Site Down' $mailid

                ;;

esac
done