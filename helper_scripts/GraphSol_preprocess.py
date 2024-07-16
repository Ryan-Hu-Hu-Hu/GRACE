#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os

def merge_files(output_dir, output_file):
    merged_content = ""
    for filename in os.listdir(output_dir):
        if filename.endswith(".fasta"):
            file_path = os.path.join(output_dir, filename)
            with open(file_path, 'r') as file:
                merged_content += file.read() 

    with open(output_dir+output_file, 'w') as merged_file:
        merged_file.write(merged_content)
        merged_file.close()




# Specify the input file and output directory
output_dir = os.getcwd()+'/helper_scripts/SPOT_Contact_inputs/'
output_file = 'dCA.fasta'

# Call the function to split sequences
merge_files(output_dir, output_file)

