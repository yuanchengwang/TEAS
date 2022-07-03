function [note_onset,duration]=hmm_note_core(midiPitchOriginal,time,pitchDeviation,onsetTime)
    global data;
    pitchFs = 1/(time(2)-time(1));
    noteRefineThresh = 0.05; 
    midiPitchOriginal = medf(midiPitchOriginal,5,length(midiPitchOriginal));   
    midiPitchGround = zeros(size(midiPitchOriginal));
    midiPitchCeil = zeros(size(midiPitchOriginal));
    midiPitchGround(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)-pitchDeviation(1);
    midiPitchCeil(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)+pitchDeviation(2);

    %get delta f0
    deltaMidiPitch = [0;diff(smooth(midiPitchOriginal,10))];
    deltaMidiPitch(abs(deltaMidiPitch) > 3) = 0; %it is necessary
    %-------END pitch pre-processing------------

    %%
    %stateRangeTransStructure = (0:384)'; %3*128+1, every midi note has 3 states: steady, transition-up, transiton-down

    %-----START of the MM note level model------
    lowest=data.str(data.track_index);
    highest=data.highest(data.track_index);
    stateRangeMIDINote = lowest{1}:highest{1}; %MIDI num [35:80] default
    numStateRangeMIDI = length(stateRangeMIDINote);
    numStatesNoteModel = 3*length(stateRangeMIDINote); %every midi note has three states: start-sustain-end
    %-----initial distribution---------------------
    %only can go to attack states.
    initalDistributionNoteModel = 1/numStateRangeMIDI*ones(3,1);
    initalDistributionNoteModel(2:end) = 0;
    initalDistributionNoteModel = repmat(initalDistributionNoteModel,numStateRangeMIDI,1);

    %--------transition matrix----------------
%         noteModelSelfTranPro = [0.3,0.8,0.2];   %the vector store note model self-transition probabilities. [startSelf,sustainSelf,endSelf]
    noteModelSelfTranPro = [0.1,0.9,0.4];
    noteTranSigma = 4; %the sigma (STD) for the note transition normal distribution
    transNoteModel = GetTransMatrixNoteModel(stateRangeMIDINote,noteModelSelfTranPro,noteTranSigma);

    %------observation matrix---------
    observationNoteModelOriginal = GetObservsMatrixNoteModel(midiPitchOriginal,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);
    observationNoteModelGround = GetObservsMatrixNoteModel(midiPitchGround,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);
    observationNoteModelCeil = GetObservsMatrixNoteModel(midiPitchCeil,deltaMidiPitch,stateRangeMIDINote,numStatesNoteModel);
    decodedHMMNote = zeros(length(midiPitchOriginal),3); 

    decodedHMMNote(:,1) = ViterbiAlgHMM(transNoteModel',observationNoteModelOriginal,initalDistributionNoteModel);

    decodedHMMNote(:,2) = ViterbiAlgHMM(transNoteModel',observationNoteModelGround,initalDistributionNoteModel);

    decodedHMMNote(:,3) = ViterbiAlgHMM(transNoteModel',observationNoteModelCeil,initalDistributionNoteModel);
    %make the resulte in MIDI scale
    decodedHMMNote = floor((decodedHMMNote)/3)+stateRangeMIDINote(1); 

    %-----END of the HMM note level model--------


    %%

    %get the voiced part directly from the pitch (assume non-zero values
    %are voiced) no need, we did it outside the hmm note core to avoid the
    %pitch deviation from boundary!
%     voicedPitch = zeros(size(decodedHMMNote));
%     voicedPitch(midiPitchOriginal > 0,1) = 1;
%     voicedPitch(midiPitchGround > 0,2) = 1;
%     voicedPitch(midiPitchCeil > 0,3) = 1;
%     decodedHMMNote = decodedHMMNote.*voicedPitch;

    %------Note aggregation-----------------
    notesHMMNoteModel = NoteAggreBaseline(decodedHMMNote,pitchFs);
    %---------------------------------------
    %------Small duration pruning---------
%         durationThresh = 0.1; %in seconds
%     notesHMMNoteModel = NotePruning_note(notesHMMNoteModel, durationThresh);
    %-------------------------------------

    %transform my format into Molina2014 format [start(s):end(s):MIDI NN]
    notesHMMNoteModelNew = cell(size(notesHMMNoteModel));
    for i = 1:length(notesHMMNoteModel)
        notesHMMNoteModelNew{1,i} = [notesHMMNoteModel{1,i}(:,1),notesHMMNoteModel{1,i}(:,1)+notesHMMNoteModel{1,i}(:,3),notesHMMNoteModel{1,i}(:,2)]+time(1);   
    end

    %------Spectral Flux onset correction-----
    for i = 1:length(notesHMMNoteModelNew)%Inside boundaries
        notesHMMNoteModelNew{1,i} = onsetCorrection(notesHMMNoteModelNew{1,i},onsetTime);
    end
    %-----------------------------------------   
    
    %------note refinement--------------
    %for i = 1:length(notesHMMNoteModelNew)
        notesHMMNoteModelNew{1,2} = noteRefinement(notesHMMNoteModelNew{1,2},noteRefineThresh); %{1,i}
    %end
    note_onset=notesHMMNoteModelNew{1,2}(:,1);
    duration=notesHMMNoteModelNew{1,2}(:,2)-notesHMMNoteModelNew{1,2}(:,1);%-data.win_length/2/data.fs
end