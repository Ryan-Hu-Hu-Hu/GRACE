## GRACE: Generative Renaissance in Artificial Computational Enzyme Design

This is the automated workflow of translational design for de novo enzyme generation

In this workflow, several models and conda environments are integrated, please download the following models and set up the corresponding conda environment: 
1. [RFdiffusion] (https://github.com/RosettaCommons/RFdiffusion)
2. [ProteinMPNN] (https://github.com/dauparas/ProteinMPNN)
3. [CLEAN] (https://github.com/tttianhao/CLEAN)
4. [SoDoPe] (https://github.com/Gardner-BinfLab/SoDoPE_paper_2020/tree/master/SWI)
5. [NetSolP] (https://services.healthtech.dtu.dk/services/NetSolP-1.0/)
6. [GraphSol] (https://github.com/jcchan23/GraphSol)

Note: After testing GraphSol, we found that there is **no need** to set protein sequence of 80 amino acid letters within one row. Besides, **this setting will cause the error in SPOT-Contact-Local**, which serves as the feature map generator in GraphSol  


To execute the de novo enzyme workflow:
```Bash
chmod +x Automated_script.sh
./Automated_script.sh
```