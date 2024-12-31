# Basic Imports
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import datetime
import math
from math import floor
import scipy as scipy
from scipy.signal import resample
import pandas as pd


# Initialize variables
Fs_ppg = 54
Fs_resp = 20
Fs_ecg = 300

# Useful directories
datapath_dir_DHMC = '/content/drive/My Drive/HeartFEV1 Project/Data/DHMC_Data/dataset/'
dhmc_spirometry = '/content/drive/My Drive/HeartFEV1 Project/Data/DHMC_Data/DHMC_Spirometry_Summary.xlsx'
datapath_dir_matlab = '/content/drive/My Drive/HeartFEV1 Project/Data/Animation_ECG_Resp_Data/dataset/'
datapath_dir_paper = '/content/drive/My Drive/HeartFEV1 Project/Data/Simulated_Obstruction_Paper_Tubes/dataset/'
datapath_dir_plastic = '/content/drive/My Drive/HeartFEV1 Project/Data/Spirometry_Simulated_Obstruction_Plastic_Tubes/dataset/'


def time_chars(x):
  return(x[65:78])

# Function to read all files from directory with cough data files
def getListOfFiles(dirName):
  # create a list of file and sub directories
  # names in the given directory
  listOfFile = os.listdir(dirName)
  allFiles = list()
  # Iterate over all the entries with selected file extension
  for entry in listOfFile:
      # Create full path
      fullPath = os.path.join(dirName, entry)
      filename, file_extension = os.path.splitext(fullPath)
      # If entry is a directory then get the list of files in this directory
      if os.path.isdir(fullPath):
          allFiles = allFiles + getListOfFiles(fullPath)
      else:
          allFiles.append(fullPath)
  return allFiles

# Extract ECG MCL1 and RESP signals
def extract_ecgnresp_files(ecg_lead_extension,file_library):
  ecg_files = []
  resp_files = []
  ppg_files = []
  RR_files = []
  resp_needed = '_resp.csv'
  RR_needed = '_RR.csv'
  ppg_needed = '_ppg.npy'
  for each in file_library:
    if each.endswith(ecg_lead_extension):
      ecg_files += [each]
      subject_name = each[:each.index(ecg_lead_extension)]
      resp_file = subject_name + resp_needed
      resp_files += [resp_file]
      RR_file = subject_name + RR_needed
      RR_files += [RR_file]
      ppg_file = subject_name + ppg_needed
      ppg_files += [ppg_file]
  return ecg_files,resp_files,RR_files,ppg_files

# Extract ECG MCL1 and RESP signals
def extract_ecgnresp_files_old(ecg_lead_extension,file_library,win_size):
  ecg_files = []
  resp_files = []
  class_files = []
  RR_files = []
  resp_needed = '_resp.csv'
  RR_needed = '_RR.csv'
  for each in file_library:
    if (each.endswith(ecg_lead_extension)) and (os.path.basename(each)[:2]==win_size):
      ecg_files += [each]
      subject_name = each[:each.index(ecg_lead_extension)]
      resp_file = subject_name + resp_needed
      resp_files += [resp_file]
      RR_file = subject_name + RR_needed
      RR_files += [RR_file]
  return ecg_files,resp_files,RR_files

def get_dataset_DHMC(PPG_true=False):
  # Get all files in folder
  allFiles = getListOfFiles(datapath_dir_DHMC)
  allFiles = sorted(allFiles, key = time_chars)   
  # Get ECG, RESP, RR files
  ecg_lead_ext = '_ecg.csv'
  ecg_files,resp_files,RR_files,ppg_files = extract_ecgnresp_files(ecg_lead_ext,allFiles)

  start = '0-'
  subjects_dhmc = []
  data_len = Fs_ppg*90
  m = 0
  n = 0

  ECG_data = np.zeros((1,27000))
  RESP_data = np.zeros((1,1800))
  PPG_data = np.zeros((1,data_len))

  for i in range(len(ecg_files)):
    # Read ECG files
    fname = os.path.basename(ecg_files[i]).lower()
    ecg_in = np.genfromtxt(ecg_files[i],delimiter=',')
    # Read RESP files
    resp_in = np.genfromtxt(resp_files[i],delimiter=',')
    # Read PPG_files
    ppg_in = np.load(ppg_files[i],allow_pickle=True)
    if PPG_true:
      # Append to ECG_data matrix - 1st window for calibration is removed
      ECG_data = np.concatenate((ECG_data,ecg_in[1:,:]),axis=0)
      # Append to RESP_data matrix - 1st window for calibration is removed
      RESP_data = np.concatenate((RESP_data,resp_in[1:,:]),axis=0)
      for j in range(1,len(ppg_in)):
          PPG_data = np.concatenate((PPG_data,np.array(ppg_in[j][:data_len]).reshape(1,data_len)),axis=0)
      subjects_dhmc.append(np.repeat(fname[fname.find(start)+len(start):fname.find(start)+len(start)+5],ecg_in.shape[0]-1))
    else:
      # Append to ECG_data matrix - 1st window for calibration is removed
      ECG_data = np.concatenate((ECG_data,ecg_in),axis=0)
      # Append to RESP_data matrix - 1st window for calibration is removed
      RESP_data = np.concatenate((RESP_data,resp_in),axis=0)
      subjects_dhmc.append(np.repeat(fname[fname.find(start)+len(start):fname.find(start)+len(start)+5],ecg_in.shape[0]))


  ECG_data = np.delete(ECG_data,0,0)
  RESP_data = np.delete(RESP_data,0,0)
  PPG_data = np.delete(PPG_data,0,0)
  subjects_dhmc = np.concatenate(subjects_dhmc)
  return ECG_data,RESP_data,PPG_data,subjects_dhmc

