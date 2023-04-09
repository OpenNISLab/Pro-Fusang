
"""
    Make 'Branches' Features for Fusang System
    designed by HGR 2022.11.17

    Reference:
    This version builds on maketree_process_3.0 and adds automation to read the data and generate the tree.
"""

import json
import os

import scipy.io as scio


"""
    Function Definition
"""
def make_bin_tree(extremum, indexs, edges, id, id2extremum):

    if len(indexs) == 1:
        if len(extremum) != 0:
            father_id = (id - 1) // 2
            edges.append([father_id, id])
            id2extremum[id] = extremum[0]
        return
    elif len(extremum) == 0:
        return
    elif id != 0:
        father_id = (id - 1) // 2
        edges.append([father_id, id])
        id2extremum[id] = -1
    else:
        id2extremum[id] = -1
    split_index = len(indexs) // 2
    left_indexs = indexs[:split_index]
    right_indexs = indexs[split_index:]
    split_extremum_index = len(extremum)
    for i, ext in enumerate(extremum):
        if ext > indexs[split_index - 1]:
            split_extremum_index = i
            break
    left_extremum = extremum[:split_extremum_index]
    right_extremum = extremum[split_extremum_index:]

    make_bin_tree(left_extremum, left_indexs, edges, (id + 1) * 2 - 1, id2extremum) ## Recurse left subtree
    make_bin_tree(right_extremum, right_indexs, edges, (id + 1) * 2, id2extremum) ## Recurse right subtree



"""
    Main function
"""


"""
    Load training data
"""
# data_colm_path = r'G:\Github-Desktop\Pro-Fusang\00_datasets\20230407_hrrp_formants_dataset\generateModel_data\columnNumber\1_0deg'
# data_valu_path = r'G:\Github-Desktop\Pro-Fusang\00_datasets\20230407_hrrp_formants_dataset\generateModel_data\ExtremeValues\1_0deg'


"""
    Load test data
"""
data_colm_path = r'G:\Github-Desktop\Pro-Fusang\00_datasets\20230407_hrrp_formants_dataset\ztest_system_data\columnNumber\1_0deg'
data_valu_path = r'G:\Github-Desktop\Pro-Fusang\00_datasets\20230407_hrrp_formants_dataset\ztest_system_data\ExtremeValues\1_0deg'


"""
    Make 'Branches' Features
"""
file_num = 0
value_n = 0 # According to the N column number file to correspond to the N value
for root, dirs, file_list in os.walk(data_colm_path):
    for file_name in file_list:
        extremum_data = []
        value_data = []

        print(file_name)
        file_path = os.path.join(data_colm_path, file_name)
        data1 = scio.loadmat(file_path)# Take the column number
        for k in data1.values():
            extremum_data.append(k)

        value_files = os.listdir(data_valu_path)
        value_file_name = value_files[value_n]
        print(value_file_name)
        file_path = os.path.join(data_valu_path, value_file_name)
        data2 = scio.loadmat(file_path)# Take the maximum
        for k in data2.values():
            value_data.append(k)


        graphs = []
        for extremum, values in zip(extremum_data[3], value_data[3]):  # Fetching data
            extremum = extremum[0][0]
            values = values[0][0]
                # print(extremum)
                # print(values)
            edges = []
            id2extremum = {}
            make_bin_tree(extremum, list(range(128)), edges, 0, id2extremum)
            id2value = {}  # Retrieve the attributes of the nodes from their indices
            for k, v in id2extremum.items():
                if v == -1:
                    id2value[k] = 0
                else:
                    for i, ext in enumerate(extremum):
                        if ext == id2extremum[k]:
                            id2value[k] = 0
            graphs.append({
                "id2value": id2value,
                "edges": edges
            })
            # print(graphs)


        save_dir = "graphs"
        os.makedirs(save_dir, exist_ok=True)
        save_name = file_name.split("/")[-1].split(".")[0]
        save_path = os.path.join(save_dir, save_name + ".json")
        with open(save_path, "w") as f:
            json.dump(graphs, f)

        value_n = value_n + 1








