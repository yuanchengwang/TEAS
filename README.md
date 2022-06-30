[![zh](https://img.shields.io/badge/lang-zh-green.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README-zh.md)
[![test](https://img.shields.io/badge/语言-测试-green.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README-zh.md)
# TEAS
TEAS: Transcription and Expressiveness Annotation System dedicated to Chinese Tranditional Instrument Pipa

############### Required package #################

This is developed on Windows and Matlab 2021a with all packages installed.
If you want to run the pyin (tony) as pitch tracker and pitch2note for note annotation, 
download sonic-annotator(64bit) and add it in the system path. 
Put the pyin_1.1.1.dll in vamplugin file in your system (C:\Program Files\Vamp Plugins for Windows) otherwise the n3 files don’t work.

################ Usage of enhanced AVA platform ##########################

1, Preset and Run Main file.
Set basic paramters in parameter_setting.m like the string properties, initial guess of BPM, etc. Set MIDI parameter in prototype_setting.m if you need special export for midi like the midi mode. 
All parameters are set by default specific to our study target, PIPA. 

Run GUI_Main.mat to activate UI in its path (Note: don’t change the directory path.)

2, Multi-track+MIDI Tab
2.1, Source separation(optional for multichannel signals.)
Import each track of audio/signal in the control panel (mono) in multitrack+MIDI tab.
Press ‘Signal Separation’ button to run the separation algorithm.
Export the audio signal and annotation for each track or get all debleeded files in ‘output’ directory.
Note: only the activated items can be saved by ‘Export All’ button. 

2.2, Global Visualization, MIDI export and Project save/load
The main music features can be globally visualized.
The advanced MIDI (MIDI with Continuous Controller, CC) can be exported by selecting the features and tracks after setting the CC channel or switch key for playing techniques.
The project can be saved or imported for user convenience. 

3, Monophonic Analysis
3.1, Audio Reading
Import denoised audio(Debleeded signal for optical signal) or raw monophonic audio if no need to denoise（Microphone captured solo signal）.

3.2, Pitch Detection
Select an appropriate pitch detector and run it, correct it.
BNLS or pYIN (Tony) is recommended. If pYIN doesn’t work, change the parameters in pyin.n3 file.
While converting the pitch area into unvoiced place, convert Yaxis into Frequency(Hz), select the pitch area and modify the area with 0. Remark the pitch error at the boundary.
A little bit boundary redundancy is favorable, a note-based boundary correction can be automatically realized whilst exporting pitch curve (Correct notes required). 

3.3, Onset/Offset Detection
double_peak parameter is activated for attack peak(for note segmentation) and natural transient (for intensity capture) in pipa case.
Logenergy is recommended for peak detection, remove the false positives and add the onsets for both peaks. Edge auto-adjustment serves to automatically adjust the point to the closest peak. 
Run offset detection after modifying the onsets.

3.4, Pitch2Note
If the Boundary is catastrophically bad, define the boundary first (select the onset/offset detection algorithm) then run the pitch2note algorithm.
Select an appropriate pitch2note method and run it, correct it. HMM+note (Modified Tony method) is preferable.
Check correct the boundary and pitch for special techniques(like vibrato、sliding、tremolo).

3.5, Vibrato analysis
Method 1:
The decision tree can be used if the parameters are given, the default parameters could give a wrong cold start.
Method 2:
select one of the FDM and periodogram as spectral estimator 
select one of the power difference and power ratio as detector
tweak the slider till the cold start goes to the best
finetune the edges of the the vibrato regions by double clicking
Method 2 is independant of the decision tree. 
Power difference and FDM is recommended while the high SNR. The periodogram can be referred in case of low SNR.
Note1: Vibrato are automatically clip in a note!!!!!Boundary needs to dilate.
Note2: vibrato can be changed as vibrato/trilling/bending，but Vibrato is default, do it yourself.

3.6, Sliding Analysis
Press the vibrato free note if there is at least a vibrato interval.
Press the getSliding(s) button, if the sliding intervals don’t get to your expectation, press it again.

Note1: Same as vibrato type, the sliding type can be changed，but sliding is set by default, change it yourself.
Note2: sliding cannot be located in a silence area. Boundary needs to define.

3.7, Tremolo Analysis
Press candidate notes to display the note areas.
Vib/Port-free (optional) used to remove the note with vibrato and sliding. not absolute, you could keep it with removing the option.
Choose log-energy or specslope.
Press the getTremolo(s) button and correct the pluck points( and natural transients if double_peak is activated).

4，Multitrack Technique Analysis
4.1, Strumming Analysis
Press multitrack button to activate a import window, 
Import the onsets/notes(pluck only) for different strings and press the test and plot button to display the imported note onsets. You could select a track to get the previous analyzed onset/note.
Get Strumming(s) and correct the strumming Area.

Warning: don't touch the method block while annotating, the modified annotation may be rewritten.

############### Future work ######################

——Undo module.
——MIDI prototype system.

############## Citation #######################

For Academic Use:
If you are using this platform in research work for publication, please cite:
Yuancheng Wang, Yuyang Jing, Wei Wei, Dorian Cazau, Olivier Adam, Qiao Wang. PipaSet and TEAS: A Multimodal Dataset and Annotation Platform for Automatic Music Transcription and Expressive Analysis dedicated to Chinese Plucked String Instrument Pipa. IEEE ACCESS, 2022.

The original code is based on the Luwei Yang's work:
If you are using AVA in research work for publication, please cite:
luweiyang.com/research/ava-project
1. Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis, In Proc. of the 42nd International Computer Music Conference (ICMC), September 2016.
2. Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: An Interactive System for Visual and Quantitative Analyses of Vibrato and Portamento Performance Styles, In Proc. of the 17th International Society for Music Information Retrieval Conference, 2016.


