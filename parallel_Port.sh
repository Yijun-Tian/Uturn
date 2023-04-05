while IFS= read -r line
do
name=`echo $line | awk '{print \$1}'`
side=`echo $line | awk '{print \$NF}'`
chr=`echo $line | awk '{print \$2}'`
Strand=`echo $line | awk '{print \$3}'`
FirstPos=`echo $line | awk '{print \$4}'`
FirstCig=`echo $line | awk '{print \$5}'`
SeconPos=`echo $line | awk '{print \$8}'`
SeconCig=`echo $line | awk '{print \$10}'`
if ([ "$side" == "left" ] && [ "$Strand" == 0 ] && [ $SeconPos -gt $FirstPos ]) || ([ "$side" == "right" ] && [ "$Strand" == 16 ] && [ $SeconPos -gt $FirstPos ])
then
     Breakpoint1=$FirstPos
     Complement=`echo $SeconCig | sed -s 's/M//g'`
     Breakpoint2=$((SeconPos+Complement))
     echo "$name $chr:${Breakpoint1}-${Breakpoint2}" >> $2.PR.txt
     #echo "We got 1 Porting read!!!"
elif ([ "$side" == "left" ] && [ "$Strand" == 16 ] && [ $FirstPos -gt $SeconPos ]) || ([ "$side" == "right" ] && [ "$Strand" == 0 ] && [ $FirstPos -gt $SeconPos ])
then
     Breakpoint1=$SeconPos
     Complement=`echo $FirstCig | sed -e 's/[2-9][0-9]S//' | sed -s 's/M//g'`
     Breakpoint2=$((FirstPos+Complement))
     echo "$name $chr:${Breakpoint1}-${Breakpoint2}" >> $2.PR.txt
     #echo "We got 1 Porting read!!!"
else
     echo "We got 1 Mystery read..."
fi
done < "$1"
wait
