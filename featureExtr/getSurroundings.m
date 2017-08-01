function [c, s, num_c, num_s] = getSurroundings( gridx, gridy, imh, imw, patchSize, surrWidth )
% coordinates of center pixels for computing regional sum in integral image(cannot overflow)
a_c = (gridx - 1) * (imh + 1) + gridy; % sR,sC
b_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy; % sR,eC+1
c_c = (gridx - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,sC
d_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,eC+1

% coordinates of surrounding pixels for computing regional sum in integral image
gridx_s = max(1, gridx - surrWidth + 1);
gridy_s = max(1, gridy - surrWidth + 1);

xs_tr = min(imw + 1, gridx + patchSize(1) + surrWidth);
ys_bl = min(imh + 1, gridy + patchSize(2) + surrWidth);

a_s = (gridx_s - 1) * (imh + 1) + gridy_s;
b_s = (xs_tr - 1) * (imh + 1) + gridy_s;
c_s = (gridx_s - 1) * (imh + 1) + ys_bl;
d_s = (xs_tr - 1) * (imh + 1) + ys_bl;

num_c = patchSize(1) * patchSize(2);
num_s = (xs_tr - (gridx_s + 1) + 1) .* (ys_bl - (gridy_s + 1) + 1) - num_c;
c = [a_c, b_c, c_c, d_c];
s = [a_s, b_s, c_s, d_s];
end

