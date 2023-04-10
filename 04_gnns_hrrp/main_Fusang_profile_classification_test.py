
"""
    GCN Nets for Fusang testing phase
    designed by HGR 2022.11.16

    Reference:
    [1]Benchmarking Graph Neural Networks
    Dwivedi V P, Joshi C K, Laurent T, et al. Benchmarking graph neural networks[J]. 2020.
    https://github.com/graphdeeplearning/benchmarking-gnns

    [2]GCN: Graph Convolutional Networks
    Thomas N. Kipf, Max Welling, Semi-Supervised Classification with Graph Convolutional Networks (ICLR 2017)
    http://arxiv.org/abs/1609.02907
"""


"""
    Importing Libs
"""
import dgl
import os
import numpy as np
import torch

import scipy.io as scio
import argparse, json

import torch.utils.data
from torch.utils.data import DataLoader

from data.data import LoadData # import dataset



"""
    GPU Setup
"""
device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
print(device)


"""
    Model Loading 
"""
model = torch.load(r"G:\Github-Desktop\Pro-Fusang\00_Fusang_dataset\trained_models\epoch_1028.pkl")
model = model.to(device)

"""
    Parameter Setting 
"""
parser = argparse.ArgumentParser()
parser.add_argument('--config', default='configs\TUs_graph_classification_GCN_HRRP_test.json')
parser.add_argument('--gpu_id', help="Please give a value for gpu id")
parser.add_argument('--model', help="Please give a value for model name")
parser.add_argument('--dataset', help="Please give a value for dataset name")
parser.add_argument('--out_dir', help="Please give a value for out_dir")
parser.add_argument('--seed', help="Please give a value for seed")
parser.add_argument('--epochs', help="Please give a value for epochs")
parser.add_argument('--batch_size', help="Please give a value for batch_size")
parser.add_argument('--init_lr', help="Please give a value for init_lr")
parser.add_argument('--lr_reduce_factor', help="Please give a value for lr_reduce_factor")
parser.add_argument('--lr_schedule_patience', help="Please give a value for lr_schedule_patience")
parser.add_argument('--min_lr', help="Please give a value for min_lr")
parser.add_argument('--weight_decay', help="Please give a value for weight_decay")
parser.add_argument('--print_epoch_interval', help="Please give a value for print_epoch_interval")
parser.add_argument('--L', help="Please give a value for L")
parser.add_argument('--hidden_dim', help="Please give a value for hidden_dim")
parser.add_argument('--out_dim', help="Please give a value for out_dim")
parser.add_argument('--residual', help="Please give a value for residual")
parser.add_argument('--edge_feat', help="Please give a value for edge_feat")
parser.add_argument('--readout', help="Please give a value for readout")
parser.add_argument('--kernel', help="Please give a value for kernel")
parser.add_argument('--n_heads', help="Please give a value for n_heads")
parser.add_argument('--gated', help="Please give a value for gated")
parser.add_argument('--in_feat_dropout', help="Please give a value for in_feat_dropout")
parser.add_argument('--dropout', help="Please give a value for dropout")
parser.add_argument('--layer_norm', help="Please give a value for layer_norm")
parser.add_argument('--batch_norm', help="Please give a value for batch_norm")
parser.add_argument('--sage_aggregator', help="Please give a value for sage_aggregator")
parser.add_argument('--data_mode', help="Please give a value for data_mode")
parser.add_argument('--num_pool', help="Please give a value for num_pool")
parser.add_argument('--gnn_per_block', help="Please give a value for gnn_per_block")
parser.add_argument('--embedding_dim', help="Please give a value for embedding_dim")
parser.add_argument('--pool_ratio', help="Please give a value for pool_ratio")
parser.add_argument('--linkpred', help="Please give a value for linkpred")
parser.add_argument('--cat', help="Please give a value for cat")
parser.add_argument('--self_loop', help="Please give a value for self_loop")
parser.add_argument('--max_time', help="Please give a value for max_time")
args = parser.parse_args()
with open(args.config) as f:
    config = json.load(f)

# model, dataset, out_dir
if args.model is not None:
    MODEL_NAME = args.model
else:
    MODEL_NAME = config['model']
if args.dataset is not None:
    DATASET_NAME = args.dataset
else:
    DATASET_NAME = config['dataset']

"""
    Data Loading 
"""
dataset = LoadData(DATASET_NAME)

test_loader = DataLoader(dataset.test, batch_size=1, shuffle=False, drop_last=False, collate_fn=dataset.collate)
print(test_loader)


"""
    Testing Model 
"""
from train.train_TUs_graph_classification import train_epoch_sparse as train_epoch, evaluate_network_sparse as evaluate_network

_, test_acc, test_sofxmax = evaluate_network(model, device, test_loader, 600)

print(test_acc)

"""
    Saving Data 
"""
target_pred_filepath = r'G:\Github-Desktop\Pro-Fusang\00_Fusang_dataset\trained_models\model_softmax_matrix\target_pred_hrrp.mat'
scio.savemat(target_pred_filepath, dict(target_pred=test_sofxmax))



#####################################################################The above code is all checked###########################################################################


















