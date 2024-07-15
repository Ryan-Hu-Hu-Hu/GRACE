#!/usr/bin/env python
# coding: utf-8

# In[30]:


import json
import ast
import os

def read_fixed_positions(file_path):
    data = {}
    current_key = None
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith('>'):
                current_key = line[1:]
                data[current_key] = []
            elif line and current_key is not None:
                positions = ast.literal_eval(line)
                data[current_key].extend(positions)
    return data


def update_fixed_positions(input_file, output_file, fixed_positions):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            data = json.loads(line)
            for key in data.keys():
                if key in fixed_positions:
                    data[key]['A'] = fixed_positions[key]
            outfile.write(json.dumps(data) + '\n')

# Read the Fixed_positions.txt file
fixed_positions = read_fixed_positions(os.path.abspath(os.getcwd())+"/helper_scripts/Fixed_positions.txt")
# Update the outputPDB_fixed_pos.jsonl file
update_fixed_positions(os.path.abspath(os.getcwd())+"/data/ProteinMPNN_result/dCA_fixed_pos.jsonl", os.path.abspath(os.getcwd())+"/data/ProteinMPNN_result/updated_dCA_fixed_pos.jsonl", fixed_positions)


# In[ ]:




