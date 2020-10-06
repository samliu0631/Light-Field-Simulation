function corn_est = GenerateCornersGT(InfoBag)
    FrameNum                            = size(InfoBag.ThetaZArray,2);
    Extrinsics                          = zeros(1, 6*FrameNum);
    cornerNumx                          = InfoBag.cornersNum(1):-1:1;
    cornerNumy                          = InfoBag.cornersNum(2):-1:1;
    [cornerNumxx,cornerNumyy]           = meshgrid(cornerNumx,cornerNumy);
    cornerNumXY                         = [cornerNumxx(:),cornerNumyy(:)];
    CornerWorldCoords                   = cornerNumXY.*InfoBag.GapDistance;
    BoardDistance                       = (InfoBag.cornersNum+[1,1]).*InfoBag.GapDistance;
    CenterWorldCoords                   = BoardDistance./2;
    CornerWorldCoords                   = CornerWorldCoords-CenterWorldCoords;  
    PointsNum                           = size(CornerWorldCoords,1);
    CornerWorldCoords                   = [CornerWorldCoords,zeros(PointsNum,1)]; % world coordinates of checkerboard corners

    for i = 1:FrameNum  
        theta_x                     = InfoBag.ThetaXArray(i);
        theta_y                     = InfoBag.ThetaYArray(i);
        theta_z                     = InfoBag.ThetaZArray(i);
        t_array                     = [  InfoBag.Xc(i),  InfoBag.Yc(i), InfoBag.Zc(i) ]; % 计算平移向量   距离在1m处。    
        R_x                         = [1 0 0; 0 cos(theta_x) -sin(theta_x) ; 0 sin(theta_x) cos(theta_x)];
        R_y                         = [cos(theta_y)   0   sin(theta_y);     0   1    0;    -sin(theta_y)    0    cos(theta_y)  ];
        R_z                         = [cos(theta_z) -sin(theta_z) 0; sin(theta_z)  cos(theta_z) 0; 0 0 1];
        R                           = R_z*R_y*R_x;  % 按照xyz轴的顺序进行坐标旋转变换。
        Rt                          = zeros(4,4);
        Rt(1:3,1:3)                 = R;
        Rt(1:3,4)                   = t_array';
        Rt(4,4)                     = 1;
        RtParam                     = GetAxisSam(Rt);
        Extrinsics((i-1)*6+1 : 6*i) = RtParam;
    end
    params      = [InfoBag.K1,InfoBag.K2,InfoBag.fx,InfoBag.fy,InfoBag.cx,InfoBag.cy,InfoBag.k1,InfoBag.k2, Extrinsics];
    
    
    %corn_est    = CalculateCornerGroundTruth(InfoBag);
    corn_est    = CalculateCornerGT( params , CornerWorldCoords, InfoBag.pixelX, InfoBag.pixelY  , InfoBag.GridCoords, InfoBag.Dmi );
end








