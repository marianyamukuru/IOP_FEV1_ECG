# Import Libraries
# Import libraries
import tensorflow as tf
# Basic Imports
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import datetime
import math
from math import floor
import scipy as scipy
import librosa as lbr
import neurokit2 as nk
import pandas as pd
import plotly.express as px
import itertools
import graphviz
import gc

# Scikit-Learn and Scipy Modules
import seaborn as sns
import sklearn.decomposition
pca = sklearn.decomposition.PCA()
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, accuracy_score,f1_score,ConfusionMatrixDisplay
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import classification_report, mean_squared_error
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler
from sklearn import svm
from sklearn.inspection import permutation_importance
from sklearn.neighbors import KNeighborsClassifier
from sklearn.feature_selection import RFECV, RFE
from sklearn.metrics import roc_curve, auc, cohen_kappa_score
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_classif, mutual_info_classif, chi2
from sklearn.feature_selection import VarianceThreshold
from sklearn.feature_selection import SequentialFeatureSelector

from scipy import signal
from scipy.stats import linregress, pearsonr, chisquare, chi2
from scipy.signal import firwin, kaiser_atten, kaiser_beta, lfilter,detrend
from scipy.signal import savgol_filter,iirnotch,lfilter,butter,savgol_coeffs,freqz,find_peaks,resample,welch,periodogram,resample_poly,decimate

# Tensorflow
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras import datasets, layers, models, optimizers, regularizers
from tensorflow.keras.callbacks import ModelCheckpoint
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense,GRU,LSTM,Conv2D,Conv1D,Bidirectional,Reshape
from keras import backend as K

# ECG Modules
import biosppy

# Initialize Variables
Fs_resp = 20
Fs_ecg = 300

b_firfilter = signal.firwin(63, cutoff=1, window='tukey',fs=Fs_resp)


def get_subj_classes(y_class_in,y_subjects_in):
  if tf.is_tensor(y_class_in):
    y_in = y_class_in.numpy()
  else:
    y_in = y_class_in
  y_sub_in = y_subjects_in
  uniq_subj = np.unique(y_sub_in)
  yout_subj = np.zeros((len(uniq_subj),))-1000
  for i in range(len(uniq_subj)):
    idx_subj = np.argwhere(y_sub_in==uniq_subj[i])[:,0]
    yout_subj[i] = np.mean(y_in[idx_subj]).round()
  return yout_subj


# Combine the data for each subject
def get_per_subject_data(x_train_data_in,y_train_data_in,y_train_data_in_fvc,y_train_data_in_bmi,subject_list_in,computation = 'median'):
  # computation = 'median'
  # subject_list_in = y_train_subjects
  # x_train_data_in = x_train_feat
  # y_train_data_in = y_class

  unique_subjs = np.unique(subject_list_in)
  subject_list_out = []
  x_train_data_out = []
  y_train_data_out = []
  y_train_data_out_fvc = []
  y_train_data_out_bmi = []

  for h in range(len(unique_subjs)):
    idx_subj = np.argwhere(subject_list_in==unique_subjs[h])[:,0]
    # Get unique classes
    unique_classes = np.unique(y_train_data_in[idx_subj])
    for j in range(len(unique_classes)):
      idx_subj_class = np.argwhere((subject_list_in==unique_subjs[h]) & (y_train_data_in==unique_classes[j]))[:,0]
      subject_list_out.append(unique_subjs[h])
      y_train_data_out.append(np.median(y_train_data_in[idx_subj_class],axis=0))
      y_train_data_out_fvc.append(np.median(y_train_data_in_fvc[idx_subj_class],axis=0))
      y_train_data_out_bmi.append(np.median(y_train_data_in_bmi[idx_subj_class],axis=0))
      if computation=='median':
        x_train_data_out.append(np.median(x_train_data_in[idx_subj_class,:],axis=0))
      if computation=='RMS':
        x_train_data_out.append(np.sqrt(np.mean(x_train_data_in[idx_subj_class,:]**2,axis=0)))
      if computation=='var':
        x_train_data_out.append(np.var(x_train_data_in[idx_subj_class,:],axis=0))
      if computation=='max':
        x_train_data_out.append(np.max(x_train_data_in[idx_subj_class,:],axis=0))
      if computation=='min':
        x_train_data_out.append(np.min(x_train_data_in[idx_subj_class,:],axis=0))
  subject_list_out = np.stack(subject_list_out)
  x_train_data_out = np.stack(x_train_data_out)
  y_train_data_out = np.stack(y_train_data_out)
  y_train_data_out_fvc = np.stack(y_train_data_out_fvc)
  y_train_data_out_bmi = np.stack(y_train_data_out_bmi)
  return x_train_data_out,y_train_data_out,y_train_data_out_fvc,y_train_data_out_bmi,subject_list_out

