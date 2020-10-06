%function : use xml file to generate the information of white raw image.
%input: ImgSize: the size of wanted white image. [height,width]
%FilePath_White :the folder path of the XML file. 
%Output:LensletGridModel GridCoords .
function [LensletGridModel,GridCoords] = FuncGenerateMLA(ImgSize,FilePath_White,ShowFlag,varargin)
    if nargin==4
       InfoBag = varargin{1};
    else
       InfoBag = [];
    end
    if isfield(InfoBag,'FlagRemoveEdge')
        FlagRemoveEdge = InfoBag.FlagRemoveEdge;
    else
        FlagRemoveEdge = true;
    end

 % *********读取白图像****************************************
    DefaultFileSpec_White   = {'*.xml'};
    DefaultPath_White = '.';
    [FileList_White, BasePath_White]   = LFFindFilesRecursive( FilePath_White, DefaultFileSpec_White , DefaultPath_White );
    if ShowFlag==true
        fprintf('Found :\n');        
        disp(FileList_White)
    end
    ImageNum_White       = length(FileList_White);
    if ImageNum_White>=1                                                   % 如果白图像数量大于1。
        CurFname_White  = FileList_White{1};                               % 读取白图像
        CurFname_White  = fullfile( BasePath_White, CurFname_White);
        [LensletGridModel ,GridCoords]= GetLensGridFormXML(CurFname_White,[ImgSize(1),ImgSize(2)]);
    end    

    % used to remove micro-images' center which following on the edge.
    if FlagRemoveEdge == true
        ImgSizeX = ImgSize(2);
        ImgSizeY = ImgSize(1);
        [GridCoords,LensletGridModel] = ValidateLensLetGridModel(GridCoords,LensletGridModel,ImgSizeX,ImgSizeY);
    end

end




