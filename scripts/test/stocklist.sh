#!/bin/bash

#run this script if you have bought new stocks to alter the stock file

# initialising fuctions:
space() 
 {
 echo ""
 }

plupdate()

 { 
    pnow=$(grep $STOCK ~/stocks/data/mains/plstate | awk '{print $2}')
    
    plsell=${1}
    space
    
    plnew=$(echo "($pnow)+($plsell)"| bc -l)
    
    lno=$(grep -n $STOCK ~/stocks/data/mains/plstate | cut -d ':' -f 1)
    sed -i "${lno}s/$pnow/$plnew/" ~/stocks/data/mains/plstate
    cat ~/stocks/data/mains/plstate
 }

  
buy()
  { 
    
    a=$(grep ^${STOCK} ~/stocks/data/mains/stocks | wc -l)
    if [[ $a -eq 0 ]]
    then 
      echo -e "${STOCK}\t\t${QTY}\t\t${PRICE}\t\t${PRICE}">>~/stocks/data/mains/stocks
      if [[ $(grep $STOCK ~/stocks/data/mains/plstate | wc -l) -eq 0 ]]
      then 
       echo -e "${STOCK}\t\t0" >>~/stocks/data/mains/plstate
      fi
    elif [[ $a -ne 0 ]]
    then
      echo ""
      curval=$(grep ^${STOCK} ~/stocks/data/mains/stocks | awk '{print $2 }')
      apnow=$(grep ^${STOCK} ~/stocks/data/mains/stocks | awk '{print $4 }')
      pricen=$(grep ^$STOCK ~/stocks/data/mains/stocks | awk '{print $3}')
      temp=$(echo "$curval*${pricen}+${PRICE}*$QTY" | bc -l)
      uval=$((($curval+${QTY})))
      aprice=$(printf %.2f $(echo "$temp/$uval" | bc -l))
      space	 
      lno=$(grep -n ^$STOCK ~/stocks/data/mains/stocks | cut -d ':' -f 1) 
      space
      sed -i "${lno}s/$curval/$uval/" ~/stocks/data/mains/stocks
      sed -i "${lno}s/$pricen/$aprice/" ~/stocks/data/mains/stocks
      sed -i "${lno}s/$apnow$/$PRICE/" ~/stocks/data/mains/stocks
    fi
  }

sell()
   {
 
    a=$(grep ^${STOCK} ~/stocks/data/mains/stocks | wc -l)
    if [[ $a -eq 0 ]]
    then 
      echo " you dont have this stock make sure you have entered correctly"
    fi
  
    pricen=$(grep ^$STOCK ~/stocks/data/mains/stocks | awk '{print $3}')
    apnow=$(grep ^${STOCK} ~/stocks/data/mains/stocks | awk '{print $4 }')
    curval=$(grep ^${STOCK} ~/stocks/data/mains/stocks | awk '{print $2 }')
    uval=$((($curval-${QTY})))
    pl=$(echo "${PRICE}*$QTY-$QTY*${pricen}-25" | bc -l)
    plupdate $pl
    if [[ $uval -eq 0 ]]
    then
     echo "meaow"
     sed -i "/^${STOCK}/d" ~/stocks/data/mains/stocks
     grep -v $STOCK ~/stocks/data/mains/stocks>temp
     cp temp ~/stocks/data/mains/stocks
     rm temp
    else  
     lno=$(grep -n ^$STOCK ~/stocks/data/mains/stocks | cut -d ':' -f 1) 
     sed -i "${lno}s/$curval/$uval/" ~/stocks/data/mains/stocks
     sed -i "${lno}s/$apnow$/$PRICE/" ~/stocks/data/mains/stocks
    fi
    } 
#stock file path stored in variable SFILE = ~/stocks/data/mains/stocks
echo ""
SFILE="~/stocks/data/mains/stocks"
# displaying current contensts of file so user has a better idea

cat ~/stocks/data/mains/stocks
# initialising the variables used
cp ~/stocks/data/mains/plstate ~/stocks/data/mains/plstatev0

cp ~/stocks/data/mains/stocks ~/stocks/data/mains/stocks0
SADD=y
STOCK=0
QTY=0
PRICE=0

echo " "
# getting into the logic

while [[ "${SADD}" = y ]]
do
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

cat ~/stocks/data/mains/stocks
