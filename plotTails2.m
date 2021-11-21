function plotTails2(wingMask_meanH2,firstColLastRow_Len_summary_median,firstColLastRow_probability,firstColLastRow_Cur_summary_median, firstColLastRow_Len_summary_IQR, firstColLastRow_Cur_summary_IQR,firstColLastRow_midPts_single_line, rescaleOpacity, defaultOpacity, bufferW,...
    probilityRestriction, distance2Edge, distance2OutterPlot, cur_plot_size, cur_err_plot_size, color1, color2,color3, shpColor, bgColor, boundaryColor, boundaryWidth, scaleLen)
    stat_cor=regionprops(wingMask_meanH2,'centroid');
    cen_meanH2=stat_cor.Centroid;

    firstColLastRow_slp=bsxfun(@minus, firstColLastRow_midPts_single_line,cen_meanH2);

    firstColLastRow_vector=firstColLastRow_slp./sqrt(firstColLastRow_slp(:,1).^2+firstColLastRow_slp(:,2).^2); %This is a vector based on the length unit =1 of the third side

    firstColLastRow_Len_summary_single_line=reshape(firstColLastRow_Len_summary_median,[],1);
    firstColLastRow_probability_single_line=reshape(firstColLastRow_probability,[],1);
    firstColLastRow_Cur_summary_single_line=reshape(firstColLastRow_Cur_summary_median,[],1);
    firstColLastRow_Len_summary_IQR_single_line=reshape(firstColLastRow_Len_summary_IQR,[],1)/2; %Get half IQR
    firstColLastRow_Cur_summary_IQR_single_line=reshape(firstColLastRow_Cur_summary_IQR,[],1)/2; %Get half IQR
    if probilityRestriction==1 %use probabilty value to restrict the output
        firstColLastRow_Len_summary_single_line(firstColLastRow_probability_single_line==0)=0; %new added
    end
    %inhibt locations with only one record (no IQR)
    firstColLastRow_Len_summary_single_line(firstColLastRow_Len_summary_IQR_single_line==0)=0;
    firstColLastRow_probability_single_line(firstColLastRow_Len_summary_IQR_single_line==0)=0;
    firstColLastRow_Cur_summary_single_line(firstColLastRow_Len_summary_IQR_single_line==0)=0;
    firstColLastRow_Cur_summary_IQR_single_line(firstColLastRow_Len_summary_IQR_single_line==0)=0;

    %Derive the start and end points of line segments
    firstColLastRow_endPts_single_line0 = firstColLastRow_midPts_single_line+firstColLastRow_Len_summary_single_line.*firstColLastRow_vector;
    firstColLastRow_endPts_single_line = firstColLastRow_endPts_single_line0(firstColLastRow_Len_summary_single_line>0,:);
    firstColLastRow_startPts_single_line  = firstColLastRow_midPts_single_line(firstColLastRow_Len_summary_single_line>0,:);

    firstColLastRow_endPts_err_single_line0=firstColLastRow_endPts_single_line0+firstColLastRow_Len_summary_IQR_single_line.*firstColLastRow_vector;
    firstColLastRow_endPts_err_single_line=firstColLastRow_endPts_err_single_line0(firstColLastRow_Len_summary_single_line>0,:);
    firstColLastRow_startPts_err_single_line= firstColLastRow_endPts_single_line;
    
    %Prepare color ratio
    prob_color=firstColLastRow_probability_single_line(firstColLastRow_Len_summary_single_line>0,:);
    curv_color=firstColLastRow_Cur_summary_single_line(firstColLastRow_Len_summary_single_line>0,:);    
    curv_color_err=firstColLastRow_Cur_summary_IQR_single_line(firstColLastRow_Len_summary_single_line>0,:);    

    %%
    %Move the coordination for the plot
    botExt=max(firstColLastRow_endPts_err_single_line(:,1));
    leftExt=min(firstColLastRow_endPts_err_single_line(:,2));
    
    newBot=round(botExt+bufferW);
    newLeft=round(leftExt-bufferW);
    xshift=-(round(newLeft));
    yshift=round(newBot-size(wingMask_meanH2,2));
    if xshift<0 xshift=1;, end;
    if yshift<0 yshift=1;, end;
    wingMask_meanH2_adj=cat(1,cat(2,zeros(size(wingMask_meanH2,1),xshift),wingMask_meanH2), zeros(yshift,size(wingMask_meanH2,2)+xshift));

    firstColLastRow_startPts_single_line_adj=[firstColLastRow_startPts_single_line(:,1),firstColLastRow_startPts_single_line(:,2)+xshift];
    firstColLastRow_endPts_single_line_adj=[firstColLastRow_endPts_single_line(:,1),firstColLastRow_endPts_single_line(:,2)+xshift];

    firstColLastRow_startPts_err_single_line_adj=[firstColLastRow_startPts_err_single_line(:,1),firstColLastRow_startPts_err_single_line(:,2)+xshift];
    firstColLastRow_endPts_err_single_line_adj=[firstColLastRow_endPts_err_single_line(:,1),firstColLastRow_endPts_err_single_line(:,2)+xshift];
    
