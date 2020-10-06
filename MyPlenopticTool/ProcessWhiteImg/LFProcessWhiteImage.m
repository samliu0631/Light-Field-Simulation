%用于读取白图像，算出微透镜中心位置，微透镜个数，微透镜的旋转情况
function [LensletGridModel,GridCoords] = LFProcessWhiteImage( WhiteImage,GridModelOptions )

    GridModelOptions = LFDefaultField( 'GridModelOptions', 'Orientation', 'horz' );
    GridModelOptions = LFDefaultField( 'GridModelOptions', 'FilterDiskRadiusMult', 1/3 );
    GridModelOptions = LFDefaultField( 'GridModelOptions', 'CropAmt', 25  ); %25 0
    GridModelOptions = LFDefaultField( 'GridModelOptions', 'SkipStep',10 );%250  1000
    GridModelOptions = LFDefaultField( 'GridModelOptions', 'ApproxLensletSpacing', 10 );%32这个数值需要修改。9.9276%%%%%%%%2018.1.29

    DispSize_pix = 160; % size of windows for visual confirmation display
    DebugBuildGridModel = false; % additional debug display


    %---Find grid params---
    [LensletGridModel, GridCoords] = LFBuildLensletGridModel( WhiteImage, GridModelOptions, DebugBuildGridModel );
    GridCoordsX = GridCoords(:,:,1);
    GridCoordsY = GridCoords(:,:,2);

    %---Visual confirmation---
    if( strcmpi(GridModelOptions.Orientation, 'vert') )
        WhiteImage = WhiteImage';
    end
    ImgSize = size(WhiteImage);
    HPlotSamps = ceil(DispSize_pix/LensletGridModel.HSpacing);
    VPlotSamps = ceil(DispSize_pix/LensletGridModel.VSpacing);

    LFFigure(1);
    clf
    subplot(331);
    imagesc(WhiteImage(1:DispSize_pix,1:DispSize_pix));
    hold on
    colormap gray
    plot(GridCoordsX(1:VPlotSamps,1:HPlotSamps), GridCoordsY(1:VPlotSamps,1:HPlotSamps), 'r.')
    axis off

    subplot(333);
    imagesc(WhiteImage(1:DispSize_pix, ImgSize(2)-DispSize_pix:ImgSize(2)));
    hold on
    colormap gray
    plot(-(ImgSize(2)-DispSize_pix)+1 + GridCoordsX(1:VPlotSamps, end-HPlotSamps:end), GridCoordsY(1:VPlotSamps, end-HPlotSamps:end), 'r.')
    axis off

    CenterStart = (ImgSize-DispSize_pix)/2;
    HCenterStartSamps = floor(CenterStart(2) / LensletGridModel.HSpacing);
    VCenterStartSamps = floor(CenterStart(1) / LensletGridModel.VSpacing);
    subplot(335);
    imagesc(WhiteImage(CenterStart(1):CenterStart(1)+DispSize_pix, CenterStart(2):CenterStart(2)+DispSize_pix));
    hold on
    colormap gray
    plot(-CenterStart(2)+1 + GridCoordsX(VCenterStartSamps + (1:VPlotSamps), HCenterStartSamps + (1:HPlotSamps)), -CenterStart(1)+1 + GridCoordsY(VCenterStartSamps + (1:VPlotSamps), HCenterStartSamps + (1:HPlotSamps)),'r.');
    axis off

    subplot(337);
    imagesc(WhiteImage(ImgSize(1)-DispSize_pix:ImgSize(1), 1:DispSize_pix));
    hold on
    colormap gray
    plot(GridCoordsX(end-VPlotSamps:end,1:HPlotSamps), -(ImgSize(1)-DispSize_pix)+1 + GridCoordsY(end-VPlotSamps:end,1:HPlotSamps), 'r.')
    axis off

    subplot(339);
    imagesc(WhiteImage(ImgSize(1)-DispSize_pix:ImgSize(1),ImgSize(2)-DispSize_pix:ImgSize(2)));
    hold on
    colormap gray
    plot(-(ImgSize(2)-DispSize_pix)+1 + GridCoordsX(end-VPlotSamps:end, end-HPlotSamps:end), -(ImgSize(1)-DispSize_pix)+1 + GridCoordsY(end-VPlotSamps:end, end-HPlotSamps:end), 'r.')
    axis off

    truesize % bigger display
    drawnow

end


