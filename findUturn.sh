for i in $(ls *.fastq.gz |  rev | cut -c 21-| rev | sort | uniq)
do

#could be customized for adaptor trimming, here shows trueseq pair-end wgs data trimming with cutadapt. Note the pipeline will treat pair end as single end for in-read uturn evidence
#quality trimming can be customized too
cutadapt -j 2 -q 20,20 --minimum-length 20\
         -a agatcggaagagcac -A agatcggaagagcgt\
         -o $i.R1_trimmed.fastq.gz -p $i.R2_trimmed.fastq.gz\
         $i.R1.fastq.gz $i.R2.fastq.gz > $i.trim.record.txt
Arg3="$i.R1_trimmed.fastq.gz,$i.R2_trimmed.fastq.gz"
echo $Arg3 $i
#CircleAlign is used identify Uturn and Porting (eccDNA) reads from the trimmed FASTQ
echo Now, the CircleAlign starts to work on sample $i
./CircAlign.sh $Arg3 $i

samtools view -H $i.softclip.bam > $i.softclip.header

cut -f 1 -d " " $i.UR.txt > $i.URList
grep -w -e 'left' $i.UR.txt | cut -f 1 -d " " > $i.N2P.URList
grep -w -e 'right' $i.UR.txt | cut -f 1 -d " " > $i.P2N.URList

samtools view -@10 $i.primaryalign.bam | grep -w -F -f $i.URList | cat $i.BAM.header - | samtools sort -@5 -o $i.UR.primary.bam
samtools view -@10 $i.primaryalign.bam | grep -w -F -f $i.N2P.URList | cat $i.BAM.header - | samtools sort -@5 -o $i.UR.N2P.primary.bam
samtools view -@10 $i.primaryalign.bam | grep -w -F -f $i.P2N.URList | cat $i.BAM.header - | samtools sort -@5 -o $i.UR.P2N.primary.bam

samtools view -@10 $i.softclip.bam | grep -w -F -f $i.URList | cat $i.softclip.header - | samtools sort -@5 -o $i.UR.softclip.bam
samtools view -@10 $i.softclip.bam | grep -w -F -f $i.N2P.URList | cat $i.softclip.header - | samtools sort -@5 -o $i.UR.N2P.softclip.bam
samtools view -@10 $i.softclip.bam | grep -w -F -f $i.P2N.URList | cat $i.softclip.header - | samtools sort -@5 -o $i.UR.P2N.softclip.bam

samtools index $i.UR.primary.bam
samtools index $i.UR.N2P.primary.bam
samtools index $i.UR.P2N.primary.bam
samtools index $i.UR.softclip.bam
samtools index $i.UR.N2P.softclip.bam
samtools index $i.UR.P2N.softclip.bam

cut -f 1 -d " " $i.PR.txt > $i.PRList
samtools view -@10 $i.primaryalign.bam | grep -w -F -f $i.PRList | cat $i.BAM.header - | samtools sort -@5 -o $i.PR.primary.bam
samtools view -@10 $i.softclip.bam | grep -w -F -f $i.PRList | cat $i.softclip.header - | samtools sort -@5 -o $i.PR.softclip.bam
samtools index $i.PR.primary.bam
samtools index $i.PR.softclip.bam

echo Sample $i completed
done
