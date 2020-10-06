clc,clear
ValidateFlag                        = true;
ShowFlag                            = false;
DataPath                            =  '../Data/Raytrix';
DefaultFileSpec_Raw                 = {'*.png'};
% set the intrinsic and extrinsic parameters.
InfoBag                             = SetConfiguration(DataPath);

% generate the data of MLA.
[LensletGridModel, GridCoords]      = FuncGenerateMLA([InfoBag.pixelY,InfoBag.pixelX], InfoBag.DataPath ,ShowFlag,InfoBag);
save([InfoBag.DataPath,'/lensmodel'], 'LensletGridModel', 'GridCoords');

% generate the ground truth data.
InfoBag.LensletGridModel            = LensletGridModel;
InfoBag.GridCoords                  = GridCoords;
corn_est                            = GenerateCornersGT(InfoBag);
save([InfoBag.DataPath,'/CornerGroundTruth'], 'corn_est');

% generate the simulated image.
GenerateSimulatedImg(InfoBag);

% Generate white image.
[SensorWhite,SensorWhiteFilted] = SimulateWhiteImg(InfoBag);

% show the validation results.
% if ValidateFlag == true
%     ShowCornerResults(InfoBag.DataPath, DefaultFileSpec_Raw, corn_est);
% end


    


function InfoBag = SetConfiguration(FilePath_Raw)
% set the parameters for raw image generation.
% Set the extrinsic parameters

    InfoBag.Zc                  = [1000 ];                 % 目标距离 单位mm
    FrameNum                    = size(InfoBag.Zc,2);
    InfoBag.Xc                  = zeros(1,FrameNum);
    InfoBag.Yc                  = zeros(1,FrameNum);
    InfoBag.ThetaXArray         = [ 0 ];
    InfoBag.ThetaYArray         = [ 0 ];
    InfoBag.ThetaZArray         = [ 0 ];
    InfoBag.FlagRemoveEdge      = false; % whether remove the micro-lenses which is not complete .
    InfoBag.ParallelFlag        = false; % whether use parallel computation.
% Set the intrinsic parameters
    InfoBag.pixelY              = 70;%200;%2000;
    InfoBag.pixelX              = 70;%200;%3000;
    InfoBag.sxy                 = 0.0055;                 % 传感器像素大小
    InfoBag.F                   = 100;                    % 主镜头焦距。
    InfoBag.B                   = 1.32;                   % MLA到传感器的距离。
    InfoBag.fm1                 = 2.35;                  % 微透镜焦距1  
    InfoBag.fm2                 = 1.92;                  % 微透镜焦距2
    InfoBag.fm3                 = 1.62;                  % 微透镜焦距3
    InfoBag.Dmi                 = 32;                    % 微透镜图像直径对应像素数。
    FocusedVdValue              = 6;
    InfoBag.k1                  = 0;
    InfoBag.k2                  = 0;
    InfoBag.bL0                 = InfoBag.F * InfoBag.Zc(1) / ( InfoBag.Zc(1)-InfoBag.F )-FocusedVdValue*InfoBag.B;                    % MLA到主镜头距离
    InfoBag.DL                  = InfoBag.bL0/( InfoBag.B/(InfoBag.Dmi*InfoBag.sxy) )-4;  % 主镜头口径。 通过f数进行计算。
    
% Calculate the rest of parameters
    InfoBag.Dml                 = InfoBag.Dmi*InfoBag.bL0/(InfoBag.bL0+InfoBag.B);  % The diameter of the micro-lenses.
    Lm                          = -InfoBag.bL0;
    Lc                          = -InfoBag.bL0-InfoBag.B;
    InfoBag.K1                  = -(Lm+InfoBag.F)*Lc/( (Lm-Lc)*InfoBag.F  );
    InfoBag.K2                  = Lm*Lc/(Lm-Lc);
    InfoBag.fx                  = (InfoBag.bL0+InfoBag.B)/InfoBag.sxy;
    InfoBag.fy                  = (InfoBag.bL0+InfoBag.B)/InfoBag.sxy;
    InfoBag.cx                  = InfoBag.pixelX/2;
    InfoBag.cy                  = InfoBag.pixelY/2;
   
% Set the parameters for simulation.
    InfoBag.NumMainRay          = 51;                   % 主透镜的横向和纵向采样数
    InfoBag.cornersNum          = [12,8]; % horizontal, vertical
    InfoBag.GapDistance         = [10,10];  % the distance gap between two corners.
    InfoBag.GapPixel            = 200;      % the pixel number between two corners. 要找到一个保证质量但同时尽可能减小开销的gappixel。
    InfoBag.DataPath            = FilePath_Raw;
end


