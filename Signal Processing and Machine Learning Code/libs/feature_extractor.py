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

from scipy import signal
from scipy.signal import find_peaks,resample


# Hand engineered respiratory features
# Hand engineered respiratory features
def get_IER(x_class):
  # Compute IER
  IER = np.zeros((x_class.shape[0],))
  for i in range(x_class.shape[0]):
    peaks_mod_t = np.argwhere(np.diff(x_class[i,:,0])==-1)[:,0]
    if len(peaks_mod_t)>2:
      IER[i] = (np.mean(x_class[i,peaks_mod_t[0]:peaks_mod_t[-1],0]))/(1-np.mean(x_class[i,peaks_mod_t[0]:peaks_mod_t[-1],0]))
  return IER

def get_RR(data_in,fs,div=5):
  RR = np.zeros((data_in.shape[0],))
  for i in range(data_in.shape[0]):
    sig = np.nan_to_num(data_in[i,:,0],nan=0,posinf=0,neginf=0)
    peaks,_ = find_peaks(sig, prominence=max(sig)/div)
    peaks_corr,_ = find_peaks(np.correlate(sig,sig,mode='same'))
    RR[i] = 60*(1/(np.mean(np.diff(peaks))/fs))
  return RR

def get_tv(x_train_clean,x_class,x_bmi):
  # Compute the average respiratory amplitude
  RA = np.zeros((x_train_clean.shape[0],))-100
  for i in range(x_train_clean.shape[0]):
    peaks_mod_t = np.argwhere(np.diff(x_class[i,:,0])==-1)[:,0]
    vals_mod_t = np.argwhere(np.diff(x_class[i,:,0])==1)[:,0]
    if peaks_mod_t[0]<vals_mod_t[0]:
      peaks_mod_t = np.delete(peaks_mod_t,0,0)
    if vals_mod_t[-1]>peaks_mod_t[-1]:
      vals_mod_t = np.delete(vals_mod_t,-1,0)
    resp_amp = x_train_clean[i,peaks_mod_t,0] - x_train_clean[i,vals_mod_t,0]
    RA[i] = np.median(resp_amp)/x_bmi[i]
  return RA

def get_skewness(x_train_clean):
  # Skewness = E(y-mu)**3/std**3
  # Compute Skewness
  Skewness = np.zeros((x_train_clean.shape[0],))-100
  for i in range(x_train_clean.shape[0]):
    Skewness[i] = ((np.mean((x_train_clean[i,:,0]-np.mean(x_train_clean[i,:,0]))**3)))/((np.std(x_train_clean[i,:,0]))**3)
  return Skewness

def get_sample_entropy(x_train_clean):
  se_out = np.zeros((x_train_clean.shape[0],))
  for k in range(x_train_clean.shape[0]):
    se_out[k] = nk.entropy_sample(x_train_clean[k,:,0])[0]
  return se_out

def get_dfa(x_train_clean):
  dfa_out = np.zeros((x_train_clean.shape[0],))
  for k in range(x_train_clean.shape[0]):
    dfa_out[k] = nk.complexity_dfa(x_train_clean[k,:,0])[0]
  return dfa_out

def get_IRA(x_train_clean,x_class,x_bmi):
  # Compute the average respiratory amplitude
  IRA = np.zeros((x_train_clean.shape[0],))-100
  for i in range(x_train_clean.shape[0]):
    peaks_mod_t = np.argwhere(np.diff(x_class[i,:,0])==-1)[:,0]
    resp_amps = x_train_clean[i,peaks_mod_t,0]
    IRA[i] = (np.max(resp_amps)-np.median(resp_amps))/x_bmi[i]
  return IRA

def get_ERA(x_train_clean,x_class,x_bmi):
  # Compute the average respiratory amplitude
  ERA = np.zeros((x_train_clean.shape[0],))-100
  for i in range(x_train_clean.shape[0]):
    vals_mod_t = np.argwhere(np.diff(x_class[i,:,0])==1)[:,0]
    resp_vals = x_train_clean[i,vals_mod_t,0]
    ERA[i] = (np.median(resp_vals)-np.min(resp_vals))/x_bmi[i]
  return ERA

def get_EA1(x_train_clean,x_class,x_bmi,fs):
  # Compute the average respiratory amplitude in 1 second
  RA1 = np.zeros((x_train_clean.shape[0],))-100
  for i in range(x_train_clean.shape[0]):
    peaks_mod_t = np.argwhere(np.diff(x_class[i,:,0])==-1)[:,0]
    resp_amp = []
    for j in range(len(peaks_mod_t)):
      if peaks_mod_t[j]+fs >= x_train_clean.shape[1]:
        break;
      resp_amp.append(x_train_clean[i,peaks_mod_t[j],0] - x_train_clean[i,peaks_mod_t[j]+fs,0])
    RA1[i] = np.median(resp_amp)/x_bmi[i]
  return RA1

# Get the hand engineered features
def get_hand_features(x_train_clean, x_class,x_bmi,fs):
  IER = get_IER(x_class)
  RR = get_RR(x_train_clean,fs)
  TV = get_tv(x_train_clean,x_class,x_bmi)
  Skewness = get_skewness(x_train_clean)
  sample_entropy = get_sample_entropy(x_train_clean)
  DFA = get_dfa(x_train_clean)
  IRV = get_IRA(x_train_clean,x_class,np.ones_like(x_bmi))
  ERV = get_ERA(x_train_clean,x_class,np.ones_like(x_bmi))
  EV1 = get_EA1(x_train_clean,x_class,np.ones_like(x_bmi),fs)
  x_features_out = np.stack([IER,RR,TV,Skewness,sample_entropy,DFA,IRV,ERV,EV1]).T
  return x_features_out
