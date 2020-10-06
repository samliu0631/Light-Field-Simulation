function PatchInterp = FillPatchtoRaw(WhitePatch,PointRawCoords,PatchSize,varargin)
    if nargin == 4
        method = varargin{1};
    else
        method = 'linear';
    end
    PatchRadius        = (PatchSize-1)/2;  
    X2                  = -PatchRadius : 1 : PatchRadius;
    Y2                  = -PatchRadius : 1 : PatchRadius;
    [XX2,YY2]            = meshgrid(X2,Y2);   
    OriginXX           = round(PointRawCoords(1))+XX2;
    OriginYY           = round(PointRawCoords(2))+YY2;
    X                  = -PatchRadius : 1 : PatchRadius;
    Y                  = -PatchRadius : 1 : PatchRadius;
    [XX,YY]            = meshgrid(X,Y);
    InterpXX           = PointRawCoords(1)+XX; % ºá×ø±ê
    InterpYY           = PointRawCoords(2)+YY; % ×Ý×ø±ê
    PatchInterp        = interp2(InterpXX,InterpYY,WhitePatch,OriginXX,OriginYY,method);
end
