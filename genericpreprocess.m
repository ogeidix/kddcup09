% CONFIGURATION
% -------------------------------------------------------------
cprintf('blue','# Choose configuration                         \n');

% trainSamples  = fullfile('..','..','data', 'small', 'orange_small_train');
% testSamples   = fullfile('..','..','data', 'small', 'orange_small_test');
%location=fullfile('..','..','data', 'small','orange_');
location=fullfile('data', 'small','orange_');
trainSamples=strcat(location,'small_train');
testSamples=strcat(location,'small_test');

nNumericFeatures     = 1:190;
nCategoricalFeatures = 191:230;

threshold = input('Select only features available in more than % of sample: [0.6] ');
if (isempty(threshold)),
	threshold  = 0.6;
end;
missing_input = input('Replace missing values with: [mean*|median|0] ','s');
if (strcmp(missing_input, '')),
    missing_input = 'mean';
end;
opt_missing_value_as_features = input('Use extra missing-value features? [0|1*] ');
if (isempty(opt_missing_value_as_features)),
	opt_missing_value_as_features  = 1;
end;
opt_rescale = input('Do you want to rescale data to unit variance? [0|1*] ');
if (isempty(opt_rescale)),
	opt_rescale  = 1;
end;
opt_whiten = input('Do you want to whiten the data? [0|1*] ');
if (isempty(opt_whiten)),
	opt_whiten  = 1;
end;




% LOAD DATASET
% -------------------------------------------------------------
% Training Sample
cprintf('blue',['\n# Loading ', trainSamples, ' dataset...             ']);
load(trainSamples);
[nSamples, nFeatures] = size(X);
cprintf('green',' [done]\n');
disp(['X = ', num2str(nSamples), ' samples with ', num2str(nFeatures), ' features']);
fprintf('\n');

cprintf('blue','# Separating numerical and categorical features                ');
Xnum = X(:,nNumericFeatures);
Xcat = X(:,nCategoricalFeatures);
cprintf('green',' [done]\n');
disp(['Xnum = feature ', num2str(nNumericFeatures(1)), '...', num2str(nNumericFeatures(end))]);
disp(['Xcat = feature ', num2str(nCategoricalFeatures(1)), '...', num2str(nCategoricalFeatures(end))]);
fprintf('\n');
clearvars X; 
%This is the default variable that is loaded, deleting it as loading
% Test file below,

% Test Sample
cprintf('blue',['# Loading ', testSamples, ' dataset...              ']);
load(testSamples);
[nSamples, nFeatures] = size(X);
cprintf('green',' [done]\n');
disp(['X = ', num2str(nSamples), ' samples with ', num2str(nFeatures), ' features\n']);
fprintf('\n');

cprintf('blue','# Separating numerical and categorical features                ');
Xtestnum = X(:,nNumericFeatures);
Xtestcat = X(:,nCategoricalFeatures);
cprintf('green',' [done]\n');
disp(['Xtestnum = feature ', num2str(nNumericFeatures(1)), '...', num2str(nNumericFeatures(end))]);
disp(['Xtestcat = feature ', num2str(nCategoricalFeatures(1)), '...', num2str(nCategoricalFeatures(end))]);
fprintf('\n');
clearvars X;

% SELECT feature present in more than x% samples
% -------------------------------------------------------------
cprintf('blue',['# Looking for features present in more than ', num2str(threshold*100),' percent samples ']);
% Training dataset variable
% Xnum_clean   = [];
% Xnum_clean_i = [];
% % Test dataset variable
% Xtestnum_clean=[];
% for f=nNumericFeatures,
%     if ((sum((Xnum(:,f).*0) == 0)/nSamples) >= threshold);
%         i = length(Xnum_clean_i)+1;
%         Xnum_clean =[Xnum_clean,Xnum(:,f)];
%         Xnum_clean_i(i) = f;
%     end;
% end;
% Simply copying the same features from the test data
% [n k]=size(Xnum_clean_i);
% for j=1:k,
%     Xtestnum_clean(:,k) =  Xtestnum(:,Xnum_clean_i(k));
% end;
Xmissingrate=mean(isnan(Xnum));
Xnum_clean_i=nNumericFeatures(Xmissingrate<1-threshold);
Xtestnum_clean=Xtestnum(:,Xnum_clean_i);
Xnum_clean=Xnum(:,Xnum_clean_i);



cprintf('green',' [done]\n');
cprintf('blue',['# Found ', num2str(length(Xnum_clean_i)), ' interesting features out of ', num2str(length(nNumericFeatures)),'\n']);
disp('Xnum_clean   = [interesting features]');
disp('Xnum_clean_i = [position of the feature in Xnum]');
fprintf('\n');

