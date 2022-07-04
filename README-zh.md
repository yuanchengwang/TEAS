<p align="center">
  <img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/TEXTLOGO.png" />
</p>

[![en](https://img.shields.io/badge/English-Document-red.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README.md)

# TEAS 琵琶转录与技巧标记系统快速入门教程

**Quick Tutorial for Transcription and Expressiveness Annotation System dedicated to Chinese traditional instrument Pipa**

## 前置准备：

- 在您的计算机上安装MATLAB R2021a或以上，并安装所有工具箱. 该平台基于Windows实现，其他操作系统可能会出问题。

- 如果您需要使用`pyin(tony)`算法来做音高追踪，请提前下载`sonic-annotator(64bit)`并将其安装目录添加到系统环境变量中，并将`pyin_1.1.1.dll`粘贴到64位的`C:\Program Files\Vamp Plugins`的系统目录中

## 启动TEAS:

- 第一步: 新建一个项目文件夹,并按照`数据集预览`（见后）中的规则命名文件.
  
  - 基本文件类型与命名规则
    
    - 音频文件:    `作品英文名`_source`轨道或弦号`.wav
      
      示例:    `NanniBay_source1.wav`
    
    - <u>数据文件</u>:    `作品英文名`_source `轨道或弦号` _`数据类型` _str`弦号`.csv
      
      示例:    `NanniBay_source1_edge_str1.csv`
    
    - 备份文件:    `源文件名`_original.csv
      
      示例:    `NanniBay_source1_pitch_str1_original.csv`
    
    <u>(*):</u>TEAS会自动通过弦号和音频源文件在导出文件时提供默认名称

- 第二步:    在`parametersetting.m`文件中设定弦号定义`track_index`、导出MIDI时的预估BPS`beats_per_second`等基础参数，在`protocolsetting.m`中设置MIDI输出时的控制按键。TEAS的默认参数设置都以琵琶和琵琶音源Ample China Pipa(ACP)为基础

- 第三步:    运行`GUI_Main.m`文件启动平台


## 使用TEAS:

TEAS标记的基本流程：

- [MSS(多轨信号分离)(可选)](#多轨信号分离)

- [一、AMT(自动音乐转录)](#自动音乐转录)
  
  1. 导入降噪处理后的分轨音频
  
  2. 生成并修改Pitch - Pitch Detection
  
  3. 标记Onset&Offset&Note - Note Detection

- 二、[EA(音乐技巧分析)](#音乐技巧分析)
  
  1. 颤音标记 - Vibrato Analysis
  
  2. 滑音标记 - Sliding Analysis
  
  3. 震音标记 - Tremolo Analysis

  4. 扫弦标记 - Strumming Analysis

- 三、[多轨显示与导出](#多轨显示与导出)
  
  1. 导入分轨或项目文件 - Multitrack+MIDI

### 多轨信号分离:
(可选)在Multitrack+MIDI界面中，每个分轨audio的`Import`中导入对应弦带有串音的录制文件，然后右侧的`Signal Separation`按钮，运算完成后，可以通过每个分轨audio的`Export`导出分离后的音频。该方法可以有效减少弦之间的串音。

### 自动音乐转录:

##### 一、导入分析分轨音频

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-13-image.png)

- 在Read Audio界面中，使用`Import Denoised Wave`按钮，选择需要导入去噪后或者分离后的文件。请确保当前文件选择的弦号与`parameter_setting.m`中设置的弦号一致

##### 二、生成并修改Pitch

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-04-image.png)

- 前往Pitch Detection界面

- 在下拉菜单中选择中意的算法
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-00-22-image.png)
  
  - Pyin(tony): 较快，但会损失一些时域连续性，适合技法简单的音高检测，复杂技巧例如轮指会出现连续性不够的问题
  
  - BNLS: 较慢，方便后续的技法标记，时域连续性较好，但同时音高稳定性会减弱
    (复杂技巧情况下建议选BNLS)
  
  - 建议临时保存用来帮助后期使用, 例如在默认名称后面加上`_original`后导出，作为参照与备份

- Pitch修正中的注意事项:
  
  - Pitch在实际过程中仅为离散音符(note)提供音高数据，时域上只需要大概清除串音的部分即可，不需要修正的太精确。 能留则留，不需要精修细剪，在下一步中可以更方便直观的找到错误的edge、并能让note识别更加精确。 频域上在某些情况下会出现八度误差，方法见修正案例。

  
  - 在标记Pitch过程中如果出现没有把握的情况，可以在上方波形图中直接点击从点击处开始部分来音频回访，按Stop按钮停止。 或者参考音高后面的声谱图。
  
  - 保存和导出Pitch Curve
    
    - 保存的方法：点击`Export Pitch Curve`按钮，前往项目目录，并选定需要保存的位置
    
    - 载入的方法：点击`Import Pitch Curve`按钮，前往项目目录，并选定之前保存好的csv文件

- Pitch修正案例:
  
  - 音调识别错误修正
    
    - 点击`Select Pitch Area`按钮，框出错误的Pitch区域，在Single point modification下方的输入框中填写正确的频率，点击`Modify`按钮。将频率设置为0则为无声。
    
    - 常见为八度泛音识别错误，框出错误后点击`Up`或者`Down`按钮即可
    
    案例:
    ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-07-34-image.png)
    
    如图所示：在88到94秒的凸起波形中存在下落的数据，观察可知下降了八度（B3->B2），解决方法：框住错误的部分，点击`Up`按钮
    
    结果：
    ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-08-13-image.png)
  
  

##### 三、生成并修改Boundaries+Notes

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-14-22-image.png)

