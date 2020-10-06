% LFBuildLensletGridModel - builds a lenslet grid model from a white image, called by LFUtilProcessWhiteImages
%
% Usage:
%     [LensletGridModel, GridCoords] = LFBuildLensletGridModel( WhiteImg, GridModelOptions, DebugDisplay )
%
% Inputs: 
%             WhiteImg : path of an image taken through a diffuser, or of an entirely white scene
% 
%     GridModelOptions : struct controlling the model-bulding options
%           .ApproxLensletSpacing : A rough initial estimate to initialize the lenslet spacing
%                                   computation
%           .FilterDiskRadiusMult : Filter disk radius for prefiltering white image for locating
%                                   lenslets; expressed relative to lenslet spacing; e.g. a
%                                   value of 1/3 means a disk filte with a radius of 1/3 the
%                                   lenslet spacing
%                        .CropAmt : Image edge pixels to ignore when finding the grid
%                       .SkipStep : As a speed optimization, not all lenslet centers contribute
%                                   to the grid estimate; <SkipStep> pixels are skipped between
%                                   lenslet centers that get used; a value of 1 means use all
%           [optional] .Precision : 'single' or 'double'
% 
%  [optional] DebugDisplay : enables a debugging display, default false
% 
% Outputs:
% 
%     LensletGridModel : struct describing the lenslet grid
%         .HSpacing, .VSpacing : Spacing between lenslets, in pixels
%          .HOffset, .VOffset  : Offset of first lenslet, in pixels
%                         .Rot : Rotation of lenslets, in radians
% 
%     GridCoords : a list of N x M x 2 pixel coordinates generated from the estimated
%                  LensletGridModel, where N and M are the estimated number of lenslets in the
%                  horizontal and vertical directions, respectively.
%
% See also:  LFUtilProcessWhiteImages

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function [LensletGridModel, GridCoords] = LFBuildLensletGridModel( WhiteImg, GridModelOptions, DebugDisplay )

%---Defaults---
GridModelOptions = LFDefaultField( 'GridModelOptions', 'Precision', 'single' );
DebugDisplay = LFDefaultVal( 'DebugDisplay', false );

%---Optionally rotate for vertically-oriented grids---
if( strcmpi(GridModelOptions.Orientation, 'vert') )
    WhiteImg = WhiteImg';
end

% Try locating lenslets by convolving with a disk
% Also tested Gaussian... the disk seems to yield a stronger result


h = zeros( size(WhiteImg), GridModelOptions.Precision );
hr = fspecial( 'disk', GridModelOptions.ApproxLensletSpacing * GridModelOptions.FilterDiskRadiusMult );
hr = hr ./ max( hr(:) ); 
hs = size( hr,1 );
DiskOffset = round( (size(WhiteImg) - hs)/2 );
h( (1:hs) + DiskOffset(1), (1:hs) + DiskOffset(2) ) = hr;
fprintf( 'Filtering...\n' );
% Convolve using fft
WhiteImg = fft2(WhiteImg);
h = fft2(h);
WhiteImg = WhiteImg.*h;
WhiteImg = ifftshift(ifft2(WhiteImg));
WhiteImg = (WhiteImg - min(WhiteImg(:))) ./ abs(max(WhiteImg(:))-min(WhiteImg(:)));
WhiteImg = cast(WhiteImg, GridModelOptions.Precision);
clear h
fprintf('Finding Peaks...\n');
% Find peaks in convolution... ideally these are the lenslet centers
Peaks = imregionalmax(WhiteImg);
PeakIdx = find(Peaks==1);
[PeakIdxY,PeakIdxX] = ind2sub(size(Peaks),PeakIdx);
clear Peaks

% Crop to central peaks; eliminates edge effects  CropAmt=25 defined in the
% LFUtilProcessWhiteImages.m
InsidePts = find(PeakIdxY>GridModelOptions.CropAmt & PeakIdxY<size(WhiteImg,1)-GridModelOptions.CropAmt & ...
    PeakIdxX>GridModelOptions.CropAmt & PeakIdxX<size(WhiteImg,2)-GridModelOptions.CropAmt);
