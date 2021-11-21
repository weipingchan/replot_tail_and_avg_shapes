grid_summary_mat_directory='...\summary_matrices';
Code_directory='...\replot_tail_and_avg_shapes';
Result_directory='...';
bufferW=50; %Buffer range from the tip of bar to the edge of image
defaultOpacity=0.8; %the opacity when all probilities are the same
boundaryOrNot=1; %whether to draw boundary of shape or not: 0 (no), 1 (yes)
boundaryWidth=2; %boundary width if there is any

%color setting
color1=[[245,164,190];[250,37,98]]/255; %red gradient for tail probability; low to high
color2=[[37,299,250];[2,39,247]]/255; %blue gradient for tail curvature; low to high
color3=[[255,255,255];[130,130,130]]/255; %gray gradient for tail curvature iqr; low to high
shpColor=1; %the color of the shape, default is 1
bgColor=1; %the color of the background, default is 0.2

%%
% define tail parameter set
group_list={'All','Heliconius','Lycaenidae', 'NymPap'}; %These should match the group names in the summary matrix folder. No need to run all files in the folder.

%[probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size, cur_err_plot_size]
prefered_tail_parameter_list=repmat([0, 8, 10, 40, 20], length(group_list), 1); %default setting for all
%prefered_tail_parameter_list(iGroup,:)=[0, 10, 15, 50, 25]; %special specification for a certain group. In this case, the ith group (NymPap) has been specified
%An additional line specify a group. If you want to specify one group, add one line; two groups, two lines
prefered_tail_parameter_list(4,:)=[0, 10, 15, 50, 25]; %special specification for a certain group. In this case, the 4th group (NymPap) has been specified


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
%%%%%%%%%%Set only above if you are not confident in your coding skill%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
addpath(genpath(Code_directory)) %Add the library to the path
% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the warning you want to enable. 
warning('off', 'Images:initSize:adjustingMag');

if ~exist(fullfile(Result_directory,'shp_tail_visualization'), 'dir')
    mkdir(fullfile(Result_directory,'shp_tail_visualization'));
end
disp(['corresponding folder is created / found.']);

phy_summary_list=dir(fullfile(grid_summary_mat_directory,'*summary*.mat')); %This need to be run before specifying the tail parameters

%search for target file name
in_grid_loc0=[];
 for matinID0=1:length(phy_summary_list)
    matinname=phy_summary_list(matinID0).name;
    matres0=strsplit(matinname,'res-');
    matres1=strsplit(matres0{2},'x');
    mat_res=str2num(matres1{1});
    groupName0=matres0{1};
    groupName=groupName0(1:end-1);
    
    for familyID=1:length(group_list)
        if strcmp(groupName, group_list{familyID})
            in_grid_loc0=[in_grid_loc0, matinID0];
        end
    end
 end

 %%
 %gather the tail info of all targets in order to make them comparable
 %across panels
firstColLastRow_Prob_all_median=cell(0,1);
firstColLastRow_Len_all_median=cell(0,1);
firstColLastRow_Cur_all_median=cell(0,1);
firstColLastRow_Len_all_IQR=cell(0,1);
firstColLastRow_Cur_all_IQR=cell(0,1);
for matinID=1:length(in_grid_loc0)
        matindir=phy_summary_list(in_grid_loc0(matinID)).folder;
        matinname=phy_summary_list(in_grid_loc0(matinID)).name;
        matres0=strsplit(matinname,'res-');
        matres1=strsplit(matres0{2},'x');
        mat_res=str2num(matres1{1});
        groupName0=matres0{1};
        groupName=groupName0(1:end-1);
        matin=fullfile(matindir,matinname);
        sppmat0=load(matin);
        fieldName=cell2mat(fieldnames(sppmat0));
        sppmat=sppmat0.(fieldName);
        clear sppmat0;
        tail_all_info=sppmat{5};
        firstColLastRow_probability=tail_all_info{1};
        firstColLastRow_Len_summary_median=tail_all_info{2};
        firstColLastRow_Cur_summary_median=tail_all_info{3};
        firstColLastRow_Len_summary_IQR=tail_all_info{4};
        firstColLastRow_Cur_summary_IQR=tail_all_info{5};
        
        firstColLastRow_Prob_all_median{matinID}=firstColLastRow_probability;
        firstColLastRow_Len_all_median{matinID}=firstColLastRow_Len_summary_median;
        firstColLastRow_Cur_all_median{matinID}=firstColLastRow_Cur_summary_median;
        firstColLastRow_Len_all_IQR{matinID}=firstColLastRow_Len_summary_IQR;
        firstColLastRow_Cur_all_IQR{matinID}=firstColLastRow_Cur_summary_IQR;
