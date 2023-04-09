import json
import os

save_dir = "G:\Github-Desktop\Pro-Fusang\\04_gnns_hrrp\Modified_TU_HRRP\Modified_TU_HRRP"
graphs_dir = "graphs"

os.makedirs(save_dir, exist_ok=True)
file_list = os.listdir(graphs_dir)

total_graphs = [] # Aggregate the graphs in each object file into an array
for i, file_name in enumerate(file_list):
    file_path = os.path.join(graphs_dir, file_name)
    with open(file_path, "r") as f:
        graphs = json.load(f)

    for graph in graphs:
        graph["cls_id"] = i + 1 # Index of graph class

    total_graphs.extend(graphs)

print(len(total_graphs))
# Graph initialization
# Nodes are numbered starting from 1
now_node_id = 1
ds_a = [] # Connection Relationship Between Nodes in Binary Tree Graph
ds_graph_indicator = []     # The class of the current node
ds_graph_labels = []        # The class of current graph
ds_node_attributes = []     # The properties of the current node


Graph_label = [1, 2, 21, 9, 10, 3, 8, 20, 4, 5, 13, 11, 12, 16, 23, 17, 18, 6, 15, 22, 14, 24, 7, 19]  # Graph labels

for graph_i, graph in enumerate(total_graphs):
    id2value = graph["id2value"]
    edges = graph["edges"]
    cls_id = graph["cls_id"]

    # The number of nodes in the current graph
    node_num = len(id2value.keys())
    # The current graph is sorted by node number
    id_values = sorted(id2value.items(), key=lambda x:x[0])


    ds_graph_labels.append(Graph_label[cls_id-1]) # Label objects according to the array Graph_label

    new_node_id_map = {}
    for node_id, value in id_values:
        new_node_id_map[node_id] = now_node_id
        now_node_id += 1
    for node_id, value in id_values:
        ds_graph_indicator.append(graph_i + 1)
        ds_node_attributes.append(value)
    for edge in edges:
        ds_a.append((new_node_id_map[str(edge[0])], new_node_id_map[str(edge[1])]))
    assert now_node_id - 1 == len(ds_graph_indicator)

# Load datasets
########### Generate hrrp graph training datasets #####################
#
with open(os.path.join(save_dir, "Modified_TU_HRRP_A.txt"), "w") as f:
    for edge in ds_a:
        f.write("%d, %d\n" % (edge[0], edge[1]))
with open(os.path.join(save_dir, "Modified_TU_HRRP_graph_indicator.txt"), "w") as f:
    for graph_id in ds_graph_indicator:
        f.write("%d\n" % (graph_id))
with open(os.path.join(save_dir, "Modified_TU_HRRP_graph_labels.txt"), "w") as f:
    for cls_id in ds_graph_labels:
        f.write("%d\n" % (cls_id))
with open(os.path.join(save_dir, "Modified_TU_HRRP_node_labels.txt"), "w") as f:
    for value in ds_node_attributes:
        f.write("%d\n" % (value))

################## Generate hrrp graph testing datasets #####################

# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_A.txt"), "w") as f:
#     for edge in ds_a:
#         f.write("%d, %d\n" % (edge[0], edge[1]))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_graph_indicator.txt"), "w") as f:
#     for graph_id in ds_graph_indicator:
#         f.write("%d\n" % (graph_id))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_graph_labels.txt"), "w") as f:
#     for cls_id in ds_graph_labels:
#         f.write("%d\n" % (cls_id))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_node_labels.txt"), "w") as f:
#     for value in ds_node_attributes:
#         f.write("%d\n" % (value))