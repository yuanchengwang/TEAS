<p align="center">
  <img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/TEXTLOGO.png" />
</p>

[![zh](https://img.shields.io/badge/点击这里-查看中文文档-green.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README-zh.md)

# TEAS Quick Tutorial

**Quick Tutorial for Transcription and Expressiveness Annotation System dedicated to Chinese traditional instrument Pipa**

## Prerequisite：

- Install MATLAB version R2021a or above, with all optional packages. This system is implemented on Windows, some issues may occur for other OS.

- If use `pyin(tony)` as `pitch tracker`, please install `sonic-annotator(64bit)` and add its installation path to SYSTEM PATH. Also, paste `pyin_1.1.1.dll` into `C:\Program Files\Vamp Plugins`.

## Starting up TEAS:

- Create a new folder for your project referring to Pipaset preview (See detailsbelow)
  
  - Naming scheme
    
    - Audio source:    `Name`_source`Track number`.wav
      
      Example:    `NanniBay_source1.wav`
    
    - <u>Dataset file</u>:    `Name`_source `Track number` _`Type` _str`String number`.csv
      
      Example:    `NanniBay_source1_edge_str1.csv`
    
    - Backup file:    `Source file name`_original.csv
      
      Example:    `NanniBay_source1_pitch_str1_original.csv`
    
    <u>(*):</u>TEAS will automatically determine the default file name via string index and name of the audio source. 

- Configure the parameters like `string_index`, initial guess of 'beats_per_second' etc in `parametersetting.m`, in addition of synthesizer MIDI setting in `protocolsetting.m` if requiring control keys. All parameters are set specific to our study target, pipa and MIDI output follows the setting of the Ample China Pipa(ACP) synthesizer.

- Run `GUI_Main.m` to launch the platform



## TEAS Workflow:

The workflow of TEAS consists of following main steps:

- [MSS(Multichannel signal separation)(Optional)](#MSS)

- [I, AMT(Automatic music transcription)](#AMT)
  
  1. Import denoised audio source
  
  2. Pitch Detection
  
  3. Note Detection

- [II, EA(Expressive Analysis)](#EA)
  
  1. Vibrato Analysis
  
  2. Sliding Analysis
  
  3. Tremolo Analysis
  
  4. Strumming Analysis

- [III, Multitrack](#Multitrack)
  
  1. Multitrack+MIDI

### MSS (Multichannel signal separation)

(Optional) Import audio source with mutual resonance in each track of Multitrack+MIDI tab. Then click on `Signal Separation` button to run the MSS. Export the debleeded signal from each track of Multitrack+MIDI tab. This step will effectively reduce the interference among the strings.

### AMT

##### Import denoised audio source

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-13-image.png)

- Under tab `ReadAudio`, import Denoised/debleeded audio source with `Import Denoised Wave` button. Make sure the string number of imported audio is the same as set in `parameter_settings.m`

##### Pitch Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-04-image.png)

- Navigate to `Pitch Detection` tab

- Select the desired algorithm for Pitch tracking.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-00-22-image.png)
  
  - pYin(tony): Fastest, good pitch detector with insufficient consistency in time for articulation like tremolo.
  
  - BNLS: Slowest, better consistency in time but slightly worse in pitch. Rough crop for the pitch curve is required. More appropriate for complex articulation analysis.
  
  - Keeping a backup of the untouched original pitch file is recommended for later use. We save it with  `_original` at the end of the filename. 

- About pitch editing:
  
  - Pitch curve from other string's vibration is recommended to mannually remove. 
  
  - Hint: Playback is provided. 
  
  - Save and export Pitch Curve
    
    - How to export：Click on the `Export Pitch Curve` button, select the saving path.
    
    - How to import：Click on the `Import Pitch Curve` button, select the loading path.
  
  - When pitch tracking gives incorrect result
    
    - Select the defective pitch after clicking the `Select Pitch Area` button or select a single point by clicking directly on the pitch curve, input the desired pitch value in `single point modification` then click the `Modify` button.
    
    - Through the spectrogram behind pitch curve, remove them by selecting the defective range and set the pitch to `0`.
    
    - Octave error may occur. Select the area and octave up or down by `Up` or the `Down` button.
    
    Pitch editing examples:![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-07-34-image.png)
    
    As shown in the figure: octave error in pitch curve located within 88 and 94 seconds.(B3-> B2), <u>Solution to this problem</u>: select the defective interval and click the `Up` button.
    
    Result：![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-08-13-image.png)

##### Note Detection

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-14-22-image.png)

- What are Boundaries:
  
  - Onset = The start of each MIDI note
  
  - Offset = The end of each MIDI note
  
  - The fake nail will produce a crisp soudn and envelope peak when touching the string. This serves to the note onset, i.e. key-on. The second peak points out the natural transient from the string which leads to the strength/velocity estimation: Each note has two onsets and a single offset for pipa case.

- Single Note Annotation
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-27-49-image.png)
  
  - As shown in the figure: Notes are shown as gray rectangles. Red lines represent onset points. Yellow lines indicate the offset which may be covered by the onsets of the subsequent notes. 

- Note annotation in Tremolo case 
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
  
  - Only the first and the last peak for the Tremolo note need to mark.
  
  - To remove Onsets/Offsets/Notes:
    
    - Click on the Onset/Offset/Note you wish to delete, then Click on `Delete Onset` or `Detele Offset` or `Delete Note`, or simply keypress `Backspace`. Do not click in the note if you are trying to edit the Boundary. move your mouse cursor upper or lower for directly selecting  the boundary.
    
    - You can speed up the workflow by Using the `Select Boundary Area` button. after doing so, you can select all Onsets and Offsets in a certain area, and choose to either delete only Onset or Offset with the corresponding button, or keypress `Backspace` on to remove all selected boundaries.
  
  - To add offset:
    
    - Click on `Add Onset` button, then click on an approximate location of peak(the closest peak will be chosen for onset).
  
  - Basic workflow of Note detection:
    
    - Click on `Onset Detection` button, the algorithm will find potential peaks (*High false positive outcome*), and mark them all as Onsets rendered as red lines. 
    
    - Remove all detective Onsets from unvoiced and tremolo intervals. `Select Boundary Area` will speed up the process. 
      
      Hint: you can toggle `Plot Audio` checkbox to determine the boundary point.
    
    - Given the corrected onsets, detect the offsets via the `Offset Detection` button. Some of them can be invisible due to the onset overlap of the following note.
    
    - Use the `zoom` function from Matlab to improve your precision while editing boundaries. Keep retrying Offset Detection as you improve Onsets. When Offset Detection is done, you can generate Notes by simply clicking on the `Pitch2note` button. with this, you can examine errors during the marking of Boundaries. Notes will be listed in the listbox anchored on the bottom left of the page. You can click on each Note to see the detailed graph of how the Note looked like. You can delete the Note you selected by clicking on the `Delete Note` button.
    
    - Caution: When `Offset Detection` or `Pitch2note` gives you this warning, fix one more defective Onset before procceed. This is due to how Pipa uses two Onsets for each Note, odd number for quantity of Onsets is not allowed.
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-53-18-image.png)
    
    - What a correct Note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-55-44-image.png)
    
    - What a correct Tremolo Note looks like:
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-56-19-image.png)
    
    - You can export currently marked Notes as a single-channel Midi file for overall examination by clicking the `Export Notes` button, and then change the format from  `.csv` to `.mid`. There will be prompts to tell you informations about BPM guessing and how to set your own initial guess of BPM. When examinating, pay attention to missing Notes/Notes with wrong Pitch.
  
  - Import and Export of Boundaries and Notes
    
    - Boundaries:
      
      - How to export：Click on the`Export Boundaries` button,select the path to save the boundary.
      
      - How to import：Click on the`Import Boundaries` button,select the boundary file to load.
    
    - Note:
      
      - How to export：Click on the`Export Notes` button,select the path to save the dataset.
      
      - How to import：Click on the`Import Notes` button,select the dataset or mid file to load.
      
      - Caution： Default Midi control key is generated based on Ample China Pipa. You can adjust these settings in `protocolsettings.m`

