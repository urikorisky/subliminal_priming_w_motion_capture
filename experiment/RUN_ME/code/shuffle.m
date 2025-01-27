% Gets trials of 1 block and shuffles them so no prime/target repeats consequetivly.
function block = shuffle(block)
    conseq = 1;
    while conseq == 1
        conseq = 0;
        block = block(randperm(height(block)), :); % shuffle block.
        for i = 2:height(block)
            if (strcmp(block.prime{i}, block.prime{i-1}) ||...
                strcmp(block.prime{i}, block.target{i-1}) ||...
                strcmp(block.prime{i}, block.distractor{i-1}) ||...
                strcmp(block.target{i}, block.target{i-1}) ||...
                strcmp(block.target{i}, block.prime{i-1}) ||...
                strcmp(block.target{i}, block.distractor{i-1}) ||...
                strcmp(block.distractor{i}, block.distractor{i-1}) ||...
                strcmp(block.distractor{i}, block.prime{i-1}) ||...
                strcmp(block.distractor{i}, block.target{i-1}))
            
                conseq = 1;
                break;
            end
        end
    end
end