function [LensletGridModel ,GridCoords]= GetLensGridFormXML(filename,imgsize)
    CalibStruct     = Read_Calibration(filename);
    LensGridCoords  = hex_lens_grid(imgsize , CalibStruct);
    
    X_min           = min(LensGridCoords(:,3));% 先横后纵
    XminID          = find(LensGridCoords(:,3)==X_min);
    XminID2          = find(LensGridCoords(:,3)==(X_min+2) );
    if length(XminID)>=length(XminID2)-1
        XminIndex =X_min;
    else
        XminIndex =X_min+1;
    end
    
    
    X_max           = max(LensGridCoords(:,3));
    XmaxID          = find(LensGridCoords(:,3)==X_max);
    XmaxID2          = find(LensGridCoords(:,3)==(X_max-2) );
    if length(XmaxID)>=length(XmaxID2)-1
        XmaxIndex =X_max;
    else
        XmaxIndex =X_max-1;
    end
    
    Y_min           = min(LensGridCoords(:,4));
    YminID          = find(LensGridCoords(:,4)==Y_min);
    YminID2          = find(LensGridCoords(:,4)==(Y_min+2) );
    if length(YminID)>=length(YminID2)-1
        YminIndex =Y_min;
    else
        YminIndex =Y_min+1;
    end
    
    Y_max           = max(LensGridCoords(:,4));
    YmaxID          = find(LensGridCoords(:,4)==Y_max);
    YmaxID2         = find(LensGridCoords(:,4)==(Y_max-2) );
    if length(YmaxID)>=length(YmaxID2)-1
        YmaxIndex =Y_max;
    else
        YmaxIndex =Y_max-1;
    end
    
    ValidXID    = find(   (LensGridCoords(:,3)>= XminIndex ) & (LensGridCoords(:,3) <= XmaxIndex) );
    ValidYID    = find(   (LensGridCoords(:,4)>= YminIndex ) & (LensGridCoords(:,4) <= YmaxIndex) );
    ValidID     = intersect(ValidXID, ValidYID);
    LensGridCoords=LensGridCoords(ValidID,:);
    
    XRange = XminIndex:1:XmaxIndex;
    YRange = YminIndex:1:YmaxIndex;
    
    GridCoords =zeros( length(YRange),length(XRange),2);
    for i=1: length(ValidID)
        Xcoord = LensGridCoords(i,3)-XminIndex+1;
        Ycoord = LensGridCoords(i,4)-YminIndex+1;
        GridCoords(Ycoord,Xcoord,1)= LensGridCoords(i,1);
        GridCoords(Ycoord,Xcoord,2)= LensGridCoords(i,2);
    end
    
    LensletGridModel.HSpacing =CalibStruct.Diameter;
    LensletGridModel.UMax = length(XRange);
    LensletGridModel.VMax = length(YRange);
    LensletGridModel.VSpacing =sqrt(3)*CalibStruct.Diameter/2; % 表示纵向的微透镜的平均个数。
    LensletGridModel.Rot  =CalibStruct.rotation;
end


