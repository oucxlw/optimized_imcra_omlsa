function [voiceseg,vsl,SF,NF]=vad(xx)

wlen=512;                               % ����֡��Ϊ25ms
inc=wlen*0.25;                          % ��֡��

xx=xx-mean(xx);                         % ����ֱ������
x=xx/max(abs(xx));                      % ��ֵ��һ��
wnd=hamming(wlen);                      % ���ô�����
y=enframe(x,wnd,inc)';                  % ��֡
fn=size(y,2);                           % ��֡��

for k=2 : fn                            % ��������غ���
    u=y(:,k);
    ru=xcorr(u);
    Ru(k)=max(ru);
end
Rum=multimidfilter(Ru,10);              % ƽ������
Rum=Rum/max(Rum);                       % ��һ��

T1=0.1;
T2=0.2;
fn=size(Rum,2);                       % ȡ��֡��

maxsilence = 40;                        % ��ʼ��  
minlen  = 5;    
status  = 0;
count   = 0;
silence = 0;

%��ʼ�˵���
xn=1;
x1=0;x2=0;
for n=2:fn
   switch status
   case {0,1}                           % 0 = ����, 1 = ���ܿ�ʼ
      if Rum(n) > T2                   % ȷ�Ž���������
         x1(xn) = max(n-count(xn)-1,1);
         status  = 2;
         silence(xn) = 0;
         count(xn)   = count(xn) + 1;
      elseif Rum(n) > T1               % ���ܴ���������
%             zcr(n) < zcr2
         status = 1;
         count(xn)  = count(xn) + 1;
      else                              % ����״̬
         status  = 0;
         count(xn)   = 0;
         x1(xn)=0;
         x2(xn)=0;
      end
   case 2,                              % 2 = ������
      if Rum(n) > T1                   % ������������
         count(xn) = count(xn) + 1;
      else                              % ����������
         silence(xn) = silence(xn)+1;
         if silence(xn) < maxsilence    % ����������������δ����
            count(xn)  = count(xn) + 1;
         elseif count(xn) < minlen      % ��������̫�̣���Ϊ������
            status  = 0;
            silence(xn) = 0;
            count(xn)   = 0;
         else                           % ��������
            status  = 3;
            x2(xn)=x1(xn)+count(xn);
         end
      end
   case 3,                              % ����������Ϊ��һ������׼��
        status  = 0;          
        xn=xn+1; 
        count(xn)   = 0;
        silence(xn)=0;
        x1(xn)=0;
        x2(xn)=0;
   end
end   
el=length(x1);
if x1==0|x2==0
    x1=1;
    x2=length(x);
end
if x1(el)==0, el=el-1; end              % ���x1��ʵ�ʳ���
if el==0, return; end
if x2(el)==0                            % ���x2���һ��ֵΪ0����������Ϊfn
    fprintf('Error: Not find endding point!\n');
    x2(el)=fn;
end
SF=zeros(1,fn);                         % ��x1��x2����SF��NF��ֵ
NF=ones(1,fn);
for i=1 : el
    SF(x1(i):x2(i))=1;
    NF(x1(i):x2(i))=0;
end
speechIndex=find(SF==1);                % ����voiceseg
voiceseg=findSegment(speechIndex);
vsl=length(voiceseg);