end

%calculate the upper and lower boundaries
firstColLastRow_Prob_all_median2= reshape(vertcat(firstColLastRow_Prob_all_median{:}),[],1);
firstColLastRow_Prob_all_median2(firstColLastRow_Prob_all_median2==0)=[];
prob_color_sacle_rng=[min(firstColLastRow_Prob_all_median2), max(firstColLastRow_Prob_all_median2)];
color_quantile=0.8; %must <=1
colorscale_opacity_rng=[(1-color_quantile)/2, (1+color_quantile)/2];

cur_quantile=0.9;
firstColLastRow_Cur_all_median2= reshape(vertcat(firstColLastRow_Cur_all_median{:}),[],1);
firstColLastRow_Cur_all_median2(firstColLastRow_Cur_all_median2<=0)=[];
curv_color_sacle_rng=[quantile(firstColLastRow_Cur_all_median2, (1-cur_quantile)/2), quantile(firstColLastRow_Cur_all_median2, (1+cur_quantile)/2)];

cur_err_quantile=0.9;
firstColLastRow_Cur_err_all_median2= reshape(vertcat(firstColLastRow_Cur_all_IQR{:}),[],1);
curv_color_err_sacle_rng=[0, quantile(firstColLastRow_Cur_err_all_median2, (1+cur_err_quantile)/2)];

%begin the real plot
for matinID=1:length(in_grid_loc0)
    try
        matindir=phy_summary_list(in_grid_loc0(matinID)).folder;
        matinname=phy_summary_list(in_grid_loc0(matinID)).name;
        matres0=strsplit(matinname,'res-');
        matres1=strsplit(matres0{2},'x');
        mat_res=str2num(matres1{1});
        groupName0=matres0{1};
        groupName=groupName0(1:end-1);
        family0=strsplit(groupName,'_');
        family=family0{1};
        matin=fullfile(matindir,matinname);
        sppmat0=load(matin);
        fieldName=cell2mat(fieldnames(sppmat0));
        sppmat=sppmat0.(fieldName);
        clear sppmat0;
        disp(['[',matinname,'] in has been read into memory']);

        sampleN=length(sppmat{8});
        scaleLen=nanmean(cell2mat(reshape(vertcat(sppmat{7}{:}),[],1)),'all');
        
        wingMask_meanF2=double(sppmat{3}{1}{1});
%         wingMask_meanF2(wingMask_meanF2==0)=0.2; %Change background to gray
        %create scale bar in black
        scalelineF=zeros(50,size(wingMask_meanF2,2))+0.2;
        %scaleline(:,:,:)=1;
        scale_to_edge=100;
        if size(scalelineF,2)-scaleLen-scale_to_edge<0
            scale_to_edge=floor((size(scalelineF,2)-scaleLen)/2);
        end
        scalelineF(20:30,round(end-scale_to_edge-scaleLen):end-scale_to_edge,:)=1;
        %combine all images together
        wingMask_meanF3=vertcat(wingMask_meanF2,scalelineF);
        
%         seg4PtsF2=sppmat{3}{1}{2};
%         wingGridsF2=sppmat{3}{1}{3};
        wingMask_meanH2=sppmat{3}{2}{1};