- 关于边缘:
  
  - Onset = MIDI音符开始的标记
  
  - Offset = MIDI音符结束的标记
  
  - 注： 在弹奏琵琶时，假指甲与琵琶的弦碰撞产生清脆声和音符的第一次峰值（note的起始,即key-on），弦起振带来第二个峰值（用于强度的估计），因此琵琶一个音拥有<u>两个能量波锋对应一个单音</u>的特殊属性。在实际标注中，一个音有两个Onset和一个Offset;


- 单音示例
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-27-49-image.png)
  
  - 如图所示，图中的灰黑色条为Note，红线为Onset,每个Note的结尾处有与第二个音开头处的Onset重叠的Offset。中间黑色的线为Pitch，图中央的单独波峰对应的是滑音

- 轮指示例
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
  
  - 遇到轮指时，只在第一个和最后一个波峰处标记Onset

- 操作说明
  
  - 如何删除Onset/Offset:
    
    - 单击于所选boundary处(不需要完全准确，程序会自动选择最近的boundary)，或者选择对应的note区块。若boundary与note重叠选取boundary，需要点击上下的非重叠部分。当图像刷新后，点击红色的Delete Onset/Offset/Note按钮或按下键盘上的退格(backspace)键
    
    - 点击右侧边栏上的`Select Boundary Area`按钮后，在图像内可以框选出一定区域内的所有Onset+Offset,此时按下键盘上的退格(backspace)键会删除所有的Onset和Offset。点击`Delete Onset`或`Delete Offset`则会删除选定区域内的所有Onset或者Offset,而不是全部删除
  
  - 如何快速添加:
    
    - 单击绿色的`Add Onset`按钮，然后在图表上点击对应的蓝色波峰附近（算法会自动调整到最近的峰值上）
    - 单击`Add Offset`按钮，然后在图表上点击对应的大致区域（一般再下幅度降之后，不会自动纠正）
    - 单击`Add Note`按钮，然后选择比选择区域稍小的区域（离散音高和范围会根据音高曲线和边缘自动纠正）
  
  - 标记流程:
    
    <ol>
    <li> 点击`Onset Detection`按钮，算法将自动识别峰值能量点（高precision会有较高的False Positive）,并将被绘制为红色竖线，也可以用`Select Boundary Area`选择一个区域的所有Boundary(Onset+offset)
    <li> 删除所有轮指处过多的Onset(删除中间红色过于密集的部分，留一头一尾)、串音对应的Onset。提示：可以通过plot audio显示与关闭音频曲线确定哪些onset是合适的位置
    <li> onset修正后,点击`Offset Detection`按钮，算法将自动识别Offset的位置，并将其绘制为黄色竖线(大部分可能和下一个音的Onset重叠，因此看不大出来)
    <li> 逐个区域使用放大镜进行修正，并重复Offset Detection。当Offset Detection完成后，将Choose pitch2note method设置为`HMM baseline`（默认）,并点击`Pitch2note`按钮，生成当前Onset识别出的音符，以辅助识别校正。当pitch2note计算完成后，将会在左下方的列表中列出所有的note，并渲染到上方图表中。鼠标单击列表或图标中的note，将会在下方图表中渲染出选中note的细节图
    </ol>
    
    - 注意:当第三步出现以下报错时，Onset为奇数（琵琶场景下），整体中存在错误
      
      ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-53-18-image.png)
      
      - 解决办法：再修正一个错误，让整体Onset数量变成偶数后重试
    
    - 图示为一个正确的音符note区域，前部有起震，振幅随着时间逐渐降低
      
      ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-55-44-image.png)
    
    - 相应的，轮指标记出的音符在上方的渲染中应为一个长音，而note图表中则是一些音不断重复的集合
      
      ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
      
      ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-56-19-image.png)
    
    - 导出单轨道Midi并对应音频进行总体查错，注意漏音、错音等情况。
      点击Export Notes按钮，在弹出的目录选择框中，将文件格式由.csv修改为.mid后保存。确认保存位置后，会出现bpm确认的弹窗。
      注意：MIDI中的BPS只有在出谱的时候才有用，不出谱的时候例如做音频合成的时候，不会影响结果。
  
  - 导入与保存Note与Edge
    
    - Edge:
      
      - 保存的方法：点击`Export Boundaries`按钮，前往项目目录并点击保存
      
      - 载入的方法：点击`Import Boundaries`按钮，前往项目目录并选定之前保存好的csv文件
    
    - Note:
      
      - 保存的方法：点击`Export Notes`按钮，前往项目目录并点击保存
      
      - 载入的方法：点击`Import Notes`按钮，前往项目目录并选定之前保存好的csv/mid文件，注意： MIDI默认control key是基于Ample China Pipa(ACP)来做的，可以在调整`protocolsetting.m`中调整

