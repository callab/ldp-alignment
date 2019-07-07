#!/bin/bash
#PBS -N MultiStanFit
#PBS -l nodes=1:ppn=10,mem=32gb
#PBS -j oe
#PBS -t 1-59
#PBS -m abef


cd $PBS_O_WORKDIR
# execute program
Rscript ~/Desktop/ldp-alignment/stanscripts/subj${PBS_ARRAYID}script.R