% CREATE matrix of extra features about missing values
% -------------------------------------------------------------
% Keeping track of the missing column in a separate matrix
cprintf('blue','# Analyzing the missing values in the interesting features...  ');
% Xnum_clean_missing = [];
% for f=1:length(Xnum_clean_i),
%     Xnum_clean_missing = [Xnum_clean_missing, (Xnum_clean(:,f).*0) == 0];
% end;
% Xtestnum_clean_missing = [];
% for f=1:length(Xnum_clean_i),
%     Xtestnum_clean_missing = [Xtestnum_clean_missing, (Xtestnum_clean(:,f).*0) == 0];
% end;
% cprintf('green',' [done]\n');
% Xnum_clean_missing=logical(Xnum_clean_missing);
Xnum_missing=isnan(Xnum_clean);
Xnum_clean_missing=logical(Xnum_missing.*-1+1);
Xtestnum_missing=isnan(Xtestnum_clean);
Xtestnum_clean_missing=logical(Xtestnum_missing.*-1+1);
disp('Xnum_clean_missing(s,f) = 0/1  (0 if feat. F is missing in S)');
fprintf('\n');



% Need to move this to a function, but i don't know why it is complaining
% Will look into it later
 % SET missing values to the median|mean
    % -------------------------------------------------------------
    cprintf('blue','# Setting missing values to mean|median of its feature...      ');
%     for f=1:length(Xnum_clean_i),
%         if (strcmp(missing_input,'mean')),
%             m = mean(Xnum_clean(Xnum_clean_missing(:,f)',f));
%         end;
%         if (strcmp(missing_input,'median')),
%             m = median(Xnum_clean(Xnum_clean_missing(:,f)',f));
%         end;
%         Xnum_clean(Xnum_clean_missing(:,f)==0,f)=m;
%     end;

if (strcmp(missing_input,'mean')),
    m=nansum(Xnum_clean)./sum(Xnum_clean_missing);
    mt=m;
    %mt=nansum(Xtestnum_clean)./sum(Xtestnum_clean_missing);
end;
if (strcmp(missing_input,'median')),
    m=nanmedian(Xnum_clean); % ignores the NAN values in the median calculation
    mt=m;
    %mt=nanmedian(Xtestnum_clean);
end;
if (strcmp(missing_input,'0')),
    m=repmat(0,1,size(Xnum_clean,2));
    mt=m;
end;
M=repmat(m,size(Xnum_clean,1),1) ;
Xnum_clean(Xnum_missing)=M(Xnum_missing);

Mt=repmat(mt,size(Xtestnum_clean,1),1) ;
Xtestnum_clean(Xtestnum_missing)=Mt(Xtestnum_missing);

obj = Xnum_clean;
cprintf('green',' [done]\n\n');
    
if (opt_rescale),
	% RESCALE features to unit variance
	% -------------------------------------------------------------
	cprintf('blue','# Rescaling features to unit variance...                       ');
	[Xnum_clean, Xnum_clean_scale] = rescale(Xnum_clean);
    % Rescale Testdata as well
    Xtestnum_clean = rescale(Xtestnum_clean,Xnum_clean_scale);
	cprintf('green',' [done]\n');
	disp('Xnum_clean_scale(f) = scale factor needed during prediction');
	disp('Xnum_clean          = Training scaled dataset');
    disp('Xtestnum_clean      = Test scaled dataset'); 
	fprintf('\n');
end;


if (opt_whiten),
	% WHITEN features to unit variance
	% -------------------------------------------------------------
	cprintf('blue','# Whitening features...                                        ');
    [Xnum_clean Xmu Xsig] = whiten(Xnum_clean);
    % Rescale Testdata as well
    Xtestnum_clean = whiten(Xtestnum_clean, Xmu, Xsig);
	cprintf('green',' [done]\n');
	disp('Xnum_clean          = Training whitened dataset');
    disp('Xtestnum_clean      = Test whitened dataset'); 
    disp('Xmu, Xsig           = Whitening parameters'); 
	fprintf('\n');
end;


if (opt_missing_value_as_features),
	% MERGE FEATURE WITH MISSING VALUE FEATURE
	% -------------------------------------------------------------
	cprintf('blue','# Merging features with missing-value features...              ');
    Xnum_clean = [Xnum_clean, Xnum_clean_missing];
    Xtestnum_clean = [Xtestnum_clean, Xtestnum_clean_missing];
	cprintf('green',' [done]\n');
% 	disp('Xnum_clean          = Full Useful Features');
%     disp('Xtestnum_clean      = Full useful features'); 
% 	fprintf('\n');
end;


% %get levels and counts for categorical features
cprintf('blue','# get levels and counts for categorical features...   \n');
[Xmissingcount,levels,lcounts,Xcat_clean_f,ntotal] = proCate1(Xcat,threshold);
% size(levels)
% 
% 
cprintf('blue','#  extend categorical features by top 9 values...   \n');
%   extend categorical features by top 9 values
[Xcat_ext] = proCate2(Xcat,Xcat_clean_f,levels,lcounts);
[Xtestcat_ext]= proCate2(Xtestcat,Xcat_clean_f,levels,lcounts);

% Combining Numerical And Categorical dataset
%Training
Xtraining_fullfeature = [Xnum_clean,Xcat_ext];
%Test
Xtest_fullfeature = [Xtestnum_clean,Xtestcat_ext];
disp('Xtraining_fullfeature  = Full Training Useful Features');
disp('Xtest_fullfeature      = Full Training useful features'); 
fprintf('\n');

% % load Ys
% Y1=load(strcat(location,'small_train_appetency.labels'));
% Y2=load(strcat(location,'small_train_churn.labels'));
% Y3=load(strcat(location,'small_test_upselling.labels'));

