close all; clearvars -except allMiceData mouseMat
filteredDat = mouseMat;

list = {'155','160','192','222','123','136','159','160b','161','144','145','142' };
for a = 1:length(list)
    turnL =[];
    oneMouse = allMiceData{a, 1}  ;
%     oneMouse = oneMouse(oneMouse(:,8)==0);
    
    figure(a)
    
    orDiff = abs(oneMouse(:,8)) - abs(oneMouse(:,9));
   unordif = unique(orDiff);
   
   %% weird -10 trials
   oneMouse(abs(orDiff)==10,:) = [];
   orDiff(abs(orDiff)==10,:) = [];
   
      unordif = unique(orDiff)

    for aa = 1: length(unordif)
        
        diffInd = find(orDiff == unordif(aa));
       
        
        turnL(aa) = length(find(oneMouse(diffInd,7) == -1))/length(oneMouse(diffInd,7));
        
        oneMouse(diffInd,7);
        
        
    end
    
    plot(turnL)
    ylim([0 1])
    xticks(1:length(unordif))
    xticklabels(unordif)
    yline(0.5)
    xline(round(length(unordif)/2))
    title([list{a},' perc correct = ' num2str(100*mean(oneMouse(:,2)))])
    
    ylabel('proportion L')
    xlabel('L-R angle')
    
end