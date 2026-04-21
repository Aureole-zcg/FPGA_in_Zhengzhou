a = imread('iesWglbkorogdti.png');  %  读入图片 jpg png


y1=zeros(1,16384);
y2=zeros(1,16384);
y3=zeros(1,16384);
y4=zeros(1,16384);
y=zeros(1,16384);

m=114;%行像素
n=79;%场像素



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%111111
fild=fopen('pic.mif','wt');
fprintf(fild,'%s\n','WIDTH=16;');
fprintf(fild,'%s\n\n','DEPTH=16384;');
fprintf(fild,'%s\n','ADDRESS_RADIX=UNS;');
fprintf(fild,'%s\n\n','DATA_RADIX=UNS;');
fprintf(fild,'%s\n','CONTENT BEGIN');

for i=1:n
    for j=1:m
        z= (i-1)*m+j ;
        z0=round(z-1);
        y1(z)= a(i,j,1) ;%红 8bit
        y2(z)= a(i,j,2) ;%绿 8bit
        y3(z)= a(i,j,3) ;%蓝 8bit
        %RGB565  fix向0取整数
        y(z)= fix(y1(z)/2^3)*2^11 + fix(y2(z)/2^2)*2^5 + fix(y3(z)/2^3) ;%彩色
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%彩色转黑白
        %y4(z)= 0.4*y1(z)+0.5*y2(z)+0.1*y3(z) ;%RGB转灰度值 
        %y(z)= fix(y4(z)/8)*2^11 + fix(y4(z)/4)*2^5 + fix(y4(z)/8) ;%黑白

    fprintf(fild,'\t%d\t',z0);
    fprintf(fild,'%s\t',':');
    fprintf(fild,'%d\t',y(z));
    fprintf(fild,'%s\n',';');
    end
end
fprintf(fild,'%s\n','END;');


