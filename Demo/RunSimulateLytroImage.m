clc,clear
ValidateFlag                        = true;
ShowFlag                            = false;
DataPath                            =  '../Data/Lytro';
DefaultFileSpec_Raw                 = {'*.png'};
% set the intrinsic and extrinsic parameters.
InfoBag                             = SetConfiguration(DataPath);

% generate the data of MLA.
[LensletGridModel, GridCoords]      = FuncGenerateMLA([InfoBag.pixelY,InfoBag.pixelX], InfoBag.DataPath ,ShowFlag);
save([InfoBag.DataPath,'/lensmodel'], 'LensletGridModel', 'GridCoords');

GridCoordsX = GridCoords(:,:,1);
GridCoordsY = GridCoords(:,:,2);
figure; plot(GridCoordsX(:),GridCoordsY(:),'*');



% generate the ground truth data.
InfoBag.LensletGridModel            = LensletGridModel;
InfoBag.GridCoords                  = GridCoords;
corn_est                            = GenerateCornersGT(InfoBag);
ShowSimulatedCorner(corn_est,GridCoords);
save([InfoBag.DataPath,'/CornerGroundTruth'], 'corn_est');

% generate the simulated image.
GenerateSimulatedImg(InfoBag);

% Generate white image.
[SensorWhite,SensorWhiteFilted] = SimulateWhiteImg(InfoBag);

% show the validation results.
%if ValidateFlag == true
%     ShowCornerResults(InfoBag.DataPath, DefaultFileSpec_Raw, corn_est);
%end


function ShowSimulatedCorner(corn_est,GridCoords)
    GridCoordsX = GridCoords(:,:,1);
    GridCoordsY = GridCoords(:,:,2);
    ImageValueNum             = length(corn_est);
    for iFile = 1 :ImageValueNum
        CurrentGroundTruthtem = corn_est{iFile};
        CornerNumPerFrame     = size(CurrentGroundTruthtem,1);
        figure;
        %plot(GridCoordsX(:) , GridCoordsY(:),'b*');
        for k = 1:CornerNumPerFrame
            CornerInfoGT     = CurrentGroundTruthtem{k};
            hold on ;
            if ~isempty(CornerInfoGT)
                plot(CornerInfoGT(:,1),CornerInfoGT(:,2),'r*');
                plot(GridCoordsX(CornerInfoGT(:,3)) , GridCoordsY(CornerInfoGT(:,3)),'b*');
            end
            hold off;
        end

    end

end


function InfoBag = SetConfiguration(FilePath_Raw)
% set the parameters for raw image generation.
% Set the extrinsic parameters
    WorkDistance                = 1000;
    FocusedVdValue              = 0;
    InfoBag.Zc                  = [  1000 ];                 % Ŀ����� ��λmm
    InfoBag.Xc                  = [  5    ];
    InfoBag.Yc                  = [  5    ];
    InfoBag.ThetaXArray         = [  pi/7 ];
    InfoBag.ThetaYArray         = [  pi/3 ];
    InfoBag.ThetaZArray         = [  0    ];
    
    
% Set the intrinsic parameters
    InfoBag.pixelY              = 100;   %2000;    % control the pixel size of sensor.
    InfoBag.pixelX              = 100;   %3000;
    InfoBag.sxy                 = 0.0055;                 % ���������ش�С
    InfoBag.F                   = 100;%35;                    % ����ͷ���ࡣ
    InfoBag.B                   = 2;                   % MLA���������ľ��롣
    InfoBag.fm1                 = 2;                  % ΢͸������1  
    InfoBag.fm2                 = 2;                  % ΢͸������2
    InfoBag.fm3                 = 2;                  % ΢͸������3
    InfoBag.Dmi                 = 11;                    % ΢͸��ͼ��ֱ����Ӧ��������
    InfoBag.k1                  = 6;
    InfoBag.k2                  = 5;
    InfoBag.bL0                 = InfoBag.F * WorkDistance / ( WorkDistance-InfoBag.F )-FocusedVdValue*InfoBag.B;                    % MLA������ͷ����
    InfoBag.DL                  = InfoBag.bL0/( InfoBag.B/(InfoBag.Dmi*InfoBag.sxy) )-3;  % ����ͷ�ھ��� ͨ��f�����м��㡣!!!!!!!!!!
    
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
    InfoBag.cornersNum          = [7,6]; % horizontal, vertical
    InfoBag.GapDistance         = [10,10];
    %InfoBag.cornersNum          = [12,8]; % horizontal, vertical 
    %InfoBag.GapDistance         = [10,10];  % the distance gap between two corners.
    InfoBag.GapPixel            = 200;      % the pixel number between two corners. Ҫ�ҵ�һ����֤������ͬʱ�����ܼ�С������gappixel��
    InfoBag.DataPath            = FilePath_Raw;
end


