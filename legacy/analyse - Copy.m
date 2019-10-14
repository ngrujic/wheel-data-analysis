

for i =1:length(block.paramsValues)-1
    
    target_orient(i) =  block.paramsValues(i).stimulusOrientation(1);
    spinner_increment(i) = block.paramsValues(i).stimulusOrientation(1)-block.paramsValues(i).stimulusOrientation(2);
    
end

targets = sort(abs(unique(target_orient)));
spinners = sort(abs(unique(spinner_increment)));
spinners(1) = [];

session_correct = block.events.feedbackValues;
session_responses = block.events.responseValues;

for i = 1:length(targets)
    for ii = 1:length(spinners)
        
        currTarg = targets(i);
        currSpin = spinners(ii);
        
        hit_ind{i,ii} = find(target_orient == currTarg & spinner_increment == currSpin & session_correct == 1);
       miss_ind{i,ii} = find(target_orient == currTarg & spinner_increment == currSpin & session_correct == 0);
        nHIT(i,ii) = sum(target_orient == currTarg & spinner_increment == currSpin & session_correct == 1);
       nMISS(i,ii) = sum(target_orient == currTarg & spinner_increment == currSpin & session_correct == 0);
       
    end
    
    fa_ind{i} = find(target_orient == currTarg & spinner_increment == 0 & session_correct == 0);
    cr_ind{i} = find(target_orient == currTarg & spinner_increment == 0 & session_correct == 1);
    nFA(i) = sum(target_orient == currTarg & spinner_increment == 0 & session_correct == 0);
    nCR(i) = sum(target_orient == currTarg & spinner_increment == 0 & session_correct == 1);
  
    
    
    hitRate = nHIT/(nHIT + nMISS);
     faRate = nFA/(nFA + nCR);
    
    
end

