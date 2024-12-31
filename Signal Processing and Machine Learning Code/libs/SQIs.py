# ECG Modules
import biosppy

# Basic Imports
import numpy as np
import scipy as scipy
from scipy import signal
from scipy.signal import find_peaks, detrend

b_firfilter_resp = signal.firwin(63, cutoff=1, window='tukey',fs=20)

# Normalize data
def data_normalize(data_in):
  min_in = data_in.min(axis=1,keepdims=True)
  max_in = data_in.max(axis=1,keepdims=True)
  data_out = (data_in-min_in)/(max_in-min_in)
  return data_out

# Define ECG SQI
def sqi_ecg(ecg_input_data,fs_ecg,lim_cc=0.78):
  bd_idx = []
  cc_out = np.zeros((ecg_input_data.shape[0],))
  for z in range(ecg_input_data.shape[0]):
    ecg_in = ecg_input_data[z,:,0]
    # Automatically process the (raw) ECG signal
    rpeaks = biosppy.signals.ecg.christov_segmenter(ecg_in,fs_ecg)[0]
    
    # Check number of r peaks
    if len(rpeaks)<=12: # less than 30 bpm
      bd_idx.append(z)
    else:
      # Get correlation coefficient between rpeaks
      rpk_dist = np.diff(rpeaks)
      r_length = int(np.floor(rpk_dist.mean()))
      if (r_length % 2)==0:
        r_length = r_length-1
      sample_size = int((r_length-1)/2)
      idx_r = np.argwhere((rpeaks-sample_size < 0)|(rpeaks+1+sample_size>len(ecg_in)))[:,0]
      new_peaks = []
      for m in range(len(rpeaks)):
        if m not in idx_r:
          new_peaks.append(rpeaks[m])

      ecg_array = np.zeros((len(new_peaks),r_length))
      for r in range(len(new_peaks)):
        array_b = ecg_in[new_peaks[r]-sample_size:new_peaks[r]+sample_size+1]
        eucli_norm = np.sqrt(np.sum(abs(array_b)**2))
        ecg_array[r,:] = array_b/eucli_norm
      avg_template = np.mean(ecg_array,0)
      cc = 0
      for m in range(ecg_array.shape[0]):
        cc += np.corrcoef(ecg_array[m,:],avg_template)[0,1]
      avg_cc = cc/ecg_array.shape[0]
      if avg_cc < lim_cc:
        bd_idx.append(z)
  return bd_idx

# Define RESP SQI
# Determine if window is invalid
def invalid_windows(in_sig,index,fs_r):
  valid_win = []
  invalid_win = []
  peaks,_ = find_peaks(in_sig)
  pk_limit = 0.2*np.percentile(in_sig[peaks],75)
  valleys,_ = find_peaks(-1*in_sig)
  vl_limit = 0.2*np.percentile(in_sig[valleys],25)
  valid_peaks = []
  for k in range(len(peaks)):
    if in_sig[peaks[k]] > pk_limit:
      valid_peaks.append(peaks[k])

  valid_valleys = []
  for k in range(len(valleys)):
    if in_sig[valleys[k]] < vl_limit:
      valid_valleys.append(valleys[k])

  final_peaks = []
  for k in range(len(valid_valleys)):
    pk_prospect = []
    if k<(len(valid_valleys)-1):
      # Check is there are peaks before and after
      idxd = np.argwhere((valid_peaks>valid_valleys[k])&(valid_peaks<valid_valleys[k+1]))[:,0]
      pk_prospect = [valid_peaks[index] for index in idxd]
      if len(pk_prospect)==1:
        final_peaks.append(pk_prospect[0])
      elif len(pk_prospect)>1:
        final_peaks.append(pk_prospect[np.argmax(in_sig[pk_prospect])])
      else:
        final_peaks=final_peaks
    if k==0:
      pk_prospect = []
      # Check is there are peaks before
      idxd = np.argwhere(valid_peaks<valid_valleys[k])[:,0]
      pk_prospect = [valid_peaks[index] for index in idxd]
      if len(pk_prospect)==1:
        final_peaks.append(pk_prospect[0])
      elif len(pk_prospect)>1:
        final_peaks.append(pk_prospect[np.argmax(in_sig[pk_prospect])])
      else:
        final_peaks=final_peaks
    if k == (len(valid_valleys)-1):
      pk_prospect = []
      # Check is there are peaks after
      idxd = np.argwhere(valid_peaks>valid_valleys[k])[:,0]
      pk_prospect = [valid_peaks[index] for index in idxd]
      if len(pk_prospect)==1:
        final_peaks.append(pk_prospect[0])
      elif len(pk_prospect)>1:
        final_peaks.append(pk_prospect[np.argmax(in_sig[pk_prospect])])
      else:
        final_peaks=final_peaks
  final_peaks = np.sort(final_peaks)
  # Get valid breaths
  breath_duration = np.diff(final_peaks)/fs_r
  if len(breath_duration)>0:
    bd_std = breath_duration.std()/breath_duration.mean()
    bd_median = np.median(breath_duration)
    bd_mean = breath_duration.mean()
    bd_pass = len(breath_duration[(breath_duration>1.5*bd_median)|(breath_duration<0.5*bd_median)])/len(breath_duration)
    if (bd_std>0) and (bd_std<0.3) and (bd_pass<0.2) and (len(final_peaks)>2): #  Valid window
      breath_samples = np.diff(final_peaks)
      b_length = int(np.floor(breath_samples.mean()))
      if (b_length % 2)==0:
        b_length = b_length-1
      sample_size = int((b_length-1)/2)
      idx_r = np.argwhere((final_peaks-sample_size < 0)|(final_peaks+1+sample_size>len(in_sig)))[:,0]
      new_peaks = []
      for m in range(len(final_peaks)):
        if m not in idx_r:
          new_peaks.append(final_peaks[m])

      breath_array = np.zeros((len(new_peaks),b_length))
      for r in range(len(new_peaks)):
        array_b = in_sig[new_peaks[r]-sample_size:new_peaks[r]+sample_size+1]
        eucli_norm = np.sqrt(np.sum(abs(array_b)**2))
        breath_array[r,:] = array_b/eucli_norm
      avg_template = np.mean(breath_array,0)
      cc = 0
      for m in range(breath_array.shape[0]):
        cc += np.corrcoef(breath_array[m,:],avg_template)[0,1]
      avg_cc = cc/breath_array.shape[0]
      if avg_cc > 0.75:
        valid_win.append(index)
      else:
        invalid_win.append(index)
    else:
      invalid_win.append(index)
  else:
    invalid_win.append(index)
  return valid_win,invalid_win

