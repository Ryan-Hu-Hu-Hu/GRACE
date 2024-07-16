#!/usr/bin/env python
# coding: utf-8

# In[57]:


import os
import numpy as np
import pandas as pd
from Bio import SeqIO
from pathlib import Path

def data_prepare(rows,sequence_prefix):
    sequence = []
    sequence_name = []
    sequence_number_counter = 1
    row_num = 0
    backup = []
    
    for i in range(len(rows)-2):
        backup.append(rows[i+2])

    for row in backup:
        if row_num < len(rows):
            if (row_num%2) == 0:
                sequence_name.append(str(sequence_prefix)+'_'+str(sequence_number_counter))
                sequence_number_counter += 1
            if (row_num%2) == 1:
                sequence.append(row)
            row_num += 1

    df = pd.DataFrame(sequence_name, columns = ['sequence_name'])
    df2 = pd.DataFrame(sequence, columns = ['sequence'])
    final_data = pd.concat([df,df2],axis = 1)
    
    with open(os.getcwd()+'/helper_scripts/seq_result/'+sequence_prefix+'.fasta','w') as OUTfile:
        for i in range(int(row_num/2)):
            OUTfile.write('>'+final_data['sequence_name'][i]+'\n'+final_data['sequence'][i])

    row_num = 0
    return final_data
            
def combine_fasta_to_tsv(input_dir, output_file):
    entries = []
    fasta_files = [f for f in os.listdir(input_dir) if f.endswith('.fasta')]

    for fasta_file in fasta_files:
        file_path = os.path.join(input_dir, fasta_file)
        sequences = SeqIO.parse(file_path, 'fasta')
        for record in sequences:
            entry = [record.id, '1.1.1.1', str(record.seq)]
            entries.append(entry)

    with open(output_file, 'w') as file:
        file.write("Entry\tEC_number\tSequence\n")
        for entry in entries:
            file.write("\t".join(entry) + "\n")

def makefile(final_data, sequence_prefix):
    final_data.to_fasta(sequence_prefix+".fasta", encoding='utf-8', index=False)
            
            
# Extract sequences and create FASTA files
input_dir =  os.getcwd()+'/helper_scripts/seqs/'
output_dir = os.getcwd()+'/helper_scripts/seq_result/'
os.makedirs(output_dir, exist_ok=True)

for input_file in os.listdir(input_dir):
    if input_file.endswith('.fa'):
        input_path = os.path.join(input_dir, input_file)
        sequence_prefix = Path(input_path).stem
        with open(input_path, 'r') as INfile:
            rows = INfile.readlines()
            final_data = data_prepare(rows, sequence_prefix)

# Combine FASTA files into a single TSV file
combine_fasta_to_tsv(output_dir, output_dir+'dCA.csv')

