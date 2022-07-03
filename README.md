<p align="center">
  <img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/TEXTLOGO.png" />
</p>

[![zh](https://img.shields.io/badge/点击这里-查看中文文档-green.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README-zh.md)

# TEAS Quick Start

**Quick Tutorial for Transcription and Expressiveness Annotation System dedicated to Chinese traditional instrument Pipa**

## Prerequisite：

- Install MATLAB version R2021a or above, with all optional packages. Implemented on Windows, this system may have some issues for other OS.

- If use `pyin(tony)` as `pitch tracker`, please install `sonic-annotator(64bit)` and add its installation path to SYSTEM PATH. Also, paste `pyin_1.1.1.dll` into `C:\Program Files\Vamp Plugins`.

## Starting up TEAS:

- Create a new folder for your project referring to the files in Pipaset preview (See details below)
  
  - Naming scheme
    
    - Audio source:    `Name`_source`Track number`.wav
      
      Example:    `NanniBay_source1.wav`
    
    - <u>Dataset file</u>:    `Name`_source `Track number` _`Type` _str`String number`.csv
      
      Example:    `NanniBay_source1_edge_str1.csv`
    
    - Backup file:    `Source file name`_original.csv
      
      Example:    `NanniBay_source1_pitch_str1_original.csv`
    
    <u>(*):</u>TEAS will automatically determine the default file name via string index and name of the audio source. 

- Configure the parameters e.g. `string_index`, initial guess of BPS 'beats_per_second' etc in `parametersetting.m`, in addition of synthesizer control-key setting in `protocolsetting.m` for MIDI export. All parameters are set specific to pipa and MIDI output following the setting of the Ample China Pipa (ACP) synthesizer.

- Run `GUI_Main.m` to launch the platform



## TEAS Workflow:

The workflow of TEAS consists of main steps below:

- [MSS(Multichannel signal separation)(Optional)](#MSS)

- [I, AMT(Automatic music transcription)](#AMT)
  
  1. Import denoised audio source
  
  2. Pitch Detection
  
  3. Boundary Detection
  
  4. Note Segmentation

- [II, EA(Expressive Analysis)](#EA)
  
  1. Vibrato Analysis
  
  2. Sliding Analysis
  
  3. Tremolo Analysis
  
  4. Strumming Analysis

- [III, Multitrack Visualization and MIDI export](#Multitrack)
  
  1. Multitrack+MIDI

### MSS

(Optional) Import audio source with mutual resonance via 'Audio import' in each track of Multitrack+MIDI tab. Then click `Signal Separation` button to run the MSS. Export the debleeded signal via 'Audio export' from each track of Multitrack+MIDI tab. This step will effectively reduce the interference among the strings.

### AMT

##### Import audio source

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-13-image.png)

- In `ReadAudio` tab, import denoised/debleeded audio source with `Import Denoised Wave` button. Make sure the string index of imported audio identical to that in `parametersettings.m`

##### Pitch Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-04-image.png)

- Navigate to `Pitch Detection` tab

- Select a pitch tracker.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-00-22-image.png)
  
  - pYin(tony): Fastest, great pitch detector with insufficient consistency in time for articulation like tremolo.
  
  - BNLS: Slowest, better consistency in time but slightly worse in pitch. Rough crop for the pitch curve is required (Recommended in complex articulation cases).
  
  - A backup of the manually processed original pitch file is recommended for later use. We save it with  `_original` at the end of the filename. 

- Pitch editing:
  
  - Pitch from other string's vibration is recommended to manually remove(convert to unvoiced place, see pitch error correction below). Hint: Playback is provided and the spectrogram behind pitch curve is available.
  
  - Import and export Pitch Curve
    
    - How to export：Click `Export Pitch Curve` button, select the saving path.
    
    - How to import：Click `Import Pitch Curve` button, select the loading path.
  
  - Pitch error correction
    
    - Select the defective pitch segment after clicking `Select Pitch Area` button or select a single point by clicking directly on the pitch curve, input the desired pitch value in `single point modification` then click the `Modify` button. 0 corresponds to unvoiced areas.
    
    - Octave error may occur. Select the area and octave up or down by `Up` or the `Down` button.
    
    Pitch editing examples:![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-07-34-image.png)
    
    As shown in the figure: octave error in pitch curve located within 88 and 94 seconds.(B3-> B2), <u>Solution to this problem</u>: select the defective area and click the `Up` button.
    
    Result：![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-08-13-image.png)

##### Boundary Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-14-22-image.png)

- Boundary definition for pipa:
  
  - Onset = The start of each MIDI note
  
  - Offset = The end of each MIDI note
  
  - The fake nails will produce a crisp sound and envelope peak while touching the string corresponding to the MIDI start, i.e. key-on. The following second peak indicates the natural transient from the string which serves to the strength/velocity estimation. Each note has two onsets and a single offset for pipa case.

- Note Annotation for a single pluck
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-27-49-image.png)
  
  - As shown in the figure: Gray rectangles represent notes, red lines the onset points, yellow lines the offset which may be covered by the onsets of the subsequent notes. 

- Note annotation in TREMOLO case 
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
  
  - Only the first(from pluck noise) and the last peak(natural transient) within the Tremolo note need to mark.
  
- To remove Onsets/Offsets/Notes:
    
  - Select the Onset/Offset/Note(Approximate position is ok for onset/offset, the closest one will be chosen; click on the rectangle to select a note), then click `Delete Onset` or `Detele Offset` or `Delete Note`, or simply keypress `Backspace`. 
    
  - You can speed up the workflow by Using the `Select Boundary Area` button to select all Onsets and Offsets in a certain area, and delete only Onsets or Offsets with `Delete Onset` or `Detele Offset` button, or keypress `Backspace` on to remove all selected boundaries.
  
- To add Onsets/Offsets/Notes:
    
  - Click `Add Onset` button, then click on an approximate position of peak(the closest peak will be chosen for onset if 'Onset auto-adjustment' checkbox is active).
  
  - No adjustment for offset.
  
  - Click `Add Note` button, then select an area within the area you want(interval overlap is not allowed in monphonic case), the pitch and the interval will be adjusted automatically. 
  
##### Note Segmentation using Corrected Boundaries
    
    - Click on `Onset Detection` button, the potential peaks for onsets will be shown (*High false positive outcome as the deleting is easier than adding*). 
    
    - Remove all detective onsets from unvoiced and tremolo intervals. 
    
      Hint: `Select Boundary Area` will speed up the process. 
      
      Hint: you can toggle `Plot Audio` checkbox to determine all the boundary positions.
    
    - Given the corrected onsets, detect the offsets via the `Offset Detection` button. Some of them can be invisible due to the onset overlap of the following note.
    
    - When all boundaries are done, notes can be generated by simply clicking on the `Pitch2note` button. An alternative correction between boundary and notes will imporve the accuracy.
    
    - Notice: Even number of onsets must be ensured before running offset detection and pitch2note functions.
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-53-18-image.png)
    
    - What a correct single-pluck note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-55-44-image.png)
    
    - What a correct tremolo note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-56-19-image.png)
    
    - The notes can be exported for overall validation by clicking the `Export Notes` button, and then change the format from  `.csv` to `.mid`. There will be a prompt to BPM selection and how to set your own initial guess of BPM. When examinating, pay attention to missing Notes/Notes with wrong Pitch.
  
  Notice that the BPM/BPS are neccessary for music notation generation. An arbitrary value works for a synthesis-only use.
  
  - Import and Export of Boundaries and Notes
    
    - Boundaries:
      
      - How to export：Click `Export Boundaries` button, select the path to save the boundary.
      
      - How to import：Click `Import Boundaries` button, select the boundary file to load.
    
    - Note:
      
      - How to export：Click `Export Notes` button, select the path to save the dataset.
      
      - How to import：Click `Import Notes` button, select the dataset or mid file to load.
      
      - Notice： Default Midi control key is generated based on Ample China Pipa. You can adjust these settings in `protocolsettings.m`

