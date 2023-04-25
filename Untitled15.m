clc;clear;close all;

noisy_file='noisy1';
enhanced1_file='enhanced1';
enhanced2_file='enhanced2';

[clean,fs]=audioread('clean1.wav');
noisy=audioread([noisy_file,'.wav']);
audiowrite('noise1.wav',noisy-clean,fs);
noise_file='noise1';
clean_file='clean1';
[~,noiseplot1]=omlsa1(noisy_file,enhanced1_file);
[nframes,cplot,nplot,splot,noiseplot2]=omlsa10(clean_file,noise_file,noisy_file,enhanced2_file);


enhanced1=audioread([enhanced1_file,'.wav']);
enhanced2=audioread([enhanced2_file,'.wav']);
N=min([length(clean),length(noisy),length(enhanced1),length(enhanced2)]);
clean=clean(1:N);
noisy=noisy(1:N);
enhanced1=enhanced1(1:N);
enhanced2=enhanced2(1:N);
noise_ori=noisy-clean;
noise_est1=noisy-enhanced1;
noise_est2=noisy-enhanced2;
% [XK,YK,ZK,nframes]=omlsa6(noise_ori,noise_est1,noise_est2);
figure;
% nframes=length(nplot);
% plot(1:nframes,cplot,'k-');hold on;
N=min([length(nplot),length(noiseplot1),length(noiseplot2)]);
figure;
plot(1:N,nplot(1:N),'k-');hold on;
plot(1:N,noiseplot1(1:N),'b-');hold on;
plot(1:N,noiseplot2(1:N),'r-');
legend('ƽ������������','��ͳ�㷨���Ƶ�����������','�Ľ��㷨���Ƶ�����������');
xlabel('֡��');
ylabel('����');
figure;
time=(0:length(noisy)-1)/fs;                        % ����ʱ��
plot(time,noisy-clean,'k-');hold on;
plot(time,noisy-enhanced1,'b-');hold on;
plot(time,noisy-enhanced2,'r-');
legend('ƽ������������','��ͳ�㷨���Ƶ�����������','�Ľ��㷨���Ƶ�����������');
xlabel('֡��');
ylabel('����');



