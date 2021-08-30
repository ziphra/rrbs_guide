#!/bin/bash
#SBATCH --job-name=ffgctest
#SBATCH --account=project_2003821
#SBATCH --output=ffgctest_output.txt
#SBATCH --error=ffgctest_error.txt
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G
#SBATCH --partition=small
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load biokit

export PATH=$PATH:/scratch/project_2003846/test_bismark/TrimGalore-0.6.6/
export PATH=$PATH:/scratch/project_2003846/test_bismark/Bismark-0.22.3/

export a=`pwd`
export b=`basename $a`
export x=_$b


mkdir ./output_quality_raw${x}/

ls data${x} > samples_raw${x}

sed 's/......$//' samples_raw${x} > samples${x}

for sample in `cat samples${x}`
do
    #fastqc raw data
    mkdir ./output_quality_raw${x}/fastqc_${sample}
    fastqc -o ./output_quality_raw${x}/fastqc_${sample} ./data${x}/${sample}.fastq
    
    trim_galore -rrbs --illumina -o trimmed_${sample} -fastqc ./data${x}/${sample}.fastq
    
    # bismark
    # alignment
    bismark -q --un --ambiguous -o ./bismark_output${x}/ ../refgen/ ./trimmed_${sample}/${sample}_trimmed.fq

    # Extract methylated sites
    bismark_methylation_extractor -s --bedGraph --counts --cytosine_report --zero_based --genome_folder ../refgen/ --output ./meth${x}/ ./bismark_output${x}/${sample}_trimmed_bismark_bt2.bam

done




