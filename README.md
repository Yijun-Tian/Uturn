# Uturn
Identifying DNA U-turn from whole-genome sequencing reads. The DNA U-turn is a special DNA structure that aligns across postivie and negative strands. This project mainly uses two-step mapping approach to find this structure in next generation sequencing data.

## Prerequisition
The pipeline prerequisition includes bowtie2, gawk and SE-MEI (extractSoftclippedRetain) in PATH.
## Instructions of compiling SE-MEI
Download SE-MEI source code from Devon Ryan's repository. Make sure to include htslib submodule (f3e1602196bbf03f426dfb363a4841932a042194) using --recursive

`git clone --recursive https://github.com/dpryan79/SE-MEI.git`

Change source code in extractSoftclipped.c to retain first alignmentment information in the output FASTQ header. The new code was named "extractSoftclippedRetain.c"

`cp extractSoftclipped.c extractSoftclippedRetain.c`

Editing line 22 in extractSoftclippedRetain.c as below, and save

```
 fprintf(of, "@%s|%s|%i|%"PRId32"|", bam_get_qname(b), hdr->target_name[b->core.tid], b->core.flag, b->core.pos+1);
 for(j=0; j<b->core.n_cigar; j++) {
   fprintf(of, "%i%c", bam_cigar_oplen(cigar[j]), BAM_CIGAR_STR[bam_cigar_op(cigar[j])]);
   }
 fprintf(of, "\n");
```
Change Makefile accordingly

```
  all: compactRepeats extractSoftclipped compareGroups extractSoftclippedRetain
  extractSoftclippedRetain: htslib extractSoftclippedRetain.o
	         $(CC) $(OPTS) $(INCLUDES) -o extractSoftclippedRetain extractSoftclippedRetain.o htslib/libhts.a -lz -lpthread -llzma -lbz2
  clean:
	       rm -f *.o compactRepeats extractSoftclipped compareGroups extractSoftclippedRetain
```
Make and make sure extractSoftclippedRetain runs smoothly

## How to run the pipeline ??


   





