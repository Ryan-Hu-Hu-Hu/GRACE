from CLEAN.utils import *
import os

csv_to_fasta("./data/dCA.csv", "./data/dCA.fasta")
retrive_esm1b_embedding("dCA")

###########Inference with max-separation
from CLEAN.infer import infer_maxsep
train_data = "split100"
test_data = "dCA"
infer_maxsep(train_data, test_data, report_metrics=False, pretrained=True)

