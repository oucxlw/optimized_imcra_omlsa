function [y,out]=omlsa7(fin,fout)
% ��onlsa7�Ļ����϶��������ε��������ڸ��ʽ����˲���
% �Լ���д��

%% 
% 1) ��ʱ����Ҷ��������
fs_ref=16000;		% 1.1) ����Ƶ��_�ο�
win_ref=512;		% 1.2) �������ڴ�С
overlap_ref=0.75*win_ref;        % 1.3) ����֡���ص�������

% 2) �����׹��Ʋ���
w=1;			% 2.1)  Ƶ��ƽ����������С=2*w+1
alpha_s=0.85;	% 2.2)  ƽ�������ĵݹ�ƽ������
Uwin=8; 	% 2.3)  �ֲ���С�����ķֽ�
Vwin=15;
Bmin=1.66;
xi_0=1.65;		% 2.4)  �ֲ���С����
gamma_0=4.6;		% 2.4)  �ֲ���С����
gamma_1=3;
alpha_d=0.85;	% 2.7)  �����ĵ���ƽ������
alpha_p=0.996;
theta_0=0.99;

% 3) �ź�ȱʧ���Ƶ�������ʲ���
alpha_xi=0.7;	% 3.1) �ݹ�ƽ������
w_local=1; 	% 3.2) Ƶ�ʾֲ�ƽ���������Ĵ�С
w_global=15; 	% 3.3) Ƶ�ʾֲ�ƽ���������Ĵ�С
f_u=10e3; 		% 3.4) ȫ�־��ߵĸ�Ƶ��ֵ
f_l=50; 		% 3.5) ȫ�־��ߵĵ�Ƶ��ֵ
P_min=0.005; 		% 3.6) �½�Լ��
xi_u_dB=-5; 	% 3.11) ���ߵ�����
xi_l_dB=-10; 	% 3.12) ���ߵ�����
xi_fu_dB=10; 	% 3.13) xi_m������ֵ
xi_fl_dB=0; 		% 3.14) xi_m������ֵ
q_max=0.998; 		% 3.15) ����Լ��

% 4) �����ߵ�����������ȹ��ƵĲ���
alpha_eta=0.95;	% 4.1) �ݹ�ƽ������
eta_min=10^(-18/10);
G_f=eta_min^0.5;	   % ��������

% ��ȡ��������
[data_in,fs]=audioread([fin '.wav']);  % ��ȡ�������ݵĴ�С, ����Ƶ��Fs �� ��������NBITS

%% ����ʵ�ʲ���Ƶ�ʵ�������
if fs~=fs_ref
    nwin=2^round(log2(fs/fs_ref*win_ref));
    overlap=overlap_ref/win_ref*nwin;
    alpha_s=alpha_s^(win_ref/nwin*fs/fs_ref);
    alpha_d=alpha_d^(win_ref/nwin*fs/fs_ref);
    alpha_eta=alpha_eta^(win_ref/nwin*fs/fs_ref);
    alpha_xi=alpha_xi^(win_ref/nwin*fs/fs_ref);
else
    nwin=win_ref;
    overlap=overlap_ref;
end
alpha_d_long=0.99;
win=hamming(nwin);
win2=win.^2;
inc=nwin-overlap;
W0=win2(1:inc);
for k=inc:inc:nwin-1
    swin2=lnshift(win2,k);
    W0=W0+swin2(1:inc);
end
W0=mean(W0)^0.5;
win=win/W0;
Cwin=sum(win.^2)^0.5;
win=win/Cwin;
out=zeros(nwin,1);
M21=nwin/2+1;

b=hanning(2*w+1);
b=b/sum(b);     %�淶��������
b_local=hanning(2*w_local+1);
b_local=b_local/sum(b_local);  % �淶��������
b_global=hanning(2*w_global+1);
b_global=b_global/sum(b_global);   % �淶��������

l_mod_lswitch=0;
k_u=round(f_u/fs*nwin+1);  % ����Ƶ�� bin for ȫ�־���
k_l=round(f_l/fs*nwin+1);  % ����Ƶ�� bin for ȫ�־���
k_u=min(k_u,M21);
k2_local=round(500/fs*nwin+1);
k3_local=round(3500/fs*nwin+1);
eta_2term=1;
xi=0;
xi_frame=0;
i_fnz=1;      % ��һ֡����ļ�����    
fnz_flag=0;     % ����ĵ�һ֡�ı�־    
zero_thres=1e-10;      

p=zeros(M21,1);
Uwin1=ones(M21,1)*8;
FLAG=[];

initfin=data_in(1:22);
data_out=initfin;
yy=enframe(data_in(23:end),nwin,inc);
nframes=size(yy,1);
[voiceseg,vsl,SF,amp]=vad(data_in(23:end));  % �˵���

