'''
Code function:
    Obtain the softmax matrix of the curvature prediction results of the trained curvature model on the target object.
'''

import tensorflow as tf
import numpy
import os
from keras.models import load_model
import scipy.io as scio


# Controls the GPU video memory usage
gpus = tf.config.experimental.list_physical_devices(device_type='GPU')
tf.config.experimental.set_virtual_device_configuration(
    gpus[0],
    [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=1024*5)]
)


# Number of neural network input angles
sample_len = 2


# Import the trained curvature model.
read_filepath_bestModel = r'Your local path\Fusang_dataset\trained_models' #File path of trained curvature model.
read_filename_bestModel = 'PDV_svmd_221119_sampleLength2_1.h5' #File name of the trained curvature model.
read_filepath_bestModel = os.path.join(read_filepath_bestModel , read_filename_bestModel)
model = load_model(read_filepath_bestModel)


# Import IF signal distribution feature data of target object in IQ domain
ztest_data_file_path = r'Your local path\Fusang_dataset\leaves_feature_dataset\lstm_dataset\ztestSystem_PDV_svmd_221119_1_0deg_allThing_rx1_1meter_1frame_sampleLength2.mat' #File path of the distribution characteristics of the target object's IF signal in the IQ domain
ztest_data = scio.loadmat(ztest_data_file_path)
test_data = ztest_data['temp_oneAngle_allThing'][:,0:sample_len]
X_test = numpy.reshape(test_data, (test_data.shape[0], sample_len, 1))


# The file path used to save the softmax matrix for prediction results
target_pred_filepath = r'Your local path\Fusang_dataset\trained_models\model_softmax_matrix\target_pred_iq.mat'


# Obtain and save the softmax matrix of model predictions
batch_size = 1
target_pred_iq = model.predict(X_test, batch_size=batch_size, verbose=0, steps=None)
scio.savemat(target_pred_filepath, dict(target_pred_iq=target_pred_iq))