function protocol=protocolsetting
%default protocol setting for 
%Types: Continuous Controller(CC)
protocol.valid=0;
protocol.midimode='Other';%'default' standard midi mode,double for ample sound pipa.depends on the DAW
protocol.note='C0';
protocol.string_force={'C1','B0','A0#','A0'};%1,2,3,4, fn required
protocol.vibrato='CC1';%'CC1'=vibrato extend control,'PB'=vibrato pitch fluctuation,'?0' key for note.
protocol.vibrato_type='note';%note:note->vib->note; range: interval triggered.
protocol.vibrato_CC_range=1;%1 semi-tone for a range and normalized to 127 for max mod range in ACP, depends on synthesizer preset.
protocol.trill=[];%=note, the subitems will be support in the future
protocol.bending=[];%vel127-63,63-1 speed
protocol.slide='E0';%vel127-63,63-1 speed
protocol.slide_in='E0';%vel127-63,63-1 speed
protocol.slide_out='E0';
% protocol.hammer_on=[];%=note
% protocol.pull_off=[];%=note
protocol.tremolo='D0#';
protocol.strumming=[];%'C#6';
protocol.resolution=120;
protocol.CC_resolution=120;%for CC and pitch bend
%protocol.
end