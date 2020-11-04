function a = getArrayFromCellArray(c, fieldname)
for(i = 1:length(c))
    a(i) = c{i}.(fieldname);
end
