function DTI = getDTI(P, RT90x, RT90y)

global Profiles

vRT90x = eval(['Profiles.',P,'.RT90x']);
vRT90y = eval(['Profiles.',P,'.RT90y']);

vDist = sqrt((vRT90x-RT90x).^2+(vRT90y-RT90y).^2);

ind = find(vDist == min(vDist), 1);

DTI = eval(['Profiles.',P,'.DTI(',num2str(ind),')']);

end