-  修改note
        
        - 记录左侧note的头位置（点击高亮该note，最左下方的输入框内会显示当前选中note的信息）<img src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-15-30-image.png" title="" alt="" width="307">
        
        - 将左侧note删除（点击高亮该note，点击Delete Note按钮或者退格backspace）
        
        - 点击右侧note，将最左下角的note开始时间设定为前一个note的开始时间，然后点击`Modify`按钮即可
        注意：调整note的边缘需要和boundary的保持一致
        
        - 处理结果：
        
        - <img title="" src="https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-16-11-image.png" alt="" width="296" data-align="left">

### 音乐技巧分析

##### 一、揉弦标记

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-56-image.png)

- 前往Vibrato Analysis页面

- 点击`Get Vibrato(s)`按钮得到Vibrato的区域及对应参数

- 分别点击左下方列表中的各音，用`Play Vibrato`按钮来聆听当前选中的Vibrato事件所在的音频，确定是否为Vibrato技法。使用`Delete Vibrato`按钮来删除当前选中的Vibrato事件。揉弦的范围会自动调整到一个音的onset（第二个）/offset之间。performance-level级别.因此只会比自动生成的范围小的。

- 在每个正确的Vibrato事件右侧选择正确的Type。 请根据实际情况自行调整vibrato/trill/bending类型

- 点击`Export Area(s)`按钮来导出所有Vibrato事件范围

- 点击`Export Parameters`按钮来导出所有Vibrato事件参数

##### 二、滑音标记

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-29-56-image.png)

- 前往Sliding Analysis页面

- 点击`Vibrato-free Pitch`按钮 - 平滑掉所有在上一步已经确定是Vibrato技法的音高曲线，以提高识别的精确度

- 点击`Get Sliding(s)`按钮得到滑音的事件区域。 点击的次数越多，音高曲线越平滑， 检测到符合筛选类型的Slidings也越多。注意：如果点击次数过多（不要超过3次），将会引入过平滑的结果影响最后的估计参数。

- 点击左下方列表中的Slidings来选中，点击`Play Sliding`可以播放当前选中的sliding区域。必要的时候可以对上图中高亮的区域放大进行检查实际Pitch Curve

- 确定好Sliding的类型，并在右下角的Types中选择正确的类型

- 点击`Export Area(s)`来导出所有Sliding事件范围

