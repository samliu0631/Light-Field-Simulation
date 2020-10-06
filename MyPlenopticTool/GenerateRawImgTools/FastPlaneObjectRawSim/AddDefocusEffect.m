function PatchImg = AddDefocusEffect(i,CellRGBLensID,PatchImg)
    if ismember(i,CellRGBLensID{1})
        % do nothing.
    end
    if ismember(i,CellRGBLensID{2})
        h = fspecial('average',[3,3]);    % The degree of blurness is up to the kernal size.
        PatchImg = imfilter(PatchImg,h);
    end
    if ismember(i,CellRGBLensID{3})
        h = fspecial('average',[5,5]);    % The degree of blurness is up to the kernal size.
        PatchImg = imfilter(PatchImg,h);
    end
end