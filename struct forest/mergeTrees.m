%% merge trained trees to a single output
function model = mergeTrees( opts )
% accumulate trees and merge into final model
nTrees=opts.nTrees; 
gtWidth=opts.gtWidth;
treeFn = [opts.modelDir 'tree/' opts.modelFnm '_tree'];
for i=1:nTrees
    t=load([treeFn int2str2(i,3) '.mat'],'tree'); 
    t=t.tree;
    if(i==1), 
        trees=t(ones(1,nTrees)); 
    else
        trees(i)=t; 
    end
end
nNodes=0; 
for i=1:nTrees, 
    nNodes=max(nNodes,size(trees(i).fids,1)); 
end
% merge all fields of all trees
model.opts=opts; 
Z=zeros(nNodes,nTrees,'uint32');
model.thrs=zeros(nNodes,nTrees,'single');
model.fids=Z; 
model.child=Z; 
model.count=Z; 
model.depth=Z;
model.segs=zeros(gtWidth,gtWidth,nNodes,nTrees,'uint8');
for i=1:nTrees, 
    tree=trees(i); 
    nNodes1=size(tree.fids,1);
    model.fids(1:nNodes1,i) = tree.fids;
    model.thrs(1:nNodes1,i) = tree.thrs;
    model.child(1:nNodes1,i) = tree.child;
    model.count(1:nNodes1,i) = tree.count;
    model.depth(1:nNodes1,i) = tree.depth;
    %     model.segs(:,:,1:nNodes1,i) = tree.hs-1;
    model.segs(:,:,1:nNodes1,i) = tree.hs;
end
% remove very small segments (<=5 pixels)
segs=model.segs;
nSegs=squeeze(max(max(segs)))+1;

% % parfor i=1:nTrees*nNodes,
% for i=1:nTrees*nNodes,
%     % for i=1:nTrees*nNodes,
%     m=nSegs(i);
%     if(m==1), continue; end;
%     S=segs(:,:,i);
%     del=0;
%     for j=1:m,
%         Sj=(S==j-1);
%         if(nnz(Sj)>5), continue; end
%         S(Sj)=median(single(S(convTri(single(Sj),1)>0)));
%         del=1;
%     end
%     if(del),
%         [~,~,S]=unique(S);
%         S=reshape(S-1,gtWidth,gtWidth);
%         segs(:,:,i)=S;
%         nSegs(i)=max(S(:))+1;
%     end
% end
% model.segs=segs; 

model.nSegs=nSegs;

% % store compact representations of sparse binary edge patches
% nBnds=opts.sharpen+1; 
% eBins=cell(nTrees*nNodes,nBnds);
% eBnds=zeros(nNodes*nTrees,nBnds);
% % parfor i=1:nTrees*nNodes,
%     for i=1:nTrees*nNodes,
%     if(model.child(i) || model.nSegs(i)==1), % only for leaf node with >1 segments
%         continue;
%     end %#ok<PFBNS>
%     E=gradientMag(single(model.segs(:,:,i)))>.01;
%     E0=0;
%     for j=1:nBnds,
%         eBins{i,j}=uint16(find(E & ~E0)'-1);
% %         is = E & ~E0;
% %         is = imresize(is, 16);
% %         imagesc(is);
%         E0=E;
%         eBnds(i,j)=length(eBins{i,j});
%         E=convTri(single(E),1)>.01;
%     end
% end
% eBins=eBins'; 
% model.eBins=[eBins{:}]';
% eBnds=eBnds'; 
% model.eBnds=uint32([0; cumsum(eBnds(:))]);
end