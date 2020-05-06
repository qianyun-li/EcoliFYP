function varargout = pr(varargin)
% PR MATLAB code for pr.fig
%      PR, by itself, creates a new PR or raises the existing
%      singleton*.
%
%      H = PR returns the handle to a new PR or the handle to
%      the existing singleton*.
%
%      PR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PR.M with the given input arguments.
%
%      PR('Property','Value',...) creates a new PR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to runbutton (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pr

% Last Modified by GUIDE v2.5 06-May-2020 20:51:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pr_OpeningFcn, ...
    'gui_OutputFcn',  @pr_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pr is made visible.
function pr_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pr (see VARARGIN)

set(handles.selectedIm, 'visible', 'off');
set(handles.segIm, 'visible', 'off');
setappdata(handles.selectedIm, 'cs', 0);
setappdata(handles.selectedIm, 'rs', 0);
set(handles.drawButton, 'enable', 'off');
set(handles.radiusSlider, 'enable', 'off');

% show reminder
remindTxt = 'Load an image to start';
set(handles.remindStr, 'String', remindTxt);

% Choose default command line output for pr
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pr wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pr_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(~, ~, ~)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in wholeRButton.
function wholeRButton_Callback(~, ~, handles)
% hObject    handle to wholeRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wholeRButton
remindTxt = 'Press the CROP IMAGE to get the roi NOW';
set(handles.remindStr, 'String', remindTxt);

% --- Executes on button press in roiRButton.
function roiRButton_Callback(~, eventdata, handles)
% hObject    handle to roiRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of roiRButton
% show reminder
remindTxt = 'Press the CROP IMAGE to get the roi NOW';
set(handles.remindStr, 'String', remindTxt);

% --- Executes on button press in runButton.
function runButton_Callback(hObject, ~, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(handles.selectedIm, 'image'))
    remindTxt = 'Please wait while running';
    set(handles.remindStr, 'String', remindTxt);
    
    % get the image
    img = getappdata(handles.selectedIm, 'image');
    
    % preprocess
    img = preprocess(img);
    
    if get(handles.clusterRButton, 'value')
        % voting algorithm
        nOL = 3; tVote = 0.4;
        [ballotBox1,ballotBox2] = vote(img,[50,50],nOL);
        imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
        imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
        imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
        imgSeg = imgSeg1&imgSeg2;
    else
        [f,~] = ksdensity(img(:), 0:1:256);
        [~, loc] = findpeaks(f, 0:1:256);
        level = (loc(2)+loc(3)) / 255 * 0.45;
        imgSeg = imbinarize(img,level);
    end
    axes(handles.segIm);
    imshow(imgSeg); impixelinfo;
    
    % Count using Cell Size Estimation
    [numMin,numMax] = countCell(img, imgSeg);
    str1 = ['Cell Size Estimation: ', num2str(round(numMin)), ' to ',  num2str(round(numMax))];
    
    %     % Count using Circle Labeling
    %     if(get(handles.CirCheck, 'Value'))
    %         [cs, rs] = imfindcircles(img, [2,25], 'Sensitivity', 0.83);
    %         setappdata(handles.selectedIm, 'cs', cs);
    %         setappdata(handles.selectedIm, 'rs', rs);
    %         str2 = ['Circle Labeling: ', num2str(size(cs,1))];
    %     end
    
    if get(handles.semiAutoRButton, 'value')
        % Overlay the image
        mask = getappdata(handles.selectedIm, 'mask');
        circles = getappdata(handles.selectedIm, 'l_cs');
        num_p = size(circles, 1);
        circles_x = circles(1:num_p,1);
        circles_y = circles(1:num_p,2);
        circles_r = getappdata(handles.selectedIm, 'l_rs');
        [imgx, imgy] = size(img);
        overlayIm = zeros(imgx, imgy);
        [cols, rows] = meshgrid(1:imgx,1:imgy);
        for i = 1 : num_p
            overlayIm = overlayIm | logical((rows-circles_x(i)).^2 + (cols - circles_y(i)).^2 <= circles_r(i).^2)';
        end
        overlayIm = overlayIm & mask;
        imgSeg = imgSeg & (~mask) | overlayIm;
    end
    
    % Display the results
    axes(handles.segIm);
    imshow(imgSeg); impixelinfo;
    set(handles.result1Str, 'String', str1);
    %     if(get(handles.CirCheck, 'Value'))
    %         set(handles.result2Str, 'String', str2);
    %     end
    
    %     axes(handles.selectedIm);
    % %         imshow(img); impixelinfo;
    %         [cs, rs] = imfindcircles(img, [2,25], 'Sensitivity', 0.83);
    %         viscircles(cs, rs, 'EdgeColor', 'b');
    %         str = ['The approximate number of cells is ', num2str(size(cs,1))];
    %         set(handles.result1Str, 'String', str);
    %     drawnow;
    remindTxt = 'Finished';
    set(handles.remindStr, 'String', remindTxt);
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveFig_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, pname] = uiputfile('*.fig');