# RESP SQI
def resp_sqi(y_in,fs_r):
  y_in_filt = np.zeros_like(y_in)
  bd_windows = []
  gd_windows = []
  for i in range(y_in.shape[0]):
    val_win = []
    inval_win = []

    # Apply 1 Hz filter
    filtered_sig = signal.filtfilt(b_firfilter_resp, 1, y_in[i,:,0])
    # Zero mean and 1 std deviation
    norm_sig = (filtered_sig-filtered_sig.mean())/filtered_sig.std()
    if np.isnan(norm_sig).any():
      bd_windows.append([i])
      y_in_filt[i,:,0] = np.zeros_like(norm_sig)
    else:
      # Detrend the signal
      detrended_sig = detrend(norm_sig)
      y_in_filt[i,:,0] = detrended_sig
      # Check the windows
      val_win, inval_win = invalid_windows(detrended_sig,i,fs_r)
      if len(inval_win)>0:
        bd_windows.append(inval_win)
      if len(val_win)>0:
        gd_windows.append(val_win)
  y_in_filt = data_normalize(y_in_filt)
  return bd_windows,gd_windows,y_in_filt

def apply_sqi(resp_data,ecg_data,fs_resp,fs_ecg,PPG_true=False):
  resp_in = data_normalize(resp_data.reshape(resp_data.shape[0],resp_data.shape[1],1))
  bd_windows,_,_ = resp_sqi(resp_in,fs_resp)
  bd_windows_resp = np.concatenate(bd_windows)
  ecg_in = data_normalize(ecg_data.reshape(ecg_data.shape[0],ecg_data.shape[1],1))
  bd_windows_ecg = sqi_ecg(ecg_in,fs_ecg)
  bd_windows_dhmc = bd_windows_ecg

  # These windows were flagged by the ECG SQI but after reviewing each window individually, I give an exception
  # The exception is because the ECG signals are different. The non-exempt windows are bad
  if PPG_true:
    cc = []
    cc.append(bd_windows_dhmc[0:2])
    cc.append(bd_windows_dhmc[11:20])
    cc.append([bd_windows_dhmc[22]])
    cc.append(bd_windows_dhmc[24:31])
    bd_windows_dhmc = np.concatenate((cc))
  else:
    cc = []
    cc.append(bd_windows_dhmc[0:2])
    cc.append([bd_windows_dhmc[13]])
    cc.append(bd_windows_dhmc[16:24])
    cc.append([bd_windows_dhmc[26]])
    cc.append(bd_windows_dhmc[28:29])
    cc.append(bd_windows_dhmc[35:])
    bd_windows_dhmc = np.concatenate((cc))
  bd_windows_dhmc_comb = np.unique(np.concatenate((bd_windows_dhmc,bd_windows_resp)))
  return bd_windows_dhmc_comb

def apply_gen_sqi(resp_data,ecg_data,fs_resp,fs_ecg):
  resp_in = data_normalize(resp_data.reshape(resp_data.shape[0],resp_data.shape[1],1))
  bd_windows,_,_ = resp_sqi(resp_in,fs_resp)
  bd_windows_resp = np.concatenate(bd_windows)
  ecg_in = data_normalize(ecg_data.reshape(ecg_data.shape[0],ecg_data.shape[1],1))
  bd_windows_ecg = sqi_ecg(ecg_in,fs_ecg)
  bd_windows_comb = np.unique(np.concatenate((bd_windows_ecg,bd_windows_resp)))
  return bd_windows_comb