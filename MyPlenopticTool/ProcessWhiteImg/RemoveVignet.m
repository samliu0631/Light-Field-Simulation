function CurImg_rawDevignet = RemoveVignet(CurImg_White,CurImg_raw)
    CurImg_White = Convert2GrayImg(CurImg_White);
    CurImg_raw   = Convert2GrayImg(CurImg_raw);
    
    CurImg_rawDevignet          = CurImg_raw./CurImg_White ;
    CurImg_rawDevignet(CurImg_rawDevignet==inf)=0;
    CurImg_rawDevignet(CurImg_rawDevignet>1)=1;
end
