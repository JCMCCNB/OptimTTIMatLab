function TTI = getTTI(P, DTI)

global Profiles

vTTI = eval(['Profiles.',P,'.TTI']);
vDTI = eval(['Profiles.',P,'.DTI']);

ind = find(vDTI == DTI, 1);

if isempty(ind)
    TTI = vTTI(find(abs(vDTI-DTI) == min(abs(vDTI - DTI)),1,'last'));
else
    TTI = vTTI(ind);
end


end