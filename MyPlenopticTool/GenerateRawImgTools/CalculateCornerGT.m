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
     
    GridCoordsX             = ImgSize_H+1-GridCoords(:,:,1); % ���ɵ������ǵ��񡣼�����ֵ��ʱ��Ҫ�㵽�������Ӧ��΢͸�����ꡣ
    GridCoordsY             = ImgSize_V+1-GridCoords(:,:,2);
    GridCoordsXOrigin       = GridCoords(:,:,1);
    GridCoordsYOrigin       = GridCoords(:,:,2);
    
    ValueImageNum           = length(ext_param)/6;     % ��ʾ����Ĵ�����
    corn_est                = cell(ValueImageNum,1);
    %**********************************************************************************
    % ��������������������µ����ꡣ
    CornerXYZ_WorldSN       = CornerWorldCoords';  % ������4ά����������ꡣ
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
            ucs                          = GridCoordsX(:);                                             % ΢͸������X�������ꡣ
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
      
            
            %CornerInfoperFrame{j}=[ImgSize_H+1-us+0.5,ImgSize_V+1-vs-0.5,LensID]; % �����ɵ����񣬷�ת�ɵ��� ���е�0.5��ƫ���ǽ���ϵͳ������
            CornerInfoperFrame{j}=[ImgSize_H+1-us,ImgSize_V+1-vs,LensID];   % �����ɵ����񣬷�ת�ɵ��� ����Ϊ��������ɵķ���ͼ���ǵ���
        end
        
        corn_est{n}= CornerInfoperFrame;
        
    end
    
end