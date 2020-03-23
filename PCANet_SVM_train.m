
addpath('./Utils');
addpath('./Liblinear');



%% PCANet parameters
PCANet.NumStages = 2;
PCANet.PatchSize = PatSize;
PCANet.NumFilters = [8 8];
PCANet.HistBlockSize = [PatSize*2, PatSize]; 
PCANet.BlkOverLapRatio = 0;
PCANet.Pyramid = [];


fprintf('\n ====== PCANet Parameters ======= \n')
PCANet

% ��ȡ lab ��Ϣ
pos_lab = find(im_lab == 1);
neg_lab = find(im_lab == 0);
% ��������������˳��
pos_lab = pos_lab(randperm(numel(pos_lab)));
neg_lab = neg_lab(randperm(numel(neg_lab)));

[ylen, xlen] = size(im1);

% ͼ����Χ���㣬Ȼ��ÿ��������ΧȡPatch������
mag = (PatSize-1)/2;
imTmp = zeros(ylen+PatSize-1, xlen+PatSize-1);
imTmp((mag+1):end-mag,(mag+1):end-mag) = im1; 
im1 = im2col_general(imTmp, [PatSize, PatSize]);
imTmp((mag+1):end-mag,(mag+1):end-mag) = im2; 
im2 = im2col_general(imTmp, [PatSize, PatSize]);
clear imTmp mag;
clear xlen ylen;

% �ϲ������� im
im1 = mat2imgcell(im1, PatSize, PatSize, 'gray');
im2 = mat2imgcell(im2, PatSize, PatSize, 'gray');
parfor idx = 1 : numel(im1)
    im{idx} = [im1{idx}; im2{idx}];    
end
clear im1 im2 idx;

% ���ѡ��ȫͼ���ذٷ�֮20�����������ձ���ɸѡ��������
[ylen, xlen] = size(im);
NumSam = round(ylen*xlen*0.2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����
[neg_x,neg_y]=size(neg_lab);
[pos_x,pos_y]=size(pos_lab);
flag =  NumSam/2;
if neg_x<flag
   NegNum = neg_x;
else
   NegNum = flag;
end
% PosNum = round(NumSam*numel(pos_lab)/(numel(neg_lab) + numel(pos_lab)));
% NegNum = NumSam - PosNum;

PosNum = NumSam - NegNum;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if NegNum > numel(neg_lab)
    NegNum = numel(neg_lab);
end


% ȡ����������ͼ���
PosPat = im(pos_lab(1:PosNum));
NegPat = im(neg_lab(1:NegNum));
TrnPat = [PosPat, NegPat];
TrnLab = [ones(PosNum, 1); zeros(NegNum, 1)];


fprintf('  SamNum : %d\n', PosNum+NegNum);
fprintf('  PosNum : %d\n', PosNum);
fprintf('  NegNum : %d\n', NegNum);


[ftrain V] = PCANet_train(TrnPat,PCANet,1); 
clear NumSam PosNum NegNum BlkIdx;
clear PosPat NegPat TrnPat;
clear pos_lab neg_lab;


fprintf('\n ====== Training Linear SVM Classifier ======= \n')
% we use linear SVM classifier (C = 1), calling libsvm library
models = train(TrnLab, ftrain', '-s 1 -q'); 
clear ftrain TrnLab;



    