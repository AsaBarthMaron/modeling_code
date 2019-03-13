function scale_cons(m, scalar)
%   scalar.ORNtoLNPN
%   scalar.PNtoLNPN
%   scalar.LNtoLNPN
%   scalar.ORNtoORN
%   scalar.LNtoORN
%   scalar.PNtoORN
%   scalar.ORN         % Should not be done in combination with ORNtoLNPN, ORN-ORN
%   scalar.LN          % Should not be done in combination with LNtoLNPN, LN-ORN
%   scalar.PN          % Should not be done in combination with PNtoLNPN, PN-ORN

nNs = length(m.KernType);
% This mostly functions off param.scale_type

% Connection indices - Should automate this, is easy to do
ind.ORNtoLNPN = {m.TypeInds.orn, [m.TypeInds.ln, m.TypeInds.pn]};
ind.PNtoLNPN = {m.TypeInds.pn, [m.TypeInds.ln, m.TypeInds.pn]};
ind.LNtoLNPN = {m.TypeInds.ln, [m.TypeInds.ln, m.TypeInds.pn]};
ind.ORNtoORN = {m.TypeInds.orn, m.TypeInds.orn};
ind.LNtoORN = {m.TypeInds.ln, m.TypeInds.orn};
ind.PNtoORN = {m.TypeInds.pn, m.TypeInds.orn};
ind.LN = {m.TypeInds.ln, 1:nNs};
ind.PN = {m.TypeInds.pn, 1:nNs};
ind.ORN = {m.TypeInds.orn, 1:nNs};


% Get 'scalar' fieldnames
fields = fieldnames(scalar);

% Adjust adjacency matrix weights 
for fn = fields'
    if scalar.(fn{1}) ~= 1
        % Be careful, it is possible to double scale certain connections.
        % e.g., scaling both 'scalar.LN' and 'scalar.LNtoPN'
        m.AdjMat = scale_type(m.AdjMat, scalar.(fn{1}), ind.(fn{1}));
    end
end
end

 