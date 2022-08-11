
close all
clear 
clc
addpath(genpath(pwd))

%This code is dependent on eeglab functions, and eeglab must insatll and
%add biosig plugin

dataset_dir = 'D:/PHD codes/DataSets/2008 Graz data set A';
save_dir = [dataset_dir,'/epoched_clean_data'];
num_subjects = 9; % participants number

%%  Start load, preprocessing & extracting epochs

eeg_preprocessing; 

%% Ready for feature extraction
close all
k_pairs = [1,2,3];
eeg_channels = 1:22;
max_class = 3;

feature_extraction_OVR;
