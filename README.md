![TEXTLOGO.png](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/TEXTLOGO.png)

[![zh](https://img.shields.io/badge/点击这里-查看中文文档-green.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README-zh.md)

# TEAS Quick Start

**Quick Tutorial for Transcription and Expressiveness Annotation System**

## Prerequisite：

- Install MATLAB version R2021a or above, with all optional packages

- If you want to use`pyin(tony)`for`pitch tracker`，Please download and install`sonic-annotator(64bit)` and add its install location to system PATH. Also, you need to put `pyin_1.1.1.dll` in `Vamp Plugins` install directory or`VAMP_PATH`.

## Staring up TEAS:

- Create a new folder for your project according to our example datasets. This is for convinence and maintainability.
  
  - File types and recommended naming scheme
    
    - Audio source:    `Name`_source`Track number`.wav
      
      Example:    `NanniBay_source1.wav`
    
    - <u>Dataset file</u>:    `Name`_source `Track number` _`Type` _str`String number`.csv
      
      Example:    `NanniBay_source1_edge_str1.csv`
    
    - Backup file:    `Source file name`_original.csv
      
      Example:    `NanniBay_source1_pitch_str1_original.csv`
    
    <u>(*):</u>TEAS will automatically decide what name it should be saved as based on your settings in string number and name of the audio source. 

- Set string properties, initial guess of BPM, etc in`parameter_setting.m`.Set MIDI parameter in `protocol_setting.m` if you need special export for midi like the midi mode. All parameters are set by default specific to our study target, PIPA.

- Run `GUI_Main.m`. You should see the default tab of TEAS: Read Audio

## TEAS Workflow:

The workflow of TEAS can be categorized into these steps:

- [AMT(Automatic music transcription)](#AMT(Automatic music transcription))
  
  1. Import denoised audio source
  
  2. Pitch Detection
  
  3. Note Detection

- [EA(Emotion analysis)](#EA(Emotion analysis))
  
  1. Vibrato Analysis
  
  2. Sliding Analysis
  
  3. Tremolo Analysis
  
  4. Strumming Analysis

- [Multitrack Midi project](#Multitrack Midi project)
  
  1. Multitrack+MIDI

### AMT(Automatic music transcription)

##### Import denoised audio source

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-13-image.png)

- Under tab `ReadAudio`, import Denoised/Separated audio source with `Import Denoised Wave` button. Make sure you are importing the same string number as what you have set in `parameter_settings.m`

##### Pitch Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-04-image.png)

- Navigate to `Pitch Detection` tab

- Select the desired algorithm for Pitch tracking.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-00-22-image.png)
  
  - Pyin(tony): Fastest, but the result lack detail in articulation such as vibrato and portamento, which is not useful in our case focusing on a rich articulation instrument - Chinese Pipa.
  
  - BNLS: Slower, but result in many detailed pitch movements. generate more noise than Pyin so you have to manually crop them. Good for emotional articulation analysis.
  
  - When the algorithm calculation is complete, edit the result slightly then press Export Pitch Curve button to export the dataset to desired location. It's recommended to keep a backup of the untouched original Pitch file for later use.  You can save it with  `_original` at the end of the filename. 

- About Pitch editing:
  
  - Pitch only serve as a frequency data for individul note(s). you should only remove the pitch which comes from other string's vibration. Instead, you should keep as much as you can for better Edge modification later and higher accuracy on Note detection.Under some circumstances there will be Octave offset for pitch, you can fix them in the `Examples for Editing Pitch` down below.
  
  - If you are feeling lost while editing Pitch, you can directly click on audio wave graph on top to playback the audio from where you clicked. Use the Stop button to stop the audio playback.
  
  - Save and export Pitch Curve
    
    - How to export：Click on the `Export Pitch Curve` button, select the location you wish to save the dataset.
    
    - How to import：Click on the `Import Pitch Curve` button, select the dataset you wish to load.

- Tutorials for Editing Pitch:
  
  - When Pitch tracking gives incorrect result
    
    - To select the defective Pitch data, click on the `Select Pitch Area` button, hold your left mouse button and drag on the Pitch graph to make a selection, or select a single point by doing left click on certain Pitch point, input the desired value in the text input box below `single point modification`then click on the `modify`button.
    
    - Examine the energy graph behind Pitch curve, When you find Pitch curve with no obvious energy indication, that usually means the Pitch is either leaked from other string. Remove them by selecting the range of defective Pitch and edit the frequency of it to `0`.
    
    - Pitch tracker sometimes don't work very well on identifying Octaves. You can select the offset Pitch and move it all by Octaves by pressing the `Up` and the `Down` button.
    
    Pitch editing examples:![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-07-34-image.png)
    
    As shown in the figure: Falling datapoints in the Pitch curve from 88 to 94 seconds, indicated that the Pitch tracker have mistaken the Octave.(B3-> B2), <u>Solution to this problem</u>: select the defective part of the Pitch curve, click the Up button.
    
    Result：![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-08-13-image.png)

##### Note Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-14-22-image.png)

- What are Boundaries:
  
  - Onset = The start of each MIDI note
  
  - Offset = The end of each MIDI note
  
  - The fake nail used when playing the Pipa will generate a peak on level curve by touching the string. This is what we marked as the start of the note, key-on. the second peak is where the string starts to vibrates. Which leads to the fundamental of Pipa transcription: Each note has two Onsets and one Offset. 

- Marking a sinlge note
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-27-49-image.png)
  
  - As shown in the figure:Notes are shown as gray stripes.Vertical red lines are Onsets.There is a Yellow vertical line inbetween the end of each note and the start of the next, which is overlayed by the first Onset of each note. The single peak in the center of the graph is representing a portamento, as the Pitch curve falls down while the note is still playing.

- Marking Tremolo(s)
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
  
  - For properly detecting Offset for Tremolos, we need to mark the first and the last level peak for the Tremolo note.
  
  - As shown in the figure: The first and last level peak is maked as Onsets.

- Tutorials on marking Note
  
  - Methods to remove Onsets/Offsets/Notes:
    
    - Click on the Onset/Offset/Note you wish to delete, then Click on `Delete Onset` or `Detele Offset` or `Delete Note`, or simply hit `Backspace` on your keyboard. Do not click in the note if you are trying to edit the Boundary. move your mouse cursor upper or lower for directly selecting  the boundary.
    
    - You can speed up the workflow by Using the `Select Boundary Area` button. after doing so, you can select all Onsets and Offsets in a certain area, and choose to either delete only Onset or Offset with the corresponding button, or hit `Backspace` on your keyboard to remove everything.
  
  - Methods to add boundaries:
    
    - Click on `Add Onset` or `Add Offset` button, then click on level peaks near anywhere you wish to create a Onset or a Offset.
  
  - Basic workflow of Note detection:
    
    - Click on `Onset Detection` button, the algorithm will find every single level peak(*higher precision will have more False Positive outcome*), and mark them all as Onsets. they will be rendered as vertical red lines. 
    
    - Remove all detective Onsets from Pitch leakage or Tremolo. You may edit them cautiously one-by-one, or use `Select Boundary Area` to speed up this process. 
      
      Hint: you can toggle `Plot Audio` checkbox to speed up the process by looking at where the note should be.
    
    - After editing Onsets, click on the `Offset Detection` button. The algorithem will automatically calculate where each Offset should be. they will be rendered as vertical yellow lines.(*most of them might be overlayed by the first Onset of the next note, which you can not see*)
    
    - Use the `zoom` function from Matlab to improve your precision while editing boundaries. Keep retrying Offset Detection as you improve Onsets. When Offset Detection is done, you can generate Notes by simply clicking on the `Pitch2note` button. with this, you can examine errors during the marking of Boundaries. Notes will be listed in the listbox anchored on the bottom left of the page. You can click on each Note to see the detailed graph of how the Note looked like. You can delete the Note you selected by pressing on the `Delete Note` button.
    
    - Caution: When `Offset Detection` or `Pitch2note` gives you this warning, fix one more defective Onset before you procceed. This is due to how Pipa uses two Onsets for each Note, odd number for quantity of Onsets is not allowed.
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-53-18-image.png)
    
    - What a correct Note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-55-44-image.png)
    
    - What a correct Tremolo Note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-56-19-image.png)
    
    - You can export currently marked Notes as a single-channel Midi file for overall examination by pressing the `Export Notes`button, and then change the format from  `.csv` to `.mid`. There will be prompts to tell you informations about BPM guessing and how to set your own initial guess of BPM. When examinating, pay attention to missing Notes/Notes with wrong Pitch.
  
  - Import and Export of Boundaries and Notes
    
    - Boundaries:
      
      - How to export：Click on the`Export Boundaries`button,select the location you wish to save the dataset.
      
      - How to import：Click on the`Import Boundaries`button,select the dataset you wish to load.
    
    - Note:
      
      - How to export：Click on the`Export Notes`button,select the location you wish to save the dataset.
      
      - How to import：Click on the``button,select the dataset or mid file you wish to load.
      
      - Caution： Default Midi control key is generated based on Ample China Pipa. You can adjust these settings in `protocolsettings.m`

