function [RT90y, RT90x] = getRT90(P, DTI)

global Profiles

vRT90x = eval(['Profiles.',P,'.RT90x']);
vRT90y = eval(['Profiles.',P,'.RT90y']);
vDTI = eval(['Profiles.',P,'.DTI']);

ind.min = find(vDTI<=DTI,1,'last');
ind.max = find(vDTI>=DTI,1,'first');

RT90x = interp1([vDTI(ind.min), vDTI(ind.max)], [vRT90x(ind.min), vRT90x(ind.max)], DTI);
RT90y = interp1([vDTI(ind.min), vDTI(ind.max)], [vRT90y(ind.min), vRT90y(ind.max)], DTI);

end