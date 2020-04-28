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
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pr

% Last Modified by GUIDE v2.5 09-Apr-2020 14:31:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
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

set(handles.SelectedIm, 'visible', 'off');
setappdata(handles.SelectedIm, 'cs', 0);
setappdata(handles.SelectedIm, 'rs', 0);
set(handles.SegIm, 'visible', 'off');
set(handles.ROIRButton, 'value', 1);
set(handles.WholeButton, 'value', 0);
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


% --- Executes on button press in WholeButton.
function WholeButton_Callback(~, ~, handles)
% hObject    handle to WholeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ROIRButton, 'value', 0);
set(handles.ROIPButton, 'Enable', 'off');
set(handles.WholeButton, 'value', 1);
% Hint: get(hObject,'Value') returns toggle state of WholeButton


% --- Executes on button press in ROIRButton.
function ROIRButton_Callback(~, eventdata, handles)
% hObject    handle to ROIRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ROIRButton, 'value', 1);
set(handles.ROIPButton, 'Enable', 'on');
set(handles.WholeButton, 'value', 0);
warndlg('Remember to Select the ROI BEFORE Running');
% Hint: get(hObject,'Value') returns toggle state of ROIRButton

% % --- Executes on button press in .
% function ManualCheck_Callback(hObject, eventdata, handles)
% % hObject    handle to ManualCheck (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if get(handles.ManualCheck, 'value')
%     set(handles.ROICir,'State','on');
%     set(handles.CellCir,'State','on');
% else
%     set(handles.ROICir,'State','off');
%     set(handles.CellCir,'State','off');
% end


% Hint: get(hObject,'Value') returns toggle state of ManualCheck

% --- Executes on button press in Run.
function Run_Callback(hObject, ~, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(handles.SelectedIm, 'image'))
    % get the image
    img = getappdata(handles.SelectedIm, 'image');
    
    if get(handles.WholeButton, 'value')
        axes(handles.SelectedIm);
        [center, radius] = diskSeg(img);
        roi = drawcircle('Center', center, 'Radius', radius);
        mask = createMask(roi);
        img(~mask) = 0;
        rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
        img = imcrop(img, rect);
        setappdata(handles.SelectedIm, 'image', img);
        imshow(img); impixelinfo;
    end
    
    % preprocess
    mask = ~(img == 0);
    img = preprocess(img,mask);
    
    % voting algorithm
    nOL = 3; tVote = 0.4;
    [ballotBox1,ballotBox2] = vote(img,[50,50],nOL,mask);
    imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
    imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
    imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
    imgSeg = imgSeg1&imgSeg2;
    axes(handles.SegIm);
    imshow(imgSeg); impixelinfo;
    
    % Count using Cell Size Estimation 
    [numMin,numMax] = countCell(imgSeg);
    str1 = ['Cell Size Estimation: ', num2str(round(numMin)), ' to ',  num2str(round(numMax))];
    
    % Count using Circle Labeling
    if(get(handles.CirCheck, 'Value'))
        [cs, rs] = imfindcircles(img, [2,25], 'Sensitivity', 0.83);
        setappdata(handles.SelectedIm, 'cs', cs);
        setappdata(handles.SelectedIm, 'rs', rs);
        str2 = ['Circle Labeling: ', num2str(size(cs,1))];
    end
    
    % Overlay the image
    mask = getappdata(handles.SelectedIm, 'mask');
    circles = getappdata(handles.SelectedIm, 'l_cs');
    num_p = size(circles, 1);
    circles_x = circles(1:num_p,1);
    circles_y = circles(1:num_p,2);
    circles_r = getappdata(handles.SelectedIm, 'l_rs');
    [imgx, imgy] = size(img);
    overlayIm = zeros(imgx, imgy);
    [cols, rows] = meshgrid(1:imgx,1:imgy);
    for i = 1 : num_p
        overlayIm = overlayIm | logical((rows-circles_x(i)).^2 + (cols - circles_y(i)).^2 <= circles_r(i).^2)';
    end
    overlayIm = overlayIm & mask;
    imgSeg = imgSeg & (~mask) | overlayIm;
    
    % Display the results
    axes(handles.SegIm);
    imshow(imgSeg); impixelinfo;
    set(handles.Result1Text, 'String', str1);
    if(get(handles.CirCheck, 'Value'))
        set(handles.Result2Text, 'String', str2);
    end
    
%     axes(handles.SelectedIm);
% %         imshow(img); impixelinfo;
%         [cs, rs] = imfindcircles(img, [2,25], 'Sensitivity', 0.83);
%         viscircles(cs, rs, 'EdgeColor', 'b');
%         str = ['The approximate number of cells is ', num2str(size(cs,1))];
%         set(handles.Result1Text, 'String', str);
%     drawnow;
else
    warndlg('Please load an image first!');
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
if ~isempty(getappdata(handles.SegIm, 'image'))
    [fname, pname] = uiputfile('*.bmp;*.jpg;*.png;*.jpeg;*.tif');
    if ~(isequal(fname, 0) || isequal(pname, 0))
        imwrite(getimage(handles.SegIm), fullfile(pname, fname));
    end
else
    warndlg('No segmented image found!');
end

% --------------------------------------------------------------------
function SaveSelectedIm_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSelectedIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.SelectedIm, 'image'))
    [fname, pname] = uiputfile('*.bmp;*.jpg;*.png;*.jpeg;*.tif');
    if ~(isequal(fname, 0) || isequal(pname, 0))
        imwrite(getimage(handles.SelectedIm), fullfile(pname, fname));
    end
