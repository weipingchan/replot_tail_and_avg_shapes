function firstColLastRow_midPts_single_line=deriveTailPlotLoc(wingGridsH2, wingMask_meanH2)
    %Prepare coordination and reference points
    firstCol_coordination=reshape(wingGridsH2(:,1,:),[],2);
    lastRow_coordination=reshape(wingGridsH2(end, :, :),[],2);

    mean_HB0=bwboundaries(wingMask_meanH2);
    mean_HB=mean_HB0{1};

    firstCol_midPts=zeros(length(firstCol_coordination)-1,2);
    for corID=1:length(firstCol_coordination)-1
        midCorPt0=(firstCol_coordination(corID,:)+firstCol_coordination(corID+1,:))/2;
        midCorPt=findCloestPt(mean_HB,flip(midCorPt0));
        firstCol_midPts(corID,:)=midCorPt;
    end
    lastRow_midPts=zeros(length(lastRow_coordination)-1,2);
    for corID=1:length(lastRow_coordination)-1
        midCorPt0=(lastRow_coordination(corID,:)+lastRow_coordination(corID+1,:))/2;
        midCorPt=findCloestPt(mean_HB,flip(midCorPt0));
        lastRow_midPts(corID,:)=midCorPt;
    end
    firstColLastRow_midPts_single_line=[firstCol_midPts ; lastRow_midPts];
end