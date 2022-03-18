% A script for analyzing multiple PEER files at the same time. You must
% save your files in .csv format. Put them in a directory with no other
% .csv files! Make sure this directory is the MATLAB working directory.

% clears all variables in memory, closes all plots, clears the command line
clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

% display channel variance
showChannelVariance = 0;                % set to 0 for batch scripts

% remove channels, set removeChannels to 1 and specify channels if desired
% (recommend do not do this)
removeChannels = 1;
channelsToRemove = {'AF7','AF8'};

% increase SNR by concatenating channels - not recommended set to 1 to use
increaseSNR = 1;

% filter parameters
filterOrder = 2;
filterLow = 0.1;                        % always keep at 0.1
filterHigh = 30;                        % set to 15 for ERP analyses, set to 30 or higher for FFT
filterNotch = 60;                       % unless in Europe use 60

% epoch parameters
epochMarkers = {'S  5','S  6'};        % the markers 5 is control 6 is oddball
currentEpoch = [-200 798];             % the time window

% baseline window
baseline = [-200 0];                    % the baseline, recommended -200 to 0

% artifact criteria
typeOfArtifactRejction = 'Difference';  % max - min difference
artifactCriteria = 60;                  % recommend maxmin of 75
individualChannelAveraging = 0;         % set to one for individual channel averaging

% peak detection
meanWindowPoints = 10;
maxWindowPoints = 25;

% specify condition and subject numbers, this is to sort the data posthoc.
% Note, this will only work if all your filenames are consistent.

numberOfConditions = 4;
numberOfParticipants = 32;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DO NOT CHANGE STUFF BELOW HERE

% load the EXCEL summary sheet that controls batch processing
files = dir('*.csv');
numberOfFiles = size(files,1);

if numberOfConditions*numberOfParticipants ~= numberOfFiles

    disp('There is a mismatch between the number of actual files and the number of conditions and participants you specified. Fix and rerun');
    return;

end

for fileCounter = 1:numberOfFiles

    disp(['Analyzing file number:' num2str(fileCounter)])
    
    fileName = files(fileCounter).name;
    
    % load the data
    EEG = doLoadMUSE(fileName);
    
    % compute channel variances
    EEG = doChannelVariance(EEG,showChannelVariance);

    if removeChannels == 1
        % option to remove front channels
        EEG = doRemoveChannels(EEG,channelsToRemove,EEG.chanlocs);
    end

    % filter the data
    EEG = doFilter(EEG,filterLow,filterHigh,filterOrder,filterNotch,EEG.srate);

    % epoch data
    EEG = doSegmentData(EEG,epochMarkers,currentEpoch); %Updated to doLoadMUSE nomenclature

    % concatenate data to increase SNR
    if increaseSNR == 1
        EEG = doIncreasePEERSNR(EEG,2);
    end

    % baseline correction
    EEG = doBaseline(EEG,baseline);

    % identify artifacts
    EEG = doArtifactRejection(EEG,typeOfArtifactRejction,artifactCriteria);

    % remove bad trials
    EEG = doRemoveEpochs(EEG,EEG.artifact.badSegments,individualChannelAveraging); %Updated to doLoadMUSE nomenclature

    % make ERPs
    ERP = doERP(EEG,epochMarkers,0);

    % add the channel artifact percentages to the ERP variable
    ERP.artifacts = EEG.channelArtifactPercentages;

    newFileName = fileName(1:end-4);
    save(newFileName,'ERP');

end

return

timeVector = ERP.times;
ERP = [];
for counter = 1:size(OUTPUT,2)
    
    ERP(:,:,:,counter) = OUTPUT(counter).erp;
    artifactPercentages(:,:,:,:,counter) = OUTPUT(counter).artifactChannelPercentages;
    
end
ERP = mean(ERP,1);
grandERP = squeeze(mean(ERP,4));
DW = squeeze(ERP(:,:,2) - ERP(:,:,1));
grandDW = mean(DW,1);

%Updated to doLoadMUSE nomenclature

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

n200MeanPeaks = mean(DW(:,n200point-meanWindowPoints:n200point+meanWindowPoints));
n200MeanTime = timeVector(n200point);
[n200MaxPeaks n200MaxLocations] = min(DW(:,n200point-maxWindowPoints:n200point+maxWindowPoints));
n200MaxTime = timeVector(n200MaxLocations+n200point-maxWindowPoints);

p300MeanPeaks = mean(DW(:,p300point-meanWindowPoints:p300point+meanWindowPoints));
p300MeanTime = timeVector(p300point);
[p300MaxPeaks p300MaxLocations] = max(DW(:,p300point-maxWindowPoints:p300point+maxWindowPoints));
p300MaxTime = timeVector(p300MaxLocations+p300point-maxWindowPoints);

% clear artifactC* b* c* DW* EEG* e* E* f* i* n200point nu* O* p300point s* ty* x* y* m* n200MaxLocations p300MaxLocations;