function GenerateSimulatedImg(InfoBag)
    FrameNum                = size(InfoBag.ThetaZArray,2);
    BoardDistance           = (InfoBag.cornersNum+[1,1]).* InfoBag.GapDistance;
    BoardPixel              = (InfoBag.cornersNum+[1,1]).* InfoBag.GapPixel; % the total pixels for the checkerboard.

    % Set the resolution of Checkerboard.
    Obj                     = zeros(BoardPixel(2),BoardPixel(1));
    for  i=1:2:InfoBag.cornersNum(1)+1
        for j=1:2:InfoBag.cornersNum(2)+1
            CornerLeft = [(i-1)*InfoBag.GapPixel+1,(j-1)*InfoBag.GapPixel+1];
            CornerRightDown = [i*InfoBag.GapPixel,j*InfoBag.GapPixel];
            Obj(CornerLeft(2):CornerRightDown(2),CornerLeft(1):CornerRightDown(1))=1;
        end    
    end
    for  i=2:2:InfoBag.cornersNum(1)+1
        for j=2:2:InfoBag.cornersNum(2)+1
            CornerLeft = [(i-1)*InfoBag.GapPixel+1,(j-1)*InfoBag.GapPixel+1];
            CornerRightDown = [i*InfoBag.GapPixel,j*InfoBag.GapPixel];
            Obj(CornerLeft(2):CornerRightDown(2),CornerLeft(1):CornerRightDown(1))=1;
        end    
    end
    %figure;imshow(Obj);

    % Set the pixel coordinates of checkerboard.
    ObjCoordsRotatedCell                = cell(FrameNum,1);
    Obj_sxy                             = BoardDistance./BoardPixel;  % 得到目标每个像素的实际尺寸。mm
    X                                   = [1:BoardPixel(1)]-(BoardPixel(1)+1)/2;  % horizontal
    Y                                   = [1:BoardPixel(2)]-(BoardPixel(2)+1)/2;  % vertical
    [XX,YY]                             = meshgrid(X,Y);
    XY                                  = [XX(:),YY(:)];
    ObjCoords                           = XY.*Obj_sxy;
    ObjCoords                           = [ObjCoords, zeros( BoardPixel(1)*BoardPixel(2) , 1) ];
    %figure;plot(ObjCoords(:,1),ObjCoords(:,2),'*');
    for i = 1:FrameNum  
        theta_x                         = InfoBag.ThetaXArray(i);
        theta_y                         = InfoBag.ThetaYArray(i);
        theta_z                         = InfoBag.ThetaZArray(i);
        t_array                         = [ InfoBag.Xc(i),  InfoBag.Yc(i), InfoBag.Zc(i) ]; % 计算平移向量   距离在1m处。
        R_x                             = [1 0 0; 0 cos(theta_x) -sin(theta_x) ; 0 sin(theta_x) cos(theta_x)];
        R_y                             = [cos(theta_y)   0   sin(theta_y);     0   1    0;    -sin(theta_y)    0    cos(theta_y)  ];
        R_z                             = [cos(theta_z) -sin(theta_z) 0; sin(theta_z)  cos(theta_z) 0; 0 0 1];
        R                               = R_z*R_y*R_x;  % 按照xyz轴的顺序进行坐标旋转变换。
        ObjCoordsRotated                = R*ObjCoords'+ t_array';    
        % add lens distortion
        CameraXIdeal            = ObjCoordsRotated(1,:);
        CameraYIdeal            = ObjCoordsRotated(2,:);
        CameraZIdeal            = ObjCoordsRotated(3,:);
        r2                      = (CameraXIdeal./CameraZIdeal).^2 + (CameraYIdeal./CameraZIdeal).^2;
        CameraXReal             = (1 + InfoBag.k1*r2 + InfoBag.k2*(r2).^2).* CameraXIdeal;
        CameraYReal             = (1 + InfoBag.k1*r2 + InfoBag.k2*(r2).^2).* CameraYIdeal;
        ObjCoordsRotated(1:2,:) = [CameraXReal;CameraYReal];
        
        ObjCoordsRotatedCell{i} = ObjCoordsRotated;
    end
    %figure; plot(CornerWorldCoords(:,1),CornerWorldCoords(:,2),'*');

    % prepared for the image simulation
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
    SensorImgOrigin                     = zeros( FrameNum , CameraParamter.ImgSize(2)*CameraParamter.ImgSize(1) ); 
    SensorImgFilted                     = zeros( FrameNum , CameraParamter.ImgSize(2)*CameraParamter.ImgSize(1) );
    G                                   = fspecial('gaussian',3,3);
     
    for j= 1:FrameNum
        ObjCoordsRotated                = ObjCoordsRotatedCell{j};
        tic;
        SensorCollector                 = SimulateRawImg(CameraParamter,InfoBag.NumMainRay, BoardPixel,Obj,ObjCoordsRotated',CellRGBLensID,LensGridCoordsX,LensGridCoordsY);
        toc;
        SensorCollectorFilted           = imfilter(SensorCollector, G, 'conv');
        SensorImgOrigin(j,:)            = SensorCollector(:)';
        SensorImgFilted(j,:)            = SensorCollectorFilted(:)';
        ImgOrigin                       = SensorImgOrigin(j,:)';
        ImgOrigin                       = reshape(ImgOrigin,  InfoBag.pixelY,   InfoBag.pixelX);
        Img                             = SensorImgFilted(j,:)';
        Img                             = reshape(Img,  InfoBag.pixelY,   InfoBag.pixelX);
        imwrite(ImgOrigin,[InfoBag.DataPath,'/Origin', num2str(100+j), '.png']);
        imwrite(Img,[InfoBag.DataPath,'/', num2str(100+j), '.png']);
    end
    
end