PeakIdxY = PeakIdxY(InsidePts);
PeakIdxX = PeakIdxX(InsidePts);

%---Form a Delaunay triangulation to facilitate row/column traversal---
Triangulation = DelaunayTri(PeakIdxY, PeakIdxX);  % DelaunayTri.

%---Traverse rows and columns of lenslets, collecting stats---
if( DebugDisplay )
    LFFigure(3);
    cla
    imagesc( WhiteImg );
    colormap gray
    hold on
end

%--Traverse vertically--����ᴩ
fprintf('Vertical fit...\n');
YStart = GridModelOptions.CropAmt*2;                       %YStart =50
YStop = size(WhiteImg,1)-GridModelOptions.CropAmt*2;       %YStop  =����������-50

XIdx = 1;

%��50���ؿ�ʼ��  ��SkipStep=250Ϊ������  ������������-50
for(  XStart = GridModelOptions.CropAmt*2  :  GridModelOptions.SkipStep   :   size(WhiteImg,2)-GridModelOptions.CropAmt*2  )
    CurPos = [XStart, YStart] ;  %CusPos=[50 50]
    YIdx = 1;
    while( 1 )
        ClosestLabel = nearestNeighbor(   Triangulation, CurPos(2), CurPos(1)   );
        ClosestPt = [  PeakIdxX(ClosestLabel)  ,   PeakIdxY(ClosestLabel)   ];

        RecPtsY(XIdx,YIdx,:) = ClosestPt;
        if( DebugDisplay ) plot( ClosestPt(1), ClosestPt(2), 'r.' ); end
        
        CurPos = ClosestPt;
        CurPos(2) = round(CurPos(2) + GridModelOptions.ApproxLensletSpacing * sqrt(3));
        if( CurPos(2) > YStop )
            break;
        end
        YIdx = YIdx + 1;
    end
    %--Estimate angle for this most recent line--
    LineFitY(XIdx,:) = polyfit(RecPtsY(XIdx, 3:end-3,2), RecPtsY(XIdx, 3:end-3,1), 1);
    XIdx = XIdx + 1;
end
if( DebugDisplay ) drawnow; end

%--Traverse horizontally--
fprintf('Horizontal fit...\n');
XStart = GridModelOptions.CropAmt*2;
XStop = size(WhiteImg,2)-GridModelOptions.CropAmt*2;
YIdx = 1;
for( YStart = GridModelOptions.CropAmt*2:GridModelOptions.SkipStep:size(WhiteImg,1)-GridModelOptions.CropAmt*2 )
    CurPos = [XStart, YStart];
    XIdx = 1;
    while( 1 )
        ClosestLabel = nearestNeighbor(Triangulation, CurPos(2), CurPos(1));
        ClosestPt = [PeakIdxX(ClosestLabel), PeakIdxY(ClosestLabel)];

        RecPtsX(XIdx,YIdx,:) = ClosestPt;
        if( DebugDisplay ) plot( ClosestPt(1), ClosestPt(2), 'y.' ); end
        
        CurPos = ClosestPt;
        CurPos(1) = round(CurPos(1) + GridModelOptions.ApproxLensletSpacing);
        if( CurPos(1) > XStop )
            break;
        end
        XIdx = XIdx + 1;
    end
    %--Estimate angle for this most recent line--
    LineFitX(YIdx,:) = polyfit(RecPtsX(3:end-3,YIdx,1), RecPtsX(3:end-3,YIdx,2), 1);
    YIdx = YIdx + 1;
end
if( DebugDisplay ) drawnow; end

%--Trim ends to wipe out alignment, initial estimate artefacts--
RecPtsY = RecPtsY(3:end-2, 3:end-2,:);  
RecPtsX = RecPtsX(3:end-2, 3:end-2,:);

