while IFS= read -r line
do
name=`echo $line | awk '{print \$1}'`
side=`echo $line | awk '{print \$NF}'`
chr=`echo $line | awk '{print \$2}'`
FirstStrand=`echo $line | awk '{print \$3}'`
SecondStrand=`echo $line | awk '{print \$6}'`
FirstPos=`echo $line | awk '{print \$4}'`
FirstCig=`echo $line | awk '{print \$5}'`
SeconPos=`echo $line | awk '{print \$8}'`
SeconCig=`echo $line | awk '{print \$10}'`
if [ "$side" == "right" ] && [ "$FirstStrand" == 0 ]
then
     Part1=`echo $FirstCig | sed -e 's/[2-9][0-9]S//' | sed -s 's/M//g'`
     Part2=`echo $SeconCig | sed -s 's/M//g'`
     Jump1=$((FirstPos+Part1))
     Jump2=$((SeconPos+Part2))
     echo "$name $chr:$Jump1-$Jump2 right" >> $2.UR.txt     
     #echo "We got 1 Uturn read!!!"
elif [ "$side" == "left" ] && [ "$FirstStrand" == 16 ]
then
     Jump2=$SeconPos
     Jump1=$FirstPos
     echo "$name $chr:$Jump1-$Jump2 left" >> $2.UR.txt
     #echo "We got 1 Uturn read!!!"
elif [ "$side" == "right" ] && [ "$FirstStrand" == 16 ]
then 
     Part1=`echo $FirstCig | sed -e 's/[2-9][0-9]S//' | sed -s 's/M//g'`
     Part2=`echo $SeconCig | sed -s 's/M//g'`
     Jump2=$((FirstPos+Part1))
     Jump1=$((SeconPos+Part2))
     echo "$name $chr:$Jump1-$Jump2 right" >> $2.UR.txt
     #echo "We got 1 Uturn read!!!"
elif [ "$side" == "left" ] && [ "$FirstStrand" == 0 ]
then
     Jump1=$SeconPos
     Jump2=$FirstPos
     echo "$name $chr:$Jump1-$Jump2 left" >> $2.UR.txt
     #echo "We got 1 Uturn read!!!"
else
     echo "We got 1 Myth read..."
fi
done < "$1"
wait