- Examples for editing Note:
  
  - Note correction.
        
    - An example for the start time correction. Notice the boundaries/corrected pitch curve must be kept consitency with the note segment information.
     
    <img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-15-30-image.png" title="" alt="" width="307">
        
    <img title="" src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-16-11-image.png" alt="" width="296" data-align="left">

### EA

##### Vibrato Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-56-image.png)

- Navigate to `Vibrato Analysis` tab.

- Click `Get Vibrato(s)`button. Algorithm will find all Pitch curves that is similar to a vibrato. The vibrato is automatically resized between the second Onset to the Offset of a Note 

- To achieve performance-level annotation, squeeze the boundary of vibratos. Choose vibrato/trill/bending types manually. Add the vibrato if lost.

- Click `Export Area(s)`button to export all Vibrato intervals.

- Click `Export Parameters` button to export all Vibrato parameters.

##### Sliding Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-29-56-image.png)

- Navigate to `Sliding Analysis` tab

- Click `Vibrato-free Pitch` button. This will flatten the pitch curve in vibrato intervals.

- Click `Get Sliding(s)` button simultaneously, while examinating by hearing each in the Slidings list. More times you click, more intervals generate. Please do not click the button for too many times, which will lead to over-smoothing artifact and biased parameters.

- Add or delete the sliding intervals and correct the boundaries.

