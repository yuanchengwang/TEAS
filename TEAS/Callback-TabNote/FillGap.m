function [ decodedHMMNoteNew ] = FillGap( decodedHMMNote, decodedHMMStru,notesHMMNoteModel,pitchFs)
%FILLGAP Fills the gap between notes from HMM note model using the outputs
%from structure HMM.
%   Input:
%   @decodedHMMNote: the decoded sequence from HMM note model that will be
%   filled.
%   @decodedHMMStru: the decoded sequence from HMM structure.
%   @notesHMMNoteModel: the notes from HMM note model.
%   @pitchFs: pitch samping rate.
%   Output:
%   @decodedHMMNoteNew: the filled decoded sequence.


    %get the gap between any two pair of notes
    decodedHMMNoteNew = decodedHMMNote; 
    notesGap = zeros(size(notesHMMNoteModel,1)-1,size(notesHMMNoteModel,2));

    for i = 1:size(notesGap,1)
       notesGap(i,1) =  notesHMMNoteModel(i,1)+notesHMMNoteModel(i,3);
       notesGap(i,3) = notesHMMNoteModel(i+1)-notesGap(i,1);
       notesGap(i,4) = i;
    end

    %get the gaps between ntoes from HMM note model
    notesGap(notesGap(:,3) < (1/pitchFs),:) = [];

    for i = 1:size(notesGap,1)
        startPoint = round(notesGap(i,1)*pitchFs);
        endPoint = round((notesGap(i,1)+notesGap(i,3))*pitchFs);
        tempGap = decodedHMMStru(startPoint:endPoint);

        if notesHMMNoteModel(notesGap(i,4),2) < notesHMMNoteModel(notesGap(i,4)+1,2)
            %the precedent note is lower than subsequent note in pitch

            %transition-down
            downRangeFrame = [];
            downIndex = find(abs(mod(tempGap,1)-2/3) < 1e-5);
            if isempty(downIndex) == 0
                downRangeFrame = [downIndex(1);downIndex(end)];
                %only get the consecutive section
                for t = 2:length(downIndex)
                    %make sure start from the beginning
                    if downIndex(1) ~= 1
                        downRangeFrame = [];
                        break;
                    end
                    %make sure it is continuous
                    if abs(downIndex(t)-downIndex(t-1)) ~= 1
                        downRangeFrame(2) = t;
                        break;
                    end
                end
            end

            %transition-up
            upRangeFrame = [];
            upIndex = find(abs(mod(tempGap,1)-1/3) < 1e-5);
            if isempty(upIndex) == 0
                upRangeFrame = [upIndex(1);upIndex(end)];
                %only get the consecutive section
                for t = length(upIndex)-1:-1:1
                    %make sure start from the ending
                    if upIndex(end) ~= length(tempGap)
                        upRangeFrame = [];
                        break;
                    end
                    %make sure it is continuous
                    if abs(upIndex(t) - upIndex(t+1)) ~=1
                        upRangeFrame(2) = t;
                        break;
                    end
                end
            end

            %replace the corresponding section
            if isempty(downRangeFrame) == 0
                decodedHMMNoteNew(startPoint+[downRangeFrame(1):downRangeFrame(2)]-1) = decodedHMMNoteNew(startPoint-1);
            end
            if isempty(upRangeFrame) == 0
                decodedHMMNoteNew(startPoint+[upRangeFrame(1):upRangeFrame(2)]-1) = decodedHMMNoteNew(endPoint+1);
            end
        elseif notesHMMNoteModel(notesGap(i,4),2) > notesHMMNoteModel(notesGap(i,4)+1,2)
            %the precedent note is larger than subsequent note in pitch

            %transition-up
            upRangeFrame = [];
            upIndex = find(abs(mod(tempGap,1)-1/3) < 1e-5);
            if isempty(upIndex) == 0
                upRangeFrame = [upIndex(1);upIndex(end)];
                %only get the consecutive section
                for t = 2:length(upIndex)
                    %make sure start from the beginning
                    if upIndex(1) ~= 1
                        upRangeFrame = [];
                    end     
                    %make sure it is continuous
                    if abs(upIndex(t)-upIndex(t-1)) ~= 1
                        upRangeFrame(2) = t;
                        break;
                    end
                end
            end        

            %transition-down
            downRangeFrame = [];
            downIndex = find(abs(mod(tempGap,1)-2/3) < 1e-5);
            if isempty(downIndex) == 0
                downRangeFrame = [downIndex(1);downIndex(end)];
                %only get the consecutive section
                for t = length(downIndex)-1:-1:1
                    %make sure start from the ending
                    if downIndex(end) ~= length(tempGap)
                        downRangeFrame = [];
                        break;
                    end
                    %make sure it is continuous
                    if abs(downIndex(t) - downIndex(t+1)) ~=1
                        downRangeFrame(2) = t;
                        break;
                    end
                end
            end

            %replace the corresponding section
            if isempty(downRangeFrame) == 0
                decodedHMMNoteNew(startPoint+[downRangeFrame(1):downRangeFrame(2)]-1) = decodedHMMNoteNew(startPoint+11);
            end
            if isempty(upRangeFrame) == 0
                decodedHMMNoteNew(startPoint+[upRangeFrame(1):upRangeFrame(2)]-1) = decodedHMMNoteNew(endPoint-1);
            end        

        end
    end

end

