
function WhiteNew = GenerateWhiteImage(LensletGridModel,GridCoords,DataPath,FilePath,Debug)
    white          = imread(FilePath);
    white          = im2double(white);
    TrueDiameter   = LensletGridModel.HSpacing;
    Diameter       = round(TrueDiameter);
    if mod(Diameter,2)==0  % make sure the circlesize is odd.
        CircleSize = Diameter+1;
    else
        CircleSize = Diameter+2;
    end

    %extract three position.

    McLensCenter3 =[GridCoords(2,2,1),GridCoords(2,2,2);
                    GridCoords(2,5,1),GridCoords(2,5,2);
                    GridCoords(2,8,1),GridCoords(2,8,2);
                    GridCoords(2,11,1),GridCoords(2,11,2)];
    McLensCenter2 =[GridCoords(2,3,1),GridCoords(2,3,2);
                    GridCoords(2,6,1),GridCoords(2,6,2);
                    GridCoords(2,9,1),GridCoords(2,9,2);
                    GridCoords(2,12,1),GridCoords(2,12,2)];
    McLensCenter1 =[GridCoords(2,4,1),GridCoords(2,4,2);    
                    GridCoords(2,7,1),GridCoords(2,7,2);
                    GridCoords(2,10,1),GridCoords(2,10,2);
                    GridCoords(2,13,1),GridCoords(2,13,2)];
    if Debug == true
        figure; imshow(white);
        hold on;
        plot(McLensCenter1(:,1),McLensCenter1(:,2),'b*');
        plot(McLensCenter2(:,1),McLensCenter2(:,2),'r*');
        plot(McLensCenter3(:,1),McLensCenter3(:,2),'y*');
        hold off;
    end
    %extract three types.
    CellRGBLensID      = ExtractRGBLensID(GridCoords,LensletGridModel);
    RLens_ID           = CellRGBLensID{1};
    GLens_ID           = CellRGBLensID{2};
    BLens_ID           = CellRGBLensID{3};
    GridCoordsX        = GridCoords(:,:,1);
    GridCoordsY        = GridCoords(:,:,2);
    RLensCoord         = [GridCoordsX(RLens_ID'),GridCoordsY(RLens_ID')];
    GLensCoord         = [GridCoordsX(GLens_ID'),GridCoordsY(GLens_ID')];
    BLensCoord         = [GridCoordsX(BLens_ID'),GridCoordsY(BLens_ID')];
    if Debug == true
        figure;imshow(white);
        hold on;
        plot(RLensCoord(:,1),RLensCoord(:,2),'b*');
        plot(GLensCoord(:,1),GLensCoord(:,2),'r*');
        plot(BLensCoord(:,1),BLensCoord(:,2),'y*');
        hold off;
    end
    %*******produce mask*************************
    Mask    = zeros(CircleSize,CircleSize);
    x       = 1:CircleSize;
    y       = 1:CircleSize;
    [xx,yy] = meshgrid(x,y);
    xy      = [xx(:),yy(:)];
    center  = [CircleSize+1,CircleSize+1]/2;
    distance= sqrt(sum((xy-center).^2,2));
    Mask(distance<(TrueDiameter)/2) = 1;    % enlarge a little 

    %******extract three types micro images **************************************
    PatchSize           = CircleSize;
    Num                 = size(McLensCenter3,1);
    PatchInterpMasked1  = zeros(size(Mask));
    for i=1:Num
        PatchInterp1        = ExtractPatchFromRaw(white,McLensCenter1(i,:),PatchSize);
        PatchInterpMasked1_1  = PatchInterp1.*Mask;
        PatchInterpMasked1  = PatchInterpMasked1+PatchInterpMasked1_1;
        PatchInterp2        = ExtractPatchFromRaw(white,McLensCenter2(i,:),PatchSize);
        PatchInterpMasked2_1  = PatchInterp2.*Mask;     
        PatchInterpMasked2  = PatchInterpMasked1+PatchInterpMasked2_1;
        PatchInterp3        = ExtractPatchFromRaw(white,McLensCenter3(i,:),PatchSize);
        PatchInterpMasked3_1  = PatchInterp3.*Mask;
        PatchInterpMasked3  = PatchInterpMasked1+PatchInterpMasked3_1;
    end
    PatchInterpMasked1 = PatchInterpMasked1./Num;
    PatchInterpMasked2 = PatchInterpMasked2./Num;
    PatchInterpMasked3 = PatchInterpMasked3./Num;

    
    if Debug == true
        figure;imshow(Mask);
        figure;imshow(PatchInterpMasked1);
        figure;imshow(PatchInterpMasked2);
        figure;imshow(PatchInterpMasked3);
    end
    %
    ImgSize         = size(white);
    WhiteNewCollect = zeros(ImgSize(1)+100,ImgSize(2)+100);
    PatchRadius     = (PatchSize-1)/2;
    X2              = -PatchRadius : 1 : PatchRadius;
    Y2              = -PatchRadius : 1 : PatchRadius;
    RLensCoord      = [GridCoordsX(RLens_ID'),GridCoordsY(RLens_ID')]+[50,50];
    for i=1:size(RLensCoord,1)
        Coords = RLensCoord(i,:);   
        FillPatchInterp1 = FillPatchtoRaw(PatchInterpMasked1,Coords,PatchSize);
        FillPatchInterp1(isnan(FillPatchInterp1))=0;
       %figure;imshow(PatchInterp)
        WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )=WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )+FillPatchInterp1;%PatchInterpMasked1;
    end

    GLensCoord          = [GridCoordsX(GLens_ID'),GridCoordsY(GLens_ID')]+[50,50];
    for i=1:size(GLensCoord,1)
        Coords = GLensCoord(i,:);    
        FillPatchInterp2 = FillPatchtoRaw(PatchInterpMasked2,Coords,PatchSize);
        FillPatchInterp2(isnan(FillPatchInterp2))=0;
        WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )=WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )+ FillPatchInterp2;%PatchInterpMasked2;
    end

    BLensCoord          = [GridCoordsX(BLens_ID'),GridCoordsY(BLens_ID')]+[50,50];
    for i=1:size(BLensCoord,1)
        Coords = BLensCoord(i,:);
        FillPatchInterp3 = FillPatchtoRaw(PatchInterpMasked3,Coords,PatchSize);
        FillPatchInterp3(isnan(FillPatchInterp3))=0;
        WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )=WhiteNewCollect( round(Coords(2))+Y2 ,round(Coords(1))+X2 )+FillPatchInterp3;%PatchInterpMasked3;
    end
    WhiteNew = WhiteNewCollect(51:ImgSize(1)+50,51:ImgSize(2)+50);
    if Debug == true
        figure;imshow(WhiteNewCollect);
        figure;imshow(WhiteNew);
    end
    imwrite(WhiteNew,[DataPath,'\WhiteRaw.png']);



end