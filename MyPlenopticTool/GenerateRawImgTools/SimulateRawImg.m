function SensorCollector= SimulateRawImg(CameraParamter,NumMainRay,BoardPixel,Obj,ObjCoords,CellRGBLensID,LensGridCoordsX,LensGridCoordsY)

if isfield(CameraParamter,'ParallelFlag')
    ParallelFlag         = CameraParamter.ParallelFlag;
else
    ParallelFlag         = false;
end

F           = CameraParamter.F;
bL0         = CameraParamter.bL0;
fm1         = CameraParamter.fm1;
fm2         = CameraParamter.fm2;
fm3         = CameraParamter.fm3;
B           = CameraParamter.B;
DL          = CameraParamter.DL;
ImgSize     = CameraParamter.ImgSize;
Dml         = CameraParamter.Dml;
sxy         = CameraParamter.sxy;
cx          = CameraParamter.cx;
cy          = CameraParamter.cy;
k1          = CameraParamter.k1;
k2          = CameraParamter.k2;
%****变换矩阵。*************************************************
M_L         = [1   0   0  0 ; -1/F  1  0  0; 0 0 1  0 ; 0  0 -1/F   1 ];      %主透镜折射矩阵。
T           = [1  bL0  0  0 ; 0     1  0  0; 0 0 1 bL0; 0  0  0     1 ];        %主透镜与微透镜之间传播
M_m1        = [1   0   0  0 ;-1/fm1 1  0  0; 0 0 1  0 ; 0  0 -1/fm1 1 ];    % 微透镜折射矩阵
M_m2        = [1   0   0  0 ;-1/fm2 1  0  0; 0 0 1  0 ; 0  0 -1/fm2 1 ]; 
M_m3        = [1   0   0  0 ;-1/fm3 1  0  0; 0 0 1  0 ; 0  0 -1/fm3 1 ]; 
T_m         = [1   B   0  0 ;   0   1  0  0; 0 0 1  B ; 0  0  0     1 ];          %微透镜到传感器的传播
%******主透镜采样*********************************************
MainLensX                           = linspace(-DL/2, DL/2 , NumMainRay);  % 对主透镜的成像进行采样。
MainLensY                           = linspace(-DL/2, DL/2 , NumMainRay);
[MainLensXX,MainLensYY]             = meshgrid(MainLensX,MainLensY);
MainLensXY                          = [MainLensXX(:),MainLensYY(:)];
ValidMainLensXY                     = MainLensXY( sqrt(sum(MainLensXY.^2,2))<DL/2 ,:);
MainLenRayNum                       = size(ValidMainLensXY,1); % 主透镜的光线采样数。
% 并行计算数据准备
ObjNew                              = Obj(:);
ObjCoordsX                          = ObjCoords(:,1);
ObjCoordsY                          = ObjCoords(:,2);
ObjCoordsZ                          = ObjCoords(:,3);
ValidMainLensX                      = ValidMainLensXY(:,1);
ValidMainLensY                      = ValidMainLensXY(:,2);
% 数据纪录
SensorCollectorR                    = zeros(ImgSize(2),ImgSize(1));
SensorCollectorG                    = zeros(ImgSize(2),ImgSize(1));
SensorCollectorB                    = zeros(ImgSize(2),ImgSize(1));
RLens_ID                            = CellRGBLensID{1};
GLens_ID                            = CellRGBLensID{2};
BLens_ID                            = CellRGBLensID{3};

