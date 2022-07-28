# motor-imagery-BCI

A MATLAB toolbox for classification of motor imagery tasks in EEG-based BCI system with CSP, FB-CSP and BSSFO

Codes and data for the following paper are extended to different methods:

Iterative Subspace Decomposition for Ocular Artifact Removal from EEG Recordings
A novel Bayesian framework for discriminative feature extraction in brain-computer interfaces
Filter bank common spatial pattern algorithm on BCI competition IV Datasets 2a and 2b
Multi-class Filter Bank Common Spatial Pattern for Four-Class Motor Imagery BCI


## 1. Introduction.

This package includes the prototype MATLAB codes for motor imagery brain-computer interfaces.

The implemented method uses CSP for feature extraction and SVM as the classifier: 

  1. Iterative Subspace Decomposition for Ocular Artifact Removal 
  2. common spatial pattern algorithm to extract features      
  3. SVM

     


## 2. Usage & Dependency.

## Dependency:
     https://github.com/hisuk/MI-BSSFO
     
     https://github.com/alexandrebarachant/covariancetoolbox
     EEGLAB tolbox
     Biosig toolbox

## Usage:
Run "eeg_preprocessing.m" to load, preprocess and extract motor imagery epochs.

