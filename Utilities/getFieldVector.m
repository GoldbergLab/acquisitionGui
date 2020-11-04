function fieldVector=getFieldVector(handles,field)

fieldVector = [];
for k = 1:size(handles,2)
    fieldVector(k) = getfield(handles, {1,k}, field);
end