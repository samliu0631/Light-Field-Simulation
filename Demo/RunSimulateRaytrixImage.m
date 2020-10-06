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

    InfoBag.Zc                  = [1000 ];                 % Ŀ����� ��λmm
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
    InfoBag.sxy                 = 0.0055;                 % ���������ش�С
    InfoBag.F                   = 100;                    % ����ͷ���ࡣ
    InfoBag.B                   = 1.32;                   % MLA���������ľ��롣
    InfoBag.fm1                 = 2.35;                  % ΢͸������1  
    InfoBag.fm2                 = 1.92;                  % ΢͸������2
    InfoBag.fm3                 = 1.62;                  % ΢͸������3
    InfoBag.Dmi                 = 32;                    % ΢͸��ͼ��ֱ����Ӧ��������
    FocusedVdValue              = 6;
    InfoBag.k1                  = 0;
    InfoBag.k2                  = 0;
    InfoBag.bL0                 = InfoBag.F * InfoBag.Zc(1) / ( InfoBag.Zc(1)-InfoBag.F )-FocusedVdValue*InfoBag.B;                    % MLA������ͷ����
    InfoBag.DL                  = InfoBag.bL0/( InfoBag.B/(InfoBag.Dmi*InfoBag.sxy) )-4;  % ����ͷ�ھ��� ͨ��f�����м��㡣
    
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
    InfoBag.NumMainRay          = 51;                   % ��͸���ĺ�������������
    InfoBag.cornersNum          = [12,8]; % horizontal, vertical
    InfoBag.GapDistance         = [10,10];  % the distance gap between two corners.
    InfoBag.GapPixel            = 200;      % the pixel number between two corners. Ҫ�ҵ�һ����֤������ͬʱ�����ܼ�С������gappixel��
    InfoBag.DataPath            = FilePath_Raw;
end


