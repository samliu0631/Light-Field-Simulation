function corn_est =CalculateCornerGT( params ,CornerWorldCoords, ImgSize_H,ImgSize_V  , GridCoords, Dmi )

    K1 = params(1);
    K2 = params(2);
    fx = params(3);
    fy = params(4);
    cx = params(5);
    cy = params(6);
    k1 = params(7);
    k2 = params(8);
    ext_param   = params(9:end);
    
    
    cx = ImgSize_H+1-cx;  % Reverse the principle point
    cy = ImgSize_V+1-cy;  % Reverse the principle point
     
    GridCoordsX             = ImgSize_H+1-GridCoords(:,:,1); % 生成的数据是倒像。计算真值的时候要点到成正像对应的微透镜坐标。
    GridCoordsY             = ImgSize_V+1-GridCoords(:,:,2);
    GridCoordsXOrigin       = GridCoords(:,:,1);
    GridCoordsYOrigin       = GridCoords(:,:,2);
    
    ValueImageNum           = length(ext_param)/6;     % 表示拍摄的次数。
    corn_est                = cell(ValueImageNum,1);
    %**********************************************************************************
    % 计算特征点的世界坐标下的坐标。
    CornerXYZ_WorldSN       = CornerWorldCoords';  % 特征点4维齐次世界坐标。
    for n = 1:ValueImageNum
        RT = SetAxisSam(ext_param(6 * n - 5 : 6 * n));
        Xc = RT(1:3, 1:3)*CornerXYZ_WorldSN + RT(1:3, 4);
        % add lens distortion.
        CameraXIdeal  = Xc(1,:);
        CameraYIdeal  = Xc(2,:);
        CameraZIdeal  = Xc(3,:);
        r2            = (CameraXIdeal./CameraZIdeal).^2 + (CameraYIdeal./CameraZIdeal).^2;
        CameraXReal   = (1 + k1*r2 + k2*(r2).^2).* CameraXIdeal;
        CameraYReal   = (1 + k1*r2 + k2*(r2).^2).* CameraYIdeal;
        Xc(1:2,:)     = [CameraXReal;CameraYReal];    
             
        CornerNumberPerFrame   = size(Xc,2);
        CornerInfoperFrame     = cell(CornerNumberPerFrame,1);
        for j=1:CornerNumberPerFrame          
            ucs                          = GridCoordsX(:);                                             % 微透镜中心X像素坐标。
            vcs                          = GridCoordsY(:);
            du = fx * Xc(1, j) - Xc(3, j).*(ucs - cx);
            dv = fy * Xc(2, j) - Xc(3, j).*(vcs - cy);
            nominator = 1./(K1 * Xc(3, j) + K2);
            du = nominator.*du;
            dv = nominator.*dv;
            validID =(abs(sqrt(du.^2+dv.^2))< Dmi/2 );
            us = ucs(validID) + du(validID);
            vs = vcs(validID) + dv(validID);
            validLensID =  find(validID>0);
            
            VALIDImgID = logical( (us>0) & (us<ImgSize_H) & (vs>0) & (vs<ImgSize_V) );
            us=us(VALIDImgID);
            vs=vs(VALIDImgID);
            LensID =validLensID(VALIDImgID);
      
            
            %CornerInfoperFrame{j}=[ImgSize_H+1-us+0.5,ImgSize_V+1-vs-0.5,LensID]; % 把生成的正像，翻转成倒像。 其中的0.5的偏差是进行系统修正。
            CornerInfoperFrame{j}=[ImgSize_H+1-us,ImgSize_V+1-vs,LensID];   % 把生成的正像，翻转成倒像。 这是为了配合生成的仿真图像是倒向。
        end
        
        corn_est{n}= CornerInfoperFrame;
        
    end
    
end