- 点击`Logistics Model`生成模型参数.如果模型不能很好的拟合曲线请调整滑音的范围。

- 点击`Export Parameters`来导出所有Sliding事件参数

注:sliding,sliding out音高取滑前音高，sliding in取滑后音高 


##### 三、轮指标记

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-22-54-image.png)

- 前往Tremolo Analysis页面

- 点击`Get Tremolo(s)`按钮来计算每个候选音符中的pluck

- 观察列表中的Note，普通的Note应该仅在第二个能量峰处存在一个pluck/onset。选中并使用`Delete Pluck`按钮或按键盘上的`Backspace`键删除多余pluck

- 若是轮指的情况，使用`Add Pluck`按钮并在缺少pluck的附近点击鼠标左键来补全pluck。

- 选择对应轮指的Type. 对于2，3弦，技巧默认是摇而不是轮，请根据实际情况进行调整。
指法：摇shaking：食指来回摇动弹奏一根弦；滚rolling：食指拇指交替，轮wheel：超过两个指头弹奏

- 示例:正确的Tremolo标记,里面pluck类似onset，两个对应一次弹奏
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-13-image.png)

- 点击`Export Area(s)+Plucks`按钮导出所有Tremolo事件范围

- 点击`Export Parameters`按钮导出所有Tremolo事件参数

##### 四、扫弦标记

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-40-43-image.png)

- 前往Strumming Analysis页面

- 点击`Multi-track Paths`按钮显示多轨onset输入的界面
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-41-49-image.png)

- 分别导入4个轨道的onset，选择`Imported`的priority优先级, 点击`Test and plot onsets`按钮，显示没根弦的起始点位置

- 点击`Get Strumming(s)`按钮得到大致的扫弦区域和参数

- 筛选出正确的Strumming序列，并使用`Delete Strumming`按钮或`Backspace`键来删除错误的Strumming序列

- 在每个Strumming的Note右侧选择正确的Type

- 点击`Export Area(s)`按钮导出所有Strumming事件范围

- 点击`Export Parameters`按钮导出所有Strumming事件参数

注： 请根据实际情况自行调整扫弦类型

### 多轨显示与导出

##### 处理分轨或项目文件

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-34-44-image.png)

- 前往Multitrack+MIDI页面

- 分别导入Track1 - Track4的分轨参数
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-35-45-image.png)
  
  - 分别点击Import下方与左边对应的按钮，可以选择文件的路径
    导入后点击勾选后方的确认框即可将对应内容绘制在图像上。

- 导出工程文件或MIDI文件
  
  - 当导入多轨道内容完成后，点击右侧`Project/MIDI Export`按钮
    选择保存为Project或保存为MIDI。
    当确认保存位置后，会出现BPM相关信息的弹窗。如果估计的BPM值与实际值偏差较大，可以在`parametersetting.m`中修改初始BPS。

##### 数据集预览
包含茉莉花南泥湾十面埋伏(第一段)的多模态数据集预览：
https://zenodo.org/record/6760047
更多数据将会在未来发布

##### 未来工作
- 图形优化
- 更多更精确的识别算法
- MPE, mxl, xml, JAMS等导出格式
- MIDI协议功能支持

##### 引用

如果您使用该平台和相关数据在您的发表的文章中，请使用以下引用: 
Yuancheng Wang, Yuyang Jing, Wei Wei, Dorian Cazau, Olivier Adam, Qiao Wang. PipaSet and TEAS: A Multimodal Dataset and Annotation Platform for Automatic Music Transcription and Expressive Analysis dedicated to Chinese Plucked String Instrument Pipa (In review). IEEE ACCESS, 2022.

最早的原始版本来源于Luwei Yang的工作: [luweiyang.com/research/ava-project](https://luweiyang.com/research/ava-project/)
如果使用 AVA在您的发表的文章中，请引用: 

Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: A Graphical User Interface for Automatic Vibrato and Portamento Detection and Analysis, In Proc. of the 42nd International Computer Music Conference (ICMC), September 2016.

Luwei Yang, Khalid Z. Rajab and Elaine Chew. AVA: An Interactive System for Visual and Quantitative Analyses of Vibrato and Portamento Performance Styles, In Proc. of the 17th International Society for Music Information Retrieval Conference, 2016.