- Examples for editing Note:
  
  - Note correction.
        
        - Log the start position of the Note on the left.<img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-15-30-image.png" title="" alt="" width="307">
        
        - Delete the Note on the left.
        
        - Edit the start position of the Note on the right to the start position of the Note on the left.
        
        - Result：
        
        - <img title="" src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-16-11-image.png" alt="" width="296" data-align="left">

### EA

##### Vibrato Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-56-image.png)

- Navigate to `Vibrato Analysis` tab.

- Click on the `Get Vibrato(s)`button. Algorithm will find all Pitch curves that is similar to a vibrato. The vibrato is automatically resized between the second Onset to the Offset of a Note 

- To achieve performance-level annotation, squeeze the boundary of vibratos. Choose vibrato/trill/bending types manually. Add the vibrato if lost.

- Click on the `Export Area(s)`button to export all Vibrato intervals.

- Click on the `Export Parameters` button to export all Vibrato parameters.

##### Sliding Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-29-56-image.png)

- Navigate to `Sliding Analysis` tab

- Click on the `Vibrato-free Pitch` button. This will flatten the pitch curve in vibrato intervals.

- Click on the `Get Sliding(s)` button simultaneously, while examinating by hearing each in the Slidings list. More times you click, more intervals generate. Please do not click the button for too many times, which will lead to over-smoothing artifact and biased parameters.