%         %create scale bar in black
%         scalelineH=zeros(50,size(wingMask_meanH2,2))+0.2;
%         %scaleline(:,:,:)=1;
%         scalelineH(20:30,round(end-100-scaleLen):end-100,:)=1;
%         %combine all images together
%         wingMask_meanH3=vertcat(wingMask_meanH2,scalelineH);
%         seg4PtsH2=sppmat{3}{2}{2};
        wingGridsH2=sppmat{3}{2}{3};
        
        firstColLastRow_midPts_single_line=deriveTailPlotLoc(wingGridsH2, wingMask_meanH2); %Derive the key coordinates for plotting tail

        tail_all_info=sppmat{5};
        firstColLastRow_probability=tail_all_info{1};
        firstColLastRow_Len_summary_median=tail_all_info{2};
        firstColLastRow_Cur_summary_median=tail_all_info{3};
        firstColLastRow_Len_summary_IQR=tail_all_info{4};
        firstColLastRow_Cur_summary_IQR=tail_all_info{5};

        parameterID=find(contains(group_list, groupName));
        %Plot tail summary
        probilityRestriction=prefered_tail_parameter_list(parameterID, 1); %Use probability to restrict the tail output or not; 1: on; 0: off
        distance2Edge=prefered_tail_parameter_list(parameterID, 2);
        distance2OutterPlot=prefered_tail_parameter_list(parameterID, 3);
        cur_plot_size=prefered_tail_parameter_list(parameterID, 4);
        cur_err_plot_size=prefered_tail_parameter_list(parameterID, 5);


        if shpColor<=0.5
            color3=[[shpColor, shpColor, shpColor]*255 ;[255,255,255]]/255; %gray gradient for curvature iqr; low to high
        end
        if boundaryOrNot==1
            if strcmp(groupName, 'male')
                boundaryColor=[2,39,247]/255;
            elseif strcmp(groupName, 'female')
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
            visoutname=fullfile(Result_directory,'shp_tail_visualization',[outnameHeader,'_bothSides_res-',num2str(mat_res),'x',num2str(mat_res),'_n-',num2str(sampleN),'_bg-',num2str(bgColor),'_boundary_tails_summary.png']);
        else
            visoutname=fullfile(Result_directory,'shp_tail_visualization',[outnameHeader,'_bothSides_res-',num2str(mat_res),'x',num2str(mat_res),'_n-',num2str(sampleN),'_bg-',num2str(bgColor),'_tails_summary.png']);
        end
        fftail=figure('visible', 'off');
        plotTails_mean_shp(wingMask_meanH2,firstColLastRow_Len_summary_median,firstColLastRow_probability,firstColLastRow_Cur_summary_median, firstColLastRow_Len_summary_IQR, firstColLastRow_Cur_summary_IQR,...
        firstColLastRow_midPts_single_line, [], defaultOpacity, bufferW, prob_color_sacle_rng, colorscale_opacity_rng, curv_color_sacle_rng, curv_color_err_sacle_rng, probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size,...
        cur_err_plot_size, color1, color2,color3, shpColor, bgColor, boundaryColor, boundaryWidth, scaleLen)
        export_fig(fftail,visoutname, ['-',imgformat],['-r',num2str(imgresolution)]);
        close(fftail);
        
        %forewing
        visoutname=fullfile(Result_directory,'shp_tail_visualization',[outnameHeader,'_bothSides_res-',num2str(mat_res),'x',num2str(mat_res),'_n-',num2str(sampleN),'_bg-',num2str(bgColor),'_forewing_summary.png']);
        fffore=figure('visible', 'off');
        plotForewing_mean_shp(wingMask_meanF2, shpColor, bgColor, boundaryColor, boundaryWidth, scaleLen);
        export_fig(fffore,visoutname, ['-',imgformat],['-r',num2str(imgresolution)]);
        close(fffore);
        disp(['saving [', groupName, '_res-',num2str(mat_res),'x',num2str(mat_res),'_spn-',num2str(sampleN),'_bg-',num2str(bgColor),'_tails_summary.png]']);
    catch
        disp(['################################']);
        disp(['################################']);
        disp(['[ ', groupName, ' ]_goes_wrong!]']);
        disp(['################################']);
        disp(['################################']);
    end
end