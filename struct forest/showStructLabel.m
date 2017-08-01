function showStructLabel( slabel)
for j = 1 : pixNum,
    segs_pertree = slabel(:,:, j, :);
    figure(i);
    montage2(segs_pertree * 255);
end
end

