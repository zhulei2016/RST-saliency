function out = BoxResize(in, f)
% out = BoxResize(in, f)
%
% Resize the boxes by a factor f

[nR nC] = BoxSize(in);

newR = f .* nR;
newC = f .* nC;

addR = round((newR - nR) ./ 2);
addC = round((newC - nC) ./ 2);

% For too small factor, only happens when even number
addR(addR * -2 == nR) = addR(addR * -2 == nR) + 1;
addC(addC * -2 == nC) = addC(addC * -2 == nC) + 1;

addBox = [-addR -addC addR addC];

out = in + addBox;