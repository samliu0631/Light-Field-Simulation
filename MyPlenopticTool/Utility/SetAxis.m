function Matrix=SetAxis(Params)

Matrix=diag([1,1,1,1]);
r=[Params(1),Params(2),Params(3)];
b=sqrt(r*r');
if b~=0
    B=1/b;
    x=Params(1)*B;
    y=Params(2)*B;
    z=Params(3)*B;
    sinb=sin(b);
    cosb=1-cos(b);
    Matrix(1,1)=1-(y*y+z*z)*cosb;
    Matrix(1,2)=-z*sinb+x*y*cosb;
    Matrix(1,3)=y*sinb+x*z*cosb;
    Matrix(2,1)=z*sinb+x*y*cosb;
    Matrix(2,2)=1-(x*x+z*z)*cosb;
    Matrix(2,3)=-x*sinb+y*z*cosb;
    Matrix(3,1)=-y*sinb+x*z*cosb;
    Matrix(3,2)=x*sinb+y*z*cosb;
    Matrix(3,3)=1-(x*x+y*y)*cosb;
end
Matrix(1,4)=Params(4);
Matrix(2,4)=Params(5);
Matrix(3,4)=Params(6);

end
