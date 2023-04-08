import json
import os

save_dir = "results"
graphs_dir = "graphs"

os.makedirs(save_dir, exist_ok=True)
file_list = os.listdir(graphs_dir)

total_graphs = [] #将所有的文件里的图汇总在一个数组里
for i, file_name in enumerate(file_list):
    file_path = os.path.join(graphs_dir, file_name)
    with open(file_path, "r") as f:
        graphs = json.load(f)

    for graph in graphs:
        graph["cls_id"] = i + 1 #加入图类别的id

    total_graphs.extend(graphs)

print(len(total_graphs))
# 初始化节点id
# 节点从 1 开始编号
now_node_id = 1
ds_a = [] # m, 点和点的链接关系
ds_graph_indicator = []     # 当前节点属于哪个图
ds_graph_labels = []        # 图属于哪个类
ds_node_attributes = []     # 当前节点的属性
# 处理每一个图

# Graph_label = [1, 2, 21, 9, 10, 3, 8, 20, 4, 5, 13, 11, 12, 16, 23, 17, 18, 6, 15, 22, 14, 24, 7, 19] #静态实验

Graph_label = [1, 2, 21, 9, 10, 3, 8, 20, 4, 5, 13, 11, 12, 16, 23, 17, 18, 6, 15, 22, 14, 24, 7, 19] #动态实验


# 动态实验打标签 待测物体：显示器
# Graph_label = [20, 20, 20]

for graph_i, graph in enumerate(total_graphs):
    id2value = graph["id2value"]
    edges = graph["edges"]
    cls_id = graph["cls_id"]   # 当前图的类别

    # 当前图的节点个数
    node_num = len(id2value.keys())
    # 当前图按节点号排序
    id_values = sorted(id2value.items(), key=lambda x:x[0])
    # 为 ds_graph_labels 添加一行类别信息

    ds_graph_labels.append(Graph_label[cls_id-1]) #根据数组Graph_label来打物体标签
    # ds_graph_labels.append(cls_id) #根据图的类别打物体标签
    # 为 ds_graph_indicator 和 ds_node_attributes 添加信息
    # 构造 id 映射关系
    new_node_id_map = {}
    for node_id, value in id_values:
        new_node_id_map[node_id] = now_node_id
        now_node_id += 1
    for node_id, value in id_values:
        ds_graph_indicator.append(graph_i + 1)
        ds_node_attributes.append(value)
    # 为 ds_a 添加信息
    for edge in edges:
        ds_a.append((new_node_id_map[str(edge[0])], new_node_id_map[str(edge[1])]))
    assert now_node_id - 1 == len(ds_graph_indicator)

# 写进文件
###########生成训练集#####################
#
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Modified_TU_HRRP\Modified_TU_HRRP\Modified_TU_HRRP_A.txt"), "w") as f:
#     for edge in ds_a:
#         f.write("%d, %d\n" % (edge[0], edge[1]))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Modified_TU_HRRP\Modified_TU_HRRP\Modified_TU_HRRP_graph_indicator.txt"), "w") as f:
#     for graph_id in ds_graph_indicator:
#         f.write("%d\n" % (graph_id))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Modified_TU_HRRP\Modified_TU_HRRP\Modified_TU_HRRP_graph_labels.txt"), "w") as f:
#     for cls_id in ds_graph_labels:
#         f.write("%d\n" % (cls_id))
# with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Modified_TU_HRRP\Modified_TU_HRRP\Modified_TU_HRRP_node_labels.txt"), "w") as f:
#     for value in ds_node_attributes:
#         f.write("%d\n" % (value))

##################生成测试集#####################

with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_A.txt"), "w") as f:
    for edge in ds_a:
        f.write("%d, %d\n" % (edge[0], edge[1]))
with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_graph_indicator.txt"), "w") as f:
    for graph_id in ds_graph_indicator:
        f.write("%d\n" % (graph_id))
with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_graph_labels.txt"), "w") as f:
    for cls_id in ds_graph_labels:
        f.write("%d\n" % (cls_id))
with open(os.path.join(save_dir, "G:\Aurora Projects\Pro-Fusang\Gnns-hrrp\Fusang_TU_HRRP\Fusang_TU_HRRP\Fusang_TU_HRRP_node_labels.txt"), "w") as f:
    for value in ds_node_attributes:
        f.write("%d\n" % (value))