function [SensorWhite,SensorWhiteFilted] = SimulateWhiteImg(InfoBag)
    GridCoordsX                         = InfoBag.GridCoords(:,:,1);
    GridCoordsY                         = InfoBag.GridCoords(:,:,2);
    cx_center                           = (InfoBag.pixelX+1)/2;  % +1 is necessary. Because the center of MLA is assumed at the precisely center.
    cy_center                           = (InfoBag.pixelY+1)/2;  % +1 is necessary. 
    LensGridCoordsX                     = cx_center+ InfoBag.bL0/( InfoBag.bL0+InfoBag.B )*( GridCoordsX-cx_center );
    LensGridCoordsY                     = cy_center+ InfoBag.bL0/( InfoBag.bL0+InfoBag.B )*( GridCoordsY-cy_center );
    CellRGBLensID                       = ExtractRGBLensID( InfoBag.GridCoords,   InfoBag.LensletGridModel);
    CameraParamter.F                    = InfoBag.F;
    CameraParamter.bL0                  = InfoBag.bL0;
    CameraParamter.fm1                  = InfoBag.fm1;
    CameraParamter.fm2                  = InfoBag.fm2;
    CameraParamter.fm3                  = InfoBag.fm3;
    CameraParamter.B                    = InfoBag.B;
    CameraParamter.DL                   = InfoBag.DL;
    CameraParamter.ImgSize              = [InfoBag.pixelX,InfoBag.pixelY];
    CameraParamter.Dml                  = InfoBag.Dml;
    CameraParamter.sxy                  = InfoBag.sxy;
    CameraParamter.cx                   = InfoBag.cx;
    CameraParamter.cy                   = InfoBag.cy;
    CameraParamter.k1                   = InfoBag.k1;
    CameraParamter.k2                   = InfoBag.k2;    
    if isfield(InfoBag,'ParallelFlag')
        CameraParamter.ParallelFlag         = InfoBag.ParallelFlag;
    else
        CameraParamter.ParallelFlag         = false;
    end    

    WhiteDist                       = 1000;
    WhiteSize                       = max( InfoBag.pixelX , InfoBag.pixelY )*3 ;
    WhitePixel                      = [ WhiteSize , WhiteSize ];
    %WhiteWidth                      = 1.6*max(InfoBag.pixelX,InfoBag.pixelX) * InfoBag.sxy*WhiteDist/(InfoBag.bL0+InfoBag.B);  % calculate the physical size of the white plane.
    WhiteWidth                      = sqrt(2)*max(InfoBag.pixelX,InfoBag.pixelX) * InfoBag.sxy*WhiteDist/(InfoBag.F);
    Obj_sxy                         = WhiteWidth./WhitePixel;  % 得到目标每个像素的实际尺寸。mm
    X                               = [1:WhitePixel(1)]-(WhitePixel(1)+1)/2;  % horizontal
    Y                               = [1:WhitePixel(2)]-(WhitePixel(2)+1)/2;  % vertical
    [XX,YY]                         = meshgrid(X,Y);
    XY                              = [XX(:),YY(:)];
    ObjCoords                       = XY.*Obj_sxy;
    ObjCoords                       = [ObjCoords, zeros( WhitePixel(1)*WhitePixel(2) , 1) ];    
    ObjWhite                        = ones(WhitePixel(2),WhitePixel(1));%%%%%%%
    WhiteObjCoordsRotated           = ObjCoords';
    WhiteObjCoordsRotated(3,:)      = WhiteObjCoordsRotated(3,:)+WhiteDist;
    tic;
    SensorWhite                     = SimulateRawImg(CameraParamter,InfoBag.NumMainRay,WhitePixel,ObjWhite,WhiteObjCoordsRotated',CellRGBLensID,LensGridCoordsX,LensGridCoordsY);
    G                               = fspecial('gaussian',3,3);
    SensorWhiteFilted               = imfilter(SensorWhite, G, 'conv');
    toc;
    imwrite(SensorWhite,[InfoBag.DataPath,'/WhiteOrigin.png']);
    imwrite(SensorWhiteFilted,[InfoBag.DataPath,'/White.png']);
end