- Examples for editing Note:
  
  - Correct the Note when the following situations occur.
  
  - Note is broken into halves due to incorrect Pitch curve. You need to merge two Notes back together.
    
    - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-11-47-image.png)
    
    - As shown in the figure, the note on the left is the head of the actual note, and the latter half is identified as a new note due to the separation of the pitch.
      
      - Plan A: Edit the Pitch,re-importing boundaries and perform pitch2note
        
        - Use the `Up` button to fix the defective Octave disconnect in the Pitch curve.
        
        - Result：
        
        - <img title="" src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-12-36-image.png" alt="" width="184" data-align="left">
      
      - Plan B: Editing the Note directly
        
        - Log the start position of the Note on the left.<img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-15-30-image.png" title="" alt="" width="307">
        
        - Delete the Note on the left.
        
        - Edit the start position of the Note on the right to the start position of the Note on the left.
        
        - Result：
        
        - <img title="" src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-16-11-image.png" alt="" width="296" data-align="left">

### EA(Emotion analysis)

##### Vibrato Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-56-image.png)

- Navigate to `Vibrato Analysis` tab.

- Click on the `Get Vibrato(s)`button. Algorithm will find all Pitch curves that is similar to a vibrato.

- Click on each Vibratos, using the `Play Vibrato` button to identify whether the Vibrato is defective or not. If it is, Delete it with the`Delete Vibrato` button.

