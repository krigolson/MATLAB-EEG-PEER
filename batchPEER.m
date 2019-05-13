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

% display channel variance
showChannelVariance = 0;                % set to 0 for batch scripts

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
currentEpoch = [-200 798];             % the time window

% baseline window
baseline = [-200 0];                    % the baseline, recommended -200 to 0

% trials to keep (if used)
trialsToKeep = 200;                     % basically a way to trim trials, do not use unless you understand what you are doing

% artifact criteria
typeOfArtifactRejction = 'Difference';  % max - min difference
artifactCriteria = 50;                  % recommend maxmin of 75
individualChannelAveraging = 0;         % set to one for individual channel averaging

% internal consistency
computeInternalConsistency = 0;         % set to 1 to do odd even averaging to allow computation of internal consistency

% wavelet analysis
waveletBaseline = [-200 -100];
waveletMin = 1;
waveletMax = 30;
waveletSteps = 30;
mortletParameter = 7;

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

for fileCounter = 1:10 % Matt, change this to 1:3 from 1:numberOfFiles to run on the first three subjects to test any changes you try.

    fileName = EXCEL.Filename{fileCounter};
    
    EEG = doLoadPEER(fileName,epochMarkers);
    
    if fileCounter == 10
        EEG.data(1,:) = EEG.data(2,:);
    end
    
    % compute channel variances
    EEG = doChannelVariance(EEG,showChannelVariance);

    % option to remove front channels
    % EEG = doRemoveChannels(EEG,channelsToRemove,EEG.chanlocs);

    % reference the data
    % EEG = doRereference(EEG,referenceChannels,channelsRereferenced,EEG.chanlocs);

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
    EEG = doArtifactRejection(EEG,typeOfArtifactRejction,artifactCriteria);

    % remove bad trials
    EEG = doRemoveEpochs(EEG,EEG.artifactPresent,individualChannelAveraging);

    % make ERPs
    ERP = doERP(EEG,epochMarkers,computeInternalConsistency);

    % do a FFT on the data
    FFT = doFFT(EEG,epochMarkers);

    % do Wavelet analysis
    % WAV = doWAV(EEG,epochMarkers,waveletBaseline,waveletMin,waveletMax,waveletSteps,mortletParameter);

    OUTPUT(fileCounter).fileName = fileName;
    OUTPUT(fileCounter).participantNumber = EXCEL.ParticipantNumber(fileCounter);
    OUTPUT(fileCounter).dataCollected = EXCEL.DateCollected(fileCounter);
    OUTPUT(fileCounter).dataSource = EXCEL.DataSource(fileCounter);
    OUTPUT(fileCounter).task = EXCEL.Task(fileCounter);
    OUTPUT(fileCounter).eyeblink = EXCEL.Eyeblink(fileCounter);
    OUTPUT(fileCounter).blocks = EXCEL.Blocks(fileCounter);
    OUTPUT(fileCounter).trials = EXCEL.Trials(fileCounter);
    OUTPUT(fileCounter).gender = EXCEL.Gender(fileCounter);
    OUTPUT(fileCounter).age = EXCEL.Age(fileCounter);
    OUTPUT(fileCounter).time = EXCEL.Time(fileCounter);
    OUTPUT(fileCounter).iv1 = EXCEL.IV1(fileCounter);
    OUTPUT(fileCounter).iv2 = EXCEL.IV2(fileCounter);
    OUTPUT(fileCounter).iv3 = EXCEL.IV3(fileCounter);
    OUTPUT(fileCounter).iv4 = EXCEL.IV4(fileCounter);
    OUTPUT(fileCounter).slept = EXCEL.Slept(fileCounter);
    OUTPUT(fileCounter).awake = EXCEL.Awake(fileCounter);
    OUTPUT(fileCounter).worked = EXCEL.Worked(fileCounter);
    OUTPUT(fileCounter).pfat = EXCEL.PFat(fileCounter);
    OUTPUT(fileCounter).mfat = EXCEL.MFat(fileCounter);
    OUTPUT(fileCounter).sq1 = EXCEL.SQ1(fileCounter);
    OUTPUT(fileCounter).sq2 = EXCEL.SQ2(fileCounter);
    OUTPUT(fileCounter).sq3 = EXCEL.SQ3(fileCounter);
    OUTPUT(fileCounter).sq4 = EXCEL.SQ4(fileCounter);
    OUTPUT(fileCounter).sq5 = EXCEL.SQ5(fileCounter);
    
    OUTPUT(fileCounter).channelMeans = EEG.channelMeans; 
    OUTPUT(fileCounter).channelCIs = EEG.channelCIs; 
    OUTPUT(fileCounter).channelVariance = EEG.channelVariance;
    OUTPUT(fileCounter).filterLow = EEG.filterLow;
    OUTPUT(fileCounter).filterHigh = EEG.filterHigh;
    OUTPUT(fileCounter).filterNotch = EEG.filterNotch;
    OUTPUT(fileCounter).filterOrder = EEG.filterOrder;
    OUTPUT(fileCounter).epochMarkers = EEG.epochMarkers;
    OUTPUT(fileCounter).epochTimes = EEG.epochTimes;
    OUTPUT(fileCounter).baselineWindow = EEG.baselineWindow;
    OUTPUT(fileCounter).artifactMethods = EEG.artifactMethods;
    OUTPUT(fileCounter).artifactCriteria = EEG.artifactCriteria;
    OUTPUT(fileCounter).artifactChannelPercentages = EEG.channelArtifactPercentages;
    
    OUTPUT(fileCounter).nbchan = EEG.nbchan;
    OUTPUT(fileCounter).eegTrials = EEG.trials; 
    OUTPUT(fileCounter).pnts = EEG.pnts;
    
    OUTPUT(fileCounter).erp = ERP.data;
    OUTPUT(fileCounter).epochCount = ERP.epochCount;
    OUTPUT(fileCounter).totalEpochs = ERP.totalEpochs;
    
    OUTPUT(fileCounter).trialsLost = ERP.epochCount/EEG.markerCount;
    OUTPUT(fileCounter).trialsLostC1 = ERP.epochCount(1)/EEG.markerCount(1);
    OUTPUT(fileCounter).trialsLostC2 = ERP.epochCount(2)/EEG.markerCount(2);

    OUTPUT(fileCounter).chanlocs = ERP.chanlocs;
    OUTPUT(fileCounter).srate = ERP.srate;
    OUTPUT(fileCounter).epochTime = ERP.epochTime;
    OUTPUT(fileCounter).timeVector = ERP.times;
    
    OUTPUT(fileCounter).fft = FFT.data;
    OUTPUT(fileCounter).fftrange = FFT.frequencies;
    OUTPUT(fileCounter).fftEpochCount = FFT.epochCount;
    OUTPUT(fileCounter).fftTotalEpochs = FFT.totalEpochs;

