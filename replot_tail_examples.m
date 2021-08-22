grid_summary_mat_directory='E:\WP_work\Dropbox\Harvard\Coloration_research\Multi_spectra_processing\Method_summary\Examplar_imgs\dorsal-ventral_map\summary_matrices';
Code_directory='E:\WP_work\Dropbox\Harvard\Coloration_research\Multi_spectra_processing\Method_summary\matlab_scripts_organized\replot_tail_and_avg_shapes';
Result_directory='E:\WP_work\Dropbox\Harvard\Coloration_research\Multi_spectra_processing\Method_summary\Examplar_imgs\dorsal-ventral_map\';
bufferW=50; %Buffer range from the tip of bar to the edge of image
rescaleOpacity=1; %rescale opacity to fit 10%-90% range or not
defaultOpacity=0.8; %the opacity when all probility are the same
boundaryOrNot=1; %whether to draw boundary of shape or not
boundaryWidth=4; %boundary width if there is any

%color setting
color1=[[245,164,190];[250,37,98]]/255; %red gradient for tail probability; low to high
color2=[[37,299,250];[2,39,247]]/255; %blue gradient for tail curvature; low to high
color3=[[255,255,255];[130,130,130]]/255; %grey gradient for tail curvature iqr; low to high
shpColor=1; %the color of shp, default is 1
bgColor=1; %the coor of background, default is 0.2

%%
% define tail parameter set
phy_summary_list=dir(fullfile(grid_summary_mat_directory,'*summary*.mat')); %This need to be run before specifying the tail paramteres

%[probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size, cur_err_plot_size]
prefered_tail_parameter_list=repmat([0, 8, 10, 40, 20], length(phy_summary_list), 1); %default setting for all
prefered_tail_parameter_list(4,:)=[0, 10, 15, 50, 25]; %special specification for a certain group

%reference list
% [[1, 10, 15, 50, 25]; %Papilionidae; [probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size, cur_err_plot_size]
% [0, 6, 8, 30, 15]; %Hedylidae
% [0, 4, 6, 16, 8]; %Hesperiidae
% [1, 6, 8, 30, 15]; %Pieridae
% [0, 4, 6, 12, 6]; %Riodinidae
% [0, 4, 6, 18, 9]; %Lycaenidae
% [1, 5, 7, 24, 12]]; %Nymphalidae
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Set only above if you are not confident about your coding skill%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');

addpath(genpath(Code_directory)) %Add the library to the path

subFolderList={'tail_summary_visualization'};
for fold=1:length(subFolderList)
    if ~exist(fullfile(Result_directory,subFolderList{fold}), 'dir')
        mkdir(fullfile(Result_directory,subFolderList{fold}));
    end
    disp(['corresponding folder ', subFolderList{fold}, ' is created / found.']);
end

% runPhyList=[1, 3]; %run only specific group; the number indicates the index of the group in the phy_summary_list
runPhyList=[1:length(phy_summary_list)]; %run entire list

for matinID0=1:length(runPhyList)
    matinID=runPhyList(matinID0);
    try
        matindir=phy_summary_list(matinID).folder;
        matinname=phy_summary_list(matinID).name;
        matres0=strsplit(matinname,'res-');
        matres1=strsplit(matres0{2},'x');
        mat_res=str2num(matres1{1});
        groupName0=matres0{1};
        groupName=groupName0(1:end-1);
        sexTail0=strsplit(groupName,'_');
        sexTail=sexTail0{end};
        matin=fullfile(matindir,matinname);
        sppmat0=load(matin);
        fieldName=cell2mat(fieldnames(sppmat0));
        sppmat=sppmat0.(fieldName);
        clear sppmat0;
        disp(['[',matinname,'] in has been read into memory']);

        scaleLen=nanmean(cell2mat(reshape(vertcat(sppmat{7}{:}),[],1)),'all');
        wingGridsH2=sppmat{3}{2}{3};
        wingMask_meanH2=sppmat{3}{2}{1};
        firstColLastRow_midPts_single_line=deriveTailPlotLoc(wingGridsH2, wingMask_meanH2); %Derive the key coordinatinos for plotting tail

        tail_all_info=sppmat{5};
        firstColLastRow_probability=tail_all_info{1};
        firstColLastRow_Len_summary_median=tail_all_info{2};
        firstColLastRow_Cur_summary_median=tail_all_info{3};
        firstColLastRow_Len_summary_IQR=tail_all_info{4};
        firstColLastRow_Cur_summary_IQR=tail_all_info{5};

        sampleN=length(sppmat{8});

        %Plot tail summary
%         disp('Start to plot tail summary');
        probilityRestriction=prefered_tail_parameter_list(matinID, 1); %Use probability to restrict the tail output or not; 1: on; 0: off
        distance2Edge=prefered_tail_parameter_list(matinID, 2);
        distance2OutterPlot=prefered_tail_parameter_list(matinID, 3);
        cur_plot_size=prefered_tail_parameter_list(matinID, 4);
        cur_err_plot_size=prefered_tail_parameter_list(matinID, 5);

        if shpColor<=0.5
            color3=[[shpColor, shpColor, shpColor]*255 ;[255,255,255]]/255; %grey gradient for curvature iqr; low to high
        end
        if boundaryOrNot==1
            if strcmp(sexTail, 'male')
                boundaryColor=[2,39,247]/255;
            elseif strcmp(sexTail, 'female')
                boundaryColor=[250,37,98]/255;
            else
                boundaryColor=[130,130,130]/255;
            end
        else
            boundaryColor=[];
        end
        
        imgformat='png';
        imgresolution=200;
        outnameHeader=groupName;
        if boundaryOrNot==1
            visoutname=fullfile(Result_directory,subFolderList{1},[outnameHeader,'_bothSides_res-',num2str(mat_res),'x',num2str(mat_res),'_n-',num2str(sampleN),'_bg-',num2str(bgColor),'_boundary_tails_summary.png']);
        else
            visoutname=fullfile(Result_directory,subFolderList{1},[outnameHeader,'_bothSides_res-',num2str(mat_res),'x',num2str(mat_res),'_n-',num2str(sampleN),'_bg-',num2str(bgColor),'_tails_summary.png']);
        end
        fftail=figure('visible', 'off');
        plotTails2(wingMask_meanH2,firstColLastRow_Len_summary_median,firstColLastRow_probability,firstColLastRow_Cur_summary_median, firstColLastRow_Len_summary_IQR, firstColLastRow_Cur_summary_IQR, firstColLastRow_midPts_single_line, rescaleOpacity, defaultOpacity, bufferW,...
            probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size, cur_err_plot_size, color1, color2,color3, shpColor, bgColor, boundaryColor, boundaryWidth, scaleLen);
        export_fig(fftail,visoutname, ['-',imgformat],['-r',num2str(imgresolution)]);
        close(fftail);
        disp(['saving [', groupName, '_res-',num2str(mat_res),'x',num2str(mat_res),'_spn-',num2str(sampleN),'_bg-',num2str(bgColor),'_tails_summary.png]']);
    catch
        disp(['################################']);
        disp(['################################']);
        disp(['[ ', groupName, ' ]_goes_wrong!]']);
        disp(['################################']);
        disp(['################################']);
    end
end