def get_lung_impairment_class(z_scores_in):
  class_out = np.zeros(len(z_scores_in),)-1000
  for a in range(len(z_scores_in)):
    if -2.5 <= z_scores_in[a] <= -1.65:
      class_out[a] = 1 # Mild class
    elif -4.0 <= z_scores_in[a] < -2.5:
      class_out[a] = 2 # Moderate class
    elif z_scores_in[a] < -4.0:
      class_out[a] = 3 # Severe class
    elif z_scores_in[a] > -1.65:
      class_out[a] = 0 # Normal
    else:
      print('Unknown class')
  return class_out


def get_subj_fev1(y_class_in,y_subjects_in):
  if tf.is_tensor(y_class_in):
    y_in = y_class_in.numpy()
  else:
    y_in = y_class_in
  y_sub_in = y_subjects_in
  uniq_subj = np.unique(y_sub_in)
  yout_subj = np.zeros((len(uniq_subj),))-1000
  for i in range(len(uniq_subj)):
    idx_subj = np.argwhere(y_sub_in==uniq_subj[i])[:,0]
    yout_subj[i] = np.mean(y_in[idx_subj])
  return yout_subj

# Compute CI for proportion
def get_CI(a,b,c,d,alpha=0.2,n=162):
  sens = a/(a+c) # TP/(TP+FN)
  spec = b/(b+d) # TN/(TN+FP)
  alpha_half = alpha/2
  z_crit = abs(scipy.stats.norm.ppf(alpha_half))
  interv_sens = z_crit*np.sqrt((sens*(1-sens))/n)
  interv_spec = z_crit*np.sqrt((spec*(1-spec))/n)
  print('Sensitivity = ', np.round(100*sens,1))
  print('Sensitivity Interval = [', np.round(100*(sens-interv_sens),1),' - ',np.round(100*(sens+interv_sens),1),']')
  print('Specificity = ', np.round(100*spec,1))
  print('Specificity Interval = [', np.round(100*(spec-interv_spec),1),' - ',np.round(100*(spec+interv_spec),1),']')
  return 0

def edr_neurokit(ecg_in,resp_in,method="charlton2016",fs=Fs_ecg):
  edr_out = np.zeros_like(resp_in)
  for i in range(ecg_in.shape[0]):
    ecg = ecg_in[i,:,0]
    # Extract peaks
    rpeaks = biosppy.signals.ecg.christov_segmenter(ecg,fs)[0]
    # rpeaks, info = nk.ecg_peaks(ecg, sampling_rate=fs)
    # Compute rate
    ecg_rate = nk.ecg_rate(rpeaks, sampling_rate=fs, desired_length=len(ecg))
    resp_out = nk.ecg_rsp(ecg_rate, sampling_rate=fs, method=method)
    if len(resp_out)==0:
      resp_out = np.zeros((len(ecg),))
    resp_out = np.nan_to_num(resp_out, nan=0,posinf=100,neginf=0)
    resp_out = (resp_out-min(resp_out))/(max(resp_out)-min(resp_out))
    if fs==Fs_ecg:
      resp_out = decimate(resp_out, q=15, ftype='fir')
    resp_out = (resp_out-min(resp_out))/(max(resp_out)-min(resp_out))
    edr_out[i,:,0] = resp_out
  return edr_out