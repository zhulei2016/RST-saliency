% calculate the mean and variance of arbitery windows as well as its surroundings of an image using
% integral image computation
function [avg_c, var_c, avg_s, var_s] = calcMeanandVariance_cs(I, gridx, gridy, patchSize, surrWidth, varFlag)

[imh, imw, imc] = size(I);
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

avg_c = zeros(length(gridx), imc);
var_c = zeros(length(gridx), imc);
avg_s = zeros(length(gridx), imc);
var_s = zeros(length(gridx), imc);

num_c = patchSize(1) * patchSize(2);
num_s = (xs_tr - (gridx_s + 1) + 1) .* (ys_bl - (gridy_s + 1) + 1) - num_c;

for i = 1 : imc,
    I_d = I(:, :, i);
    % compute integral image
    %     I_int = integralImage(I_d);
    %     if varFlag == 1,
    %         I_int2 = integralImage(I_d.*I_d);
    %     end
    I_int = cumsum(cumsum(I_d, 2), 1);  % for previous matlab version
    I_int = padarray(I_int,[1 1],'pre');
    if varFlag == 1,
        I_int2 = cumsum(cumsum(I_d.*I_d, 2), 1);
        I_int2 = padarray(I_int2,[1 1],'pre');
    end
    % for center regions
    s1_c = I_int(a_c) + I_int(d_c) - I_int(b_c) - I_int(c_c);
    avg_c(:, i) = s1_c / num_c;
    if varFlag == 1,
        s2_c = I_int2(a_c) + I_int2(d_c) - I_int2(b_c) - I_int2(c_c);
        v_c = s2_c / num_c;
        var_c(:, i) = v_c-(avg_c(:, i).*avg_c(:, i));
    else
        var_c = [];
    end
    % for surrounding regions
    s1_s = I_int(a_s) + I_int(d_s) - I_int(b_s) - I_int(c_s);
    avg_s(:, i) = (s1_s - s1_c) ./ num_s;
    if varFlag == 1,
        s2_s = I_int2(a_s) + I_int2(d_s) - I_int2(b_s) - I_int2(c_s);
        v_s = (s2_s - s2_c) ./ num_s;
        var_s(:, i) = v_s-(avg_s(:, i).*avg_s(:, i));
    else
        var_s = [];
    end
end

% xc_tl = gridx;
% yc_tl = gridy;
% xc_br = gridx + patchSize(1) - 1;
% yc_br = gridy + patchSize(2) - 1;
% 
% xs_tl = max(1, gridx - surrWidth + 1);
% ys_tl = max(1, gridy - surrWidth + 1);
% xs_br = min(imw, gridx + patchSize(1) - 1 + surrWidth);
% ys_br = min(imh, gridy + patchSize(2) - 1 + surrWidth);
% 
% imsz = imh * imw;
% m = zeros(length(gridx), 3); s = zeros(length(gridx), 3);
% for i = 1 : length(gridx),
%     [x_cent,y_cent] = meshgrid(xc_tl(i) : xc_br(i), yc_tl(i) : yc_br(i));
%     [x_surr,y_surr] = meshgrid(xs_tl(i) : xs_br(i), ys_tl(i) : ys_br(i));
%     
%     pix_cent = (x_cent - 1) * imh + y_cent;
%     pix_surr = (x_surr - 1) * imh + y_surr;
%     pix_surr = setdiff(pix_surr, pix_cent);
%     
%     m(i, 1) = mean( I(pix_surr) );   s(i, 1) = std(I(pix_surr),1 )^2;
%     m(i, 2) = mean(I(pix_surr + imsz) );   s(i, 2) = std(I(pix_surr + imsz),1 )^2;
%     m(i, 3) = mean(I(pix_surr + imsz * 2) ); s(i, 3) = std(I(pix_surr + imsz * 2),1 )^2;
%     
% end
% ttt = var_s(:, 1 : 3) - s;