- Select the correct `Type` for each Sliding.

- Click `Export Area(s)` button to export all Sliding intervals. 

- Click `Logistics Model` button for parameter estimation.

- Click `Export Parameters` button to export all Sliding parameters.

##### Tremolo Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-22-54-image.png)

- Navigate to `Tremolo Analysis` tab.

- Click `Get Tremolo(s)` button to calculate the plucks in each Note.

- Examine each candidate note. If the Note is just a regular Note, only a single pluck exist at the second onset peak. If there is more than one pluck for a normal note, remove the extra plucks by click on the pluck then deleting via `Delete Pluck` button, or simply keypress `Backspace`.

- If tremolo occurs, add the 
 You should add the missing pluck in a tremolo by clicking on `Add Pluck` button and click on approximate pluck position. Clicking Delete the defective ones with `Delete Pluck` button, or keypress `Backspace`.

- Choose the correct `Type` for each tremolo. For the 2nd and the 3rd string, default Tremolo type is `shaking`. 
  Fingering: Shaking: plucking with index finger, Rolling: alternative plucking using thumb and index fingers, Wheel: plucking with more than 2 fingers.

- Example of a correct tremolo pluck annotation:
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-13-image.png)

- Click `Export Area(s)+Plucks`button to export all Tremolo intervals.

- Click `Export Parameters` button to export all Tremolo parameters.

##### Strumming Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-40-43-image.png)

- Navigate to `Strumming Analysis`tab.

- Click `Multi-track Paths`button to a new interface.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-41-49-image.png)

- Import Onset for all the tracks, select the priority with `Imported` and click `Test and plot onsets` button. The starting point of each note is rendered in the graph.

- Click `Get Strumming(s)`button.

- Filter the Correct Strumming sequence, use `Delete Strumming` button or key press `Backspace` to delete defective Strumming sequences.

- Choose the correct Type for each Strumming Note on the right side panel.

- Click `Export Area(s)` button to export all Strumming intervals.

- Click `Export Parameters`button to export all Strumming parameters.

### Multitrack

##### Multitrack+MIDI

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-34-44-image.png)

- Navigate to`Multitrack+MIDI`tab
![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-35-45-image.png)
- Import audio and features in dataset
  
  - Import audio or music features in each track and visualize by toggling the corresponding checkbox.

- Export Project or Midi file
  
  - Click `Project/MIDI Export` button and choose to save mulittrack session to Project or Midi. When exporting Midi,there will be prompts to tell you informations about BPM guessing and how to set your own initial guess of BPM. 
    

## Preview datasets

Pipaset preview  including JasmineFlower, NanniBay and Ambush from ten sides(Section 1) is available on:

https://zenodo.org/record/6760047

More pieces of music in the future.

## Todo
- Graphic optimization
- More and better algorithms
- MPE,(music)XML,JAMS format support
- MIDI protocol

## Citation

For Academic Use: If you are using this platform in research work for publication, please cite: Yuancheng Wang, Yuyang Jing, Wei Wei, Dorian Cazau, Olivier Adam, Qiao Wang. PipaSet and TEAS: A Multimodal Dataset and Annotation Platform for Automatic Music Transcription and Expressive Analysis dedicated to Chinese Plucked String Instrument Pipa (In review). IEEE ACCESS, 2022.

The original code is based on the Luwei Yang's work: If you are using AVA in research work for publication, please cite: https://luweiyang.com/research/ava-project

Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis, In Proc. of the 42nd International Computer Music Conference (ICMC), September 2016.

Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: An Interactive System for Visual and Quantitative Analyses of Vibrato and Portamento Performance Styles, In Proc. of the 17th International Society for Music Information Retrieval Conference, 2016.
