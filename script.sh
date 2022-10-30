#! /bin/bash

ltc_data=$(curl -L whattomine.com/coins/4-ltc-scrypt)
ltc_price=$(echo $ltc_data | grep -oP '(?<=LTC_BTC">)[\d](\d|,|\.)*' | head -1)

btc_data=$(curl -L whattomine.com/coins/1-btc-sha-256)
btc_price=$(echo $btc_data | grep -oP '(?<=BTC_USDT">)[$\d](\d|,|\.)*'| head -1)

btc_price=$(echo "${btc_price//,/}")
btc_price=$(echo "${btc_price//\$/}")
ltc_usdt=$(echo $ltc_price*$btc_price | bc)


message=`date`" LTC current price (USDT) : "$ltc_usdt
current_hour=$(date +%T | cut -d " " -f5 | cut -d ":" -f1-2)

# If it is a new day -> erase all previous data 
if [ "$current_hour" == "00:00" ]
then
	echo $message > script_ltc_log
else
	echo $message >> script_ltc_log
fi

# If LTC price goes above 100 $, send a telegram message
if [ $(echo "$ltc_usdt >= 100.00" | bc -l) -eq 1 ]
then
    ./telegram_bot "$message"
fi

# If it is 23:59, send a recap message on telegram
if [ "$current_hour" == "23:59" ]
then
    # Get the lowest and highest price of the day
    low_price=100000
    high_price=0

    old_IFS=$IFS    
    IFS=$'\n' 

    file="script_ltc_log"

    for ligne in $(<$file)
    do
        price=$(awk -F'$' '{print $2}' <<< "$ligne")
	
        if [ $(echo "$price >= $high_price" | bc -l) -eq 1 ]
        then   
		high_price=$(echo ${price:0:6})
        fi
        if [ $(echo "$price <= $low_price" | bc -l) -eq 1 ]
	then   
		low_price=$(echo ${price:0:6})
        fi
    done

    IFS=$old_IFS 

    message="Daily checkup on LTC highest and lowest price of the day : [$high_price;$low_price]"
    ./telegram_bot "$message"
	
fi