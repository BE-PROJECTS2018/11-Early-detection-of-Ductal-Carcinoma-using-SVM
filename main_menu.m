function varargout = main_menu(varargin)
% MAIN_MENU MATLAB code for main_menu.fig
%      MAIN_MENU, by itself, creates a new MAIN_MENU or raises the existing
%      singleton*.
%
%      H = MAIN_MENU returns the handle to a new MAIN_MENU or the handle to
%      the existing singleton*.
%
%      MAIN_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_MENU.M with the given input arguments.
%
%      MAIN_MENU('Property','Value',...) creates a new MAIN_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_menu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_menu

% Last Modified by GUIDE v2.5 03-Mar-2018 11:47:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_menu_OpeningFcn, ...
                   'gui_OutputFcn',  @main_menu_OutputFcn, ...
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


% --- Executes just before main_menu is made visible.
function main_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_menu (see VARARGIN)

% Choose default command line output for main_menu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_menu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_menu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% TRAINING
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;                                                                % Disable warnings

imgSet = [imageSet('.\DDSM Database\DDSM_Benign'),...
         imageSet('.\DDSM Database\DDSM_Malignant'),...
         imageSet('.\DDSM Database\DDSM_Normal')];

% Show message box
mb = msgbox('Training Data........'); 

% Loop over the folders
 for i = 1:length({imgSet.Description})
     % Loop over images in that particular folder
     for j = 1:[imgSet(i).Count]
         Image = read(imgSet(i),j);                                         % Read image
         Image = im2uint8(Image);                                           % Change integar type
         Image = imresize(Image,[1000,667]);                                % Resize image
         [IDX,sep] = otsu(Image,3);                                         % Perform OTSU thresholding
         [M,N] = size(IDX);                                                 % Find out size i.e. no. of rows and columns
         a2 = zeros(M,N);                                                   % Create a zero matrix to append data in future
        % Loop over pixels in an image
        for i3 = 1:M
            for j3 = 1:N
                % Give some threshold value
                if(IDX(i3,j3)>= 2 )
                    a2(i3,j3) = 1;
                else
                    a2(i3,j3) = 0;
                end
            end
        end
     
        [b,num] = bwlabel(a2,8);                                            % Find number of label connected objects
        count_pixels_per_obj = sum(bsxfun(@eq,b(:),1:num));                 % Count the pixels for every blob being obtained
        [~,ind] = max(count_pixels_per_obj);                                % Find blob corresponding to the maximum pixel
        a2 = (b==ind);                                                      % Take only that blob from entire image

        seg_image = Image;
        seg_image(~a2) = 0;                                                 % Highlight only that blob from original image
        a2 = adapthisteq(seg_image);
        
        F = fft2(a2);                                                       % Perform Fourier Transform
        Fa = abs(F);                                                        % Get the magnitude
        Fb = log(Fa+1);                                                     % Use log, for perceptual scaling, and +1 since log(0) is undefined
        Fc = mat2gray(Fb);                                                  % Convert matrix to grayscale image      
        
        F1 = fftshift(F);                                                   % Center FFT
        F2 = abs(F1);                                                       % Get the magnitude
        F3 = log(F2+1);                                                     % Use log, for perceptual scaling, and +1 since log(0) is undefined
        F4 = mat2gray(F3);                                                  % Convert matrix to grayscale image  
        
        [p3, p4] = size(F4);                                                % Find out size of an image
        q1 = 400; 
        i3_start = floor((p3-q1)/2); 
        i3_stop = i3_start + q1;
        i4_start = floor((p4-q1)/2);
        i4_stop = i4_start + q1; 
        F5 = F4(i3_start:i3_stop, i4_start:i4_stop, :);

       
        GLCM2 = graycomatrix(F5,'Offset',[0 1; -1 1; -1 0; -1 -1]);         % Create gray-level co-occurrence matrix from image
        stats = GLCM_Features1(GLCM2,0);                                    % Find out GLCM features in this
        t1= struct2array(stats);                                            % Convert this structure to an array
        f2(j,:) = t1;                                                       % Make feature vector of all images
    end
     
    if (i>=1)
        featureD_dft([(((i-1)*j)+1):(i*j)],:) = f2;                         % Make feature vectors of all images of all folders
    end    
 end

save featureD_dft featureD_dft;                                             % Save this as a ".mat" file
close(mb);
mb = msgbox('Training Completed');
close(mb);                                                                  % Close Message Box


%% CLASSIFICATION
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = classify_image;
close(main_menu);
