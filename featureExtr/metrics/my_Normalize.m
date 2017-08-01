function norm_A = my_Normalize(A, min_r, max_r)
B = double(A);
max_A = max(B(:));
min_A = min(B(:));
if max_A - min_A < eps,
    norm_A = B;
else
    norm_A = (B - min_A) / (max_A - min_A);
    norm_A = norm_A * (max_r - min_r) + min_r;
end
end