mignsx = 8;
migosx = 4;
migdsx = 1;

mignsy = 8;
migosy = 7;
migdsy = 1;

nmig = mignsx*mignsy;

xshot=migosx:migdsx:migosx+mignsx*migdsx;
yshot=migosy:migdsy:migosy+mignsy*migdsy;

ShotsList = zeros(nmig,1);
XLines = zeros(nmig,1);
YLines = zeros(nmig,1);
CurrentShot = 1;

for isx = 1:mignsx
    for isy = 1:mignsy
        xline = 9+2*xshot(isx)-1;
        XLines(CurrentShot) = xline;
        yline = 9+2*yshot(isy)-1;
        YLines(CurrentShot) = yline;
        
        N=1+20+4*(yline-2)+(20+4*(xline-2))*267;
        
        ShotsList(CurrentShot) = N;
        CurrentShot = CurrentShot + 1;
    end
end
    

b = num2str(ShotsList); c = cellstr(b);

dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points

plot(XLines,YLines,'x');
text(XLines+dx, YLines+dy, c);
axis([12 35 12 45]);
