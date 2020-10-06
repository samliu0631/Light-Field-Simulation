function [Obj_CameraCoords,Obj,PixelSize] = PreparePlaneObject(InfoBag)
% generate the scene(point cloud) in world coordinate system.
    ObjImgSize     = InfoBag.ObjImgSize;    % 
    PicPath        = InfoBag.PicPath;
    Distance       = InfoBag.ObjDistance;   % The physical distance of the image. mm.
        
% Get the info of camera.
    bL0     = InfoBag.bL0;
    B       = InfoBag.B;
    pixelY  = InfoBag.pixelY;
    pixelX  = InfoBag.pixelX;
    sxy     = InfoBag.sxy;    
    %Height  = sxy*pixelY*Distance/(bL0+B);
    Width   = sxy*pixelX*Distance/(bL0+B)+50;
    
    ImgMetricSize  = Width;   % The physical size of the image. mm.
  
    % set the image size which is odd.
    Xradius  = round(ObjImgSize(1)/2);
    if mod(Xradius,2)==0
        Xradius = Xradius+1;
    end
    Yradius  = round(ObjImgSize(2)/2);
    if mod(Yradius,2)==0
        Yradius = Yradius+1;
    end
    ObjImgSize     = [2*Xradius+1, 2*Yradius+1];  % Actual picture resolution.  
    PixelSize      = ImgMetricSize/ObjImgSize(1);  % The physical size of the pixel.
    
    % Read the picture.
    Obj1 = imread(PicPath);
    Obj1 = im2double(rgb2gray(Obj1));
    Obj = imresize(Obj1, [ObjImgSize(2),ObjImgSize(1)]); % resize the image to unify the resolution.

    % generate the location of the point clouds.
    X        = -Xradius : Xradius;
    Y        = -Yradius : Yradius;
    [XX,YY]  = meshgrid(X,Y);
    XY       = [XX(:),YY(:)];
    PixelNum = size(XY,1);
    ObjWorldCoords1 = [XY.*PixelSize,Distance+zeros(PixelNum,1)];
    Obj_CameraCoords = ObjWorldCoords1;
    
    % visually validate the results
    %figure;pcshow(Obj_CameraCoords,Obj);
    %xlabel('X');ylabel('Y');zlabel('Z');
    %figure;plot3( Obj_CameraCoords(:,1), Obj_CameraCoords(:,2), Obj_CameraCoords(:,3),'*' );
end