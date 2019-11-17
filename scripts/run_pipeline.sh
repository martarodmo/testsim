# Establecer directorio de trabajo: export WD=<ruta_del_directorio>
# Comando de ejecución: bash scripts/run_pipeline.sh >>  log/run_pipeline.out 2>&1

rm -r log/cutadapt 2>/dev/null
rm -r res/genome 2>/dev/null
rm -r out 2>/dev/null
rm Log.out 2>/dev/null

echo "###########################################"
echo "# DOWNLOADING..."
echo "###########################################"
mkdir -p res/genome
wget -O res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -k res/genome/ecoli.fasta.gz
rm res/genome/ecoli.fasta.gz

# place here any commands that need to be run before analysing the samples
for sample in $(ls data/*.fastq.gz | cut -d "_" -f1 | sed 's:data/::' | sort | uniq);
do
	echo "###########################################"
	echo "# PROCESSING... $sample"
	echo "###########################################"
	bash scripts/analyse_sample.sh $sample
done;

echo "###########################################"
echo "# GENERATING REPORT..."
echo "###########################################"
mkdir -p out/multiqc
multiqc -o out/multiqc $WD
echo "###########################################"
echo "# EXPORTING ENVIRONMENT..."
echo "###########################################"
mkdir -p envs
conda env export > envs/rna-seq.yaml
