function [GridCoords,LensletGridModel]= ValidateLensLetGridModel(GridCoords,LensletGridModel,ImgSizeX,ImgSizeY)
    GridCoordsX  = GridCoords(:,:,1);
    GridCoordsY  = GridCoords(:,:,2);    
    Radius       = LensletGridModel.HSpacing/2;
    
    % check the edge of the MLA.
    if sum( GridCoordsX(:,end)>(ImgSizeX-Radius) ) > 1
        GridCoords(:,end,:)=[];
    end
    if sum( GridCoordsY(end,:)>(ImgSizeY-Radius) ) > 1
        GridCoords(end,:,:)=[];
    end
    if sum( GridCoordsX(:,1)<(Radius) ) > 1
        GridCoords(:,1,:)=[];
    end
    if sum( GridCoordsY(1,:)<(Radius) ) > 1
        GridCoords(1,:,:)=[];
    end   
    % update the LensletGridModel
    LensletGridModel.UMax = size(GridCoords,2);
    LensletGridModel.VMax = size(GridCoords,1);
end