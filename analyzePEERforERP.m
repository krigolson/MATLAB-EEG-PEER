clear all;
close all;
clc;

% analyze a single PEER subject and generate peak data and single subject
% waveforms. Note, you have to select a PEER export file in csv format and
% not the full data export. This is specifically intended for the PEER
% oddball paradigm series. Note, this code also deletes channels AF7 and
% AF8 and combines TP9 and TP10

% VARIABLES

[fileName filePath] = uigetfile('*.csv');

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

% artifact criteria
typeOfArtifactRejction = 'Difference';  % max - min difference
artifactCriteria = 50;                  % recommend maxmin of 75
individualChannelAveraging = 0;         % set to one for individual channel averaging

% internal consistency
computeInternalConsistency = 0;         % set to 1 to do odd even averaging to allow computation of internal consistency

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMANDS
   
% remove the .csv
fileName(end-3:end) = [];
EEG = doLoadPEER(fileName,epochMarkers);

% compute channel variances
EEG = doChannelVariance(EEG,showChannelVariance);
    
% option to remove front channels
EEG = doRemoveChannels(EEG,channelsToRemove,EEG.chanlocs);
    
% filter the data
EEG = doFilter(EEG,filterLow,filterHigh,filterOrder,filterNotch,EEG.srate);

% epoch data
EEG = doSegmentData(EEG,epochMarkers,currentEpoch);

% concatenate data to increase SNR
EEG = doIncreasePEERSNR(EEG,2);

% baseline correction
EEG = doBaseline(EEG,baseline);
    
% identify artifacts
EEG = doArtifactRejection(EEG,typeOfArtifactRejction,artifactCriteria);

% remove bad trials
EEG = doRemoveEpochs(EEG,EEG.artifactPresent,individualChannelAveraging);

% make ERPs
ERP = doERP(EEG,epochMarkers,computeInternalConsistency);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT THE OUTPUT

% plot the results
subplot(1,2,1);
plot(ERP.times,ERP.data(1,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(1,:,2),'LineWidth',3);
hold off;
title('Channel TP');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

dw = squeeze(ERP.data(1,:,2) - ERP.data(1,:,1));

subplot(1,2,2);
plot(ERP.times,dw,'LineWidth',3);
title('TP Difference Wave');
ylabel('Voltage (uV)');
xlabel('Time (ms): Click on the N200 and P300');

[x y] = ginput(2);

for n200point = 1:size(ERP.times,2)
    if ERP.times(n200point) >= x(1)
        break
    end
end
for p300point = 1:size(ERP.times,2)
    if ERP.times(p300point) >= x(2)
        break
    end
end

n200peak = dw(n200point);
n200time = ERP.times(n200point);
p300peak = dw(p300point);
p300time = ERP.times(p300point);

disp(['The N200 amplitude is ' num2str(n200peak) 'uV and occured at ' num2str(round(n200time*1000)) ' ms.']);
disp(['The P300 amplitude is ' num2str(p300peak) 'uV and occured at ' num2str(round(p300time*1000)) ' ms.']);

disp(['The total artifact percentage is ' num2str(EEG.channelArtifactPercentages) '%.']);

conditionalWaveforms = squeeze(ERP.data);
differeneWaveform = dw;
timePoints = ERP.times*1000;

clear a* b* ch* cu* com* dw ERP EEG e* f* i* r* s* ty* x* y*