# $1 is the input FASTQ file name, $2 is the base name for all output
bowtie2 --threads 4 --very-sensitive-local -x ensembl_hg38_clean -U $1 -S $2.primaryalign.raw.sam

samtools view -@4 -Sh $2.primaryalign.raw.sam | grep -e "^@" -e "XM:i:[012][^0-9]" | samtools view -bS -q 10 - > $2.primaryalign.bam

samtools flagstat $2.primaryalign.raw.sam > $2.primary.stat.txt
samtools flagstat $2.primaryalign.bam > $2.primary.filtered.stat.txt

samtools view -H $2.primaryalign.bam > $2.BAM.header

samtools view $2.primaryalign.bam | awk '{if($2==0) print $0;}' | cat $2.BAM.header - | extractSoftclippedRetain -l 20 - > $2.softclip_for.fastq.gz
samtools view $2.primaryalign.bam | awk '{if($2==16) print $0;}' | cat $2.BAM.header - | extractSoftclippedRetain -l 20 - | seqkit seq -r -p -v -t dna - | gzip - > $2.softclip_rev.fastq.gz

pigz -c -d -k $2.softclip_for.fastq.gz $2.softclip_rev.fastq.gz | pigz - > $2.softclip.fastq.gz

bowtie2 --threads 4 --very-sensitive-local -x ensembl_hg38_clean -U $2.softclip.fastq.gz -S $2.softclip.raw.sam

samtools view -@4 -Sh $2.softclip.raw.sam | grep -e "^@" -e "XM:i:[01][^0-9]" | samtools view -bS -q 10 - > $2.softclip.bam
samtools flagstat $2.softclip.raw.sam > $2.softclip.stat.txt
samtools flagstat $2.softclip.bam > $2.softclip.filtered.stat.txt

rm $2.MixturePortInput $2.MixtureUturnInput #$2.primaryalign.raw.sam $2.softclip.raw.sam
#If primary and softclip alignments are on the same chromosome ($2==$7) and are on same strand ($3==$6==0 or $3==$6==16), export to potential porting reads Input. Left and Right denotes softclip sides (on forward strand)
samtools view $2.softclip.bam | sed 's/|/\t/g' | awk '{if($2==$7 && $3==$6) print $0;}' | awk '$5~/^[2-9][0-9]S[0-9]{1,3}M$/ {print $0,"left";}' > $2.LeftPortInput
samtools view $2.softclip.bam | sed 's/|/\t/g' | awk '{if($2==$7 && $3==$6) print $0;}' | awk '$5~/^[0-9]{1,3}M[2-9][0-9]S$/ {print $0,"right";}' > $2.RightPortInput
#If primary and softclip alignments are on the same chromosome ($2==$7) and are on opposite strands ($3+$6==16), export to potential Uturn reads Input. Left and Right denotes softclip sides (on forward strand)
samtools view $2.softclip.bam | sed 's/|/\t/g' | awk '{if($2==$7 && $3+$6==16) print $0;}' | awk '$5~/^[2-9][0-9]S[0-9]{1,3}M$/ {print $0,"left";}' > $2.LeftUturnInput
samtools view $2.softclip.bam | sed 's/|/\t/g' | awk '{if($2==$7 && $3+$6==16) print $0;}' | awk '$5~/^[0-9]{1,3}M[2-9][0-9]S$/ {print $0,"right";}' > $2.RightUturnInput
#merge alignments for 
cat $2.LeftPortInput $2.RightPortInput | awk '$10~/^[0-9]{1,3}M$/ {print $0;}'> $2.MixPortInput
cat $2.LeftUturnInput $2.RightUturnInput | awk '$10~/^[0-9]{1,3}M$/ {print $0;}'> $2.MixUturnInput
