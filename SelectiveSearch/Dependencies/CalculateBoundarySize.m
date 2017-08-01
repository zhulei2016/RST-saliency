function boundary = CalculateBoundarySize(aa, bb)
% boundary = CalculateBoundarySize(a,b) calculates the size of the boundary
% between blob a and blob b
%
% Faster version

% Make sure a is the smaller blob
if (aa.borderSize > bb.borderSize)
    a = bb;
    b = aa;
else
    a = aa;
    b = bb;
end

% Get the bounding rectangle for the intersection of a and b. We actually
% need a bounding rectangle which adds 1 to each border for if we have two
% non-overlapping rectangles (but still a border).
boundingRect = [max(a.rect(1), b.rect(1))-1, max(a.rect(2), b.rect(2))-1, ...
                 min(a.rect(3), b.rect(3))+1, min(a.rect(4), b.rect(4))+1];
             
%%% Construct boundMaskA
boundMask = zeros(boundingRect(3) - boundingRect(1) + 1, ...
                   boundingRect(4) - boundingRect(2) + 1);

rB = boundingRect(1) - a.rect(1) + 1;
if (rB == 0)
    rB = 1;
    rBZ = 2;
else
    rBZ = 1;
end

rE = boundingRect(3) - a.rect(1) + 1;
if (rE == size(a.mask, 1) + 1)
    rE = size(a.mask,1);
    rEZ = 1;
else
    rEZ = 0;
end

cB = boundingRect(2) - a.rect(2) + 1;
if (cB == 0)
    cB = 1;
    cBZ = 2;
else
    cBZ = 1;
end

cE = boundingRect(4) - a.rect(2) + 1;
if (cE == size(a.mask,2) + 1)
    cE = size(a.mask,2);
    cEZ = 1;
else
    cEZ = 0;
end

boundMask(rBZ:end-rEZ, cBZ:end-cEZ) = a.mask(rB:rE,cB:cE);
    
rB = boundingRect(1) - b.rect(1) + 1;
if (rB == 0)
    rB = 1;
    rBZ = 2;
else
    rBZ = 1;
end

rE = boundingRect(3) - b.rect(1) + 1;
if (rE == size(b.mask, 1) + 1)
    rE = size(b.mask,1);
    rEZ = 1;
else
    rEZ = 0;
end

cB = boundingRect(2) - b.rect(2) + 1;
if (cB == 0)
    cB = 1;
    cBZ = 2;
else
    cBZ = 1;
end

cE = boundingRect(4) - b.rect(2) + 1;
if (cE == size(b.mask,2) + 1)
    cE = size(b.mask,2);
    cEZ = 1;
else
    cEZ = 0;
end

boundMask(rBZ:end-rEZ, cBZ:end-cEZ) = boundMask(rBZ:end-rEZ, cBZ:end-cEZ) + 2 * b.mask(rB:rE,cB:cE);               

boundary = mexBoundarySize(boundMask);