%% PDF FOR ORIENTATIoNS
clear all
% close all
x = 0:(pi/18):(pi-pi/18);
y = sin(2*x-(pi/2))*2+2.2;
% figure
% plot (x,y)
y_int = trapz(y)
y_prob = y/y_int;

x_deg = 0:10:170;
subplot(2,1,1)
plot (x_deg,y_prob)

tims = round(y_prob*200)
sum tims
ref = [];
for i = 1:18
    
    ref = [ref, repmat(x_deg(i),1, tims(i))];
    
end
alles = [];
for x = 1:10
    targ = ref + 15+rand*30;
    
    all = [targ,ref];
    
    all(all>=180) = all(all>=180)-180;
    all(all<0) = all(all<0)+180;
    
%     histogram(all,72)

alles = [alles,all];

end
subplot(2,1,2)
hist(alles,18)
