function p = plotHistPatch(edges, n)
%edges and n should from histc, the are the same length because
%the last value of n containes the number of values that equal the
%last value of edges.

if(size(edges,1) > size(edges,2))
    edges = edges';
end
x = [edges;edges]; x=x(:); x = [x;edges(end);edges(end)];

if(size(n,1) > size(n,2))
    n = n';
end
y = [n;n]; y=y(:); y = [0;y;0];

p = patch(x,y,[0,0,1]);
