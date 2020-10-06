function CellRGBLensID = ExtractRGBLensID(GridCoords,LensletGridModel)
    GridCoordsX                                 =  GridCoords(:,:,1);              % 微透镜中心横坐标
    %GridCoordsY                                 =  GridCoords(:,:,2);              % 微透镜中心纵坐标。
    LensHMax                                    =  LensletGridModel.UMax;          % 微透镜图像横向像素数
    LensVMax                                    =  LensletGridModel.VMax;          % 微透镜图像纵向像素数
    RLens_ID                                    =  [];
    GLens_ID                                    =  [];
    BLens_ID                                    =  [];
    if  GridCoordsX(1,1) > GridCoordsX(2,1)
        GLensIndex_Xodd                         =  1:3: LensletGridModel.UMax;     % 不同微透镜对应的序号。
        GLensIndex_Xeven                        =  3:3: LensletGridModel.UMax;     % 需要判断第一行和第二行的前后关系，再决定
        RLensIndex_Xodd                         =  2:3: LensletGridModel.UMax;
        RLensIndex_Xeven                        =  1:3: LensletGridModel.UMax;
        BLensIndex_Xodd                         =  3:3: LensletGridModel.UMax;
        BLensIndex_Xeven                        =  2:3: LensletGridModel.UMax;
    else
        GLensIndex_Xodd                         =  1:3: LensletGridModel.UMax;     % 不同微透镜对应的序号。
        GLensIndex_Xeven                        =  2:3: LensletGridModel.UMax;     % 需要判断第一行和第二行的前后关系，再决定
        RLensIndex_Xodd                         =  2:3: LensletGridModel.UMax;
        RLensIndex_Xeven                        =  3:3: LensletGridModel.UMax;
        BLensIndex_Xodd                         =  3:3: LensletGridModel.UMax;
        BLensIndex_Xeven                        =  1:3: LensletGridModel.UMax;
    end

    for hangshu=1:LensletGridModel.VMax
        if(mod(hangshu,2)~=0)
            RLens_ID                            = [ RLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(RLensIndex_Xodd)),RLensIndex_Xodd)];
            GLens_ID                            = [ GLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(GLensIndex_Xodd)),GLensIndex_Xodd)];
            BLens_ID                            = [ BLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(BLensIndex_Xodd)),BLensIndex_Xodd)];
        else
            RLens_ID                            = [ RLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(RLensIndex_Xeven)),RLensIndex_Xeven)];
            GLens_ID                            = [ GLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(GLensIndex_Xeven)),GLensIndex_Xeven)];
            BLens_ID                            = [ BLens_ID , sub2ind( [LensVMax,LensHMax],hangshu*ones(1,length(BLensIndex_Xeven)),BLensIndex_Xeven)];
        end
    end
    CellRGBLensID ={RLens_ID;GLens_ID;BLens_ID}; %%%%%%%%%%%

end
