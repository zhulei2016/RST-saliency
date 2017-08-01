function lab_img = slic_rgb2Lab(rgb_img)
%   rgb to XYZ
R = double(rgb_img(:, :, 1));
G = double(rgb_img(:, :, 2));
B = double(rgb_img(:, :, 3));

R = R / 255;
G = G / 255;
B = B / 255;

t = (R <= 0.04045); s = (R > 0.045);
R(t) = R(t) / 12.92;
R(s) = ((R(s) + 0.055) / 1.055) .^ 2.4;

t = (G <= 0.04045); s = (G > 0.045);
G(t) = G(t) / 12.92;
G(s) = ((G(s) + 0.055) / 1.055) .^ 2.4;

t = (B <= 0.04045); s = (B > 0.045);
B(t) = B(t) / 12.92;
B(s) = ((B(s) + 0.055) / 1.055) .^ 2.4;

X = R * 0.4124564 + G * 0.3575761 + B * 0.1804375;
Y = R * 0.2126729 + G * 0.7151522 + B * 0.0721750;
Z = R * 0.0193339 + G * 0.1191920 + B * 0.9503041;

epsilon = 0.008856;     %actual CIE standard
kappa   = 903.3;		%actual CIE standard
fa = 1.0 / 3.0;

Xr = 0.950456;          %reference white
Yr = 1.0;               %reference white
Zr = 1.088754;          %reference white

xr = X/Xr;
yr = Y/Yr;
zr = Z/Zr;


t = (xr > epsilon); s = (xr <= epsilon);
xr(t) = xr(t) .^ fa;
xr(s) = (xr(s) * kappa + 16.0) / 116;

t = (yr > epsilon); s = (yr <= epsilon);
yr(t) = yr(t) .^ fa;
yr(s) = (yr(s) * kappa + 16.0) / 116;

t = (zr > epsilon); s = (zr <= epsilon);
zr(t) = zr(t) .^ fa;
zr(s) = (zr(s) * kappa + 16.0) / 116;

lab_img = zeros(size(rgb_img));
lab_img(:, :, 1) = 116.0 * yr - 16.0;
lab_img(:, :, 2) = 500.0 * (xr - yr);
lab_img(:, :, 3) = 200.0 * (yr - zr);
end
