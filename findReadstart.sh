# $1 is the *.primaryalign.bam file.
Base=$(basename $1 .primaryalign.bam)
# The first step is to subset this BAM file to obtain alignments of Uturn read pairs, to generate a table file called .primaryalign.UturnPair.tab
# Note that the read pair here is named in SRA convention, e.g. SRR1291024.133589363.1, SRR1291024.133589363.2.
# As such, please change the code by the read pair identification accordingly
samtools view $1 | grep -w -F -f <(cut -d"." -f1-2 $Base.URList) - | sort -k1,1 > $Base.primaryalign.UturnPair.tab
echo Start dissecting start in $1
split --additional-suffix=".tab" -n l/20 $Base.primaryalign.UturnPair.tab $Base.primaryalign.UturnPair.
ls $Base.primaryalign.UturnPair.*.tab | parallel -j 20 "bash parallel_ReadStart.sh {} $Base"
wait
rm $Base.primaryalign.UturnPair.*.tab
echo Finish looking for Read start in $Base
