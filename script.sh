#! /bin/bash

ltc_data=$(curl -L whattomine. com/coins/4-ltc-scrypt)
ltc_price=$Cecho $ltc_data grep -oP | head -1)

btc_data-$(curl -L whattomine. com/coins/1-btc-sha-256)
btc_price=$Cecho $btc_data | grep -oP | head -1)

btc_price=$Cecho "$(btc_price//,//"")
ltc_usdt=$(echo $1tc_prices$btc_price | bc)

message= `date`" LTC current price (USDT) : "$1tc_usdt

echo $message >> script_ltc_log

if [ : $(echo "$1tc_price >= 100.00" bc -1) -eq 1
then
    ./telegram_bot "$message"
fi
