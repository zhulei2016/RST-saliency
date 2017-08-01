% calculate the mean and variance of arbitery windows as well as its surroundings of an image using
% integral image computation
function [avg_c, var_c, avg_s, var_s] = intMeanStd(I, c, s, num_c, num_s, varFlag)
imc = size(I, 3); nPix = size(c, 1);
a_c = c(:, 1); b_c = c(:, 2); c_c = c(:, 3); d_c = c(:, 4);
a_s = s(:, 1); b_s = s(:, 2); c_s = s(:, 3); d_s = s(:, 4);
avg_c = zeros(nPix, imc); var_c = zeros(nPix, imc);
avg_s = zeros(nPix, imc); var_s = zeros(nPix, imc);

for i = 1 : imc
    I_d = I(:, :, i);
    % compute integral image
    %     I_int = integralImage(I_d);
    %     if varFlag == 1,
    %         I_int2 = integralImage(I_d.*I_d);
    %     end
    I_int = cumsum(cumsum(I_d, 2), 1);  % for previous matlab version
    I_int = padarray(I_int,[1 1],'pre');
    if varFlag == 1
        I_int2 = cumsum(cumsum(I_d.*I_d, 2), 1);
        I_int2 = padarray(I_int2,[1 1],'pre');
    end
    % for center regions
    s1_c = I_int(a_c) + I_int(d_c) - I_int(b_c) - I_int(c_c);
    avg_c(:, i) = s1_c / num_c;
    if varFlag == 1
        s2_c = I_int2(a_c) + I_int2(d_c) - I_int2(b_c) - I_int2(c_c);
        v_c = s2_c / num_c;
        var_c(:, i) = v_c-(avg_c(:, i).*avg_c(:, i));
    else
        var_c = [];
    end
    % for surrounding regions
    s1_s = I_int(a_s) + I_int(d_s) - I_int(b_s) - I_int(c_s);
    avg_s(:, i) = (s1_s - s1_c) ./ num_s;
    if varFlag == 1
        s2_s = I_int2(a_s) + I_int2(d_s) - I_int2(b_s) - I_int2(c_s);
        v_s = (s2_s - s2_c) ./ num_s;
        var_s(:, i) = v_s-(avg_s(:, i).*avg_s(:, i));
    else
        var_s = [];
    end
end
var_c = abs(sqrt(var_c));
var_s = abs(sqrt(var_s));

