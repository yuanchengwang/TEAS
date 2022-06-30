![TEXTLOGO.png](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/TEXTLOGO.png)

[![en](https://img.shields.io/badge/English-Document-red.svg)](https://github.com/yuanchengwang/TEAS/blob/main/README.md)
# TEAS 快速入门教程

**Quick Tutorial for Transcription and Expressiveness Annotation System**

## 前置准备：

- 在您的计算机上安装MATLAB R2021a 或以上，并安装所有扩展Packages

- 如果您需要使用`pyin(tony)`算法来使用`pitch tracker`等功能，请提前下载`sonic-annotator(64bit)`并将其安装目录添加到系统环境变量中。同时，您需要将`pyin_1.1.1.dll`存放到`Vamp Plugins`的安装目录，或您指定的`VAMP_PATH`目录中

## 启动TEAS:

- 第一步: 新建一个项目文件夹。为了提高项目的一致性和可维护性，我们建议您按照`示例数据集`中的规则对文件进行命名
  
  - 基本文件类型与命名规则
    
    - 音频文件:    `作品英文名`_source`轨道或弦号`.wav
      
      - 示例:    `NanniBay_source1.wav`
    
    - <u>数据文件</u>:    `[作品英文名]`_source `[轨道或弦号]` _`[数据类型]` _str`弦号`.csv
      
      - 示例:    `NanniBay_source1_edge_str1.csv`
    
    - 备份文件:    `源文件名`_original.csv
      
      - 示例:    `NanniBay_source1_pitch_str1_original.csv`
    
    <u>(*):</u>TEAS会自动通过弦号定义和音频源文件在导出文件时提供标准化的名称

- 第二步:    在`parameter_setting.m`文件中设定基础参数，如：弦号定义、导出MIDI时的预估BPM等。如果您对MIDI输出有其他需求，可以在`prototype_setting.m`中依照您需要的输出方式进行设置。TEAS的默认参数设置都以琵琶为基础

- 第三步:    运行`GUI_Main.m`文件，您将看到TEAS的默认页面: Read Audio

## 使用TEAS:

使用TEAS进行标记可以粗略分为以下步骤：
- [零、MSS(多源分离)- Multitrack](#可选：多源分离缓解串音)

- [一、AMT(自动音乐转录)](#自动音乐转录)
  
  1. [导入降噪处理后的分轨音频](#一、导入降噪后的分轨音频)
  
  2. [生成并修改Pitch - Pitch Detection](#二、生成并修改Pitch)
  
  3. [标记Onset&Offset&Note - Note Detection](#三、生成并修改Edges+Notes)

- 二、[EA(音乐技巧分析)](#音乐技巧分析)
  
  1. [识别并标记颤音 - Vibrato Analysis](#识别并标记揉弦)
  
  2. [识别并标记滑音 - Sliding Analysis](#识别并标记滑音)
  
  3. [识别并标记震音 - Tremolo Analysis](#识别并标记轮指)

  4. [识别并标记扫弦 - Strumming Analysis](#识别并标记扫弦)

- 三、[多轨显示与输出](#多轨分析处理)
  
  1. [导入分轨或项目文件 - Multitrack+MIDI](#处理分轨或项目文件)
  

### 自动音乐转录:
##### 零、导入降噪后的分轨音频（可选）

- 在Multitrack+MIDI界面中，每个track的audio部分导入对应弦带有串音的录制文件，然后右侧的Signal Separation按钮，运算完成后，可以在每个track的audio部分导出分离后的音频。

##### 一、导入降噪后的分轨音频

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-13-image.png)

- 在Read Audio界面中，使用`Import Denoised Wave`按钮，选择需要导入的去噪或者分离后的文件。请确保当前文件选择的弦号与`parameter_setting.m`中设置的弦号一致

##### 二、生成并修改Pitch

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-03-59-04-image.png)

- 前往Pitch Detection界面

- 在下拉菜单中选择中意的算法
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-00-22-image.png)
  
  - Pyin(tony): 较快，但会损失一些时域连续性，适合技法简单的（连续）音高检测
  
  - BNLS: 较慢，方便后续的技法标记，时域连续性较好，但同时音高稳定性较弱
    (TEAS的标记对象为琵琶，建议选BNLS)
  
  - 算法运行完毕后，对音高进行适当修正和清理后，点击Export Pitch Curve按钮，前往项目目录，并将默认名称后面加上`_original`后导出，作为参照与备份

- Pitch修正中的注意事项:
  
  - Pitch在实际过程中仅为离散音符(note)提供音高数据，时域上只需要大概清除串音的部分即可，不需要修正的太精确。频域上在某些情况下会出现八度误差，方法间修正案例。
  能留则留，不需要精修细剪，在下一步中可以更方便直观的找到错误的edge、并能让note识别更加精确
  
  - 在标记Pitch过程中如果出现没有把握的情况，可以在上方波形图中直接点击从点击处开始部分来播放音频，按Stop按钮停止
  
  - 保存和导出Pitch Curve
    
    - 保存的方法：点击Export Pitch Curve按钮，前往项目目录，并选定需要保存的位置
    
    - 载入的方法：点击Import Pitch Curve按钮，前往项目目录，并选定之前保存好的csv文件

- Pitch修正案例:
  
  - 音调识别错误修正
    
    - 点击Select Pitch Area按钮，拖动鼠标框住错误的音高曲线部分； 直接点击则是选择一个点，在single point modification下方的输入框中填写正确的频率再modify

    - 观察Pitch线后方对应的能量图(蓝色为低，红色为高)，若有Pitch但后方无明显对应基频的响度，则为漏音，鼠标框柱对应Pitch的线，将频率改写为0，点击Modify按钮即可
    
    - 常见为八度泛音识别错误，框出错误后点击Up或者Down按钮即可
    
    案例:![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-07-34-image.png)
    
    如图所示：在88到94秒的凸起波形中存在下落的数据，观察可知下降了八度（B3->B2），解决方法：框住错误的部分，点击Up按钮
    
    结果：![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-04-08-13-image.png)
  
  

##### 三、生成并修改Boundaries+Notes

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-14-22-image.png)

- 关于边缘:
  
  - Onset = MIDI音符开始的标记
  
  - Offset = MIDI音符结束的标记
  
  - 注： 在弹奏琵琶时，假指甲与琵琶的弦碰撞产生的第一次碰撞，让琵琶一个音拥有<u>两个能量波锋对应一个单音</u>的属性。因此，在实际标注中，我们需要使两个Onset对应一个Offset

- 单音示例
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-27-49-image.png)
  
  - 如图所示，图中的灰黑色条为Note，红线为Onset,每个Note的结尾处有与第二个音开头处的Onset重叠的Offset。中间黑色的线为Pitch，图中央的单独波峰对应的是滑音

- 轮指示例
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
  
  - 为了Offset检测的需要，当出现轮指时，第一个Onset标记于轮指开始的第一个波峰，第二个Onset标记于轮指的最后一次波峰
  
  - 如图所示，在蓝色线的能量聚集处，第一个波峰和最后一个波峰分别标记了Onset

- 操作说明
  
  - 如何快速删除:
    
    - 在不使用缩放工具的情况下(鼠标指针图标为正常的指针)，单击于所选边缘处(不需要完全准确，程序会自动选择最近的boundary)，或者选择对应的note区块。若Onset于note重叠，需要点击Onset于note上下的非重叠部分。当图像刷新后，点击红色的Delete Onset/offset/note按钮或按下键盘上的退格(backspace)键
    
    - 点击右侧边栏上的Select Boundary Area按钮后，在图像内可以框选出一定区域内的所有Onset+Offset,此时按下键盘上的退格(backspace)键会删除所有的Onset和Offset。点击Delete Onset或Delete Offset则会删除选定区域内的所有Onset或者Offset,而不是全部删除
  
  - 如何快速添加:
    
    - 在不使用缩放工具的情况下(鼠标指针图标为正常的指针)，单击绿色的Add Onset按钮，然后在图表上点击对应的蓝色波峰处
  
  - 标记流程:
    
    <ol>
    <li> 点击Onset Detection按钮，算法将自动识别峰值能量点（高precision会有较高的False Positive）,并将被绘制为粉色竖线，也可以用Select Boundary Area选择一个区域的所有Boundary(Onset+offset)
    <li> 可以通过plot audio显示与关闭音频曲线确定哪些onset是合适的位置
    <li> 删除所有轮指处过多的Onset(删除中间红色过于密集的部分，留一头一尾)、Pitch为零(没有Pitch黑线但被识别成Onset)的Onset
    <li> 当onset没有过于明显的错误时(没有过于密集的/出现于无Pitch部分的),点击Offset Detection按钮，算法将自动识别Offset的位置，并将其绘制为黄色竖线(大部分可能和下一个音的Onset重叠，因此看不大出来)
    <li> 逐个区域使用放大镜进行修正，并重复Offset Detection。当Offset Detection完成后，将Choose pitch2note method设置为HMM baseline（默认）,并点击Pitch2note按钮，生成当前Onset识别出的音符，以辅助识别校正。当pitch2note计算完成后，将会在左下方的列表中列出所有的note，并渲染到上方图表中。鼠标单击列表或图标中的note，将会在下方图表中渲染出选中note的细节图

    </ol>
    
    - 注意:当第三步出现以下报错时，Onset为奇数，整体中存在错误
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-53-18-image.png)
      
      - 解决办法：再修正一个错误，让整体Onset数量变成偶数后重试
    
    - 图示为一个正确的Note，前部有起震，振幅随着时间逐渐降低
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-55-44-image.png)
    
    - 相应的，轮指标记出的note在上方的渲染中应为一个长音，而note图表中则是一些音不断重复的集合
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-29-41-image.png)
      
      - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-13-56-19-image.png)
    
    - 导出单轨道Midi并对应音频进行总体查错，注意漏音、错音等情况。
      点击Export Notes按钮，在弹出的目录选择框中，将文件格式由.csv修改为.mid后保存。确认保存位置后，会出现bpm确认的弹窗。如果估计的bpm值与实际值偏差较大，可以从command window中直接设置bpm
  
  - 导入与保存Note与Edge
    
    - Edge:
      
      - 保存的方法：点击Export Boundaries按钮，前往项目目录并点击保存
      
      - 载入的方法：点击Import Boundaries按钮，前往项目目录并选定之前保存好的csv文件
    
    - Note:
      
      - 保存的方法：点击Export Notes按钮，前往项目目录并点击保存
      
      - 载入的方法：点击Import Notes按钮，前往项目目录并选定之前保存好的csv/mid文件，注意： Mid默认control key是基于Ample China Pipa来做的，可以在调整prototypesetting.m中调整

- 实际案例:
  
  - 当以下情况情况出现时，需要对note进行修正。
  
  - 因pitch的识别或修正错误而导致的note断开，需要对两个note进行merge操作
    
    - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-11-47-image.png)
    
    - 如图所示，左边的note为该note的头，而后半因pitch的分离而导致被识别成了一个新的note
      
      - 可选方案1: 修正pitch，再重导入boundaries后进行pitch2note
        
        - 对前方低八度的pitch进行移高八度处理（使用up按钮即可）
        
        - 处理结果：
        
        - <img title="" src="file:///C:/Users/14862/AppData/Roaming/marktext/images/2022-06-30-14-12-36-image.png" alt="" width="184" data-align="left">
      
      - 可选方案2: 直接修改note的位置
        
        - 记录左侧note的头位置（点击高亮该note，最左下方的输入框内会    显示当前选中note的信息）<img src="file:///C:/Users/14862/AppData/Roaming/marktext/images/2022-06-30-14-15-30-image.png" title="" alt="" width="307">
        
        - 将左侧note删除（点击高亮该note，点击Delete Note按钮）
        
        - 点击右侧note，将最左下角的note开始时间设定为前一个note的开    始时间，然后点击Modify按钮即可
        
        - 处理结果：
        
        - <img title="" src="file:///C:/Users/14862/AppData/Roaming/marktext/images/2022-06-30-14-16-11-image.png" alt="" width="296" data-align="left">

### 音乐技巧分析

##### 一、识别并标记揉弦

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-56-image.png)

- 前往Vibrato Analysis页面

- 点击Get Vibrato(s)按钮，将会列出所有类似于Vibrato的事件

- 分别点击左下方列表中的各音，用Play Vibrato按钮来聆听当前选中的Vibrato事件所在的音频，确定是否为Vibrato技法。若不是，使用Delete Vibrato按钮来删除当前选中的Vibrato事件

- 在每个正确的Vibrato事件右侧选择正确的Type

- 点击Export Area(s)按钮来导出所有Vibrato事件范围

- 点击Export All按钮来导出所有Vibrato事件参数

##### 二、识别并标记滑音

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-29-56-image.png)

- 前往Sliding Analysis页面

- 点击Vibrato-free Pitch按钮 - 筛选掉所有在上一步已经确定是Vibrato技法的Pitch，以提高识别的精确度

- 逐次点击Get Sliding(s)按钮,检测到符合筛选类型的Slidings会逐渐增多。每次点击都会增加检测的细致程度。注意：如果点击次数过多，将会引入过量错误结果，需要靠聆听和观察Note中的Pitch走向来进行取舍

- 点击左下方列表中的Slidings来选中，点击Play Sliding可以播放当前选中的sliding区域。必要的时候可以对上图中高亮的区域放大进行检查实际Pitch Curve

- 确定好Sliding的类型，并在右下角的Types中选择正确的类型

- 点击Export Area(s)来导出所有Sliding事件范围

- 点击Logistics Model生成模型参数

- 点击Export All来导出所有Sliding事件参数

##### 三、识别并标记轮指

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-22-54-image.png)

- 前往Tremolo Analysis页面

- 点击Get Tremolo(s)按钮来计算每个Note中的pluck

- 依次检查每一个Note,如果是一个普通的Note,则只出现一个pluck在能量峰处。若出现多余的pluck，请鼠标左键点击该pluck后点击Delete Pluck按钮或按键盘上的Backspace键

- 若出现Tremolo，需要检查是否除了最后一个音以外的每个音的头和尾处的能量峰上都拥有一个pluck，若缺失则使用Add Pluck按钮并点击需要添加的位置。若出现多余或错位的pluck则鼠标左键点击该Pluck后点击Delete Pluck按钮或按键盘上的Backspace键

- 在每个正确的Tremolo右侧选择对应的Type

- 示例:正确的Tremolo标记
  
  - ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-28-13-image.png)

