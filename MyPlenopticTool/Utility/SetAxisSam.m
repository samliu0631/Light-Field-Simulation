function Matrix=SetAxisSam(Params)
gelma   =    Params(1);
theta   =    Params(2);
faile   =    Params(3);
cos_gelma      =    cos(gelma);
sin_gelma      =    sin(gelma);
cos_theta      =    cos(theta);
sin_theta      =    sin(theta);
cos_faile      =    cos(faile);
sin_faile      =    sin(faile);

Matrix      = zeros(4,4);
Matrix(1,1) = cos_theta*cos_faile;
Matrix(1,2) = sin_gelma*sin_theta*cos_faile - cos_gelma*sin_faile;
Matrix(1,3) = cos_gelma*sin_theta*cos_faile + sin_gelma*sin_faile;
Matrix(2,1) = cos_theta*sin_faile;
Matrix(2,2) = sin_gelma*sin_theta*sin_faile + cos_gelma*cos_faile;
Matrix(2,3) = cos_gelma*sin_theta*sin_faile - sin_gelma*cos_faile;
Matrix(3,1) = -sin_theta;
Matrix(3,2) = sin_gelma*cos_theta;
Matrix(3,3) = cos_gelma*cos_theta;

Matrix(1,4)=Params(4);
Matrix(2,4)=Params(5);
Matrix(3,4)=Params(6);

Matrix(4,4)=1;
end
