#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os

def split_sequences(input_file, output_dir):
    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    with open(input_file, 'r') as f:
        lines = f.readlines()

    for i in range(0, len(lines), 2):
        header = lines[i].strip()
        sequence = ''.join(lines[i+1:i+2])

        output_file = os.path.join(output_dir, f"{header[1:]}.fasta")

        with open(output_file, 'w') as f:
            f.write(header + '\n')
            #formatted_sequence = '\n'.join([sequence[j:j+79] for j in range(0, len(sequence), 79)])
            #f.write(formatted_sequence)
            f.write(sequence)


# Specify the input file and output directory
input_file = os.getcwd()+'/data/solubility_result/dCA.fasta'
output_dir = os.getcwd()+'/helper_scripts/SPOT_Contact_inputs/'


# Call the function to split sequences
split_sequences(input_file, output_dir)


