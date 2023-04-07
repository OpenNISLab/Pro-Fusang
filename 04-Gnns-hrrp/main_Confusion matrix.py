import numpy
import numpy as np

import os
import scipy.io as scio

from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt



pred_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\target_pred\target_pred_HRRP.mat'
ztest_data_label = scio.loadmat(pred_label_file_path)
# print(ztest_data_label)
y_softmax = np.array(ztest_data_label['target_pred'])
y_pred = np.argmax(y_softmax, axis=1)

# test_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\target_pred\thing_Real_label.mat'
# test_label_file_path = scio.loadmat(test_label_file_path)
# print(ztest_data_label)
# y_true = np.array(test_label_file_path['thing_Real_label'])+1

test_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\target_pred\24-newlabel-1m-Autothreshold1\Fusang_TU_HRRP_graph_labels.txt'
y_true = numpy.loadtxt(test_label_file_path)
y_true = y_true-1


C = confusion_matrix(y_true, y_pred) # 可将'1'等替换成自己的类别，如'cat'。
C_mat_norm = C.astype('float') / C.sum(axis=1)[:, np.newaxis]
C_mat_norm = np.around(C_mat_norm, decimals=2)

plt.figure(figsize=(24,24))
# sns.heatmap(C_mat_norm, annot=True, cmap='Blues')

plt.matshow(C_mat_norm, cmap=plt.cm.Blues) # 根据最下面的图按自己需求更改颜色
# plt.colorbar()

for i in range(len(C)):
    for j in range(len(C)):
        plt.annotate(C[j, i], xy=(i, j), horizontalalignment='center', verticalalignment='center')

#归一化
# for i in range(len(C)):
#     for j in range(len(C)):
#         plt.annotate(C_mat_norm[j, i], xy=(i, j), horizontalalignment='center', verticalalignment='center')


indices = range(len(C))
# plt.tick_params(labelsize=15) # 设置左边和上面的label类别如0,1,2,3,4的字体大小。
plt.xticks(indices, ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)', '(j)', '(k)', '(l)', '(m)', '(n)', '(o)', '(p)', '(q)', '(r)', '(s)', '(t)', '(u)', '(v)', '(w)', '(x)'])
plt.yticks(indices, ['Metal drum1(a)', 'Metal drum1(b)', 'Ceramic mug(c)', 'Glass cup1(d)', 'Glass cup2(e)', 'Plastic cup(f)', 'Winebottle(g)', 'Fire extinguisher(h)', 'Bucket(i)', 'Phone(j)', 'Pad(k)', 'Keyboard(l)', 'Host(m)', 'Tissue box(n)', 'Router(o)','Laptop(p)','Paper box1(q)','Paper box2(r)', 'Wood board(s)','Flat display(t)','Curved display(u)','Teapot(v)','Microwave oven(w)','Toaster(x)'])

# plt.ylabel('True label')
# plt.xlabel('Predicted label')
# plt.tight_layout()
plt.ylabel('True label', fontdict={'family': 'Arial', 'size': 12}) # 设置字体大小。
plt.xlabel('Predicted label', fontdict={'family': 'Arial', 'size': 12})
# plt.xticks(range(0,5), labels=['a','b','c','d','e']) # 将x轴或y轴坐标，刻度 替换为文字/字符
# plt.yticks(range(0,5), labels=['a','b','c','d','e'])
plt.show()
