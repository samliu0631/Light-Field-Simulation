function Params=GetAxis(Matrix)

Params=zeros(1,6);
cosb=(3-Matrix(1,1)-Matrix(2,2)-Matrix(3,3))/2;
if cosb<=0
    Params(1)=0;
    Params(2)=0;
    Params(3)=0;
elseif cosb>=2
    Params(1)=0.5*(1+Matrix(1,1))*pi;
    Params(2)=0.5*(1+Matrix(2,2))*pi;
    Params(3)=0.5*(1+Matrix(3,3))*pi;
else
    b=acos(1-cosb);
    sinb=sin(b);
    if b~=0 && sinb~=0
        Params(1)=(Matrix(3,2)-Matrix(2,3))/(2*sinb)*b;
        Params(2)=(Matrix(1,3)-Matrix(3,1))/(2*sinb)*b;
        Params(3)=(Matrix(2,1)-Matrix(1,2))/(2*sinb)*b;
    end
end
Params(4)=Matrix(1,4);
Params(5)=Matrix(2,4);
Params(6)=Matrix(3,4);

end