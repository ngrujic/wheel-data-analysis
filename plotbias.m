 clearvars -except allMiceData mouseMat
filteredDat = mouseMat;
figure
list = {'123' '222' '192' '155' '160' '144' '145' '136' '142' '159' '160b' '161'};
for a = 1:length(list)
    turnL =[];
    oneMouse = allMiceData{a, 1}  ;
%     oneMouse = oneMouse(oneMouse(:,8)==0);
    
    subplot(3,4,a)
    
    orDiff = abs(oneMouse(:,7)) - abs(oneMouse(:,8));
   unordif = unique(orDiff);
   
   %% weird -10 trials
   oneMouse(abs(orDiff)==10,:) = [];
   orDiff(abs(orDiff)==10,:) = [];
      unordif = unique(orDiff)

    for aa = 1: length(unordif)
        
        diffInd = find(orDiff == unordif(aa));
       
        
        turnL(aa) = length(find(oneMouse(diffInd,9) == -1))/length(oneMouse(diffInd,9));
        
        oneMouse(diffInd,6);
        
        
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