end

save('OUTPUT','OUTPUT');

% do some of the key analyses for Mat - look and see what this is doing
% this one is going to grab all the erp data
for counter = 1:size(OUTPUT,2)
    allERP(:,:,:,counter) = OUTPUT(counter).erp;
end
% create the grand average
meanERP = mean(allERP,4);
timeVector = OUTPUT(1).timeVector; 
% plot for all 4 channels
figure;
subplot(2,2,1);
plot(timeVector,meanERP(1,:,1));
hold on;
plot(timeVector,meanERP(1,:,2));
title('AF7');
subplot(2,2,2);
plot(timeVector,meanERP(2,:,1));
hold on;
plot(timeVector,meanERP(2,:,2));
title('AF7');
subplot(2,2,3);
plot(timeVector,meanERP(3,:,1));
hold on;
plot(timeVector,meanERP(3,:,2));
title('AF7');
subplot(2,2,4);
plot(timeVector,meanERP(4,:,1));
hold on;
plot(timeVector,meanERP(4,:,2));
title('AF7');

% challenge, Matt, repeat this code to analyze other variables such as
% epoch count, trials lost, etc.
for counter = 1:size(OUTPUT,2)
    allArtifacts(:,counter) = OUTPUT(counter).artifactChannelPercentages;
end
meanArtifacts = mean(allArtifacts,2);
stdArtifacts = std(allArtifacts,[],2);
cis = stdArtifacts*tinv(0.05,size(OUTPUT,2))/sqrt(size(OUTPUT,2));
figure;
barwitherr(cis,meanArtifacts);

% clear a* b* c* D* e* E* F* f* i* m* n* o* r* s* t* v* w*