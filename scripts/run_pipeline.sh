#########################################################################################################
# Creación y activación de un nuevo ambiente
# 	conda create -y --name ambiente_ejercicio_1
# 	conda activate ambiente_ejercicio_1
# Establecer directorio de trabajo:
#	export WD=<ruta_del_directorio>
#		por ejemplo: export WD=`pwd`
# Comando de ejecución:
#	bash scripts/run_pipeline.sh >  log/run_pipeline.out 2>&1
# Exportación del ambiente
#	mkdir -p envs
#	conda env export > envs/rna-seq.yaml
#########################################################################################################

echo "###########################################"
echo "# CLEARING Working Directory (`echo $WD`)..."
echo "###########################################"

rm -r log/cutadapt 2>/dev/null
rm -r res/genome 2>/dev/null
rm -r out 2>/dev/null
rm -r envs 2>/dev/null
rm Log.out 2>/dev/null

echo "###########################################"
echo "# DOWNLOADING..."
echo "###########################################"
mkdir -p res/genome
wget -O res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -k res/genome/ecoli.fasta.gz
rm res/genome/ecoli.fasta.gz


echo "###########################################"
echo "# GENERARING INDEX..."
echo "###########################################"
echo "Running STAR index..."
mkdir -p $WD/res/genome/star_index
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $WD/res/genome/star_index/ --genomeFastaFiles $WD/res/genome/ecoli.fasta --genomeSAindexNbases 9
echo

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
echo "# END"
echo "###########################################"
