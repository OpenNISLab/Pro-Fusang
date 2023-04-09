# Pro-Fusang
 This repository is an Open-source code for the paper "Graph-inspired Robust and Accurate Object Recognition on Commodity mmWave Devices". 
 

## Abstract
>Fusang is a novel object recognition system that only requires a single COTS mmWave Radar. It uses HRRP data and IQ 
samples of the reflected radar signals to achieve robust and accurate object recognition without relying on target augmentation 
or specialized optical hardware.

>The basic idea of Fusang is leveraging the large bandwidth of mmWave Radars to capture a unique set of fine-grained reflected responses generated by object shapes. Moreover, Fusang constructs two novel graphstructured features to robustly represent the reflected responses of
the signal in the frequency domain and IQ domain, and carefully designs a neural network to accurately recognize objects even in
different multipath scenarios. We have implemented a prototype of Fusang on a commodity mmWave Radar device. Our experiments with 24 different objects show that Fusang achieves a mean accuracy  of 97% in different multipath environments.

## Overview
![overview](./overview.png)

## Quick Start

### 1. Environment installation

#### 1.1 Setup Conda
```
# Conda installation

# For Windows
Download from official website: https://www.anaconda.com/

# For Linux
curl -o ~/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# For OSX
curl -o ~/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh

chmod +x ~/miniconda.sh    
./miniconda.sh  

source ~/.bashrc          # For Linux
source ~/.bash_profile    # For OSX
```

#### 1.2 Setup Python environment
```
# Clone GitHub repo
conda install git
git clone https://github.com/OpenNISLab/Pro-Fusang.git
cd Pro-Fusang

# Install python environment
cd 04_gnns_hrrp
conda env create -f environment.yml   

# Activate environment
conda activate envs
```

### 2. Download datasets 
We train and test Fusang with real data collected from our Ti-IWR1843 millimeter-wave radar. 
We pick 24 objects that are most frequently seen in the indoor environment (including multiple materials, 
curvatures and sizes) to evaluate the performance of Fusang, especially in offices and houses.
For each object, we rotate each object and collect the reflected signals at 9 angles (From
0-180 degrees, 20 degrees at per time) spanning distances of 1-5m. 
For the sake of reproducibility of our paper's results, we have also shared preprocessed radar datasets on GitHub, 
named as *00_datasets*, to replicate the results of Section 5.1 of the paper.
The total datasets (94.5GB uncompressed) used in the Fusang system can be downloaded from
[here](https://1drv.ms/u/s!AuVCef5KAvp_gQf8LDiXAiQEQ_dZ?e=vMbTm9 "All raw data").

### 3. Step-by-Step Instructions
*Disclaim: Although we have worked hard to ensure our code are robust, our tool remains a research 
prototype. It can still have glitches when using in complex, real-life settings. If you discover any bugs, 
please raise an issue, describing how you ran the program and what problem you encountered. 
We will get back to you ASAP. Thank you.*

#### 3.1 Data preprocessing
* Svmd precessing. The data received by radar is first decomposed by svmd to eliminate the influence of multipath noise.
```
# Run the IF_svmd.m in the 01_svmd_precessing
```
* Hrrp generation. The hrrp formants of the target reflected signal is extracted.
```
# Run the calculate_Extreme_values.m in the 02_hrrp_generation
```
Note: Above steps, Matlab R2021b or later is recommended.

#### 3.2 Feature extraction
After the filtered radar signal is obtained, the system extracts the energy distribution of target 
radar echo in IQ domain and Hrrp respectively.
* *Leaves* feature. It's used to represent the energy distribution of target curvature in IQ domain.
```
# Run the data_preprocessed.m in the 03_curvature_extraction
```
* *Branches* feature. It's used to represent the energy distribution of two-dimensional target profiles in hrrp data.
```
# Construct the graph feature based on hrrp
cd 04_gnns_hrrp/Fusang_graph_data_preprocess
python Fusang_maketree_process_4.0.py
python Fusang_maketu_process2TU.py
```
Note: The preprocessed data path in Section 3.1 needs to be provided with the above code.

#### 3.3 Training model
Gcn model.
```
# Run the main file (at the root of the 04_gnns_hrrp)
cd 04_gnns_hrrp
python main_Fusang_profile_classification_train.py --config 'configs/TUs_graph_classification_GCN_HRRP_train.json' # for CPU
python main_Fusang_profile_classification_train.py --gpu_id 0 --config 'configs/TUs_graph_classification_GCN_HRRP_train.json' # for GPU
```
The training and network parameters for each dataset and network is stored in a json file in the `configs/` directory.

LSTM model.
```
# Run the main file (at the root of the 05_rnns_iq)
cd 05_rnns_iq
python main_Fusang_curvature_classification_train.py 
```

Fusion model. At this stage, the confidence threshold of fusion module is determined by a large number 
of labeled training data.
```
# Run the System_test.m in the root of the 06_fusion_model
```


#### 3.4 Testing
The training set and test set are generated separately in the data preprocessing stage of Section 3.1 to ensure that the target 
to be tested has not been trained in advance.

Gcn model.
```
# Run the main file (at the root of the 04_gnns_hrrp)
cd 04_gnns_hrrp
python main_Fusang_profile_classification_test.py --config 'configs/TUs_graph_classification_GCN_HRRP_test.json' # for CPU
python main_Fusang_profile_classification_test.py --gpu_id 0 --config 'configs/TUs_graph_classification_GCN_HRRP_test.json' # for GPU
```

LSTM model.
```
# Run the main file (at the root of the 05_rnns_iq)
cd 05_rnns_iq
python main_Fusang_curvature_classification_test.py 
```

Fusion model. At this stage, the confidence threshold will be fixed and obtained through 
a large number of training experiments in the previous stage.
```
# Run the System_test.m in the root of the 06_fusion_model
```
