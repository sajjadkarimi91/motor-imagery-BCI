# motor-imagery-BCI

A MATLAB toolbox for classification of motor imagery tasks in EEG-based BCI system with CSP and FB-CSP 

Codes and data for the following paper are extended to different methods:

Iterative Subspace Decomposition for Ocular Artifact Removal from EEG Recordings
Filter bank common spatial pattern algorithm on BCI competition IV Datasets 2a and 2b


## 1. Introduction.

This package includes the prototype MATLAB codes for motor imagery brain-computer interfaces.

The implemented method uses CSP for feature extraction and SVM as the classifier: 

  1. Iterative Subspace Decomposition for Ocular Artifact Removal 
  2. common spatial pattern algorithm to extract features      
  3. SVM and Naive-Bayes classification   


## 2. Usage & Dependency.

## Dependency:
     https://github.com/hisuk/MI-BSSFO     
     https://github.com/alexandrebarachant/covariancetoolbox
     EEGLAB tolbox
     Biosig plugin for eeglab

## Usage:
Run "main_pw.m" or "main_ovr.m" to perform A-Z for MI-BCI. 