def get_spirometry_vals(subjects_in):
  # Read in the Spirometry Values
  DHMC_data = pd.read_excel(dhmc_spirometry)
  # Read in the FEV1 and FVC values
  fev1_values = np.array(DHMC_data['FEV1'])
  fvc_values = np.array(DHMC_data['FVC'])
  bmi_values = np.array(DHMC_data['BMI'])
  # Match FEV1 and FVC to each data window
  subj_id = np.array(DHMC_data['Subject ID'])
  sub_int = []
  # Get the unique subject IDs
  for m in range(len(subj_id)):
    sub_int.append((subj_id[m][5:]).lower())
  sub_int = np.array(sub_int)
  # Save FEV1, FVC and BMI values for each window here
  fev1 = np.zeros((len(subjects_in),))-1000
  fvc = np.zeros((len(subjects_in),))-1000
  bmi = np.zeros((len(subjects_in),))-1000
  # Parse spirometry data file
  for k in range(len(sub_int)):
    idx_possible = np.argwhere(subjects_in==sub_int[k])[:,0]
    fev1[idx_possible] = fev1_values[k]
    fvc[idx_possible] = fvc_values[k]
    bmi[idx_possible] = bmi_values[k]

  return fev1,fvc,bmi

def get_dataset_Matlab():
  # Get all files in folder
  allFiles = getListOfFiles(datapath_dir_matlab)
  allFiles = sorted(allFiles, key = time_chars)   
  # Get ECG, RESP, RR files
  win = 90
  ecg_lead_ext = '_ecg.csv'
  win_size = str(win)
  ecg_files,resp_files,RR_files = extract_ecgnresp_files_old(ecg_lead_ext,allFiles,win_size)

  # Read the ECG and RESP files into an array
  test_subjects = ['s003','s013','s014']
  val_subjects = []
  test_idx1 = []
  val_idx= []
  subjects = []
  ecg_length_input = Fs_ecg*win
  resp_length_input = Fs_resp*win
  ECG_set = np.zeros((1,ecg_length_input))
  RESP_set  = np.zeros((1,resp_length_input))
  RR_set = np.zeros((1,resp_length_input))
  start = 's'
  end = '_r0'
  for i in range(len(ecg_files)):
    # Read in the data
    fname = os.path.basename(ecg_files[i])
    ecg_data = np.genfromtxt(ecg_files[i], delimiter=',')
    resp_data = np.genfromtxt(resp_files[i], delimiter=',')
    RR_data = np.genfromtxt(RR_files[i], delimiter=',')
    if ecg_data.ndim==1:
        ecg_data = ecg_data.reshape(1,len(ecg_data))
        resp_data = resp_data.reshape(1,len(resp_data))
        RR_data = RR_data.reshape(1,len(RR_data))
    subjects = np.append(subjects,np.repeat(int(fname[fname.find(start)+len(start):fname.rfind(end)]),ecg_data.shape[0]))
    ECG_set = np.append(ECG_set,ecg_data, axis=0)
    RESP_set = np.append(RESP_set,resp_data, axis=0)
    RR_set = np.append(RR_set,RR_data, axis=0)
    if any(x in ecg_files[i] for x in test_subjects):
        test_idx1 = np.append(test_idx1,int(fname[fname.find(start)+len(start):fname.rfind(end)]))
    if any(x in ecg_files[i] for x in val_subjects):
        val_idx = np.append(val_idx,int(fname[fname.find(start)+len(start):fname.rfind(end)]))

  # Remove first index of empty set
  ECG_set = np.delete(ECG_set,0,0)
  RESP_set = np.delete(RESP_set,0,0)
  RR_set = np.delete(RR_set,0,0)
  return ECG_set,RESP_set,RR_set,subjects,test_idx1,val_idx