for i=1:nframes
    y=(yy(i,:))';
    
    if (~fnz_flag && abs(y(1))>zero_thres) ||  (fnz_flag && any(abs(y)>zero_thres))       % �°汾omlsa3
        fnz_flag=1;     
        % 1. ��ʱ����Ҷ����
        Y=fft(win.*y);
        Y2=abs(Y(1:M21)).^2;
        if i==i_fnz    
            lambda_d=Y2;
        end
        
        gamma=Y2./max(lambda_d,1e-10);
        eta=alpha_eta*eta_2term+(1-alpha_eta)*max(gamma-1,0);
        eta=max(eta,eta_min);
        v=gamma.*eta./(1+eta);

        % 2.1. ��Ƶ��ƽ������
        Sf=conv(b,Y2);  % ��Ƶ��ƽ������
        Sf=Sf(w+1:M21+w);
        if i==i_fnz     
            Sy=Y2;
            S=Sf;
            St=Sf;
            lambda_dav=Y2;
            SER=Y2;
        else
            S=alpha_s*S+(1-alpha_s)*Sf;     % ��ʱ��ƽ������
        end
        if i<14+i_fnz     
            Smin=S;
            SMact=S;
        else
            Smin=min(Smin,S);
            SMact=min(SMact,S);
        end
        
        % �ֲ���Сֵ����
        I_f=double(Y2<gamma_0*Bmin.*Smin & S<xi_0*Bmin.*Smin);
        conv_I=conv(b,I_f);
        conv_I=conv_I(w+1:M21+w);
        Sft=St;
        idx=find(conv_I);
        if ~isempty(idx)
            conv_Y=conv(b,I_f.*Y2);
            conv_Y=conv_Y(w+1:M21+w);
            Sft(idx)=conv_Y(idx)./conv_I(idx);
        end
        if i<14+i_fnz     
            St=S;
            Smint=St;
            SMactt=St;
        else
            St=alpha_s*St+(1-alpha_s)*Sft;
            Smint=min(Smint,St);
            SMactt=min(SMactt,St);
        end
        qhat=ones(M21,1);
        phat=zeros(M21,1);

        gamma_mint=Y2./Bmin./max(Smint,1e-10);   
        zetat=S./Bmin./max(Smint,1e-10);      
        idx=find(gamma_mint>1 & gamma_mint<gamma_1 & zetat<xi_0);
        qhat(idx)=(gamma_1-gamma_mint(idx))/(gamma_1-1);
        phat(idx)=1./(1+qhat(idx)./(1-qhat(idx)).*(1+eta(idx)).*exp(-v(idx)));
        phat(gamma_mint>=gamma_1 | zetat>=xi_0)=1;
        P=mean(phat(1:159));
        if SF(i)==0
            phat(160:end)=phat(160:end)*0.7;
            if  P<0.05
                phat(1:159)=phat(1:159)*0.7;
            end
        end
        
        A=alpha_d+(alpha_p-alpha_d)*phat;
        B=zeros(M21,1);
        idx=find(phat>=theta_0);
        B(idx)=(1-alpha_p)*phat(idx);
        C=(1-alpha_d)*(1-phat);
        lambda_dav=A.*lambda_dav+B.*SER+C.*Y2;
        
        if i<14+i_fnz     
            lambda_dav_long=lambda_dav;
        else
            alpha_dt_long=alpha_d_long+(1-alpha_d_long)*phat;
            lambda_dav_long=alpha_dt_long.*lambda_dav_long+(1-alpha_dt_long).*Y2;
        end
        
        p=p+phat;
        if mod(i,Vwin)==0
            P=zeros(M21,1);
            P(p>6)=1;
            p=zeros(M21,1);
            if i<=Vwin*Uwin
                Uwin1=ones(M21,1)*8;
                FLAG=[FLAG,P];
            else
                FLAG=[FLAG(:,2:end),P];
                FG=sum(FLAG,2);
                Uwin1=FG;
                Uwin1(FG==7)=8;
                Uwin1(FG==6)=8;
                Uwin1(FG==1)=2;
                Uwin1(FG==0)=1;
            end
        end
        
        l_mod_lswitch=l_mod_lswitch+1;
        if l_mod_lswitch==Vwin
            l_mod_lswitch=0;
            if i==Vwin-1+i_fnz    
                SW=repmat(S,1,Uwin);
                SWt=repmat(St,1,Uwin);
            else
                SW=[SW(:,2:Uwin) SMact];
                Smin=minline(SW,Uwin1);
                SMact=S;
                SWt=[SWt(:,2:Uwin) SMactt];
                Smint=minline(SWt,Uwin1);
                SMactt=St;
            end
        end
        
        % 2.4. �����׹���
        lambda_d=1.4685*lambda_dav;  
        
        % 4. �ź�ȱʧ���Ƶ��������
        xi=alpha_xi*xi+(1-alpha_xi)*eta;
        xi_local=conv(xi,b_local);
        xi_local=xi_local(w_local+1:M21+w_local);
        xi_global=conv(xi,b_global);
        xi_global=xi_global(w_global+1:M21+w_global);
        dxi_frame=xi_frame;
        xi_frame=mean(xi(k_l:k_u));
        dxi_frame=xi_frame-dxi_frame;
        if xi_local>0, xi_local_dB=10*log10(xi_local); else xi_local_dB=-100; end
        if xi_global>0, xi_global_dB=10*log10(xi_global); else xi_global_dB=-100; end
        if xi_frame>0, xi_frame_dB=10*log10(xi_frame); else xi_frame_dB=-100; end

        P_local=ones(M21,1);
        P_local(xi_local_dB<=xi_l_dB)=P_min;
        idx=find(xi_local_dB>xi_l_dB & xi_local_dB<xi_u_dB);
        P_local(idx)=P_min+(xi_local_dB(idx)-xi_l_dB)/(xi_u_dB-xi_l_dB)*(1-P_min);
        P_global=ones(M21,1);
        P_global(xi_global_dB<=xi_l_dB)=P_min;
        idx=find(xi_global_dB>xi_l_dB & xi_global_dB<xi_u_dB);
        P_global(idx)=P_min+(xi_global_dB(idx)-xi_l_dB)/(xi_u_dB-xi_l_dB)*(1-P_min);

        m_P_local=mean(P_local(3:(k2_local+k3_local-3)));    % ƽ���������ڸ���
        if m_P_local<0.25
            P_local(k2_local:k3_local)=P_min;    % ���� P_local (frequency>500Hz) �Խ����������ֵĸ���
        end        
        if (m_P_local<0.5) && (i>120)
            idx=find( lambda_dav_long(8:(M21-8)) > 2.5*(lambda_dav_long(10:(M21-6))+lambda_dav_long(6:(M21-10))) );
            P_local([idx+6;idx+7;idx+8])=P_min;   % ȥ����������
        end   

        if xi_frame_dB<=xi_l_dB
            P_frame=P_min;
        elseif dxi_frame>=0
            xi_m_dB=min(max(xi_frame_dB,xi_fl_dB),xi_fu_dB);
            P_frame=1;
        elseif xi_frame_dB>=xi_m_dB+xi_u_dB
            P_frame=1;
        elseif xi_frame_dB<=xi_m_dB+xi_l_dB
            P_frame=P_min;
        else
            P_frame=P_min+(xi_frame_dB-xi_m_dB-xi_l_dB)/(xi_u_dB-xi_l_dB)*(1-P_min);
        end
        q=1-P_global.*P_local*P_frame;   
        q=min(q,q_max);

        gamma=Y2./max(lambda_d,1e-10);
        eta=alpha_eta*eta_2term+(1-alpha_eta)*max(gamma-1,0);
        eta=max(eta,eta_min);
        v=gamma.*eta./(1+eta);
        PH1=zeros(M21,1);
        idx=find(q<0.9);
        PH1(idx)=1./(1+q(idx)./(1-q(idx)).*(1+eta(idx)).*exp(-v(idx)));

        % 7. Spectral Gain
        GH1=ones(M21,1);
        idx=find(v>5);
        GH1(idx)=eta(idx)./(1+eta(idx));
        idx=find(v<=5 & v>0);
        GH1(idx)=eta(idx)./(1+eta(idx)).*exp(0.5*expint(v(idx)));

        lambda_d_global=lambda_d;   
        lambda_d_global(4:M21-3)=min([lambda_d_global(4:M21-3),lambda_d_global(1:M21-6),lambda_d_global(7:M21)],[],2);   % �°汾
        Sy=0.8*Sy+0.2*Y2;    
        GH0=G_f*(lambda_d_global./(Sy+1e-10)).^0.5;   
        G=GH1.^PH1.*GH0.^(1-PH1);
        eta_2term=GH1.^2.*gamma;
        SER=Y2-G.*G.*Y2;
        
        X=[zeros(3,1); G(4:M21-1).*Y(4:M21-1); 0];
        X(M21+1:nwin)=conj(X(M21-1:-1:2)); %����Ƶ�׵ķ��ԳƷ�Χ
        x=Cwin^2*win.*real(ifft(X));
        out=out+x;
    else        
        if ~fnz_flag        
            i_fnz=i_fnz+1;        
        end         
    end         
    data_out=[data_out;out(1:inc)];
    out=[out(inc+1:nwin); zeros(inc,1)];   % �������֡
end
audiowrite([fout '.wav'],data_out,fs);

function y = lnshift(x,t)
szX=size(x);
if szX(1)>1
    n=szX(1);
    y=[x((1+t):n); x(1:t)];
else
    n=szX(2);
    y=[x((1+t):n) x(1:t)];
end