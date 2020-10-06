function Params=GetAxisSam(Matrix)

if Matrix(3,1)~=1 && Matrix(3,1)~=-1
    theta  =   -asin(Matrix(3,1));
    gelma  =   atan2( Matrix(3,2)/cos(theta) , Matrix(3,3)/cos(theta) );
    faile   =   atan2( Matrix(2,1)/cos(theta) , Matrix(1,1)/cos(theta) );
else
    faile  =   0;
    if Matrix(3,1)==-1
        theta      =   pi/2;
        gelma  =   atan2( Matrix(1,2),Matrix(1,3) );
    else
        theta      =   -pi/2;
        gelma  =   atan2( -Matrix(1,2),-Matrix(1,3) );
    end
end
Params(1)=gelma;
Params(2)=theta;
Params(3)=faile;
Params(4)=Matrix(1,4);
Params(5)=Matrix(2,4);
Params(6)=Matrix(3,4);
end
