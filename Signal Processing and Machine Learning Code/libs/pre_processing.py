import os
import sys
import numpy as np
from scipy import signal
from scipy.signal import resample


# Normalize data
def data_normalize(data_in):
  min_in = data_in.min(axis=1,keepdims=True)
  max_in = data_in.max(axis=1,keepdims=True)
  data_out = (data_in-min_in)/(max_in-min_in)
  return data_out

# Normalize data
def data_normalize_standardscaler(data_in):
  data_out = np.zeros_like(data_in)
  for i in range(data_in.shape[0]):
    if data_in.ndim == 3:
      data_out[i,:,0] = (data_in[i,:,0] - np.mean(data_in[i,:,0]))/np.std(data_in[i,:,0])
    else:
      data_out[i,:] = (data_in[i,:] - np.mean(data_in[i,:]))/np.std(data_in[i,:])
  return data_out

# Upsample PPG Data
def up_sampling_data(data_in,new_len):
  data_upsample = np.zeros((data_in.shape[0],new_len,1))
  for i in range(data_in.shape[0]):
    data_to_upsample = data_in[i,:,0]
    data_to_upsample = (data_to_upsample-min(data_to_upsample))/(max(data_to_upsample)-min(data_to_upsample))
    data_upsample[i,:,0] = resample(data_to_upsample,new_len)
  return data_upsample