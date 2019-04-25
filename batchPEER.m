%%% PEER analysis software by Olave E. Krigolson
%%% Version 1.0, November 18th, 2018
%%% Version 1.1, December 5th, 2018
%%% Removed convert VIHA - this is now to be done before using
%%% convertAspire.m
%%% now supports batch analysis of PEER.csv files
%%% files are loaded from an EXCEL summary file

clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% remove channels
channelsToRemove = {'AF7','AF8'};

% reference paramters (0 = none, 1 = front to back, 2 = all to back)
referenceChannels = {'TP9','TP10'};
channelsRereferenced = {'ALL'};

% filter parameters
filterOrder = 2;
filterLow = 0.1;                        % always keep at 0.1
filterHigh = 30;                        % set to 15 for ERP analyses, set to 30 or higher for FFT
filterNotch = 60;                       % unless in Europe use 60

% epoch parameters
epochMarkers = {'5','6'};               % the markers 5 is control 6 is oddball
currentEpoch = [-200 800];              % the time window

% baseline window
baseline = [-200 0];                    % the baseline, recommended -200 to 0

% trials to keep (if used)
trialsToKeep = 200;

% artifact criteria
artifactCriteria = 75;                  % recommend maxmin of 75

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DO NOT CHANGE STUFF BELOW HERE

% select the files to load
[filePath] = uigetdir('Select the directory where the data is');

%Change directory to where the data is
cd(filePath);

% load the EXCEL summary sheet that controls batch processing
try 
    EXCEL = readtable('SUMMARY.xlsx');
    numberOfFiles = size(EXCEL,1);
catch
    error('NO SUMMARY.xlsx FILE PRESENT TO LOAD');
end

for fileCounter = 1:numberOfFiles
    
    % display current file 
    disp(['Currently Processing File ' num2str(fileCounter) ' of ' num2str(numberOfFiles)]);

    % fix file name structure for single file if needed
    fileName = EXCEL.Filename{fileCounter};
    fileName = [fileName '.csv'];

    EEG = doLoadPEER(fileName);

    % compute channel variances
    EEG = doChannelVariance(EEG,0);

    % option to remove front channels
    % EEG = doRemoveChannels(EEG,channelsToRemove,EEG.chanlocs);

    % reference the data
    EEG = doRereference(EEG,referenceChannels,channelsRereferenced,EEG.chanlocs);

    % filter the data
    EEG = doFilter(EEG,filterLow,filterHigh,filterOrder,filterNotch,EEG.srate);

    % epoch data
    EEG = doSegmentData(EEG,epochMarkers,currentEpoch);

    % remove trials if needed
    % EEG = doRemoveTrials(EEG,trialsToKeep)

    % concatenate data to increase SNR
    % EEG = doIncreasePEERSNR(EEG,2);

    % apply a linear detrend to the data if asked for
    % EEG = doDetrend(EEG);

    % baseline correction
    EEG = doBaseline(EEG,baseline);

    % identify artifacts
    EEG = doArtifactRejection(EEG,'Difference',artifactCriteria);

    % remove bad trials
    EEG = doRemoveEpochs(EEG,EEG.artifactPresent);

    % make ERPs
    ERP = doERP(EEG,{'5','6'},1);
        
    % do a FFT on the data
    FFT = doFFT(EEG,{'5','6'});

    DATA(1) = fileCounter;
    DATA(2) = EEG.analyzeFrontChannels;             
    DATA(3) = EEG.rereferenceFrontChannels;           
    DATA(4) = EEG.rerefenceFactor;                    
    DATA(5) = EEG.doFFT;                              
    DATA(6) = EEG.applyDetrend;                                      
    DATA(7) = EEG.artifactCriteria;                 
    DATA(8) = EEG.filterLow;                        
    DATA(9) = EEG.filterHigh;                        
    DATA(10) = EEG.filterNotch;                                     
    DATA(11) = EEG.currentEpoch(1);
    DATA(12) = EEG.currentEpoch(2);
    DATA(13) = EEG.baseline(1);
    DATA(14) = EEG.baseline(2);
    DATA(14) = EEG.srate;                            
    DATA(15) = EEG.numberOfConditions;                 
    DATA(16) = EEG.numberOfChannels;
    DATA(17) = EEG.trialWereTrimmed;
    DATA(18) = EEG.actualTrialCount;
    DATA(19) = EEG.desiredTrials;
    DATA(20) = size(condition1Markers,1);
    DATA(21) = size(condition2Markers,1);
    DATA(22) = size(evenC1Markers,1);
    DATA(23) = size(oddC1Markers,1);
    DATA(24) = size(evenC2Markers,1);
    DATA(25) = size(oddC2Markers,1);
    DATA(26) = ftotal;
    DATA(27) = ftotal-flost;
    DATA(28) = flost;
    DATA(29) = flost/ftotal*100;
    DATA(30) = stotal;
    DATA(31) = stotal - slost;
    DATA(32) = slost;
    DATA(33) = slost/stotal*100;
    DATA(34) = (flost+slost)/EEG.desiredTrials*100;
    DATA(35) = varAF7;
    DATA(36) = varAF8;
    DATA(37) = varTP9;
    DATA(38) = varTP10;
    DATA(39) = referenceChoice;
    DATA(40) = maxminAF7;
    DATA(41) = maxminAF8;
    DATA(42) = maxminTP9;
    DATA(43) = maxminTP10;
    DATA(44) = interpFront;
    DATA(45) = interpBack;
    
    
    OUTPUT.ERP(:,:,:,fileCounter) = ERP;

    OUTPUT.FFT(:,:,:,fileCounter) = FFT;
        
    OUTPUT.FFTRange(:) = frequencies2;

    OUTPUT.DATA(fileCounter,:) = DATA;

    OUTPUT.TIME = EEG.timeVector(1:size(ERP,2));
    
    OUTPUT.EXCEL = EXCEL;
    
end

save('OUTPUT','OUTPUT');

clear a* c* D* e* E* F* f* i* m* n* o* r* s* t* v*