else
    warndlg('No selected image found!');
end

% --------------------------------------------------------------------
function ROICir_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ROICir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    


% --- Executes on button press in ROIPButton.
function ROIPButton_Callback(hObject, eventdata, handles)
% hObject    handle to ROIPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.SelectedIm, 'image'))
    % get the image
    if get(handles.ROIRButton, 'value')
        roi = drawcircle();
        setappdata(handles.SelectedIm, 'radius', []);
        setappdata(handles.SelectedIm, 'center', []);
        l = addlistener(roi,'ROIClicked', @(src,evt)roiSelect(src,evt,handles));
        uiwait(handles.figure1);
        delete(l);
        setappdata(handles.SelectedIm, 'cs', 0);
        setappdata(handles.SelectedIm, 'rs', 0);
        setappdata(handles.SelectedIm, 'l_cs', []);
        setappdata(handles.SelectedIm, 'l_rs', []);
        set(get(handles.SegIm, 'children'), 'visible', 'off');
        set(handles.Result1Text, 'String', []);
        set(handles.Result2Text, 'String', []);
    end
end
function roiSelect(src,evt,varargin)
    handles = varargin{1};
    img = getimage(handles.SelectedIm);
    center = getappdata(handles.SelectedIm, 'center');
    radius = getappdata(handles.SelectedIm, 'radius');
    evname = evt.EventName;

    switch(evname)
        case{'ROIClicked'}
            if isequal(center,src.Center) && isequal(radius,src.Radius)
                mask = createMask(src);
                img(~mask) = 0;
                rect = [src.Center(1)-src.Radius, src.Center(2)-src.Radius, src.Radius*2, src.Radius*2];
                img = imcrop(img, rect);
                setappdata(handles.SelectedIm, 'image', img);
                uiresume(handles.figure1);
                axes(handles.SelectedIm);
                handles.image1 = imshow(img,'Parent',handles.SelectedIm);impixelinfo;
                set(handles.image1,'ButtonDownFcn',{@SelectedIm_ButtonDownFcn,handles});
            else
                setappdata(handles.SelectedIm, 'center', src.Center);
                setappdata(handles.SelectedIm, 'radius', src.Radius); 
            end
    end


% --------------------------------------------------------------------
function LoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.SelectedIm);
[fname,pname] = uigetfile({'*.bmp;*.jpg;*.png;*.jpeg;*.tif'},...
                'Pick an image', '/image/');
str = [pname fname];
if isequal(fname, 0) || isequal(pname, 0)
    warndlg('Please select an image first!');
    return;
else
    img = rgb2gray(imread(str));
    setappdata(handles.SelectedIm, 'image', img);
    setappdata(handles.SelectedIm, 'cs', 0);
    setappdata(handles.SelectedIm, 'rs', 0);
    setappdata(handles.SelectedIm, 'l_cs', []);
    setappdata(handles.SelectedIm, 'l_rs', []);
    set(get(handles.SegIm, 'children'), 'visible', 'off');
    set(handles.Result1Text, 'String', []);
    set(handles.Result2Text, 'String', []);
    
    handles.image1 = imshow(img,'Parent',handles.SelectedIm);
    set(handles.image1,'ButtonDownFcn',{@SelectedIm_ButtonDownFcn,handles});
