% software for analyzing multiple PEER oddball files at the same time. You must
% have an EXCEL spreadsheet with filenames in a column with the title of
% Filename.

clear all;
close all;
clc;

[fileName filePath] = uigetfile('*.xlsx');
cd(filePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% display channel variance
showChannelVariance = 0;                % set to 0 for batch scripts

% remove channels
channelsToRemove = {'AF7','AF8'};

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

% peak detection
meanWindowPoints = 10;
maxWindowPoints = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DO NOT CHANGE STUFF BELOW HERE

% load the EXCEL summary sheet that controls batch processing
try 
    EXCEL = readtable(fileName);
    numberOfFiles = size(EXCEL,1);
catch
    error('NO SUMMARY.xlsx FILE PRESENT TO LOAD');
end

for fileCounter = 1:numberOfFiles

    fileName = EXCEL.Filename{fileCounter};
    
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
    ERP = doERP(EEG,epochMarkers,0);
    
    OUTPUT(fileCounter).artifactChannelPercentages = EEG.channelArtifactPercentages;
    OUTPUT(fileCounter).eegTrials = EEG.trials; 
    
    OUTPUT(fileCounter).erp = ERP.data;
    OUTPUT(fileCounter).epochCount = ERP.epochCount;
    OUTPUT(fileCounter).totalEpochs = ERP.totalEpochs;
    
    OUTPUT(fileCounter).trialsLost = ERP.epochCount/EEG.markerCount;
    OUTPUT(fileCounter).trialsLostC1 = ERP.epochCount(1)/EEG.markerCount(1);
    OUTPUT(fileCounter).trialsLostC2 = ERP.epochCount(2)/EEG.markerCount(2);
    
    OUTPUT(fileCounter).timeVector = ERP.times;

end

timeVector = ERP.times;
ERP = [];
for counter = 1:size(OUTPUT,2)
    
    ERP(:,:,:,counter) = OUTPUT(counter).erp;
    artifactPercentages(counter) = OUTPUT(counter).artifactChannelPercentages;
    
end
ERP = squeeze(ERP);
grandERP = mean(ERP,3);
DW = ERP(:,2,:) - ERP(:,1,:);
DW = squeeze(DW);
grandDW = mean(DW,2);

subplot(1,2,1);
plot(timeVector,grandERP(:,1));
hold on;
plot(timeVector,grandERP(:,2));
title('Channel TP');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(1,2,2);
plot(timeVector,grandDW);
title('Channel TP');
ylabel('Voltage (uV)');
xlabel('Time (ms): Click on the N200 and P300 peaks');
[x y] = ginput(2);

for n200point = 1:size(timeVector,2)
    if timeVector(n200point) >= x(1)
        break
    end
end
for p300point = 1:size(timeVector,2)
    if timeVector(p300point) >= x(2)
        break
    end
end

n200MeanPeaks = mean(DW(n200point-meanWindowPoints:n200point+meanWindowPoints,:));
n200MeanTime = timeVector(n200point)*1000;
[n200MaxPeaks n200MaxLocations] = min(DW(n200point-maxWindowPoints:n200point+maxWindowPoints,:));
n200MaxTime = timeVector(n200MaxLocations+n200point-maxWindowPoints)*1000;

p300MeanPeaks = mean(DW(p300point-meanWindowPoints:p300point+meanWindowPoints,:));
p300MeanTime = timeVector(p300point)*1000;
[p300MaxPeaks p300MaxLocations] = max(DW(p300point-maxWindowPoints:p300point+maxWindowPoints,:));
p300MaxTime = timeVector(p300MaxLocations+p300point-maxWindowPoints)*1000;

clear artifactC* b* c* DW* EEG* e* E* f* i* n200point nu* O* p300point s* ty* x* y* m* n200MaxLocations p300MaxLocations;