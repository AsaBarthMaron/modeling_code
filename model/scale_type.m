function adjMat = scale_type(adjMat, typeScalar, typeInds)
% typeInds      - Cell of format {xInds, yInds}. Can specify all (:) for
%                 either yInds (all outputs of xInds) or xInds (all inputs
%                 to yInds).
   adjMat(typeInds{1}, typeInds{2}) = adjMat(typeInds{1}, typeInds{2}) .* typeScalar;
end