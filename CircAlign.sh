#!/bin/bash
#$1 is the FASTQ file name, $2 is the basename for the output files
bash bowtie_align.sh $1 $2

echo Start dissecting Port reads in $2
split --additional-suffix=".txt" -n l/10 $2.MixPortInput PortAliquot.$2.
ls PortAliquot.$2.*.txt | parallel -j 10 "bash parallel_Port.sh {} $2"
wait
rm PortAliquot.$2.*.txt
echo Finish dissecting Port reads in $2

echo Start dissecting Uturn reads in $2
split --additional-suffix=".txt" -n l/10 $2.MixUturnInput UturnAliquot.$2.
ls UturnAliquot.$2.*.txt | parallel -j 10 "bash parallel_Uturn.sh {} $2"
wait
rm UturnAliquot.$2.*.txt
echo Finish dissecting Uturn reads in $2

awk 'BEGIN {FS=OFS=" "} NR>0 {a[$2]+=1} END {for (m in a) {print m,a[m]}}' $2.PR.txt | sort > $2.Port.profile
awk 'BEGIN {FS=OFS=" "} NR>0 {a[$2]+=1} END {for (m in a) {print m,a[m]}}' $2.UR.txt | sort > $2.Uturn.profile
awk 'BEGIN {FS=OFS=" "} NR>0 {total[$2$3]+=1;Coor[$2]++;Dire[$3]++} END {n=asorti(Dire,cp1); printf "Directions"; for (i=1; i<=n; i++) {printf "%s%s",FS,cp1[i]}; print ""; m=asorti(Coor,cp2); for (j=1;j<=m;j++) {printf "%s", cp2[j]; for (k=1; k<=n; k++) {printf "%s%i",FS,total[cp2[j]cp1[k]]}; print ""}}' $2.UR.txt > $2.Pattern.txt
