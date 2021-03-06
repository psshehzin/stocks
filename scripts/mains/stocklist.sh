#!/bin/bash

#run this script if you have bought new stocks to alter the stock file

# initialising fuctions:

monthlypro()

 {  
    buys=$(printf %.2f $(echo "$2*$3" | bc -l))
    sells=$(printf %.2f $(echo "$1*$3" | bc -l))
    month=$(date | cut -d ' ' -f2)
    year=$(date | awk '{print $6}')
    if [[ ! -f /home/shps/stocks/dev/$year ]]
    then
      touch /home/shps/stocks/dev/${year}
      echo -e "Month\t\t\t\tbuyval\t\t\t\tselval\t\t\t\tprofit" >> /home/shps/stocks/dev/$year
    fi

    
    if [[ $(grep $month /home/shps/stocks/dev/$year | wc -l) -eq 0 ]]
    then
      echo -e "$month\t\t\t\t0\t\t\t\t0\t\t\t\t0" >> /home/shps/stocks/dev/$year
    fi
    space
    lno=$(grep -n $month /home/shps/stocks/dev/$year | cut -d ':' -f1)
    cbuyval=$(grep $month /home/shps/stocks/dev/$year  | awk '{print $2}')
    csellval=$(grep $month /home/shps/stocks/dev/$year | awk '{print $3}')
    profitold=$(grep $month /home/shps/stocks/dev/$year | awk '{print $4}')
    cbuynew=$(echo "$cbuyval+$buys" | bc -l)
    csellnew=$(echo "$csellval+$sells-20" | bc -l)
    profitnew=$(printf %.2f $(echo "(($csellnew-$cbuynew)*100)/$cbuynew" | bc -l))
    
    flag=1
    if [[ $cbuynew = $csellnew ]]
    then
       flag=2
    fi
    
    sed -i "${lno}s?$(cat /home/shps/stocks/dev/$year| grep $month)?$(echo -e "$month\t\t\t\t$cbuynew\t\t\t\t$csellnew\t\t\t\t$profitnew")?" /home/shps/stocks/dev/$year
    
    
    cat /home/shps/stocks/dev/$year
    space
}

space() 
 {
 echo ""
 }

plupdate()

 { 
    pnow=$(grep $STOCK /home/shps/stocks/dev/data/plstate | awk '{print $2}')
    plsell=${1}
    plnew=$(echo "($pnow)+($plsell)"| bc -l)
    lno=$(grep -n $STOCK /home/shps/stocks/dev/data/plstate | cut -d ':' -f 1)
    sed -i "${lno}s/$pnow/$plnew/" /home/shps/stocks/dev/data/plstate
    space
    cat /home/shps/stocks/dev/data/plstate
    space

}

  
buy()
  { 
    
    a=$(grep ^${STOCK} ${SFILE} | wc -l)
    if [[ $a -eq 0 ]]
    then 
      echo -e "${STOCK}\t\t${QTY}\t\t${PRICE}\t\t${PRICE}">>$SFILE
      if [[ $(grep $STOCK /home/shps/stocks/dev/data/plstate | wc -l) -eq 0 ]]
      then 
       echo -e "${STOCK}\t\t0" >>/home/shps/stocks/dev/data/plstate
      fi
    elif [[ $a -ne 0 ]]
    then
      echo ""
      curval=$(grep ^${STOCK} ${SFILE} | awk '{print $2 }')
      apnow=$(grep ^${STOCK} ${SFILE} | awk '{print $4 }')
      pricen=$(grep ^$STOCK $SFILE | awk '{print $3}')
      temp=$(echo "$curval*${pricen}+${PRICE}*$QTY" | bc -l)
      uval=$((($curval+${QTY})))
      aprice=$(printf %.2f $(echo "$temp/$uval" | bc -l))
      space	 
      lno=$(grep -n ^$STOCK $SFILE | cut -d ':' -f 1) 
      space
      sed -i "${lno}s/$curval/$uval/" $SFILE
      sed -i "${lno}s/$pricen/$aprice/" $SFILE
      sed -i "${lno}s/$apnow$/$PRICE/" $SFILE
    fi
  }

sell()
   {
 
    a=$(grep ^${STOCK} ${SFILE} | wc -l)
    if [[ $a -eq 0 ]]
    then 
      echo " you dont have this stock make sure you have entered correctly"
    fi
  
    pricen=$(grep ^$STOCK $SFILE | awk '{print $3}')
    apnow=$(grep ^${STOCK} ${SFILE} | awk '{print $4 }')
    curval=$(grep ^${STOCK} ${SFILE} | awk '{print $2 }')
    uval=$((($curval-${QTY})))
    pl=$(echo "${PRICE}*$QTY-$QTY*${pricen}-20" | bc -l)
    plupdate $pl
    monthlypro $PRICE $pricen $QTY
    if [[ $uval -eq 0 ]]
    then
     echo "meaow"
     sed -i "/^${STOCK}/d" $SFILE
     grep -v $STOCK $SFILE>temp
     cp temp $SFILE
     rm temp
    else  
     lno=$(grep -n ^$STOCK $SFILE | cut -d ':' -f 1) 
     sed -i "${lno}s/$curval/$uval/" $SFILE
     sed -i "${lno}s/$apnow$/$PRICE/" $SFILE
    fi
    } 
#stock file path stored in variable SFILE = /vagrant/data/stocks
echo ""
SFILE="/home/shps/stocks/dev/data/stocks"
# displaying current contensts of file so user has a better idea


# initialising the variables used

SADD=y
STOCK=0
QTY=0
PRICE=0
tdate=$(date +%y-%m-%d)
year=$(date | awk '{print $6}')
cp /home/shps/stocks/dev/data/stocks /home/shps/stocks/backups/"$tdate".stocksbu
cp /home/shps/stocks/dev/data/plstate /home/shps/stocks/backups/"$tdate".plstatebu
cp /home/shps/stocks/dev/$year /home/shps/stocks/backups/"$tdate".yearbu

echo " "
# getting into the logic

while [[ "${SADD}" = y ]]
do
   cat $SFILE
   space
   space
   read -p "do you want to buy or sell a stock today b/s: " -e ADR
   if [[ $ADR != b && $ADR != s ]]
   then
     echo -e " you need to choose either b or s"
     exit 1
   fi
   space
   read -p " enter the stock for which details have to be modified (if new you can suggest a name else neter name as displayed in above list: " -e STOCK
   echo " "
   read -p " quantity of stock bought or sold: " -e QTY
   echo " "
   read -p " buy price or sell price: " -e PRICE
   case ${ADR} in 
     b) 
        buy $STOCK $QTY $PRICE ;;
     s) 
        sell  $STOCK $QTY $PRICE ;;
   esac
   read -p " are there more stocks to add or remove (y/n) " -e  SADD
 #  fi
done

echo " altered file "
read -p " do you want to take backup of script y or n " -e val
if [[ "$val" = y ]]
then
cp /home/shps/stocks/scripts/mains/stocklist.sh /home/shps/stocks/backups/"$tdate".scriptbu
fi
cat $SFILE

read -p " do you want to revert files no or yes  " -e val
if [[ "$val" = yes ]]
then
cp /home/shps/stocks/backups/"$tdate".stocksbu /home/shps/stocks/dev/data/stocks 
cp /home/shps/stocks/backups/"$tdate".plstatebu /home/shps/stocks/dev/data/plstate
cp /home/shps/stocks/backups/"$tdate".yearbu /home/shps/stocks/dev/$year
fi