%--Estimate angle--
SlopeX = mean(LineFitX(:,1));
SlopeY = mean(LineFitY(:,1));

AngleX = atan2(-SlopeX,1);
AngleY = atan2(SlopeY,1);
EstAngle = mean([AngleX,AngleY]);

%--Estimate spacing, assuming approx zero angle--
t=squeeze(RecPtsY(:,:,2));
YSpacing = diff(t,1,2);
YSpacing = mean(YSpacing(:))/2 / (sqrt(3)/2);

t=squeeze(RecPtsX(:,:,1));
XSpacing = diff(t,1,1);
XSpacing = mean(XSpacing(:));

%--Correct for angle--
XSpacing = XSpacing / cos(EstAngle);
YSpacing = YSpacing / cos(EstAngle);

%--Build initial grid estimate, starting with CropAmt for the offsets--
LensletGridModel = struct('HSpacing',XSpacing, 'VSpacing',YSpacing*sqrt(3)/2, 'HOffset',GridModelOptions.CropAmt, ...
    'VOffset',GridModelOptions.CropAmt, 'Rot',-EstAngle, 'Orientation', GridModelOptions.Orientation, ...
    'FirstPosShiftRow', 2 );
LensletGridModel.UMax = ceil( (size(WhiteImg,2)-GridModelOptions.CropAmt*2)/XSpacing );
LensletGridModel.VMax = ceil( (size(WhiteImg,1)-GridModelOptions.CropAmt*2)/YSpacing/(sqrt(3)/2) );
GridCoords = LFBuildHexGrid( LensletGridModel );

%--Find offset to nearest peak for each--
GridCoordsX = GridCoords(:,:,1);
GridCoordsY = GridCoords(:,:,2);
BuildGridCoords = [GridCoordsX(:), GridCoordsY(:)];

IdealPts = nearestNeighbor(Triangulation, round(GridCoordsY(:)), round(GridCoordsX(:)));
IdealPtCoords = [PeakIdxX(IdealPts), PeakIdxY(IdealPts)];

%--Estimate single offset for whole grid--
EstOffset = IdealPtCoords - BuildGridCoords;
EstOffset = median(EstOffset);
LensletGridModel.HOffset = LensletGridModel.HOffset + EstOffset(1);
LensletGridModel.VOffset = LensletGridModel.VOffset + EstOffset(2);

%--Remove crop offset / find top-left lenslet--
NewVOffset = mod( LensletGridModel.VOffset, LensletGridModel.VSpacing );
VSteps = round( (LensletGridModel.VOffset - NewVOffset) / LensletGridModel.VSpacing ); % should be a whole number

VStepParity = mod( VSteps, 2 );
if( VStepParity == 1 )
    LensletGridModel.HOffset = LensletGridModel.HOffset + LensletGridModel.HSpacing/2;
end

NewHOffset = mod( LensletGridModel.HOffset, LensletGridModel.HSpacing/2 );
HSteps = round( (LensletGridModel.HOffset - NewHOffset) / (LensletGridModel.HSpacing/2) ); % should be a whole number

HStepParity = mod( HSteps, 2 );
LensletGridModel.FirstPosShiftRow = 2-HStepParity;

if( DebugDisplay )
    plot( LensletGridModel.HOffset, LensletGridModel.VOffset, 'ro' );
    plot( NewHOffset, NewVOffset, 'yx');
    drawnow
end

LensletGridModel.HOffset = NewHOffset;
LensletGridModel.VOffset = NewVOffset;

%---Finalize grid---
LensletGridModel.UMax = floor((size(WhiteImg,2)-LensletGridModel.HOffset)/LensletGridModel.HSpacing) + 1;
LensletGridModel.VMax = floor((size(WhiteImg,1)-LensletGridModel.VOffset)/LensletGridModel.VSpacing) + 1;

GridCoords = LFBuildHexGrid( LensletGridModel );

fprintf('...Done.\n');

end



