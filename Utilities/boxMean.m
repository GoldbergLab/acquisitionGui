function muM = boxMean(M, m, n);

%Take mean of mxn chunks of M.
mSyll = size(M,1)/m;
nSyll = size(M,2)/n;

mCollapse = eye(mSyll);
mCollapse = mCollapse(:,repmat(1:mSyll,m,1));

nCollapse = eye(nSyll);
nCollapse = nCollapse(repmat(1:nSyll,n,1),:);

muM = (mCollapse * M * nCollapse)./(m*n);