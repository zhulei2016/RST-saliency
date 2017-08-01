function e = ChangeEdges(e, a, b, c)
% This function replaces in the edge list 'e' the merged blobs a and b with
% their fusion 'c'.

for i = 1:size(e,1)
    if (e(i,1) == a)
        e(i,1) = e(i,2);
        e(i,2) = c;
    end
    
    if (e(i,2) == a)
        e(i,2) = c;
    end
    
    if (e(i,1) == b)
        e(i,1) = e(i,2);
        e(i,2) = c;
    end
    
    if (e(i,2) == b)
        e(i,2) = c;
    end
end

e = unique(e,'rows');       
        