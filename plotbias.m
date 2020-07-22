close all; clearvars -except allMiceData mouseMat
filteredDat = mouseMat;

list = {'155' '160' '192' '123' '222' '137' '159' '160b' '161' '144' '136' '145' '142' };
for a = 1:length(unique(filteredDat(:,1)))
    turnL =[];
    oneMouse = allMiceData{a, 1}  ;
%     oneMouse = oneMouse(oneMouse(:,8)==0);
    
    figure(a)
    
    orDiff = abs(oneMouse(:,11)) - abs(oneMouse(:,12));
   unordif = unique(orDiff);
   
   %% weird -10 trials
   oneMouse(abs(orDiff)==10,:) = [];
   orDiff(abs(orDiff)==10,:) = [];
      unordif = unique(orDiff)

    for aa = 1: length(unordif)
        
        diffInd = find(orDiff == unordif(aa));
       
        
        turnL(aa) = length(find(oneMouse(diffInd,6) == -1))/length(oneMouse(diffInd,6));
        
        oneMouse(diffInd,6);
        
        
    end
    
    plot(turnL)
    ylim([0 1])
    xticks(1:length(unordif))
    xticklabels(unordif)
    yline(0.5)
    xline(round(length(unordif)/2))
    title([list{a},' perc correct = ' num2str(100*mean(oneMouse(:,3)))])
    
    ylabel('proportion L')
    xlabel('L-R angle')
    
end