%     distance2Edge=6;
    cur_loc0 = firstColLastRow_midPts_single_line-distance2Edge*firstColLastRow_vector;
    cur_loc1 =cur_loc0(firstColLastRow_Len_summary_single_line>0,:); %The location to plot curvature
    cur_loc=[cur_loc1(:,1),cur_loc1(:,2)+xshift];
    
%     distance2OutterPlot=8;
    cur_err_loc0 = cur_loc0-distance2OutterPlot*firstColLastRow_vector;
    cur_err_loc1 =cur_err_loc0(firstColLastRow_Len_summary_single_line>0,:); %The location to plot curvature
    cur_err_loc=[cur_err_loc1(:,1),cur_err_loc1(:,2)+xshift];
    
    %%
    
    %Deal with color
    if max(prob_color)~=min(prob_color)
        colorscale_prob=rescale(prob_color);
    else
        colorscale_prob=zeros(size(prob_color,1),1)+0.3;
    end
    
    color_quantile=0.8; %must <=1
    colorscale_opacity=colorscale_prob;
    if round(std(colorscale_prob),4)>0
        if rescaleOpacity==1
            colorscale_opacity(colorscale_opacity<=quantile(colorscale_prob, (1-color_quantile)/2))=quantile(colorscale_prob, (1-color_quantile)/2);
            colorscale_opacity(colorscale_opacity>=quantile(colorscale_prob, (1+color_quantile)/2))=quantile(colorscale_prob, (1+color_quantile)/2);
            colorscale_opacity=rescale(colorscale_opacity, defaultOpacity, 1);
        end    
    else
     colorscale_opacity=zeros(size(colorscale_opacity,1),1)+defaultOpacity;
    end
    
    if max(curv_color)~=min(curv_color)
        colorscale_cur=rescale(curv_color);
    else
        colorscale_cur=zeros(size(curv_color,1),1)+0.3;
    end

        colorscale_cur_err=rescale(curv_color_err);

%     color1=[[245,164,190];[250,37,98]]/255; %red gradient for probability
%     color2=[[37,299,250];[2,39,247]]/255; %blue gradient for curvature
%     color3=[[255,255,255];[0,0,0]]/255; %gray gradient for curvature iqr
    if ~isempty(colorscale_prob)
        color_prob=color1(1,:).*(1-colorscale_prob)+color1(2,:).*(colorscale_prob);
    end
    if ~isempty(colorscale_cur)
        color_cur=color2(1,:).*(1-colorscale_cur)+color2(2,:).*(colorscale_cur);
    else
        color_cur=[];
    end
    if ~isempty(colorscale_cur_err)
        color_cur_err=color3(1,:).*(1-colorscale_cur_err)+color3(2,:).*(colorscale_cur_err);
    else
        color_cur_err=[];
    end

    shpRegion=wingMask_meanH2_adj==1;
    bgRegion=wingMask_meanH2_adj==0;
    wingMask_meanH2_adj2=wingMask_meanH2_adj;
    wingMask_meanH2_adj2(shpRegion)=shpColor; %Change shape color to gray
    wingMask_meanH2_adj2( bgRegion)=bgColor; %Change background to gray
    
    %create scale bar in black
    scalelineH=zeros(50,size(wingMask_meanH2_adj2,2))+bgColor;
    scale_to_edge=100;
    if size(scalelineH,2)-scaleLen-scale_to_edge<0
    scale_to_edge=floor((size(scalelineH,2)-scaleLen)/2);
    end
    if bgColor<=0.5
        scaleColor=1;
    else
        scaleColor=0;
    end
    scalelineH(20:30,round(end-scale_to_edge-scaleLen):end-scale_to_edge,:)=scaleColor;
    %combine all images together
    wingMask_meanH2_adj3=vertcat(wingMask_meanH2_adj2, scalelineH);
    
    [B_wing0,~]=bwboundaries(wingMask_meanH2_adj);
    B_wing=B_wing0{1};

    imshow(wingMask_meanH2_adj3);hold on;
    if ~isempty(boundaryColor)
        plot(B_wing(:,2), B_wing(:,1), 'Color', boundaryColor, 'linewidth', boundaryWidth);
    end
    %Plot main tail
    for coID=1:size(firstColLastRow_endPts_single_line_adj,1)
        plotline=[firstColLastRow_startPts_single_line_adj(coID,:);firstColLastRow_endPts_single_line_adj(coID,:)];
        pp=plot(plotline(:,2),plotline(:,1),'Color',color_prob(coID,:),'LineWidth',5);
        pp.Color(4) = colorscale_opacity(coID);
    end
    %Plot error bar
    for coID=1:size(firstColLastRow_endPts_err_single_line_adj,1)
        plotline=[firstColLastRow_startPts_err_single_line_adj(coID,:);firstColLastRow_endPts_err_single_line_adj(coID,:)];
        pc=plot(plotline(:,2),plotline(:,1),'Color',color_prob(coID,:),'LineWidth',0.5);
        pc.Color(4) = colorscale_opacity(coID);
    end
    if ~isempty(color_cur) && ~isempty(cur_loc)
        scatter(cur_loc(:,2),cur_loc(:,1), cur_plot_size, color_cur,'filled');
    end
    if ~isempty(color_cur_err) && ~isempty(cur_err_loc)
        scatter(cur_err_loc(:,2),cur_err_loc(:,1), cur_err_plot_size, color_cur_err,'filled');
    end
end