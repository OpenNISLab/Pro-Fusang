import numpy
import numpy as np
import matplotlib.pyplot as plt
import scipy.io as scio

from sklearn.metrics import confusion_matrix  # 生成混淆矩阵的函数

'''
首先是从结果文件中读取预测标签与真实标签，然后将读取的标签信息传入python内置的混淆矩阵矩阵函数confusion_matrix(真实标签,
预测标签)中计算得到混淆矩阵，之后调用自己实现的混淆矩阵可视化函数plot_confusion_matrix()即可实现可视化。
三个参数分别是混淆矩阵归一化值，总的类别标签集合，可是化图的标题
'''


def plot_confusion_matrix(cm, labels_name, title):
    np.set_printoptions(precision=2)
    # print(cm)
    # plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)  # 在特定的窗口上显示图像
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title(title, fontdict={'family': 'Arial', 'size': 16})  # 图像标题
    plt.colorbar()
    num_local = np.array(range(len(labels_name)))
    plt.xticks(num_local, labels_name, size=10, rotation=0)  # 将标签印在x轴坐标上
    plt.yticks(num_local, labels_name, size=10)  # 将标签印在y轴坐标上
    # plt.ylabel('True label')
    plt.xlabel('Predicted label', fontdict={'family': 'Arial', 'size': 16})
    plt.ylabel('True label', fontdict={'family': 'Arial', 'size': 16})
    # show confusion matrix
    plt.savefig('./Fusang-acc.pdf', bbox_inches='tight', format='pdf')
    # plt.savefig('./' + title + '.pdf', bbox_inches='tight', format='pdf')
    plt.show()

# gt = []
# pre = []
# with open("result.txt", "r") as f:
#     for line in f:
#         line = line.rstrip()  # rstrip() 删除 string 字符串末尾的指定字符（默认为空格）
#         words = line.split()
#         pre.append(int(words[0]))
#         gt.append(int(words[1]))

pred_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\systemresult\20221119_systemResult_PDm2_Atf1\PDm2_Atf1\sample_system_pred_label.mat'
ztest_data_label = scio.loadmat(pred_label_file_path)
y_tmp = np.array(ztest_data_label['sample_system_pred_label'])
y_pred = y_tmp[:] #提取数组的第一个元素，因为数组一共就一个元素，所以相当于全取

pred_label_file_path = r'F:\github-project\Graph-learning\GNNs\benchmarking-gnns-master\benchmarking-gnns-master\systemresult\20221119_systemResult_PDm2_Atf1\PDm2_Atf1\thing_Real_label.mat'
ztest_data_label = scio.loadmat(pred_label_file_path)
y_tmp_1 = np.array(ztest_data_label['thing_Real_label'])
y_true = y_tmp_1[:] #提取数组的第一个元素，因为数组一共就一个元素，所以相当于全取


cm = confusion_matrix(y_true, y_pred)  # 计算混淆矩阵
print('type=', type(cm))
cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]  # 归一化
labels = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)', '(j)', '(k)', '(l)', '(m)', '(n)', '(o)', '(p)', '(q)', '(r)', '(s)', '(t)', '(u)', '(v)', '(w)', '(x)']

plot_confusion_matrix(cm, labels, 'Accuracy = 98.2%')  # 绘制混淆矩阵图，可视化