if ~(isequal(fname, 0) || isequal(pname, 0))
    saveas(gcf, fullfile(pname,fname));
end

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveSegIm_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSegIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.segIm, 'image'))
    [fname, pname] = uiputfile('*.bmp;*.jpg;*.png;*.jpeg;*.tif');
    if ~(isequal(fname, 0) || isequal(pname, 0))
        imwrite(getimage(handles.segIm), fullfile(pname, fname));
    end
else
    warndlg('No segmented image found!');
end

% --------------------------------------------------------------------
function SaveSelectedIm_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSelectedIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.selectedIm, 'image'))
    [fname, pname] = uiputfile('*.bmp;*.jpg;*.png;*.jpeg;*.tif');
    if ~(isequal(fname, 0) || isequal(pname, 0))
        imwrite(getimage(handles.selectedIm), fullfile(pname, fname));
    end
else
    warndlg('No selected image found!');
end


% --- Executes on button press in cropButton.
function cropButton_Callback(hObject, eventdata, handles)
% hObject    handle to cropButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

img = getappdata(handles.selectedIm, 'image'); 
if ~isempty(img)
    % Got the image
    if get(handles.wholeRButton, 'value') == false
        % Whole image button not selected
        if get(handles.roiRButton, 'value')
            % ROI radio button selected
            roi = drawcircle();
            setappdata(handles.selectedIm, 'radius', []);
            setappdata(handles.selectedIm, 'center', []);
        else
            % Auto Detection radio button selected
            img = getappdata(handles.selectedIm, 'image');
            axes(handles.selectedIm);
            [center, radius] = diskSeg(img);
            roi = drawcircle('Center', center, 'Radius', radius);
        end
        
        l = addlistener(roi,'ROIClicked', @(src,evt)roiSelect(src,evt,handles));
        uiwait(handles.figure1);
        delete(l);
        setappdata(handles.selectedIm, 'cs', 0);
        setappdata(handles.selectedIm, 'rs', 0);
        setappdata(handles.selectedIm, 'l_cs', []);
        setappdata(handles.selectedIm, 'l_rs', []);
        set(get(handles.segIm, 'children'), 'visible', 'off');
        set(handles.result1Str, 'String', []);
        %             set(handles.result2Str, 'String', []);
    end
    
    set(handles.cropButton, 'enable', 'off');
end

function roiSelect(src,evt,varargin)
handles = varargin{1};
img = getimage(handles.selectedIm);
img_ori = getappdata(handles.selectedIm, 'oriIm');
center = getappdata(handles.selectedIm, 'center');
radius = getappdata(handles.selectedIm, 'radius');
evname = evt.EventName;

switch(evname)
    case{'ROIClicked'}
        if isequal(center,src.Center) && isequal(radius,src.Radius)
            mask = createMask(src);
            img(~mask) = 0;
            img_ori(~mask) = 0;
            rect = [src.Center(1)-src.Radius, src.Center(2)-src.Radius, src.Radius*2, src.Radius*2];
            img = imcrop(img, rect);
            img_ori = imcrop(img_ori, rect);
            setappdata(handles.selectedIm, 'image', img);
            uiresume(handles.figure1);
            axes(handles.selectedIm);
            handles.image1 = imshow(img_ori,'Parent',handles.selectedIm);impixelinfo;
            set(handles.image1,'ButtonDownFcn',{@selectedIm_ButtonDownFcn,handles});
        else
            setappdata(handles.selectedIm, 'center', src.Center);
            setappdata(handles.selectedIm, 'radius', src.Radius);
        end
end

% --------------------------------------------------------------------
function CellCir_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ROICir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'State'),'on')
    pan(handles.selectedIm,'off');
    zoom(handles.selectedIm,'off');
    enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'circle');
    iptSetPointerBehavior(handles.selectedIm, enterFcn);
    iptPointerManager(handles.figure1,'enable');
end

% --------------------------------------------------------------------
function CellCir_OffCallback(hObject, eventdata, handles)
% hObject    handle to ROICir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'arrow');
iptSetPointerBehavior(handles.selectedIm, enterFcn);
iptPointerManager(handles.figure1,'disable');

% --- Executes on mouse press over axes background.
function selectedIm_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to selectedIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(get(handles.CellCir,'State'),'on')
    return;
end
point = get(handles.selectedIm,'CurrentPoint');
point = point(1,1:2);
c = getappdata(handles.selectedIm, 'c');
r = getappdata(handles.selectedIm, 'r');
if (point(1)-c(1))^2 + (point(2)-c(2))^2 >= r^2
    return;
end
cs = getappdata(handles.selectedIm, 'l_cs');
rs = getappdata(handles.selectedIm, 'l_rs');
cs = [cs; point];
rs = [rs get(handles.radiusSlider, 'Value')];
handles.v = viscircles(cs, rs, 'Color', 'b');
set(handles.image1,'ButtonDownFcn',{@selectedIm_ButtonDownFcn,handles});
set(handles.v,'PickableParts','none');
setappdata(handles.selectedIm, 'l_cs', cs);
setappdata(handles.selectedIm, 'l_rs', rs);
set(handles.v,'HitTest','off');


