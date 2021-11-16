function plotForewing_mean_shp(wingMask_meanF2, shpColor, bgColor, boundaryColor, boundaryWidth, scaleLen)
    wingMask_meanF2_adj=wingMask_meanF2;

    shpRegion=wingMask_meanF2_adj==1;
    bgRegion=wingMask_meanF2_adj==0;
    wingMask_meanF2_adj2=wingMask_meanF2_adj;
    wingMask_meanF2_adj2(shpRegion)=shpColor; %Change shape colort to grey
    wingMask_meanF2_adj2( bgRegion)=bgColor; %Change background to grey
    
    %create scale bar in black
    scalelineF=zeros(50,size(wingMask_meanF2_adj2,2))+bgColor;
    scale_to_edge=100;
    if size(scalelineF,2)-scaleLen-scale_to_edge<0
        scale_to_edge=floor((size(scalelineF,2)-scaleLen)/2);
    end
    if bgColor<=0.5
        scaleColor=1;
    else
        scaleColor=0;
    end
    scalelineF(20:30,round(end-scale_to_edge-scaleLen):end-scale_to_edge,:)=scaleColor;
    %combine all image together
    wingMask_meanF2_adj3=vertcat(wingMask_meanF2_adj2, scalelineF);
    
    [B_wing0,~]=bwboundaries(wingMask_meanF2_adj);
    B_wing=B_wing0{1};
    
    imshow(wingMask_meanF2_adj3);hold on;
    if ~isempty(boundaryColor)
        plot(B_wing(:,2), B_wing(:,1), 'Color', boundaryColor, 'linewidth',boundaryWidth);
    end
end