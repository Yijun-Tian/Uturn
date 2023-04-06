#$1 is aliquot name in parallel {}, $2 is sample basename
while IFS= read -r line
do
name=`echo $line | awk '{print \$1}'`
Strand=`echo $line | awk '{print \$2}'`
chr=`echo $line | awk '{print \$3}'`
Pos=`echo $line | awk '{print \$4}'`
Cig=`echo $line | awk '{print \$6}'`

if [ "$Strand" == 0 ] && [[ $Cig =~ ^[0-9]{1,3}M ]]
#read mapped to positive strand and is a left match, so read start is the left most position of the alignment
 then
    Start=$Pos
    echo "$name $chr $Start Forward" >> $2.ReadStart.txt
 elif [ "$Strand" == 16 ] && [[ $Cig =~ [0-9]{1,3}M$ ]]
#read mapped to negative strand and is a right match, so read start is the right most position of the alignment, which need some calculation
  then
  #Fomular calculates bases extended from the left most position, read start is therefore left most plus matched extension
    Fomular=`echo $Cig | sed -e 's/[0-9]\{1,3\}S//g;s/[0-9]\{1,3\}I//g' | sed -e 's/D/+1+/g;s/M/+/g;s/+$//g'`
    Match=$((Fomular))
    Start=$((Pos+Match))
    echo "$name $chr $Start Reverse" >> $2.ReadStart.txt
elif [ "$Strand" == 0 ] && [[ $Cig =~ ^[0-9]{1,3}S ]]
#read mapped to positive strand and is a right match, so read start is on the opposite(negative) strand, and need find read start by read name in the softclipped alignment (UR.softclip.bam)
  then
    samtools view $2.UR.softclip.bam | grep -F "$name|" > $1.temp.txt
     if [ -s $1.temp.txt ]
      then 
       S_Pos=$(cut -f 4 $1.temp.txt)
       S_Match=$(cut -f 6 $1.temp.txt | sed -e 's/M//g')
       Start=$((S_Pos+S_Match))
       echo "$name $chr $Start Reverse" >> $2.ReadStart.txt
       else         
       echo "$name NA NA No_start" >> $2.ReadStart.txt
     fi
     rm $1.temp.txt
elif [ "$Strand" == 16 ] && [[ $Cig =~ [0-9]{1,3}S$ ]]
#read mapped to negative strand and is a left match, so read start is on the opposite(positive) strand, and need find read start by read name in the softclipped alignment (UR.softclip.bam)
   then
   samtools view $2.UR.softclip.bam | grep -F "$name|" > $1.temp.txt
     if [ -s $1.temp.txt ]
      then 
       S_Pos=$(cut -f 4 $1.temp.txt)
       Start=$S_Pos
      echo "$name $chr $Start Forward" >> $2.ReadStart.txt
      else
      echo "$name NA NA No_start" >> $2.ReadStart.txt
     fi
    rm $1.temp.txt
else
   echo "$name Myth Myth Myth" >> $2.ReadStart.txt
fi
done < "$1"
wait
