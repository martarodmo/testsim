if [ "$#" -eq 1 ]
then
    sampleid=$1
    echo "Running cutadapt..."
    mkdir -p $WD/log/cutadapt
    mkdir -p $WD/out/cutadapt
    cutadapt -m 20 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o $WD/out/cutadapt/${sampleid}_1.trimmed.fastq.gz -p $WD/out/cutadapt/${sampleid}_2.trimmed.fastq.gz $WD/data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz > $WD/log/cutadapt/${sampleid}.log
    echo
    echo "Running FastQC..."
    mkdir -p $WD/out/fastqc
    fastqc -o $WD/out/fastqc data/${sampleid}*.fastq.gz
    echo
    echo "Running STAR index..."
    mkdir -p $WD/res/genome/star_index
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $WD/res/genome/star_index/ --genomeFastaFiles $WD/res/genome/ecoli.fasta --genomeSAindexNbases 9
    echo
    echo "Running STAR alignment..."
    mkdir -p $WD/out/star/${sampleid}
    STAR --runThreadN 4 --genomeDir $WD/res/genome/star_index/ --readFilesIn $WD/out/cutadapt/${sampleid}_1.trimmed.fastq.gz $WD/out/cutadapt/${sampleid}_2.trimmed.fastq.gz --readFilesCommand zcat --outFileNamePrefix $WD/out/star/${sampleid}/
    echo
else
    echo "Usage: $0 <sampleid>"
    exit 1
fi
