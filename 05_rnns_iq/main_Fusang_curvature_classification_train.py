'''
Code function:
    Train the curvature model.
Input data:
    The distribution characteristics of IF signal in IQ domain and corresponding curvature label.
Output data:
    Trained curvature model.
'''


import tensorflow as tf
import numpy
import os
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.layers import LSTM
from keras.utils import np_utils
from keras.callbacks import EarlyStopping,ModelCheckpoint
import scipy.io as scio
from sklearn.model_selection import train_test_split
from keras.layers.normalization import BatchNormalization


# Controls the GPU video memory usage
gpus = tf.config.experimental.list_physical_devices(device_type='GPU')
tf.config.experimental.set_virtual_device_configuration(
    gpus[0],
    [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=1024*5)]
)


# Number of neural network input angles
sample_len = 2


# The file path to save the model
save_filepath_bestModel = r'Your local path\Fusang_dataset\trained_models'#File path to save the trained curvature model
save_filename_bestModel = 'PDV_svmd_221119_sampleLength2_1.h5'#File name of the trained curvature model
save_filepath_bestModel = os.path.join(save_filepath_bestModel , save_filename_bestModel)


# Read the data set (containing the corresponding curvature label)
alldata_file_path = r'Your local path\Fusang_dataset\leaves_feature_dataset\lstm_dataset\generateModel_PDV_svmd_221119_1_0deg_allThing_rx1_1meter_6frame_sampleLength2.mat'#The file path to the data set
all_data_label = scio.loadmat(alldata_file_path)
all_label = all_data_label['temp_oneAngle_allThing'][:,sample_len] #Extract the curvature label
all_data = all_data_label['temp_oneAngle_allThing'][:,0:sample_len]#The feature data set of IF signal distribution in IQ domain is extracted


# Construct the training set and verification set
train_data, val_data, train_label, val_label = train_test_split(all_data, all_label, test_size=0.2, random_state=1 ,shuffle = True ,stratify = all_label)

X_train = numpy.reshape(train_data, (train_data.shape[0], sample_len, 1))
y_train = np_utils.to_categorical(train_label)

X_val = numpy.reshape(val_data, (val_data.shape[0], sample_len, 1))
y_val = np_utils.to_categorical(val_label)


# create and fit the model
batch_size = 128
epochs_num = 1000
early_stopping = EarlyStopping(monitor='val_accuracy', min_delta=0.0001, patience=10, mode='auto', restore_best_weights=True)
checkpointer = ModelCheckpoint(filepath=save_filepath_bestModel,monitor='val_accuracy', verbose=1, save_best_only=True,  save_weights_only=False,mode='auto',period=1)

model = Sequential()
model.add(LSTM(256, return_sequences=True,input_shape=(X_train.shape[1], X_train.shape[2])))
model.add(BatchNormalization())
model.add(LSTM(128))
model.add(Dense(y_train.shape[1], activation='softmax'))

model.compile(loss='categorical_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
model.fit(X_train, y_train, epochs=epochs_num, batch_size=batch_size,validation_data=(X_val,y_val), callbacks=[early_stopping , checkpointer],verbose=2)