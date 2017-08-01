% calculate the mean and variance of arbitery windows using integral image computation
function locSum = calcLocSum(I, gridx, gridy, patchSize)
% if isdouble(I), Ip = I; else Ip = double(I); end
Ip = double(I);
[imh, ~, imc] = size(Ip);
% coordinates of center pixels for computing regional sum in integral image(cannot overflow)
a_c = (gridx - 1) * (imh + 1) + gridy; % sR,sC
b_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy; % sR,eC+1
c_c = (gridx - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,sC
d_c = (gridx + patchSize(1) - 1) * (imh + 1) + gridy + patchSize(2); % eR+1,eC+1

locSum = zeros(length(gridx), imc);
for i = 1 : imc,
    I_d = Ip(:, :, i);
    % compute integral image
    %     I_int = integralImage(I_d);
    %     if varFlag == 1,
    %         I_int2 = integralImage(I_d.*I_d);
    %     end
    I_int = cumsum(cumsum(I_d, 2), 1);  % for previous matlab version
    I_int = padarray(I_int,[1 1],'pre');
    % for center regions
    locSum(:, i) = I_int(a_c) + I_int(d_c) - I_int(b_c) - I_int(c_c);
end

