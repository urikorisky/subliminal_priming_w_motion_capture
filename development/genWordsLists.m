% For each stimuli word, generates a list of words that don't share common letters in same
% location with it.
% primes are from same category as distractors and can't share letters with it.
% targets are from different category from primes and can't share letters with it.
% Generates 4 lists:
%   art_primes - possible primes for each artificial distractor.
%   nat_primes - possible primes for each natural prime.
%   art_targets - possible targets for each natural prime.
%   nat_targets - possible targets for each artificial prime.
% Saves results to file.
function [] = genWordsLists()
    
    words = readtable('./stimuli/word_lists/word_freq_list.xlsx');
    words = words(:,[1,3]); % Remove word frequencies.
    nWords = height(words);
    % List all words. Later we eliminate bad words.
    nat_primes = cell2table(repmat(words.natural,1,nWords));
    art_primes = cell2table(repmat(words.artificial,1,nWords));
    art_targets = cell2table(repmat(words.artificial,1,nWords));
    nat_targets = cell2table(repmat(words.natural,1,nWords));
    
    for iWord = 1:height(words)
        % natural primes for each natural dist.
        share_letters = any(words.natural{iWord} == cell2mat(words.natural), 2);
        nat_primes(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % artificial primes for each artificial dist.
        share_letters = any(words.artificial{iWord} == cell2mat(words.artificial), 2);
        art_primes(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % artificial targets for each natural prime.
        share_letters = any(words.natural{iWord} == cell2mat(words.artificial), 2);
        art_targets(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % natural targets for each artificial prime.
        share_letters = any(words.artificial{iWord} == cell2mat(words.natural), 2);
        nat_targets(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
    end
    
    % Add Column headers.
    nat_primes = [words.natural' ; nat_primes];
    art_primes = [words.artificial' ; art_primes];
    art_targets = [words.natural' ; art_targets];
    nat_targets = [words.artificial' ; nat_targets];
    
    % Writes column headers and then fills columns.
    writetable(nat_primes,'./stimuli/word_lists/nat_primes.xlsx', 'WriteVariableNames',0);
    writetable(art_primes,'./stimuli/word_lists/art_primes.xlsx', 'WriteVariableNames',0);
    writetable(art_targets,'./stimuli/word_lists/art_targets.xlsx', 'WriteVariableNames',0);
    writetable(nat_targets,'./stimuli/word_lists/nat_targets.xlsx', 'WriteVariableNames',0);
end