function corn_est    = CalculateCornerGroundTruth(InfoBag)
    BoardCornerGap      = InfoBag.GapDistance;
    BoardCornerXYNum    = [InfoBag.cornersNum(2),InfoBag.cornersNum(1)];
    fL                  = InfoBag.F;
    bL0                 = InfoBag.bL0;
    B                   = InfoBag.B;
    pixelX              = InfoBag.pixelX;
    pixelY              = InfoBag.pixelY;
    cx                  = InfoBag.cx;
    cy                  = InfoBag.cy;
    sx                  = InfoBag.sxy;
    sy                  = InfoBag.sxy ;
    LensletGridModel    = InfoBag.LensletGridModel;
    GridCoords          = InfoBag.GridCoords;
    
    % 对微透镜以及微透镜图像的半径进行缩放调整，因为存在投影效应。
    Ratio               = bL0/(bL0+B);
    GridCoordsX         = GridCoords(:,:,1);
    GridCoordsY         = GridCoords(:,:,2);
    LensCoordsX         = (GridCoordsX-cx).*Ratio+cx;
    LensCoordsY         = (GridCoordsY-cy).*Ratio+cy;
    LensCoords          = cat(3,LensCoordsX,LensCoordsY);
    BoardCornerNum      = BoardCornerXYNum(1)*BoardCornerXYNum(2);  % 特征点的总个数。
    TotalImage_H        = pixelX/2;  % 全聚焦图的像素数。
    TotalImage_V        = pixelY/2;  % 全聚焦图的像素数。
    lens_type           = 4;
    
   
    % Generate the world coordinates of 3D points.
    cornerNumx                          = InfoBag.cornersNum(1):-1:1;
    cornerNumy                          = InfoBag.cornersNum(2):-1:1;
    [cornerNumxx,cornerNumyy]           = meshgrid(cornerNumx,cornerNumy);
    cornerNumXY                         = [cornerNumxx(:),cornerNumyy(:)];
    CornerWorldCoords                   = cornerNumXY.*InfoBag.GapDistance;
    BoardDistance                       = (InfoBag.cornersNum+[1,1]).*InfoBag.GapDistance;
    CenterWorldCoords                   = BoardDistance./2;
    CornerWorldCoords                   = CornerWorldCoords-CenterWorldCoords;  
    PointsNum                           = size(CornerWorldCoords,1);
    CornerWorldCoords                   = [CornerWorldCoords,zeros(PointsNum,1),ones(PointsNum,1)]; % world coordinates of checkerboard corners
    
    
    FrameNum                = size(InfoBag.ThetaXArray,2); 
    allPts                          = cell(FrameNum,1);
    for i = 1:FrameNum
        theta_x                     = InfoBag.ThetaXArray(i);
        theta_y                     = InfoBag.ThetaYArray(i);
        theta_z                     = InfoBag.ThetaZArray(i);
        t_array                     = [  InfoBag.Xc(i),  InfoBag.Yc(i), InfoBag.Zc(i) ]; % 计算平移向量   距离在1m处。
        R_x                         = [1 0 0; 0 cos(theta_x) -sin(theta_x) ; 0 sin(theta_x) cos(theta_x)];
        R_y                         = [cos(theta_y)   0   sin(theta_y);     0   1    0;    -sin(theta_y)    0    cos(theta_y)  ];
        R_z                         = [cos(theta_z) -sin(theta_z) 0; sin(theta_z)  cos(theta_z) 0; 0 0 1];
        R                           = R_z*R_y*R_x;  % 按照xyz轴的顺序进行坐标旋转变换。
        Rt                          = zeros(4,4);
        Rt(1:3,1:3)                 = R;
        Rt(1:3,4)                   = t_array';
        Rt(4,4)                     = 1;
        CornerXYZ_Camera            = Rt*CornerWorldCoords';
        CornerXYZ_Camera            = CornerXYZ_Camera./CornerXYZ_Camera(4,:);
        CornerZ_Camera              = CornerXYZ_Camera(3,:);                        % Zc
        % add lens distortion.
        
        
        
        % ************
        bL                          = (fL.*CornerZ_Camera)./(CornerZ_Camera-fL);    % 像点距离微透镜中心的位置。
        b                           = bL-bL0;                                       % 像点距离微透镜平面的距离。
        CornerXYZ_XI                = ones(4,BoardCornerNum);
        CornerXYZ_XI(1,:)           = -bL0.*CornerXYZ_Camera(1,:)./CornerZ_Camera;% 这里之所以有负号是因为成的倒像。
        CornerXYZ_XI(2,:)           = -bL0.*CornerXYZ_Camera(2,:)./CornerZ_Camera;
        CornerXYZ_XI(3,:)           = b;
        %*******************************************************************************************
        CornerXYZ_Virtual           = ones(4,BoardCornerNum);
        CornerXYZ_Virtual(1,:)      = bL.*CornerXYZ_XI(1,:)./bL0    ;
        CornerXYZ_Virtual(2,:)      = bL.*CornerXYZ_XI(2,:)./bL0    ;
        CornerXYZ_Virtual(3,:)      = CornerXYZ_XI(3,:)            ;
        
        % 虚空间坐标转换为全聚焦图像素坐标*********************************************************
        Ks=[1/sx    0    0   cx;
            0     1/sy   0   cy;
            0       0   1/B   0;
            0       0    0    1];        
        CornerXYZ_TotalImg = Ks*CornerXYZ_Virtual;  % 转换到原始图像素坐标系下。    
        CornerXYZ_TotalImg(1:2,:)       = CornerXYZ_TotalImg(1:2,:)/2;       
        Corner_VirtualImgCoordXYZ       = CornerXYZ_TotalImg(1:3,:);
        Cell_Corner_microImg_Coord      = ProjectCorner3Dto2D( lens_type, TotalImage_H, TotalImage_V , LensletGridModel, GridCoords,LensCoords, Corner_VirtualImgCoordXYZ' , true ); %LensCoords
        allPts{i}                       = Cell_Corner_microImg_Coord;
    end
       
    corn_est=allPts;
end



