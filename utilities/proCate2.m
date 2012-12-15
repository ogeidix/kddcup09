function [Xce] = proCate2(Xc,Xcate_clean_f,levels,lcounts)
% this fucntion supports continuous process for data chunks, by setting the
% parameters with last compute results.
Xcshort=Xc(:,Xcate_clean_f);
[n,k]=size(Xcshort);
maxfea=9;

levelshort=ones(maxfea,k).*-1;
for i=1:k
    [numc,idxc]=sort(lcounts(:,Xcate_clean_f(i)),'descend');
    levelshort(:,i)=levels(idxc(1:maxfea),Xcate_clean_f(i));
end;

%create extended categorical X, with features represent missing and other 
% values all the way to the left. So the structure of Xce will be: 
% Xce=[feature1missing,feature2missing,..feature1othervalue, 
%     feature2othervalue,...feature1value1,feature1value2,...feature2value1,
%     feature2value2...]
ke=sum(sum(levelshort~=0));

Xce=zeros(n,ke+2*maxfea);

for i=1:n  
    jvalue=zeros(2*maxfea,1);
    for f=1:k        
        numf=sum(levelshort(:,f)~=0);
        t=ismember(levelshort(1:numf,f),Xcshort(i,f));
        jvalue=[jvalue;t];
        if Xcshort(i,f)==0;
            jvalue(f)=1;
        elseif sum(jvalue)==0
            jvalue(maxfea+f)=1;            
        end;
    end;
    Xce(i,:)=jvalue';      
end;

end

