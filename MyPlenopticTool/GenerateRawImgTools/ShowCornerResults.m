function ShowCornerResults(FilePath_Raw, DefaultFileSpec_Raw, corn_est)
    DefaultPath                  = '.';
    [FileList_raw, BasePath_raw] = LFFindFilesRecursive( FilePath_Raw, DefaultFileSpec_Raw , DefaultPath );
    fprintf('Found :\n'); disp(FileList_raw);
    FrameNum                     = size(corn_est,1);
    for j=1:FrameNum
        CurFname_raw                = FileList_raw{ j };                            % ¶ÁÈ¡È«¾Û½¹Í¼
        CurFname_raw                = fullfile( BasePath_raw, CurFname_raw);
        CurImg_raw                  = imread( CurFname_raw);
        corn_current                = corn_est{j};
        CornerNum                   = size( corn_current,1);
        figure; imshow(CurImg_raw);
        hold on;
        if CornerNum>0
            for k=1:CornerNum
                cornercoords        = corn_current{k};
                if ~isempty(cornercoords)
                    plot(cornercoords(:,1),cornercoords(:,2),'*');
                end
            end
        end
        hold off;
    end
end