%parfor ix                   = 1 : BoardPixel(1)*BoardPixel(2)
if ParallelFlag==true
    parfor ix                   = 1 : BoardPixel(1)*BoardPixel(2)
        if ObjNew(ix)           ~=0
            dx                  = ObjCoordsX(ix);
            dy                  = ObjCoordsY(ix);
            dz                  = ObjCoordsZ(ix);
            In                  = ObjNew(ix);
            theta               = atan( ( ValidMainLensX - dx )/dz );
            beta                = atan( ( ValidMainLensY - dy )/dz ) ;
            RayMLA              = T*M_L*[ValidMainLensX';theta';ValidMainLensY';beta'];    %透镜的转换及移动距离v
            %*****MLA照射到CCD*********
            x_mla               = RayMLA(1,:);           %得到在微透镜平面上的x坐标。
            y_mla               = RayMLA(3,:);
            ID                  = findLensID(x_mla, y_mla, LensGridCoordsX, LensGridCoordsY, Dml,sxy,[cx,cy],ImgSize);
            validID             = ID(ID~=0);
            if ~isempty(validID)
                x_mla_valid     = x_mla(ID'~=0); % 计算有效的光线x坐标
                y_mla_valid     = y_mla(ID'~=0); % 计算有效的光线y坐标
                pixelX          = (x_mla_valid/sxy + cx)';  %　光线在MLA对应的像素横坐标
                pixelY          = (y_mla_valid/sxy + cy)';  %　光线在MLA对应的像素纵坐标
                [LensNumy,LensNumx] = size(LensGridCoordsX);
                LensCoordsX     = LensGridCoordsX( validID );
                LensCoordsY     = LensGridCoordsY( validID );
                
                RayMLAvalid     = RayMLA(:,(ID'~=0)');   % 计算有效的光线数据
                NewX            = (pixelX-LensCoordsX)*sxy;
                NewY            = (pixelY-LensCoordsY)*sxy;
                RayMLAvalid(1,:)= NewX';              % 将光线xy坐标换为相对于微透镜中心的坐标。
                RayMLAvalid(3,:)= NewY';
                
                % 寻找微透镜类型。
                [RvalidID,Ria,~]  = intersect(validID',RLens_ID);
                [GvalidID,Gia,~]  = intersect(validID',GLens_ID);
                [BvalidID,Bia,~]  = intersect(validID',BLens_ID);
                
                if ~isempty(RvalidID)
                    IDlogical1  =logical(sum(validID== RvalidID , 2)');
                    NewRay1     = T_m* M_m1 * RayMLAvalid( :,IDlogical1  );
                    ID1         = find(IDlogical1==1 );
                    
                    LensCoordsXR  = LensCoordsX(IDlogical1);
                    LensCoordsYR  = LensCoordsY(IDlogical1);
                    x_pixel = (NewRay1(1,:)/sxy+LensCoordsXR')';
                    y_pixel = (NewRay1(3,:)/sxy+LensCoordsYR')';
                    theta1  =  NewRay1(2,:)';
                    theta2  =  NewRay1(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorR =SensorCollectorR +SensorTem;
                    end
                end
                
                if ~isempty(GvalidID)
                    IDlogical2  =logical(sum(validID== GvalidID,2)');
                    NewRay2 = T_m* M_m2 * RayMLAvalid( :,IDlogical2  );
                    ID2  = find(IDlogical2==1 );
                    
                    LensCoordsXG  = LensCoordsX(IDlogical2);
                    LensCoordsYG  = LensCoordsY(IDlogical2);
                    x_pixel = (NewRay2(1,:)/sxy+LensCoordsXG')';
                    y_pixel = (NewRay2(3,:)/sxy+LensCoordsYG')';
                    theta1  =  NewRay2(2,:)';
                    theta2  =  NewRay2(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorG =SensorCollectorG +SensorTem;
                    end
                end
                
                if ~isempty(BvalidID)
                    IDlogical3  =logical(sum(validID== BvalidID,2)');
                    NewRay3 = T_m* M_m3 * RayMLAvalid( :, IDlogical3 );
                    ID3  = find(IDlogical3==1);
                    
                    LensCoordsXB  = LensCoordsX(IDlogical3);
                    LensCoordsYB  = LensCoordsY(IDlogical3);
                    x_pixel = (NewRay3(1,:)/sxy+LensCoordsXB')';
                    y_pixel = (NewRay3(3,:)/sxy+LensCoordsYB')';
                    theta1  =  NewRay3(2,:)';
                    theta2  =  NewRay3(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorB =SensorCollectorB +SensorTem;
                    end
                end
            end
        end
    end
    
else
    for ix                   = 1 : BoardPixel(1)*BoardPixel(2)
        if ObjNew(ix)           ~=0
            dx                  = ObjCoordsX(ix);
            dy                  = ObjCoordsY(ix);
            dz                  = ObjCoordsZ(ix);
            In                  = ObjNew(ix);
            theta               = atan( ( ValidMainLensX - dx )/dz );
            beta                = atan( ( ValidMainLensY - dy )/dz ) ;
            RayMLA              = T*M_L*[ValidMainLensX';theta';ValidMainLensY';beta'];    %透镜的转换及移动距离v
            %*****MLA照射到CCD*********
            x_mla               = RayMLA(1,:);           %得到在微透镜平面上的x坐标。
            y_mla               = RayMLA(3,:);
            ID                  = findLensID(x_mla, y_mla, LensGridCoordsX, LensGridCoordsY, Dml,sxy,[cx,cy],ImgSize);
            validID             = ID(ID~=0);
            if ~isempty(validID)
                x_mla_valid     = x_mla(ID'~=0); % 计算有效的光线x坐标
                y_mla_valid     = y_mla(ID'~=0); % 计算有效的光线y坐标
                pixelX          = (x_mla_valid/sxy + cx)';  %　光线在MLA对应的像素横坐标
                pixelY          = (y_mla_valid/sxy + cy)';  %　光线在MLA对应的像素纵坐标
                [LensNumy,LensNumx] = size(LensGridCoordsX);
                LensCoordsX     = LensGridCoordsX( validID );
                LensCoordsY     = LensGridCoordsY( validID );
                
                RayMLAvalid     = RayMLA(:,(ID'~=0)');   % 计算有效的光线数据
                NewX            = (pixelX-LensCoordsX)*sxy;
                NewY            = (pixelY-LensCoordsY)*sxy;
                RayMLAvalid(1,:)= NewX';              % 将光线xy坐标换为相对于微透镜中心的坐标。
                RayMLAvalid(3,:)= NewY';
                
                % 寻找微透镜类型。
                [RvalidID,Ria,~]  = intersect(validID',RLens_ID);
                [GvalidID,Gia,~]  = intersect(validID',GLens_ID);
                [BvalidID,Bia,~]  = intersect(validID',BLens_ID);
                
                if ~isempty(RvalidID)
                    IDlogical1  =logical(sum(validID== RvalidID , 2)');
                    NewRay1     = T_m* M_m1 * RayMLAvalid( :,IDlogical1  );
                    ID1         = find(IDlogical1==1 );
                    
                    LensCoordsXR  = LensCoordsX(IDlogical1);
                    LensCoordsYR  = LensCoordsY(IDlogical1);
                    x_pixel = (NewRay1(1,:)/sxy+LensCoordsXR')';
                    y_pixel = (NewRay1(3,:)/sxy+LensCoordsYR')';
                    theta1  =  NewRay1(2,:)';
                    theta2  =  NewRay1(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorR =SensorCollectorR +SensorTem;
                    end
                end
                
                if ~isempty(GvalidID)
                    IDlogical2  =logical(sum(validID== GvalidID,2)');
                    NewRay2 = T_m* M_m2 * RayMLAvalid( :,IDlogical2  );
                    ID2  = find(IDlogical2==1 );
                    
                    LensCoordsXG  = LensCoordsX(IDlogical2);
                    LensCoordsYG  = LensCoordsY(IDlogical2);
                    x_pixel = (NewRay2(1,:)/sxy+LensCoordsXG')';
                    y_pixel = (NewRay2(3,:)/sxy+LensCoordsYG')';
                    theta1  =  NewRay2(2,:)';
                    theta2  =  NewRay2(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorG =SensorCollectorG +SensorTem;
                    end
                end
                
                if ~isempty(BvalidID)
                    IDlogical3  =logical(sum(validID== BvalidID,2)');
                    NewRay3 = T_m* M_m3 * RayMLAvalid( :, IDlogical3 );
                    ID3  = find(IDlogical3==1);
                    
                    LensCoordsXB  = LensCoordsX(IDlogical3);
                    LensCoordsYB  = LensCoordsY(IDlogical3);
                    x_pixel = (NewRay3(1,:)/sxy+LensCoordsXB')';
                    y_pixel = (NewRay3(3,:)/sxy+LensCoordsYB')';
                    theta1  =  NewRay3(2,:)';
                    theta2  =  NewRay3(4,:)';
                    Ratio   = sqrt(cos(theta1).^2 + cos(theta2).^2);
                    IDList  = (x_pixel>0.5)&(x_pixel<ImgSize(1))& (y_pixel>0.5)&(y_pixel<ImgSize(2));
                    x_pixelnew = x_pixel( IDList  );
                    y_pixelnew = y_pixel( IDList );
                    if  ~isempty(x_pixelnew) &&~isempty(y_pixelnew)
                        id          = round(y_pixelnew)+(round(x_pixelnew)-1)*ImgSize(2);
                        SensorTem   = zeros(ImgSize(2),ImgSize(1));
                        SensorTem(id) = SensorTem(id )+ In.*Ratio(IDList);
                        SensorCollectorB =SensorCollectorB +SensorTem;
                    end
                end
            end
        end
    end
    
end

%toc;
SensorCollectorR =SensorCollectorR/max(max(SensorCollectorR));
SensorCollectorG =SensorCollectorG/max(max(SensorCollectorG));
SensorCollectorB =SensorCollectorB/max(max(SensorCollectorB));
SensorCollector =SensorCollectorR+SensorCollectorG+SensorCollectorB;

end