% --- Executes on button press in drawROIButton.
function drawButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.selectedIm, 'image'))
    remindTxt = "Draw the ROI and Circle the cells using the CIRCLE IN TOOLBAR";
    set(handles.remindStr, 'String', remindTxt);
    roi = drawcircle();
    setappdata(handles.selectedIm, 'r', []);
    setappdata(handles.selectedIm, 'c', []);
    k = addlistener(roi,'ROIClicked', @(src,evt)roiDraw(src,evt,handles));
    uiwait(handles.figure1);
    delete(k);
end
function roiDraw(src,evt,varargin)
handles = varargin{1};
center = getappdata(handles.selectedIm, 'c');
radius = getappdata(handles.selectedIm, 'r');
evname = evt.EventName;

switch(evname)
    case{'ROIClicked'}
        if isequal(center,src.Center) && isequal(radius,src.Radius)
            mask = createMask(src);
            setappdata(handles.selectedIm, 'mask', mask);
            img = getappdata(handles.selectedIm,'image');
            uiresume(handles.figure1);
            handles.image1 = imshow(img, 'Parent', handles.selectedIm);
            handles.h = viscircles(center, radius);
            set(handles.image1,'ButtonDownFcn',{@selectedIm_ButtonDownFcn,handles});
            set(handles.h,'PickableParts','none');
            set(handles.h,'HitTest','off');
        else
            setappdata(handles.selectedIm, 'c', src.Center);
            setappdata(handles.selectedIm, 'r', src.Radius);
        end
end


% --- Executes on slider movement.
function radiusSlider_Callback(hObject, eventdata, handles)
% hObject    handle to radiusSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
slider_value = get(hObject, 'Value');
set(handles.radiusText, 'String', num2str(slider_value));


% --- Executes during object creation, after setting all properties.
function radiusSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiusSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'Min', 5);
set(hObject, 'Max', 20);
set(hObject, 'Value', 13);


% --- Executes on button press in loadImButton.
function loadImButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadImButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.selectedIm);
[fname,pname] = uigetfile({'*.bmp;*.jpg;*.png;*.jpeg;*.tif'},...
    'Pick an image', '/image/');
str = [pname fname];
if isequal(fname, 0) || isequal(pname, 0)
    return;
else
    img_ori = rgb2gray(imread(str));
    setappdata(handles.selectedIm, 'oriIm', img_ori);
    setappdata(handles.selectedIm, 'cs', 0);
    setappdata(handles.selectedIm, 'rs', 0);
    setappdata(handles.selectedIm, 'l_cs', []);
    setappdata(handles.selectedIm, 'l_rs', []);
    set(handles.autoRButton, 'value', 1);
    set(handles.clusterRButton, 'value', 1);
    set(get(handles.segIm, 'children'), 'visible', 'off');
    set(handles.result1Str, 'String', []);
    set(handles.result2Str, 'String', []);
    set(handles.cropButton, 'enable', 'on');
    remindTxt = 'Press the CROP IMAGE Button NOW to get the ROI';
    set(handles.remindStr, 'String', remindTxt);
    
    % Resize image width to 3120
    img_ori = imresize(img_ori, 3120 / size(img_ori,2));
    setappdata(handles.selectedIm, 'oriIm', img_ori);
    
    % top-hat filtering
    se = strel('disk',90);
    img = imtophat(img_ori, se);
    setappdata(handles.selectedIm, 'image', img);
    
    handles.image1 = imshow(img_ori,'Parent',handles.selectedIm);
    set(handles.image1,'ButtonDownFcn',{@selectedIm_ButtonDownFcn,handles});
end


% --- Executes on button press in autoRButton.
function autoRButton_Callback(hObject, eventdata, handles)
% hObject    handle to autoRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoRButton
set(handles.drawButton, 'enable', 'off');
set(handles.radiusSlider, 'enable', 'off');
remindTxt = 'Choose the METHOD and RUN';
set(handles.remindStr, 'String', remindTxt);


% --- Executes on button press in semiAutoRButton.
function semiAutoRButton_Callback(hObject, eventdata, handles)
% hObject    handle to semiAutoRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of semiAutoRButton
set(handles.drawButton, 'enable', 'on');
set(handles.radiusSlider, 'enable', 'on');
remindTxt = 'Operate the LABEL MANUALLY section';
set(handles.remindStr, 'String', remindTxt);


% --- Executes on button press in clusterRButton.
function clusterRButton_Callback(hObject, eventdata, handles)
% hObject    handle to clusterRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clusterRButton


% --- Executes on button press in threshRButton.
function threshRButton_Callback(hObject, eventdata, handles)
% hObject    handle to threshRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of threshRButton


% --- Executes on button press in AutoDetectionRButton.
function AutoDetectionRButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoDetectionRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoDetectionRButton
remindTxt = 'Press the CROP IMAGE to get the roi NOW';
set(handles.remindStr, 'String', remindTxt);
