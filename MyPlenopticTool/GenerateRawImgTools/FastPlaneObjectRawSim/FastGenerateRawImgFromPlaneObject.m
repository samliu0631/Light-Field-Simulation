function RawImg = FastGenerateRawImgFromPlaneObject(InfoBag)
    % Data preprocess.
    % Get the data with regard to the object image.
    Obj_CameraCoords = InfoBag.Obj_CameraCoords; % coordinate of the object image. 
    Obj              = im2double(InfoBag.Obj);              % Object image.
    [ObjY,ObjX]      = size(Obj);                % Object size.
    cm               = (ObjX+1)/2;               % Object image center.
    cn               = (ObjY+1)/2;               % Object image center.
    PixelSize        = InfoBag.PixelSize;        % Physical size of the 
    PlaneDistance    = Obj_CameraCoords(1,3);    % the distance between plane and camera center.
    
    % Get the date with regard to the MLA.
    GridCoordsX      = InfoBag.GridCoords(:,:,1);
    GridCoordsY      = InfoBag.GridCoords(:,:,2);    
    CellRGBLensID    = ExtractRGBLensID( InfoBag.GridCoords,   InfoBag.LensletGridModel);
    
    % Add blur to different micro-images.
    
    % Get the date with regard to the plenoptic camera.
    cu               = (InfoBag.pixelX+1)/2;            % principal point location.
    cv               = (InfoBag.pixelY+1)/2;            % principal point location.
    K1               = InfoBag.K1;
    K2               = InfoBag.K2;
    fx               = InfoBag.fx;  
    Dmi              = InfoBag.Dmi;                     % the diameter of micro-image .
    ImgSize          = [InfoBag.pixelX,InfoBag.pixelY]; % the size of the raw image.
    RawImgHeight     = ImgSize(2);
    RawImgWidth      = ImgSize(1);
    MicImgNum        = size( GridCoordsX(:),1 );        % the number of micro-image.    
    
    % Calculate the Circle relative coordinate in the object plane.
    ScaleFactor      = fx*PixelSize / ( K2 + PlaneDistance * K1 );    
    ValidPDFRadius   = Dmi/2;    
    MicImgRadius     = round(Dmi/2)+3;    
    % the interger radius. Increase the radius in order to avoid the edge
    % effect of the subsequent mean filter.
    Xrange           = -MicImgRadius : 1 : MicImgRadius;
    Yrange           = -MicImgRadius : 1 : MicImgRadius;
    [XX,YY]          = meshgrid(Xrange, Yrange);
    XY               = [XX(:),YY(:)];
    CircleIndex      = find( sqrt( sum(XY.^2,2) )< ValidPDFRadius );
    CircleXY         = XY(CircleIndex,:);   
    
    % iterate each micro-image 
    RawImg  = zeros( RawImgHeight,RawImgWidth );
    for i = 1: MicImgNum
        % find the corresponding location in the raw image.
        CurMicImgCenter  = [GridCoordsX(i),GridCoordsY(i)];        
        
        % Calculate the location in Obj image.
        ObjCircelCenter   = PlaneDistance/( fx * PixelSize ).*( CurMicImgCenter - [cu,cv] )+[cm,cn];
        PatchXX           = ObjCircelCenter(1) + XX.*(1/ScaleFactor);
        PatchYY           = ObjCircelCenter(2) + YY.*(1/ScaleFactor);
        ObjImgRadius      = floor( MicImgRadius*(1/ScaleFactor) )+2;
        ObjCenterXOrigin  = round(ObjCircelCenter(1));
        ObjCenterYOrigin  = round(ObjCircelCenter(2));
        PatchUPX          = ObjCenterXOrigin - ObjImgRadius;
        PatchUPY          = ObjCenterYOrigin - ObjImgRadius;
        PatchDownX        = ObjCenterXOrigin + ObjImgRadius;
        PatchDownY        = ObjCenterYOrigin + ObjImgRadius;        
        
        if ( PatchUPX>0) && (PatchUPY>0)  && (PatchDownX< ObjX) && (PatchDownY< ObjY)          
            % Extract the image patch from Object image.
            PatchImgOrigin      = Obj( PatchUPY : PatchDownY , PatchUPX : PatchDownX );            
            OriginX             = PatchUPX : PatchDownX;
            OriginY             = PatchUPY : PatchDownY;
            [OriginXX,OriginYY] = meshgrid(OriginX,OriginY);            
            PatchImg            = interp2(OriginXX,OriginYY,PatchImgOrigin,PatchXX,PatchYY,'linear'); %  'nearest' 'cubic'
            
            % Add blurness according to the different micro-images
            % classification.
            PatchImg = AddDefocusEffect(i,CellRGBLensID,PatchImg);
            
            % Extract the circle part.         
            PatchImgCircle  = PatchImg(CircleIndex);
            
            % Calculate the location in micro-image.
            RawImgCoord      = CurMicImgCenter + CircleXY;  % Relative location in raw image.
            PixLocPx         = round( RawImgCoord(:,1) );
            PixLocPy         = round( RawImgCoord(:,2) );
            LinearInd        = int32( PixLocPx.*RawImgHeight+PixLocPy );
            
            % Boundary check.
            ValidID_X        = ( PixLocPx < RawImgWidth ) & ( PixLocPx > 0 );
            ValidID_Y        = ( PixLocPy < RawImgHeight ) & ( PixLocPy > 0 );
            ValidID          =  find( ( ValidID_X & ValidID_Y ) ==1 );
                        
            % Store the pixel value.
            RawImg(LinearInd(ValidID)) = PatchImgCircle(ValidID);
        end
    end
end