function CalibStruct =Read_Calibration(filename)  % 函数功能，读取Raytrix的XML。
    RaytrixXML                      = xml2struct(filename);
    CalibStruct.Diameter            = str2double(RaytrixXML.Children(4).Children.Data);
    CalibStruct.offset              = [str2double(RaytrixXML.Children(2).Children(2).Children.Data), str2double(RaytrixXML.Children(2).Children(4).Children.Data)  ];
    CalibStruct.rotation            = str2double(RaytrixXML.Children(6).Children.Data);
    CalibStruct.lens_base_x         = [str2double(RaytrixXML.Children(12).Children(2).Children.Data), str2double(RaytrixXML.Children(12).Children(4).Children.Data) ];
    CalibStruct.lens_base_y         = [str2double(RaytrixXML.Children(14).Children(2).Children.Data), str2double(RaytrixXML.Children(14).Children(4).Children.Data) ];
    CalibStruct.sub_grid_base       = [str2double(RaytrixXML.Children(16).Children(2).Children.Data), str2double(RaytrixXML.Children(16).Children(4).Children.Data) ];
    CalibStruct.lens_border         = str2double(RaytrixXML.Children(8).Children.Data); 
    lens_type                       = cell(3,1);
    for i=1:3
        offsetx                 = str2double(RaytrixXML.Children(20+(i-1)*2).Children(2).Children(2).Children.Data);
        offsety                 = str2double(RaytrixXML.Children(20+(i-1)*2).Children(2).Children(4).Children.Data);
        depthmin                = str2double(RaytrixXML.Children(20+(i-1)*2).Children(4).Children(2).Children.Data);
        depthmax                = str2double(RaytrixXML.Children(20+(i-1)*2).Children(4).Children(4).Children.Data);
        lens_struct.offset      = [offsetx ,offsety];
        lens_struct.depth       = [depthmin,depthmax];
        lens_type{i}            = lens_struct;
    end
     CalibStruct.lens_type   =lens_type;
end

