close all;
clear all;

% v = VideoReader('highway.avi');
% v.CurrentTime=0;
% video=readFrame(v);
% im=video;

im = imread('test_im12.png');

[h w c]=size(im);
figure
imshow(im);
imwrite(im,"obraz_color.png");
title('obraz w RGB');

%% skala szarosci 
% wsteSpne przeksztalcenie w celu przeprowadzeni binaryzacji 
% wyliczanie skladowej L z formatu HSL

im_grey=zeros(h,w);
for i=1:h
    for j=1:w
        im_grey(i,j)=max(im(i,j,:))/2+min(im(i,j,:))/2;
%         im_grey2(i,j)=im_
    end;
end;
im_grey2=im_grey/255;



figure
imshow(im_grey2);
title('skala szarosci');
imwrite(im_grey2,"obraz_grey.png");

%% binaryzacja
% binaryzacja stalym progiem dawala dla dobrze oswietlonej jezdni dobre
% oddzielenie od pasów ruchu. Dla zbyt przeswietlonych jezdni, lub zbyt
% zacienionych pasy albo maja tendencje sie laczyc z fragmentami jezdni lub
% pobocza.

for x=1:h
    for y=1:w
        if im_grey(x,y) > 192
            im_bin(x,y)=1;
        else
            im_bin(x,y)=0;
        end;
    end;
end;
figure
imshow(im_bin);
title('binaryzacja progiem 192');
imwrite(im_bin,"obraz_binarny.png");

%% ROI
% trapez zainteresowanie ma na celu usuniecie czesci niebosklonu i bobocza
% w celu skuteczniejszej detekcji pasów.

im_bin1=zeros(h,w);
im_bin2=zeros(h,w);

for x=1:h
    for y=1:w
        w1=y-3/8*w;
        w2=-y+w*5/8;
        
        if x>h*1/2
            if w1<x
                if w2<x
                    im_bin1(x,y)=im_bin(x,y);
%                     im_bin1(x,y)=im_gray(x,y);
                    im_bin2(x,y)=1;
                end;
            end;
        end;
    end;
end;

figure
imshow(im_bin1);
title('ROI');
% imshow(im_bin1,[0 255]);
% figure
% imshow(im_bin2);
imwrite(im_bin1,"obraz_roi.png");
imwrite(im_bin2,"roi.png");

%% zamkniecie
% wykorzystane w celu pozbycia sie pojedynczych czarnych pixeli na pasach

SE=strel('square',3);
im_bin3=imdilate(im_bin1,SE);
im_bin3=imerode(im_bin3,SE);

% figure 
% imshow(im_bin3);

% im_bin3=imerode(im_bin3,SE);
% im_bin3=imdilate(im_bin3,SE);

figure 
imshow(im_bin3);
title('Zamkniecie');
% im_bin3=im_bin1

%%  LMPS
% Detekcja pasów ruchu i usuniecie elementów nie nalezacych do pasow jezdni.

im_bin4=zeros(h,w);
for x=1:h
    if x>h/2
        threshold_up=(((x-h/2)*62)/h)+(w/90);
        treshold_down=(((x-h/2)*20)/h)+(w/400);
    else
        treshold_down=0;
        threshold_up=0;
    end;
    szerokosc_rysowaniej_linii=0.008*w;
    grubosc_linii=0;
    szerokosc_narysowanej_linii=0;
    flaga_rysowania_linii=0;
    for y=1:w
        
%        if x==1
%            flaga_rysowania_linii=0;
%            szerokosc_narysowanej_linii=0;
%            grubosc_linii=0;
%        end;
       if im_bin3(x,y)==1
           grubosc_linii=grubosc_linii+1;
       else
           if grubosc_linii>treshold_down && grubosc_linii<threshold_up
               flaga_rysowania_linii=1;
           end;
           grubosc_linii=0;
       end;
       if flaga_rysowania_linii==1
           szerokosc_narysowanej_linii=szerokosc_narysowanej_linii+1;
           im_bin4(x,y)=1;
       end;
       if szerokosc_rysowaniej_linii<szerokosc_narysowanej_linii
           flaga_rysowania_linii=0;
           szerokosc_narysowanej_linii=0;
       end;
    end;
    
end;

figure
imshow(im_bin4);
title('LMPS');
imwrite(im_bin4,"obraz_lmps.png");

