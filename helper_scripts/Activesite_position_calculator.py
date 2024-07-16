#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import Bio
from Bio import SeqIO
from Bio import BiopythonWarning
import warnings
from pathlib import Path

# In[3]:


def extract(files):
    file_type = ".pdb"
    A = []
    for file in files:
        if file.endswith(file_type):
            #A.append("../data/RFdiffusion_result/"+file)
            A.append(os.path.abspath(os.getcwd())+"/data/RFdiffusion_result/"+file)
    #print("Files contained: ",A)
    return A


# In[4]:


def catch_fixed_position(target):
    active_sites = ['WGY','LR','LNNGHAFNVEFDDS','RLIQFHFHWGS','GSEHT', 'KYAAELHLVHW','DFGKAV','LAVLGIFL','KGKS','ES','SETTPPLLECV','WIVL','LMVDNWR']
    
    
    for record in SeqIO.parse(target, "pdb-atom"):
        #print("Sequence: \n",record.seq,"\n")
        #print("Location of active sites: ")
        fixed_position = [] 
        for active_site in active_sites:

            if record.seq.find(active_site) != -1:
                #print(record.seq.find(active_site))

                for i in range(record.seq.find(active_site) +1 , record.seq.find(active_site) + len(active_site) + 1):
                    #print(i)
                    fixed_position.append(i)
    with open(os.getcwd()+"/helper_scripts/Fixed_positions.txt",'a') as Outfile:
        #Outfile.write(">File: " + target)
        #Outfile.write("\nfixed_postion: \n")
        Outfile.write(">"+Path(target).stem)
        Outfile.write("\n"+str(fixed_position)+"\n")
        #Outfile.write(str(fixed_position) + "\n\n")


# In[5]:


#Main
#For all the files
#home_dir = r"../data/RFdiffusion_result/"
cwd = os.getcwd()
print(cwd)
home_dir=os.path.abspath(cwd)+"/data/RFdiffusion_result/"
#home_dir = r"../data/"
all_files = os.listdir(home_dir)
working_files = extract(all_files)

for file in working_files:
    warnings.simplefilter('ignore', BiopythonWarning)
    catch_fixed_position(file)


# In[6]:





# In[ ]:




