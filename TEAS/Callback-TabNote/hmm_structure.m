function [note_onset,duration,avgPitch]=hmm_structure(pitchVibrato,time,h)
%HMM_baseline: Pitch2note using HMM with midi spelling
%voiced/onset/unvoiced and trend(steady,up,down)
% Reference: Baseline method in PROBABILISTIC TRANSCRIPTION OF SUNG MELODY USING A PITCH DYNAMIC MODEL
    global data;
    waitbar(0.1,h,sprintf('%d%% Pitch2Note converting...',10));
    pitchFs = 1/(time(2)-time(1));
    
    %-------------------------------------------------
    %get the power curve with the same sampling rate with the f0
    widowLengthf0 = 1024;
    stepf0 = round(44100/pitchFs); 
    % [powerCurve, timePowerCurve] = GetPowerCurve('../../Dataset/Huangjiangqin/Huangjiangqin-2.wav',widowLengthf0,stepf0);
%     [powerCurve, ZCRCurve, timePowerCurve] = GetPowerZCR([folderPath,'clk_vt_me01.wav'],widowLengthf0,stepf0);
    
    [powerCurve, ~, timePowerCurve] = GetPowerZCR(data.Cleaned_speech,widowLengthf0,stepf0,data.fs);
    %do interpolation if the size of power curve is not same as the f0
    powerCurve = spline(timePowerCurve,powerCurve,time);
    %ZCRCurve = spline(timePowerCurve,ZCRCurve,time);
    %-------------------------------------------------

    %-------START pitch pre-processing------------

    %--Median filtering----
    % pitchVibrato = medf(pitchVibrato',3,length(pitchVibrato))';

    %get pitch deviation
    pitchDeviation = GetPitchDeviation(pitchVibrato);
    pitchDevGround = pitchDeviation(1);
    pitchDevCeil = pitchDeviation(2);

    midiPitchVibrato = freqToMidi(pitchVibrato);

    midiPitchOriginal = freqToMidi(pitchVibrato);
    %--Median filtering----
    %midiPitchOriginal = medf(midiPitchOriginal,5,length(midiPitchOriginal));

    midiPitchGround = zeros(size(midiPitchOriginal));
    midiPitchCeil = zeros(size(midiPitchOriginal));
    midiPitchGround(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)-pitchDevGround;
    midiPitchCeil(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)+pitchDevCeil;

    %get delta f0
    deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,10))];
    waitbar(0.2,h,sprintf('%d%% Pitch2Note converting...',20));
    deltaMidiPitch(abs(deltaMidiPitch) > 3) = 0; %it is necessary
    %-------END pitch pre-processing------------

    %%

    stateRangeMIDI = [1:128]';
    stateRangeTransBaseline = [0:128]';  %128 midi notes "0" for silent state.
    stateRangeTransStructure = [0:384]'; %3*128+1, every midi note has 3 states: steady, transition-up, transiton-down
    stateRangeTransition = [-1,0,1]'; %the transition states: up, steady, down.

    %------------START of Baseline method----------------
    %Assign the f0 to the nearest MIDI NN
    decodedBaseline = round(midiPitchVibrato);
    %------------End of Baseline method------------------

    %---------Get initial state PDF, transiton matrix and observation matrix
    initialStateDistribution = 1/length(stateRangeTransStructure)*ones(1,length(stateRangeTransStructure));
    [transPitchBaseline,transPitchStructure] = ...
        GetTransMatrix(stateRangeTransBaseline,stateRangeTransition);
    waitbar(0.3,h,sprintf('%d%% Pitch2Note converting...',30));
    observsBaselineOriginal = GetObservsMatrixBaseline(midiPitchOriginal,stateRangeTransBaseline);
    observsBaselineGround = GetObservsMatrixBaseline(midiPitchGround,stateRangeTransBaseline);
    observsBaselineCeil = GetObservsMatrixBaseline(midiPitchCeil,stateRangeTransBaseline);

    observsStructureOriginal = ...
        GetObservsMatrixStructure(midiPitchOriginal,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    observsStructureGround = ...
        GetObservsMatrixStructure(midiPitchGround,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    observsStructureCeil = ...
        GetObservsMatrixStructure(midiPitchCeil,deltaMidiPitch,stateRangeMIDI,stateRangeTransition);
    %------------------------------
    waitbar(0.4,h,sprintf('%d%% Pitch2Note converting...',40));
    %-------Power curve HMM-------
    %two states: voiced and unvoiced
    initialStateDistributionPowerCurve = [0.5,0.5];
    transPowerCurve = [0.7,0.3;...
                       0.3,0.7];

    [~,observationMatrixPowerTemp] = GetObservsMatrixPower(powerCurve,stateRangeTransStructure);
    decodedPower =  ViterbiAlgHMM(transPowerCurve,observationMatrixPowerTemp,initialStateDistributionPowerCurve);

    decodedPower = 1./decodedPower;
    decodedPower(decodedPower == 0.5) = 0;
    %-------------------------------------------------------
    %%

    %-------START of HMM Baseline-------------
    %[original, ground, ceil]
    decodedHMMBase = zeros(length(midiPitchOriginal),3); 
    %midiTranscriptionCeilHMMBaseline = ViterbiAlgHMM(transPitchBaseline,observsBaselineCeil,initialStateDistribution);
    waitbar(0.5,h,sprintf('%d%% Pitch2Note converting...',50));
    decodedHMMBase(:,1) = ViterbiAlgHMM(transPitchBaseline,observsBaselineOriginal,initialStateDistribution);
    decodedHMMBase(:,2) = ViterbiAlgHMM(transPitchBaseline,observsBaselineGround,initialStateDistribution);
    decodedHMMBase(:,3) = ViterbiAlgHMM(transPitchBaseline,observsBaselineCeil,initialStateDistribution);
    waitbar(0.6,h,sprintf('%d%% Pitch2Note converting...',60));
    decodedHMMBase = decodedHMMBase-1;
    %-------END of HMM Baseline---------------

    %-------START of the HMM Sturcture------------
    %[original, ground, ceil]
    decodedHMMStru = zeros(length(midiPitchOriginal),3);    
    decodedHMMStru(:,1) = ViterbiAlgHMM(transPitchStructure,observsStructureOriginal,initialStateDistribution);
    decodedHMMStru(:,2) = ViterbiAlgHMM(transPitchStructure,observsStructureGround,initialStateDistribution);
    decodedHMMStru(:,3) = ViterbiAlgHMM(transPitchStructure,observsStructureCeil,initialStateDistribution);
    waitbar(0.7,h,sprintf('%d%% Pitch2Note converting...',70));
    decodedHMMStru = decodedHMMStru/3;
    decodedHMMStru(decodedHMMStru == (1/3)) = 0;

    decodedHMMStruSteady = zeros(size(decodedHMMStru));
    for i = 1:size(decodedHMMStru,2)
        decodedHMMStruSteady(decodedHMMStru(:,i)-floor(decodedHMMStru(:,i)) == 0,i) = decodedHMMStru(decodedHMMStru(:,i)-floor(decodedHMMStru(:,i)) == 0,i);
    end
    %-------END of the HMM Sturcture------------

    %-----START of the HMM note level model------
    stateRangeMIDINote = [0:128]; %MIDI num 1:128, 0 for silent
    numStateRangeMIDI = length(stateRangeMIDINote);
    numStatesNoteModel = 3*length(stateRangeMIDINote); %every midi note has three states: start-sustain-end
    %-----initial distribution---------------------
    %only can go to attack states.
    initalDistributionNoteModel = 1/numStateRangeMIDI*ones(3,1);
    initalDistributionNoteModel(2:end) = 0;
    initalDistributionNoteModel = repmat(initalDistributionNoteModel,numStateRangeMIDI,1);

    %--------transition matrix----------------
    noteModelSelfTranPro = [0.1,0.9,0.4];
    noteTranSigma = 4;
    transNoteModel = GetTransMatrixNoteModel(stateRangeMIDINote,noteModelSelfTranPro,noteTranSigma);

    %------observation matrix---------
    
    observationNoteModelOriginal = GetObservsMatrixNoteModel(midiPitchOriginal,deltaMidiPitch,stateRangeMIDI,numStateRangeMIDI);
    observationNoteModelGround = GetObservsMatrixNoteModel(midiPitchGround,deltaMidiPitch,stateRangeMIDI,numStateRangeMIDI);
    observationNoteModelCeil = GetObservsMatrixNoteModel(midiPitchCeil,deltaMidiPitch,stateRangeMIDI,numStateRangeMIDI);
    
    decodedHMMNote = zeros(length(midiPitchOriginal),3); 
    decodedHMMNote(:,1) = ViterbiAlgHMM(transNoteModel',observationNoteModelOriginal,initalDistributionNoteModel);
    decodedHMMNote(:,2) = ViterbiAlgHMM(transNoteModel',observationNoteModelGround,initalDistributionNoteModel);
    decodedHMMNote(:,3) = ViterbiAlgHMM(transNoteModel',observationNoteModelCeil,initalDistributionNoteModel);
    decodedHMMNote = floor((decodedHMMNote-1)/3);
    waitbar(0.8,h,sprintf('%d%% Pitch2Note converting...',80));
    notesBaseline = NoteAggreBaseline(decodedBaseline,pitchFs); 
    notesHMMBase = NoteAggreBaseline(decodedHMMBase,pitchFs);
    notesHMMStruSteady = NoteAggreBaseline(decodedHMMStruFollow,pitchFs);
    notesHMMNoteModel = NoteAggreBaseline(decodedHMMNote,pitchFs);
    %---------------------------------------

    %---------START OF fill gap------------------
    decodedHMMNoteGap(:,1) = FillGap(decodedHMMNote(:,1),decodedHMMStru(:,1),notesHMMNoteModel{1,1},pitchFs);
    decodedHMMNoteGap(:,2) = FillGap(decodedHMMNote(:,2),decodedHMMStru(:,2),notesHMMNoteModel{1,2},pitchFs);
    decodedHMMNoteGap(:,3) = FillGap(decodedHMMNote(:,3),decodedHMMStru(:,3),notesHMMNoteModel{1,3},pitchFs);
    %---------END OF fill gap------------------

    %------Small duration pruning---------
    durationThresh = 0.1; %in seconds
    notesBaseline = NotePruning_note(notesBaseline, durationThresh);
    notesHMMBase = NotePruning_note(notesHMMBase, durationThresh);
    notesHMMStruSteady = NotePruning_note(notesHMMStruSteady, durationThresh);
    notesHMMNoteModel = NotePruning_note(notesHMMNoteModel, durationThresh);
    %！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    note_onset=notesHMMNoteModel{1,1}(:,1);
    duration=notesHMMNoteModel{1,1}(:,2)-notesHMMNoteModel{1,1}(:,1);
    %-----------------------------------
    if ~isempty(note_onset)
        avgPitch=zeros(length(note_onset),1);
        for i=1:length(note_onset)
            avgPitch(i)=mean(pitchRaw(logical((time>=note_onset(i)).*(time<=note_onset(i)+duration(i)))));%averaging the pitch within a note
        end
        %Eliminate NAN and 0 notes
        nan_zero=(avgPitch==0)+(isnan(avgPitch));
        nan_zero=logical(nan_zero>0);
        note_onset(nan_zero)=[];
        duration(nan_zero)=[];
        avgPitch(nan_zero)=[];
    else
        avgPitch=[];
    end
    waitbar(0.9,h,sprintf('%d%% Pitch2Note converting...',90));
end