function chord_xml(xml_path,chord)
if strcmp(xml_path(end-6:end),'pchords')
chordname={'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
docNode = com.mathworks.xml.XMLUtils.createDocument('Chords');
%commentElement = docNode.createComment('This is a comment');
%docRootNode    = docRootNode.appendChild(commentElement);


docRootNode = docNode.getDocumentElement();
docRootNode.setAttribute('Author','Yuancheng Wang');%Change it by your name
docRootNode.setAttribute('Category','Alternative');
docRootNode.setAttribute('Key','C');

for i = 1:size(chord,1)
    chordsnode=docNode.createElement('Chord');
    %chordsnode.appendChild(docNode.createTextNode(sprintf('Jack')));
    chordsnode.setAttribute('ID',num2str(i));
    chordsnode.setAttribute('Root',chordname{chord(i,5)});
    chordsnode.setAttribute('Type','User');
    chordsnode.setAttribute('Pos','User');
    for j=1:4 
        stringRootNode = docNode.createElement('String');
        stringRootNode.setAttribute('ID',num2str(j));
        stringRootNode.setAttribute('Fret',num2str(chord(i,j)));
        chordsnode.appendChild(stringRootNode);
    end
    %fprintf(fid,[' <Chord ID="',num2str(j),'" Root=",',chordname{chord(j,5)},'" Type="User" Pos="User">','\r\n']);
%     <String ID="4" Fret="3"/>
%     <String ID="3" Fret="2"/>
%     <String ID="2" Fret="3"/>
%     <String ID="1" Fret="3"/>
    docRootNode.appendChild(chordsnode);
end
xmlwrite(xml_path,docNode);
else
    msgbox('Bad format for pchords.');
end
end