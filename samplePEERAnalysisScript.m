clear all;
close all;
clc;

% todo list
% PEER artifact algorithm? 
% compute RTs and accuracy

% VARIABLES

fileName = 'testData1';

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMANDS

EEG = doLoadPEER(fileName,epochMarkers);

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
WAV = doWAV(EEG,epochMarkers,waveletBaseline,waveletMin,waveletMax,waveletSteps,mortletParameter);

DISC.EEG = EEG;
DISC.ERP = ERP;
DISC.FFT = FFT;
DISC.WAV = WAV;
save(fileName,'DISC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT THE OUTPUT

% plot the results
subplot(4,4,1);
plot(ERP.times,ERP.data(1,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(1,:,2),'LineWidth',3);
hold off;
title('Channel AF7');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(4,4,2);
plot(ERP.times,ERP.data(2,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(2,:,2),'LineWidth',3);
hold off;
title('Channel AF8');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(4,4,3);
plot(ERP.times,ERP.data(3,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(3,:,2),'LineWidth',3);
hold off;
title('Channel TP9');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(4,4,4);
plot(ERP.times,ERP.data(4,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(4,:,2),'LineWidth',3);
hold off;
title('Channel TP10');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(4,4,5);
dataToPlot = squeeze(FFT.data(1,1:30,:));
bar(dataToPlot);
title('FFT Analysis');
xticks([1:1:30]);
xticklabels(FFT.frequencies);
xlabel('Frequency (Hz)');
ylabel('Power (uV^2)');

subplot(4,4,6);
dataToPlot = squeeze(FFT.data(2,1:30,:));
bar(dataToPlot);
title('FFT Analysis');
xticks([1:1:30]);
xticklabels(FFT.frequencies);
xlabel('Frequency (Hz)');
ylabel('Power (uV^2)');

subplot(4,4,7);
dataToPlot = squeeze(FFT.data(3,1:30,:));
bar(dataToPlot);
title('FFT Analysis');
xticks([1:1:30]);
xticklabels(FFT.frequencies);
xlabel('Frequency (Hz)');
ylabel('Power (uV^2)');

subplot(4,4,8);
dataToPlot = squeeze(FFT.data(4,1:30,:));
bar(dataToPlot);
title('FFT Analysis');
xticks([1:1:30]);
xticklabels(FFT.frequencies);
xlabel('Frequency (Hz)');
ylabel('Power (uV^2)');

subplot(4,4,9);
dataToPlot = squeeze(WAV.data(3,:,:,1));
imagesc(dataToPlot);
title('Channel TP9: Condition One');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(dataToPlot,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);

subplot(4,4,10);
dataToPlot = squeeze(WAV.data(3,:,:,2));
imagesc(dataToPlot);
title('Channel TP9: Condition Two');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(dataToPlot,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);

subplot(4,4,11);
dataToPlot = squeeze(WAV.data(4,:,:,1));
imagesc(dataToPlot);
title('Channel TP10: Condition One');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(dataToPlot,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);

subplot(4,4,12);
dataToPlot = squeeze(WAV.data(4,:,:,2));
imagesc(dataToPlot);
title('Channel TP10: Condition Two');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(dataToPlot,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);

subplot(4,4,13);
bar(EEG.channelArtifactPercentages);
xlabel('Channel');
ylabel('Artifact Percentage');
ylim([0 100]);

subplot(4,4,14);
bar(EEG.channelVariance);
xlabel('Channel');
ylabel('Channel Variance');