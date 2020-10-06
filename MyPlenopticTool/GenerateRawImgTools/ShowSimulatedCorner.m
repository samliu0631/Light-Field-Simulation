function ShowSimulatedCorner(corn_est,GridCoords)
    GridCoordsX = GridCoords(:,:,1);
    GridCoordsY = GridCoords(:,:,2);
    ImageValueNum             = length(corn_est);
    for iFile = 1 :ImageValueNum
        CurrentGroundTruthtem = corn_est{iFile};
        CornerNumPerFrame     = size(CurrentGroundTruthtem,1);
        figure;
        plot(GridCoordsX(:) , GridCoordsY(:),'b*');
        for k = 1:CornerNumPerFrame
            CornerInfoGT     = CurrentGroundTruthtem{k};
            hold on ;
            if ~isempty(CornerInfoGT)
                plot(CornerInfoGT(:,1),CornerInfoGT(:,2),'r*');
                %plot(GridCoordsX(CornerInfoGT(:,3)) , GridCoordsY(CornerInfoGT(:,3)),'b*');
            end
            hold off;
        end

    end

end