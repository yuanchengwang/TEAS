%Ample sound pipa
function AmpleChinaPipa_protocol
global protocol;
protocol.midimode='low';%An octave lower midi mode
protocol.valid=1;
%channel setting
protocol.note='C0';
protocol.string_force={'C1','B0','A0#','A0'};%1,2,3,4, fn required
protocol.vibrato='CC1';
protocol.trill='C0';%=note
protocol.bending='F0#';%vel127-63,63-1 speed
protocol.slide='E0';%vel127-63,63-1 speed
protocol.pull='G0#';%vel127-63,63-1 speed bend-up
protocol.push='G0';%bend down
protocol.hammer_on='C0';%=note
protocol.pull_off='C0';%=note
protocol.tremolo='D0#';%fn required
protocol.harmonic='C#0';
%Modification function
%protocol.fn.note=@;
%protocol.fn.XX_fn=@XX_fn(a) a+b;
end