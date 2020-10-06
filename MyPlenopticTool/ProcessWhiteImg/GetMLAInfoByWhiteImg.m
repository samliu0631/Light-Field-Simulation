function [LensletGridModel,GridCoords,ImgSize]= GetMLAInfoByWhiteImg(WhitePath, FileSpecWhite,RoughRadius)
    GridModelOptions.ApproxLensletSpacing = RoughRadius;
    [FileList_raw, BasePath_raw]    = ReadRawImgInfo(WhitePath, FileSpecWhite); 
    WhiteImage                      = ReadRawImg(BasePath_raw,FileList_raw, 1);
    [LensletGridModel,GridCoords]   = LFProcessWhiteImage( WhiteImage,GridModelOptions);

    Radius       = LensletGridModel.HSpacing/2;
    ImgSize      = size(WhiteImage);
    GridCoordsX  = GridCoords(:,:,1);
    GridCoordsY  = GridCoords(:,:,2);
    
    % check the edge of the MLA.
    if sum( GridCoordsX(:,end)>(ImgSize(2)-Radius) ) > 1
        GridCoords(:,end,:)=[];
    end
    if sum( GridCoordsY(end,:)>(ImgSize(1)-Radius) ) > 1
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