end


% --------------------------------------------------------------------
function CellCir_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ROICir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'State'),'on')
    pan(handles.SelectedIm,'off');
    zoom(handles.SelectedIm,'off');
    enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'circle');
    iptSetPointerBehavior(handles.SelectedIm, enterFcn);
    iptPointerManager(handles.figure1,'enable');
end

% --------------------------------------------------------------------
function CellCir_OffCallback(hObject, eventdata, handles)
% hObject    handle to ROICir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

enterFcn = @(figHandle, currentPoint) set(figHandle, 'Pointer', 'arrow');
iptSetPointerBehavior(handles.SelectedIm, enterFcn);
iptPointerManager(handles.figure1,'disable');


% --- Executes on selection change in PopupMenu.
function PopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupMenu
index_selected = get(hObject, 'Value');
axes(handles.SelectedIm);
if(index_selected == 2)
    cs = getappdata(handles.SelectedIm, 'cs');
    rs = getappdata(handles.SelectedIm, 'rs');
    if(cs == 0 | rs == 0)
       set(get(handles.SelectedIm, 'children'), 'visible', 'off');
    else
        viscircles(cs, rs, 'EdgeColor', 'b');
    end
else
    img = getappdata(handles.SelectedIm, 'image');
    imshow(img); impixelinfo;
end

% --- Executes during object creation, after setting all properties.
function PopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Original Image'; 'Labeled Image'});


% --- Executes on mouse press over axes background.
function SelectedIm_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SelectedIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(get(handles.CellCir,'State'),'on')
    return;
end
point = get(handles.SelectedIm,'CurrentPoint');
point = point(1,1:2);
c = getappdata(handles.SelectedIm, 'c');
r = getappdata(handles.SelectedIm, 'r');
if (point(1)-c(1))^2 + (point(2)-c(2))^2 >= r^2
       return;
end
cs = getappdata(handles.SelectedIm, 'l_cs');
rs = getappdata(handles.SelectedIm, 'l_rs');
cs = [cs; point];
rs = [rs get(handles.radiusSlider, 'Value')];
handles.v = viscircles(cs, rs, 'Color', 'b');
set(handles.image1,'ButtonDownFcn',{@SelectedIm_ButtonDownFcn,handles});
set(handles.v,'PickableParts','none');
setappdata(handles.SelectedIm, 'l_cs', cs);
setappdata(handles.SelectedIm, 'l_rs', rs);
set(handles.v,'HitTest','off');


% --- Executes on button press in drawROIButton.
function drawROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(handles.SelectedIm, 'image'))
    roi = drawcircle();
    setappdata(handles.SelectedIm, 'r', []);
    setappdata(handles.SelectedIm, 'c', []);
    k = addlistener(roi,'ROIClicked', @(src,evt)roiDraw(src,evt,handles));
    uiwait(handles.figure1);
    delete(k);
end
function roiDraw(src,evt,varargin)
    handles = varargin{1};
    center = getappdata(handles.SelectedIm, 'c');
    radius = getappdata(handles.SelectedIm, 'r');
    evname = evt.EventName;
    
    switch(evname)
        case{'ROIClicked'}
            if isequal(center,src.Center) && isequal(radius,src.Radius)
                mask = createMask(src);
                setappdata(handles.SelectedIm, 'mask', mask);
                img = getappdata(handles.SelectedIm,'image');
                uiresume(handles.figure1);
                handles.image1 = imshow(img, 'Parent', handles.SelectedIm);
                handles.h = viscircles(center, radius);
                set(handles.image1,'ButtonDownFcn',{@SelectedIm_ButtonDownFcn,handles});
                set(handles.h,'PickableParts','none');
                set(handles.h,'HitTest','off');
            else
                setappdata(handles.SelectedIm, 'c', src.Center);
                setappdata(handles.SelectedIm, 'r', src.Radius); 
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
set(hObject, 'Min', 6);
set(hObject, 'Max', 20);
set(hObject, 'Value', 13);