function LensGridCoords = hex_lens_grid(imgsize , CalibStruct)
    imgcenter       = (imgsize+1)/2;  % 先纵后横
       
    CentralLensCoord =[imgcenter(1)-CalibStruct.offset(2),imgcenter(2)+CalibStruct.offset(1)]; % 先纵后横  
    
    LensNumWidth    = ceil(imgsize(2)/CalibStruct.Diameter);  % 横向宽度
    LensNumHeight   = ceil(imgsize(1)/( CalibStruct.Diameter/2*sqrt(3) ) );
    HalfWidthNum    = ceil( (LensNumWidth+1)/2 )+1;  % 防止漏检
    HalfHeightNum   = ceil( (LensNumHeight+1)/2 )+1; % 防止漏检
    WidthIDRange    = -HalfWidthNum:HalfWidthNum;
    HeightIDRange   = -HalfHeightNum:HalfHeightNum;
    [XX,YY]         = meshgrid(WidthIDRange,HeightIDRange); % 先横后纵
    XY              = [XX(:),YY(:)];
    CoordMatrix     = [CalibStruct.Diameter,0;0 sqrt(3)*CalibStruct.Diameter/2];
    GridCoords      =  (CoordMatrix*XY')';
    yodd= find(mod(XY(:,2),2)==1);
    GridCoords(yodd,1) = GridCoords(yodd,1)+CalibStruct.Diameter/2;
    angle =-CalibStruct.rotation;
    R=[cos(angle),-sin(angle);sin(angle),cos(angle)];
    RotateGrid  =(R*GridCoords')';
    GridCoordsFinal =RotateGrid+ [CentralLensCoord(2),CentralLensCoord(1)];  % 先横后纵
    Radius = CalibStruct.Diameter/2;
       
    %****剔除中心位于图像之外的微透镜中心********
%     validIDw            = find(  ( (GridCoordsFinal(:,1))-Radius >=0) & ( (GridCoordsFinal(:,1)+Radius ) <imgsize(2) ) ) ;
%     validIDh            = find(  ( (GridCoordsFinal(:,2))-Radius >=0) & ( (GridCoordsFinal(:,2)+Radius ) <imgsize(1) ) ) ;
    validIDw            = find(  ( (GridCoordsFinal(:,1)) >=0) & ( (GridCoordsFinal(:,1) ) <imgsize(2) ) ) ;
    validIDh            = find(  ( (GridCoordsFinal(:,2)) >=0) & ( (GridCoordsFinal(:,2) ) <imgsize(1) ) ) ;
    validID             = intersect(validIDh,validIDw);
    GridCoordsFinal     = GridCoordsFinal(validID,:);
    XY                  = XY(validID,:);
    LensGridCoords = [GridCoordsFinal ,XY];
end



















% CalibInfo   = MLACalibration(CalibStruct);
% tlenses     = hex_lens_grid(imgsize,CalibInfo.lens_diameter, CalibInfo.rot_angle ,CalibInfo.offset ,CalibInfo.lbasis );
% figure;imshow(img);
% hold on;
% plot(tlenses(:,4),tlenses(:,3),'r*');
% hold off;

% function CalibInfo=MLACalibration(CalibStruct)  % 根据XML的数据生成关于微透镜阵列的数据。
% CalibInfo.lens_diameter     = CalibStruct.Diameter;
% CalibInfo.lens_radius       = CalibInfo.lens_diameter /2;
% CalibInfo.offset            = [-CalibStruct.offset(2), CalibStruct.offset(1)];
% CalibInfo.rot_angle         = CalibStruct.rotation;
% CalibInfo.lens_border       = CalibStruct.lens_border;
% lens_base_x                 = [ -CalibStruct.lens_base_x(2) , CalibStruct.lens_base_x(1)];
% lens_base_y                 = [ -CalibStruct.lens_base_y(2) , CalibStruct.lens_base_y(1)];
% lbx                         = lens_base_x;
% lby                         = -lens_base_y+lens_base_x;
% CalibInfo.lbasis            = [lby',lbx'];
% CalibInfo.pbasis            = CalibInfo.lbasis .*CalibInfo.lens_diameter;
% CalibInfo.inner_lens_radius = CalibInfo.lens_radius-CalibInfo.lens_border;
% CalibInfo.lens_types        = CalibStruct.lens_type;
% end
% 
% function tlenses = hex_lens_grid(img_shape,diam,angle,offset,B,filter_method )
% 
% if norm( B(1,:) )>1
%     switch_xy =true;
% else
%     switch_xy =false;
% end
% fprintf('The B is %8.5f,%8.5f; %8.5f,%8.5f\n',B(1),B(3),B(2),B(4)) ;
% lens_centers        = [];
% h                   = img_shape(1);
% w                   = img_shape(2);
% img_center          = [(h+1)/2,(w+1)/2];
% ny                  = ceil(h*sqrt(2)/diam)+2;
% nx                  = ceil(w*sqrt(2)/diam)+4;
% r                   = diam/2;
% sx                  = -(nx*diam -w)/2;
% sy                  = -(ny*r*sqrt(3)-h)/2;
% for i=1:ny+1
%     py= (i-1)*sqrt(3)*r+sy;
%     for j=1:nx+1
%        px =(sx+(j-1)*diam)+mod(i-1,2)*r; 
%         if switch_xy ==true
%            lens_centers=[lens_centers;[px,py]] ;
%         else
%            lens_centers=[lens_centers;[py,px]] ;
%         end       
%     end
% end
% lorgin=lens_orgin(lens_centers,img_center); % 找到距离图像中心最近的透镜。
% lens_centers= lens_centers-lorgin;           % 调整微透镜中心坐标为 相对于中心的值。
% lenses = axial_coordinates(B*diam,lens_centers);
% tlenses = transform_grid(lenses, img_center,angle,offset);
% %****剔除中心位于图像之外的微透镜中心********
% validIDh = find(  ( (tlenses(:,3)-r)>=0) & ( (tlenses(:,3)+r) <h ) ) ;
% validIDw = find(  ( (tlenses(:,4)-r)>=0) & ( (tlenses(:,4)+r) <w ) ) ;
% validID = intersect(validIDh,validIDw);
% tlenses =tlenses (validID,:);
% end
% 
% 
% 
% function LensCoord =lens_orgin(lens_centers,img_center)
%     dist =sum( (lens_centers-img_center).^2,2 );
%     [~,I]=min(dist);
%     LensCoord =lens_centers(I,:);
% end
% 
% 
% function lenses = axial_coordinates(B,centers)
% lenses=[];
% tmp= B\centers';
% axial_coord =int32(round(tmp));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lenses =[double(axial_coord'),centers];
% end
% 
% 
% function acenters =transform_grid(lenses, img_center,angle,offset)
% 
% R=[cos(angle),-sin(angle);sin(angle),cos(angle)];
% acenters = (R*double(lenses(:,3:4)')+offset'+img_center')';
% acenters =[lenses(:,1:2),acenters];
% end







