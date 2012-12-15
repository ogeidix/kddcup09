function [Xmissingcount,levels,lcounts,Xcate_clean_f,ntotal] = proCate1(X,thresh,Xmissingcountlast,levelslast,lcountslast,nlast)
% this fucntion supports continuous process for data chunks, by setting the
% parameters with last compute results.

% thresh:  minimum filling rate criteria to include a feature
% Xmissingcountlast: missing records numbers from last computing per feature
% nlast: total number of records from last computing

%keep maxf large for multiple chunks.
maxf=16000;


[n,k]=size(X);
if (nargin < 2) thresh=.6;XmissingCountast=zeros(1,k);levelslast=ones(maxf,k).*0;lcountslast=zeros(maxf,k);nlast=0; end;
if (nargin < 3) Xmissingcountlast=zeros(1,k);levelslast=ones(maxf,k).*0;lcountslast=zeros(maxf,k);nlast=0;  end;

Xmissingcount=sum(X==0)+Xmissingcountlast;
ntotal=n+nlast;
for f=1:k
    fordinal=ordinal(X(:,f));
    [countf,levelf]=hist(fordinal);    
%     sizelf=size(levelf,2);
%     convert ordinal to number
    levelfn=str2num(char(levelf));
%     merge levels , counts
    [levelfnmerge,a,c]=unique([levelfn;levelslast(:,f)]);
    levelfnmerge(c);
    countf=[countf';lcountslast(:,f)];
    countfmerge=zeros(length(a),1);
    for i=1:length(c);
        countfmerge(c(i))=countfmerge(c(i))+countf(i);
    end;
    
    sizelf=size(levelfnmerge,1);
    
    if sizelf>=maxf
        levels(:,f)=levelfnmerge(1:maxf,1);
        lcounts(:,f)=countfmerge(1:maxf,1);
    else
%       fill additional naan levels with 0
        fillings=ones(maxf-sizelf,1).*0;
        lcounts(:,f)=[countfmerge;fillings.*0];
        levels(:,f)=[levelfnmerge;fillings];
    end;       
end;

% current clean numerical features
XfillingRate=1-Xmissingcount./ntotal;
f=[1:k];
Xcate_clean_f=f(XfillingRate>thresh);
bar(XfillingRate(Xcate_clean_f)); title('Good feature');
end

