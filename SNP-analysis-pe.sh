#! /bin/sh

echo "Script usage SNP-analysis-pe.sh input prefix fastq1 fastq2"
# Read input file

#echo "Enter the input reference filename:"
input="$1"

#echo "Enter the output prefix (e.g. reference-mutant)"
prefix="$2"

#echo "Enter the fastq file 1"
fastq1="$3"

#echo "Enter the fastq file 2"
fastq2="$4"

#gzipping
#gzip -d *.gz ;

# Bowtie2 alignment
bowtie2-build $input $prefix ;
bowtie2 -x $prefix -1 $fastq1 -2 $fastq2 -S $prefix.sam ;


#convert sam to bam
samtools view -Sb $prefix.sam -o $prefix.bam ;


#sort the bam file
samtools sort $prefix.bam -o "$prefix"-sorted.bam ;

#index the bam file
samtools index "$prefix"-sorted.bam ;


#create bcf file
samtools mpileup -f $input "$prefix"-sorted.bam > "$prefix".mpileup ;

#create vcf file
java -jar /usr/local/share/scripts/exec/VarScan.v2.3.9.jar pileup2snp "$prefix".mpileup --min-coverage 10 --min-var-freq 0.1 > "$prefix".snps ;
java -jar /usr/local/share/scripts/exec/VarScan.v2.3.9.jar pileup2snp "$prefix".mpileup --min-coverage 10 --min-var-freq 0.5 > "$prefix"-filtered.snps ;

echo "Done!"

exit 0
