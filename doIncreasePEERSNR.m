function [inputData] = doIncreasePEERSNR(inputData,optionFlag)

    % function by Olave Krigolson, April 2019
    % the purpose of this function is to effectively double the number of
    % trials for PEER / MUSE data sets by assuming that the data on
    % channels AF/AF8 and TP9/TP10 are mirrored but slightly different.
    % The logic here is based on obsevrations in the Krigolson Lab that the
    % P300 on channels TP9 and TP10 are highly correlated. Note, this is
    % only done if it is not possible to increase the number of trials -
    % this is a last case ditch effort to increase SNR (number of trials)
    % when no other method is feasible. This will create two new channels
    % AF and TP which are the concatenated data from AF7/TP9 and AF8/TP10.
    % The event structure is double so events can be combined into ERPs,
    % etc.
    % option flag indicates if the front channels are removed or not. If
    % set to 0 if all channels are present and you want to pool AF7 and AF8
    % and then TP9 and TP10, if set to 1 the assumption is the back
    % channels are deleted and only the front channels are pooled, if set
    % to 2 then the assumption is the front channels are deleted and only
    % the back channels are pooled
    
    if optionFlag == 0
    
        currentNumberOfTrials = size(inputData.data,3);
        newNumberOfTrials = 2*currentNumberOfTrials;
        tempFrontChannel = [];
        tempBackChannel = [];
        tempFrontChannel(1,:,1:currentNumberOfTrials) = inputData.data(1,:,1:currentNumberOfTrials); 
        tempFrontChannel(1,:,currentNumberOfTrials+1:newNumberOfTrials) = inputData.data(2,:,1:currentNumberOfTrials);
        tempBackChannel(1,:,1:currentNumberOfTrials) = inputData.data(3,:,1:currentNumberOfTrials); 
        tempBackChannel(1,:,currentNumberOfTrials+1:newNumberOfTrials) = inputData.data(4,:,1:currentNumberOfTrials);
        inputData.allMarkers(currentNumberOfTrials+1:newNumberOfTrials,:) = inputData.allMarkers(1:currentNumberOfTrials,:);
        inputData.epoch(currentNumberOfTrials+1:newNumberOfTrials) = inputData.epoch;
        inputData.data = [];
        inputData.data(1,:,:) = tempFrontChannel;
        inputData.data(2,:,:) = tempBackChannel;
        inputData.nbchan = 2;
        inputData.trials = newNumberOfTrials;
        inputData.chanlocs(5).labels = 'AF';
        inputData.chanlocs(5).type = [];
        inputData.chanlocs(5).theta = 0.0;
        inputData.chanlocs(5).radius = 0.5111;
        inputData.chanlocs(5).X = 0.7875;
        inputData.chanlocs(5).Y = 0.0;
        inputData.chanlocs(5).Z = -0.0349;
        inputData.chanlocs(5).sph_theta = 0.0;
        inputData.chanlocs(5).sph_phi = -2.0;
        inputData.chanlocs(5).sph_radius = 1.0;
        inputData.chanlocs(5).urchan = 1;
        inputData.chanlocs(5).ref = [];
        inputData.chanlocs(6).labels = 'TP';
        inputData.chanlocs(6).type = [];
        inputData.chanlocs(6).theta = 0.0;
        inputData.chanlocs(6).radius = 0.6389;
        inputData.chanlocs(6).X = -0.2801;
        inputData.chanlocs(6).Y = 0.0;
        inputData.chanlocs(6).Z = -0.4226;
        inputData.chanlocs(6).sph_theta = 0.0;
        inputData.chanlocs(6).sph_phi = -26.0;
        inputData.chanlocs(6).sph_radius = 1.0;
        inputData.chanlocs(6).urchan = 2;
        inputData.chanlocs(6).ref = [];
        inputData.chanlocs(1:4) = [];
        
    end
    if optionFlag == 1
        
        currentNumberOfTrials = size(inputData.data,3);
        newNumberOfTrials = 2*currentNumberOfTrials;
        tempFrontChannel = [];
        tempFrontChannel(1,:,1:currentNumberOfTrials) = inputData.data(1,:,1:currentNumberOfTrials); 
        tempFrontChannel(1,:,currentNumberOfTrials+1:newNumberOfTrials) = inputData.data(2,:,1:currentNumberOfTrials);
        inputData.allMarkers(currentNumberOfTrials+1:newNumberOfTrials,:) = inputData.allMarkers(1:currentNumberOfTrials,:);
        inputData.epoch(currentNumberOfTrials+1:newNumberOfTrials) = inputData.epoch;
        inputData.data = [];
        inputData.data(1,:,:) = tempFrontChannel;
        inputData.nbchan = 1;
        inputData.trials = newNumberOfTrials;
        inputData.chanlocs(1:2) = [];
        inputData.chanlocs(1).labels = 'AF';
        inputData.chanlocs(1).type = [];
        inputData.chanlocs(1).theta = 0.0;
        inputData.chanlocs(1).radius = 0.5111;
        inputData.chanlocs(1).X = 0.7875;
        inputData.chanlocs(1).Y = 0.0;
        inputData.chanlocs(1).Z = -0.0349;
        inputData.chanlocs(1).sph_theta = 0.0;
        inputData.chanlocs(1).sph_phi = -2.0;
        inputData.chanlocs(1).sph_radius = 1.0;
        inputData.chanlocs(1).urchan = 1;
        inputData.chanlocs(1).ref = [];        
        
    end
    if optionFlag == 2
        
        currentNumberOfTrials = size(inputData.data,3);
        newNumberOfTrials = 2*currentNumberOfTrials;
        tempBackChannel = [];
        tempBackChannel(1,:,1:currentNumberOfTrials) = inputData.data(1,:,1:currentNumberOfTrials); 
        tempBackChannel(1,:,currentNumberOfTrials+1:newNumberOfTrials) = inputData.data(2,:,1:currentNumberOfTrials);
        inputData.allMarkers(currentNumberOfTrials+1:newNumberOfTrials,:) = inputData.allMarkers(1:currentNumberOfTrials,:);
        inputData.epoch(currentNumberOfTrials+1:newNumberOfTrials) = inputData.epoch;
        inputData.data = [];
        inputData.data(1,:,:) = tempBackChannel;
        inputData.nbchan = 1;
        inputData.trials = newNumberOfTrials;
        inputData.chanlocs(1:2) = [];
        inputData.chanlocs(1).labels = 'TP';
        inputData.chanlocs(1).type = [];
        inputData.chanlocs(1).theta = 0.0;
        inputData.chanlocs(1).radius = 0.6389;
        inputData.chanlocs(1).X = -0.2801;
        inputData.chanlocs(1).Y = 0.0;
        inputData.chanlocs(1).Z = -0.4226;
        inputData.chanlocs(1).sph_theta = 0.0;
        inputData.chanlocs(1).sph_phi = -26.0;
        inputData.chanlocs(1).sph_radius = 1.0;
        inputData.chanlocs(1).urchan = 2;
        inputData.chanlocs(1).ref = [];

    end
    
end