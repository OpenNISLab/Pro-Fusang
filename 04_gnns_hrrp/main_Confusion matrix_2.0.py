import numpy
import numpy as np

import os
import scipy.io as scio

from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt

def plot_confusion_matrix(cm, labels_name, title):
    np.set_printoptions(precision=2)
    # print(cm)
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)  # 在特定的窗口上显示图像
    # plt.imshow(cm, interpolation='nearest')
    plt.title(title, fontdict={'family': 'Arial', 'size': 16})  # 图像标题
    # plt.colorbar()
    num_local = np.array(range(len(labels_name)))
    plt.xticks(num_local, labels_name, size=10, rotation=0)  # 将标签印在x轴坐标上
    plt.yticks(num_local, labels_name, size=10)
    # plt.yticks(num_local, ['Metal drum1(a)', 'Metal drum1(b)', 'Ceramic mug(c)', 'Glass cup1(d)', 'Glass cup2(e)', 'Plastic cup(f)', 'Winebottle(g)', 'Fire extinguisher(h)', 'Bucket(i)', 'Phone(j)', 'Pad(k)', 'Keyboard(l)', 'Host(m)', 'Tissue box(n)', 'Router(o)','Laptop(p)','Paper box1(q)','Paper box2(r)', 'Wood board(s)','Flat display(t)','Curved display(u)','Teapot(v)','Microwave oven(w)','Toaster(x)'], size=9)  # 将标签印在y轴坐标上
    # plt.ylabel('True label')
    plt.xlabel('Predicted label', fontdict={'family': 'Arial', 'size': 16})
    plt.ylabel('True label', fontdict={'family': 'Arial', 'size': 16})
    # show confusion matrix
    plt.savefig('./BS2-acc.pdf', bbox_inches='tight', format='pdf')
    plt.show()



pred_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\target_pred\24-newlabel-1m-Autothreshold1\target_pred_HRRP.mat'
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
labels = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)', '(j)', '(k)', '(l)', '(m)', '(n)', '(o)', '(p)', '(q)', '(r)', '(s)', '(t)', '(u)', '(v)', '(w)', '(x)']

plot_confusion_matrix(C, labels, 'Accuracy = 83.5%')  # 绘制混淆矩阵图，可视化