def get_dataset_PaperTubes():
  # Get all files in folder
  allFiles = getListOfFiles(datapath_dir_paper)
  allFiles = sorted(allFiles, key = time_chars)   
  # Get ECG, RESP, RR files
  ecg_lead_ext = '_ecg.csv'
  ecg_files,resp_files,RR_files,ppg_files = extract_ecgnresp_files(ecg_lead_ext,allFiles)

  start = 's'

  subjects_sim = []
  no_tube = []
  open_tube = []
  one_hole = []
  five_hole = []

  ECG_data = np.zeros((1,27000))
  RESP_data = np.zeros((1,1800))
  data_len = Fs_ppg*90
  PPG_data = np.zeros((1,data_len))

  m = 0
  n = 0
  for i in range(len(ecg_files)):
    # Read ECG files
    fname = os.path.basename(ecg_files[i]).lower()
    ecg_in = np.genfromtxt(ecg_files[i],delimiter=',')
    # Append to ECG_data matrix - 1st window for calibration is removed
    ECG_data = np.concatenate((ECG_data,ecg_in[1:,:]),axis=0)
    # Read RESP files
    resp_in = np.genfromtxt(resp_files[i],delimiter=',')
    # Append to RESP_data matrix - 1st window for calibration is removed
    RESP_data = np.concatenate((RESP_data,resp_in[1:,:]),axis=0)
    # Read PPG_files
    ppg_in = np.load(ppg_files[i],allow_pickle=True)
    for j in range(1,len(ppg_in)):
        PPG_data = np.concatenate((PPG_data,np.array(ppg_in[j][:data_len]).reshape(1,data_len)),axis=0)

    subjects_sim = np.append(subjects_sim,np.repeat(int(fname[fname.find(start)+len(start):fname.find(start)+len(start)+3]),ecg_in.shape[0]-1))
    n = ecg_in.shape[0]-1
    if 'no_tube' in fname:
        no_tube.append(np.arange(m,m+n))
    elif 'open' in fname:
        open_tube.append(np.arange(m,m+n))
    elif 'one_hole' in fname:
        one_hole.append(np.arange(m,m+n))
    elif 'five_hole' in fname:
        five_hole.append(np.arange(m,m+n))
    else:
        print('Unknown test',fname)
    m = m+n
  no_tube = list(np.concatenate(no_tube))
  open_tube = list(np.concatenate(open_tube))
  one_hole = list(np.concatenate(one_hole))
  five_hole = list(np.concatenate(five_hole))

  ECG_data = np.delete(ECG_data,0,0)
  RESP_data = np.delete(RESP_data,0,0)
  PPG_data = np.delete(PPG_data,0,0)
  return ECG_data,RESP_data,PPG_data,subjects_sim,no_tube,open_tube,one_hole,five_hole

def get_dataset_PlasticTubes():
  # Get all files in folder
  allFiles = getListOfFiles(datapath_dir_plastic)
  allFiles = sorted(allFiles, key = time_chars)   
  # Get ECG, RESP, RR files
  ecg_lead_ext = '_ecg.csv'
  ecg_files,resp_files,RR_files,ppg_files = extract_ecgnresp_files(ecg_lead_ext,allFiles)

  start = 'sp'

  subjects_sim = []
  normal = []
  mild = []
  moderate = []
  severe = []
  very_severe = []

  ECG_data = np.zeros((1,27000))
  RESP_data = np.zeros((1,1800))
  data_len = Fs_ppg*90
  PPG_data = np.zeros((1,data_len))

  m = 0
  n = 0
  for i in range(len(ecg_files)):
      # Read ECG files
      fname = os.path.basename(ecg_files[i]).lower()
      ecg_in = np.genfromtxt(ecg_files[i],delimiter=',')
      # Append to ECG_data matrix - 1st window for calibration is removed
      ECG_data = np.concatenate((ECG_data,ecg_in[1:,:]),axis=0)
      # Read RESP files
      resp_in = np.genfromtxt(resp_files[i],delimiter=',')
      # Append to RESP_data matrix - 1st window for calibration is removed
      RESP_data = np.concatenate((RESP_data,resp_in[1:,:]),axis=0)
      # Read PPG_files
      ppg_in = np.load(ppg_files[i],allow_pickle=True)
      for j in range(1,len(ppg_in)):
          PPG_data = np.concatenate((PPG_data,np.array(ppg_in[j][:data_len]).reshape(1,data_len)),axis=0)

      subjects_sim.append(np.repeat(fname[fname.find(start)+len(start):fname.find(start)+len(start)+3],ecg_in.shape[0]-1))
      n = ecg_in.shape[0]-1
      if 'normal' in fname:
        normal.append(np.arange(m,m+n))
      elif 'mild' in fname:
        mild.append(np.arange(m,m+n))
      elif 'moderate' in fname:
        moderate.append(np.arange(m,m+n))
      elif 'very' in fname:
        very_severe.append(np.arange(m,m+n))
      elif 'severe' in fname:
        severe.append(np.arange(m,m+n))
      else:
        print('Unknown test',fname)
      m = m+n
  normal = list(np.concatenate(normal))
  mild = list(np.concatenate(mild))
  moderate = list(np.concatenate(moderate))
  severe = list(np.concatenate(severe))
  very_severe = list(np.concatenate(very_severe))

  ECG_data = np.delete(ECG_data,0,0)
  RESP_data = np.delete(RESP_data,0,0)
  PPG_data = np.delete(PPG_data,0,0)
  subjects_sim = np.concatenate(subjects_sim)
  return ECG_data,RESP_data,PPG_data,subjects_sim,normal,mild,moderate,severe,very_severe