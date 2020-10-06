function GrayImg = Convert2GrayImg(Img)
    b=size(Img,3);
    if b==3
        GrayImg = rgb2gray(Img);
    else
        GrayImg = Img;
    end 
    GrayImg = im2double(GrayImg);
end
