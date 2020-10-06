function FastSimulateAndSaveImg(DataPath,PicDir,PicFileClass,Rf,ShowFlag)
    % set the intrinsic and extrinsic parameters.
    InfoBag             = SetPlaneSimConfiguration();

    % Calculate the plenoptic disc radius with regard to the object distance.
    ObjDistance         = - InfoBag.K2/(InfoBag.K1 + Rf);
    InfoBag.ObjDistance = ObjDistance;

    % generate the data of MLA.
    [LensletGridModel, GridCoords]      = FuncGenerateMLA( [InfoBag.pixelY,InfoBag.pixelX], DataPath ,false);
    save([DataPath,'/lensmodel'], 'LensletGridModel', 'GridCoords');
    InfoBag.LensletGridModel            = LensletGridModel;
    InfoBag.GridCoords                  = GridCoords;


    % generate the scene.
    [FileList_raw, BasePath_raw]    = ReadRawImgInfo(PicDir, PicFileClass);  
    ImageNum                        = length(FileList_raw);  
    for id = 1:ImageNum  
        CurFname_raw                       = FileList_raw{id};                            % ¶ÁÈ¡È«¾Û½¹Í¼
        CurFname_raw                       = fullfile( BasePath_raw, CurFname_raw);
        InfoBag.PicPath                    = CurFname_raw;
        [Obj_CameraCoords, Obj,PixelSize]  = PreparePlaneObject(InfoBag);  % change up to useness.
        InfoBag.Obj_CameraCoords           = Obj_CameraCoords;
        InfoBag.Obj                        = Obj;
        InfoBag.PixelSize                  = PixelSize;  % the physical size of the image pixel in the object image.

        % generate the simulated image.        
        RawImg = FastGenerateRawImgFromPlaneObject(InfoBag);
        if ShowFlag
            figure;imshow(RawImg);
        end
        
        % Store the simulated Img.
        imwrite(RawImg,[DataPath,'Raw\R',num2str(Rf),'\','Raw',num2str(100+id), '.png']);    
    end
end