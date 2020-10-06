function ID= findLensID(x_mla, y_mla, LensGridCoordsX, LensGridCoordsY, Dml,sxy,cxy,ImgSize)  % 加上3类焦距。
    Num = size(x_mla,2); % 光线数量。
    ID  = zeros(Num,1);
    [LensNumy,LensNumx] = size(LensGridCoordsX);
    for i=1:Num
        pixelX = x_mla(i)/sxy + cxy(1);
        pixelY = y_mla(i)/sxy + cxy(2);
        if pixelX >ImgSize(1) || pixelX <0 || pixelY >ImgSize(2)|| pixelY <0
            ID(i) =0;
        else
            Offsetx = pixelX - LensGridCoordsX(1,1);
            Offsety = pixelY - LensGridCoordsY(1,1);
            Numx = 1+ floor( Offsetx/( Dml ) );
            Numy = 1+ floor( Offsety/( sqrt(3) * Dml / 2 ) );
            Xmin = max(1, Numx-2);
            Xmax = min(Numx+2 ,LensNumx);
            Ymin = max(1, Numy-2);
            Ymax = min(Numy+2 ,LensNumy);
            RangeLensGridCoordsX =LensGridCoordsX( Ymin:Ymax ,Xmin:Xmax );
            RangeLensGridCoordsY =LensGridCoordsY( Ymin:Ymax ,Xmin:Xmax );
            X=Xmin:Xmax;
            Y=Ymin:Ymax;
            [XX,YY] = meshgrid(X,Y);
            XY  = [XX(:),YY(:)];
            LensGridsXY =[RangeLensGridCoordsX(:),RangeLensGridCoordsY(:)];
            ValidID =sqrt(sum(([pixelX,pixelY]-LensGridsXY).^2,2))<(Dml/2);
            TargetCoords =LensGridsXY(ValidID,:);
            if isempty(TargetCoords)
                ID(i) = 0;
            else
                 TEMxy= XY(ValidID,:);
                 ID(i)= TEMxy(2)+ (TEMxy(1)-1)*LensNumy;
            end
        end        
    end   
end