- 点击Export Area(s)+Plucks按钮导出所有Tremolo事件范围

- 点击Export Parameters按钮导出所有Tremolo事件参数

##### 四、识别并标记扫弦

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-40-43-image.png)

- 前往Strumming Analysis页面

- 点击Multi-track Paths按钮
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-41-49-image.png)

- 分别导入4个轨道的onset

- 点击Get Strumming(s)按钮

- 筛选出正确的Strumming序列，并使用Delete Strumming按钮或Backspace键来删除错误的Strumming序列

- 在每个Strumming的Note右侧选择正确的Type

- 点击Export Area(s) 按钮导出所有Strumming事件范围

- 点击Export Parameters按钮导出所有Strumming事件参数

### 多轨分析处理

##### 处理分轨或项目文件

![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-34-44-image.png)

- 前往Multitrack+MIDI页面

- 分别导入Track1 - Track4的分轨参数
  
  ![](https://github.com/yuanchengwang/TEAS/blob/main/readme-assets/2022-06-30-14-35-45-image.png)
  
  - 分别点击Import下方与左边对应的按钮，可以选择文件的路径
    导入后点击勾选后方的确认框即可将对应内容绘制在图像上。

- 导出工程文件或MIDI文件
  
  - 当导入多轨道内容完成后，点击右侧Project/MIDI Export
    在弹出的文件选择框的下方可以选择保存为Project或保存为Midi文件。
    当确认保存位置后，会出现bpm确认的弹窗。如果估计的bpm值与实际值偏差较大，可以从command window中直接设置bpm。