%% otwarcie 
% wykorzystane w celu pozbycia sie pojedynczych paskow bialych pikseli.
% 
% SE=strel('square',3);
% % im_bin5=imdilate(im_bin4,SE);
% % im_bin5=imerode(im_bin5,SE);
% 
% % figure 
% % imshow(im_bin5);
% 
% im_bin5=imerode(im_bin4,SE);
% im_bin5=imdilate(im_bin5,SE);
% 
% figure 
% imshow(im_bin5);
% title('Otwarcie');
% % im_bin3=uint8(im_bin3);
% imwrite(im_bin5,"test_2.png");

im_bin5=im_bin4;

%% srodki ciezkosci
m00=[0 0 0 0];
m01=[0 0 0 0];
m10=[0 0 0 0];
n00=[0 0 0 0]; 
n01=[0 0 0 0]; 
n10=[0 0 0 0];

for x=1:h
    for y=1:w
        if y<w/2
            if (x>h/2) && (x<=h*5/8)
                m00(1)=m00(1)+im_bin5(x,y);
                m01(1)=m01(1)+im_bin5(x,y)*y;
                m10(1)=m10(1)+im_bin5(x,y)*x;
            elseif (x>h*5/8) && (x<=h*3/4)
                m00(2)=m00(2)+im_bin5(x,y);
                m01(2)=m01(2)+im_bin5(x,y)*y;
                m10(2)=m10(2)+im_bin5(x,y)*x;
            elseif (x>h*3/4) && (x<=h*7/8)
                m00(3)=m00(3)+im_bin5(x,y);
                m01(3)=m01(3)+im_bin5(x,y)*y;
                m10(3)=m10(3)+im_bin5(x,y)*x;
            elseif (x>h*7/8)
                m00(4)=m00(4)+im_bin5(x,y);
                m01(4)=m01(4)+im_bin5(x,y)*y;
                m10(4)=m10(4)+im_bin5(x,y)*x;
            end;
        else
            if (x>h/2) && (x<=h*5/8)
                n00(1)=n00(1)+im_bin5(x,y);
                n01(1)=n01(1)+im_bin5(x,y)*y;
                n10(1)=n10(1)+im_bin5(x,y)*x;
            elseif (x>h*5/8) && (x<=h*3/4)
                n00(2)=n00(2)+im_bin5(x,y);
                n01(2)=n01(2)+im_bin5(x,y)*y;
                n10(2)=n10(2)+im_bin5(x,y)*x;
            elseif (x>h*3/4) && (x<=h*7/8)
                n00(3)=n00(3)+im_bin5(x,y);
                n01(3)=n01(3)+im_bin5(x,y)*y;
                n10(3)=n10(3)+im_bin5(x,y)*x;
            elseif (x>h*7/8)
                n00(4)=n00(4)+im_bin5(x,y);
                n01(4)=n01(4)+im_bin5(x,y)*y;
                n10(4)=n10(4)+im_bin5(x,y)*x;
            end;
        end;
        
    end;
end;

l=0;
r=0;
for i=1:4
    if m00(i)~=0 
        l=l+1;
        Xl(l)=floor(m10(i)/m00(i));
        Yl(l)=floor(m01(i)/m00(i));
    end
    if n00(i)~=0
        r=r+1;
        Xr(r)=floor(n10(i)/n00(i));
        Yr(r)=floor(n01(i)/n00(i));
    end
end



b=floor(h/2):1:h;

figure
% imshow(im_gray,[0 255]);
imshow(im);
hold on
if l>1
    vq1=interp1(Xl,Yl,b,'spline');
    plot(vq1,b,'b','LineWidth',2);
end
if r>1
    vq2=interp1(Xr,Yr,b,'spline');
    plot(vq2,b,'g','LineWidth',2);
end
plot(Yl,Xl,'bs',...
    'MarkerSize',8,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor','r');
plot(Yr,Xr,'gs',...
    'MarkerSize',8,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor','r');
hold off

% figure
% imshow(im_bin5)
% hold on
% plot([1 w],[h/2 h/2],'red');
% plot([1 w],[h*5/8 h*5/8],'red');
% plot([1 w],[h*3/4 h*3/4],'red');
% plot([1 w],[h*7/8 h*7/8],'red');
% plot([w/2 w/2],[h/2 h],'red');
% hold off

