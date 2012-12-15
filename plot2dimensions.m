function plot2dimensions(X, Y, f1, f2)
	if(size(f1,2)==1)
		figure;
		plot(X(Y==-1,f1), X(Y==-1,f2), 'g.');
		hold on;
		plot(X(Y==+1,f1), X(Y==+1,f2), 'r.');
		xlabel(['Feature ',num2str(f1)]);
		ylabel(['Feature ',num2str(f2)]);
		legend('Class -1', 'Class +1');
	else,
		for f=1:length(f1),
  			plot2dimensions(X, Y, f1(f), f2(f));
		end;
	end;