- Select correct `Type` for each Vibrato. on the left side panel.

- Click on the `Export Area(s)`button to export all Vibrato range.

- Click on the `Export All` button to export all Vibrato parameters.

NOTE1: Please remeber to choose vibrato/trill/bending types manually.

NOTE2: Vibrato will automatically resize between the second Onset to the Offset of the Note, in order to achieve performance-level precision.

##### Sliding Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-29-56-image.png)

- Navigate to `Sliding Analysis` tab

- Click on the `Vibrato-free Pitch`button. This wil filter out all the Pitch where Vibratos have already been recognized to improve the accuracy of Sliding Detection.

- Click on the`Get Sliding(s)` button simultaneously, while examinating by hearing each Sliding in the Slidings list. The more you press, the more results will come out. Please do not press the button for too many times, which will lead to over-smoothing artifact and break the result.

- Examine the Slidings result by listening to them and remove the defective result.

- Select the correct `Type` for each Sliding.

- Click on the `Export Area(s)` button to export all Sliding range.

- Click on the `Logistics Model` button to calculate Logistics Model.

- Click on the `Export All` button to export all Sliding parameters.

NOTE: `sliding`/`sliding out` uses the Pitch before the slide, while `sliding in` uses the Pitch after the slide

##### Tremolo Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-22-54-image.png)

- Navigate to `Tremolo Analysis` tab.

- Click on `Get Tremolo(s)` button to calculate the plucks in each Note.

- Examine each Note. If the Note is just a regualr Note, there should be only one pluck at the peak level of the Note. If there is more than one pluck for a normal Note, delete the redundant ones by click on the pluck then click on the `Delete Pluck` button, or simply hitting the `Backspace` key on your keyboard.

- If a Tremolo Note is found, examine whether there are two plucks on every single Note where one is at the start and the other at the end, except for the last Note which we only put one pluck on the start of the Note. You should add the missing pluck in a tremolo by clicking on `Add Pluck` button and click on where you wish the pluck to be. Delete the defective ones with `Delete Pluck` button, or hitting `Backspace` key on your keyboard.

- Choose the correct `Type` for each tremolo.

- Example of a correct Tremolo mark:
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-13-image.png)

- Click on the`Export Area(s)+Plucks`button to export all Tremolo range.

- Click on the `Export Parameters` button to export all Tremolo parameters.

NOTE: for the 2nd and the 3rd string, default Tremolo type is `shaking`. 

##### Strumming Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-40-43-image.png)

- Navigate to `Strumming Analysis`tab.

- Click on `Multi-track Paths`button.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-41-49-image.png)

- Import Onset for all the tracks, select the imported Onsets and click on the`test and plot` button. The starting point of each note is rendered in the graph.

- Click on the `Get Strumming(s)`button.

- Filter the Correct Strumming sequence, use `Delete Strumming` button or `Backspace` key on your keyboard to delete defective Strumming sequences.

- Choose the correct Type for each Strumming Note on the right side panel.

- Click on the`Export Area(s)` button to export all Strumming range.

- Click on the `Export Parameters`button to export all Strumming parameters.

### Multitrack Midi project

##### Multitrack+MIDI

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-34-44-image.png)

- Navigate to`Multitrack+MIDI`tab

- Import Datasets for Track1 to Track4![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-35-45-image.png)
  
  - Click on the corresponding buttons to each file types under the `Import` section to select the file path for individual datasets.
    You can preview the data by toggling the checkbox.

- Export Project or Midi file
  
  - Click on the `Project/MIDI Export` button and choose to save mulittrack session to Project or Midi. When exporting Midi,there will be prompts to tell you informations about BPM guessing and how to set your own initial guess of BPM. 
    

## Preview datasets

Preview dataset including JasmineFlower, NanniBay and Ambush from ten sides.
https://zenodo.org/record/6760047
More datasets will add on in the future.

## Todo

- More and better detection algorithms.
- MPE,(music)XML,JAMS exports
- MIDI protocols

## Citation

For Academic Use: If you are using this platform in research work for publication, please cite: Yuancheng Wang, Yuyang Jing, Wei Wei, Dorian Cazau, Olivier Adam, Qiao Wang. PipaSet and TEAS: A Multimodal Dataset and Annotation Platform for Automatic Music Transcription and Expressive Analysis dedicated to Chinese Plucked String Instrument Pipa. IEEE ACCESS, 2022.

The original code is based on the Luwei Yang's work: If you are using AVA in research work for publication, please cite: https://luweiyang.com/research/ava-project
Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis, In Proc. of the 42nd International Computer Music Conference (ICMC), September 2016.
Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: An Interactive System for Visual and Quantitative Analyses of Vibrato and Portamento Performance Styles, In Proc. of the 17th International Society for Music Information Retrieval Conference, 2016.
