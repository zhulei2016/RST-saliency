% calculate the mean and variance of arbitery windows using integral image computation
function [avg_c, var_c] = calcVariance(I, gridx, gridy, patchSize)
% if isdouble(I), Ip = I; else Ip = double(I); end
Ip = double(I);
[imh, ~, imc] = size(Ip);
% coordinates of center pixels for computing regional sum in integral image(cannot overflow)
a_c = (gridx - 1) * (imh + 1) + gridy; % sR,sC
b_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy; % sR,eC+1
c_c = (gridx - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,sC
d_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,eC+1

avg_c = zeros(length(gridx), imc);
var_c = zeros(length(gridx), imc);
num_c = patchSize(1) * patchSize(2);
for i = 1 : imc,
    I_d = Ip(:, :, i);
    % compute integral image
    %     I_int = integralImage(I_d);
    %     if varFlag == 1,
    %         I_int2 = integralImage(I_d.*I_d);
    %     end
    I_int = cumsum(cumsum(I_d, 2), 1);  % for previous matlab version
    I_int = padarray(I_int,[1 1],'pre');
    I_int2 = cumsum(cumsum(I_d.*I_d, 2), 1);
    I_int2 = padarray(I_int2,[1 1],'pre');
    % for center regions
    s1_c = I_int(a_c) + I_int(d_c) - I_int(b_c) - I_int(c_c);
    avg_c(:, i) = s1_c / num_c;
    s2_c = I_int2(a_c) + I_int2(d_c) - I_int2(b_c) - I_int2(c_c);
    v_c = s2_c / num_c;
    var_c(:, i) = v_c-(avg_c(:, i).*avg_c(:, i));
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
% for i = 1 : length(gridx),
%     [x_cent,y_cent] = meshgrid(xc_tl(i) : xc_br(i), yc_tl(i) : yc_br(i));
%     [x_surr,y_surr] = meshgrid(xs_tl(i) : xs_br(i), ys_tl(i) : ys_br(i));
%
%     pix_cent = (x_cent - 1) * imh + y_cent;
%     pix_surr = (x_surr - 1) * imh + y_surr;
%     pix_surr = setdiff(pix_surr, pix_cent);
%
%     m(1) = mean( I(pix_surr) );   s(1) = std(I(pix_surr) )^2;
%     m(2) = mean(I(pix_surr + imsz) );   s(2) = std(I(pix_surr + imsz) )^2;
%     m(3) = mean(I(pix_surr + imsz * 2) ); s(3) = std(I(pix_surr + imsz * 2) )^2;
% end

