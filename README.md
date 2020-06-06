# E. coli Bacteria Image Segmentation

## Abstract
Microbiological research and analysis often rely on colony counting to estimate the growth of the cells. The traditional manual counting approach takes much time, and it is labor-intensive and error-prone. This project proposed a fully automatic approach to segment the E. coli bacteria image and approximate the colony number. Image segmentation is a very important phase during this process for it determines the accuracy of the final counting result.

微生物研究和分析中经常通过菌落计数来观察细胞的生长情况。传统的人工计数方法耗时长，劳动强度高，而且容易出错。本项目提出了一种全自动的方式来分割大肠杆菌的图像并估算图像中菌落的数量。在这个过程中，图像分割是一个很重要的环节因为其决定了最终计数结果的准确率。

## Installation
### Method 1
* Download MATLAB 2018b or newer with Image Processing Toolbox, Statistics and Machine Learning Toolbox, Signal Processing Toolbox
* RUN 'src/GUI.m' using MATLAB

### Method 2: For Windows
* Directly download the application from [this link](https://uofmacau-my.sharepoint.com/:u:/g/personal/db62303_umac_mo/Eb_y_-rBhJNJhugDbg72rOYBdwS87MWPDSm8zFS7_r9wUw?e=w074US)
* Run the application

### Method 2: For Mac
* Directly download the application from [this link] (https://uofmacau-my.sharepoint.com/:u:/g/personal/db61140_umac_mo/EQk5_5vQaqtBuzBeUT4gEckBbQzR14qm_yv8jCIpcfQlwg?e=9mWDxV) 
* Run the application

## Features
* **ROI Extraction**: 
    * Automatic central area extraction from the Petri dish
    * Circle the ROI interactively
    
* **Adjust the Open Operation in Image Preprocessing**: 
    * Adjust the radius of the dish-shaped structure element in image preprocessing
    * Disable the open operation
    
* **Image Segmentation Method**: 
    * K-means clustering
    * Otsu's binarization

* **Automatic or Semi-automatic Image segmentation**

* **Some features in GUI**: 
    * The Compare Tool: allow users to compare part of the original image and the selected image
    * The Votes Customization Tool: Customize the number of votes in voting-based K-means clustering

## Usage
* Step 1: Press the 'Load Image' button in the 'Data' panel

* Step 2: **Wait until** the text on the top changed into 'Press the CROP IMAGE Button NOW to get the ROI', Choose in the 'Area' panel and press the 'Crop Image' button. 
    * If you choose the 'Auto Detection', go to step 3. 
    * If you choose the 'ROI', go to step 4.

* Step 3: 
    * If you are satisfied with the result of auto detection, double click the circle in the selected image. 
    * If you are not satisfied, adjust the radius of the ROI or move the position of the ROI. Then double click the ROI.

* Step 4: Draw a circle in the selected image. Adjust the radius of the ROI and move its position to locate the ROI. Then double click the ROI.

* Step 5: Choose in the 'Degree' Panel.

* Step 6: Adjust the 'Preprocess:Open' panel (or not).

* Step 7: Choose the method in the 'Method' panel. You can enable or disable the 'Autothresh' depending on the image segmentation result (We suggest you to enable for large area).

* Step 8: 
    * If you choose 'Semi-automatic' in step 5, press the 'Draw ROI' in the 'Label Manually' panel. After drawing the ROI, press the circle-shaped tool in the tool bar. Adjust the radius of the labeled colony using keyboard (Press Q to increase and E to decrease) or the slider. Label the colonies in the Previously drawn ROI.
    * If not, go to step 9.
    
* Step 9: Press the 'Run' button and wait until the program finishes.

* Step 10: 
    * If you are not satisfied with the segmentation result. Change the number of votes using the slider below the selected image. Press the 'Recount' button to update the colony number.
    * If not, go to step 11.
    
* Step 11: If you want to segment other images, repeat step 1-10.

## Built With

* [MATLAB](https://www.mathworks.com/products/matlab.html)

## Authors
* **Li Qianyun** - <jasmineqy0@gmail.com>
* **Lin Guangze** - <lgz98616@gmail.com>