- Add or delete the sliding intervals and correct the boundaries.

- Select the correct `Type` for each Sliding.

- Click on the `Export Area(s)` button to export all Sliding intervals. 

- Click on the `Logistics Model` button for parameter estimation.

- Click on the `Export Parameters` button to export all Sliding parameters.

##### Tremolo Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-22-54-image.png)

- Navigate to `Tremolo Analysis` tab.

- Click on `Get Tremolo(s)` button to calculate the plucks in each Note.

- Examine each candidate note. If the Note is just a regular Note, only a single pluck exist at the second onset peak. If there is more than one pluck for a normal note, remove the extra plucks by click on the pluck then deleting via `Delete Pluck` button, or simply keypress `Backspace`.

- If tremolo occurs, add the 
 You should add the missing pluck in a tremolo by clicking on `Add Pluck` button and click on approximate pluck position. Clicking Delete the defective ones with `Delete Pluck` button, or keypress `Backspace`.

- Choose the correct `Type` for each tremolo. For the 2nd and the 3rd string, default Tremolo type is `shaking`. 
  Fingering: Shaking: plucking with index finger, Rolling: alternative plucking using thumb and index fingers, Wheel: plucking with more than 2 fingers.

- Example of a correct Tremolo mark:
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-13-image.png)

- Click on the`Export Area(s)+Plucks`button to export all Tremolo intervals.

- Click on the `Export Parameters` button to export all Tremolo parameters.

##### Strumming Analysis

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-40-43-image.png)

- Navigate to `Strumming Analysis`tab.

- Click on `Multi-track Paths`button.
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-41-49-image.png)

- Import Onset for all the tracks, select the priority with `Imported` and click on the `Test and plot onsets` button. The starting point of each note is rendered in the graph.

- Click on the `Get Strumming(s)`button.

- Filter the Correct Strumming sequence, use `Delete Strumming` button or key press `Backspace` to delete defective Strumming sequences.

- Choose the correct Type for each Strumming Note on the right side panel.

- Click on the`Export Area(s)` button to export all Strumming intervals.

- Click on the `Export Parameters`button to export all Strumming parameters.

### Multitrack

##### Multitrack+MIDI

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-34-44-image.png)

- Navigate to`Multitrack+MIDI`tab

- Import Dataset![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-35-45-image.png)
  
  - Import audio or music features in each track and visualize by toggling the corresponding checkbox.

- Export Project or Midi file
  
  - Click on the `Project/MIDI Export` button and choose to save mulittrack session to Project or Midi. When exporting Midi,there will be prompts to tell you informations about BPM guessing and how to set your own initial guess of BPM. 
    

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
