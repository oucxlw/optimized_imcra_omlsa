clc;clear;close all;

snr = 15;

clean_name = 'clean';
noise_name = '���̻�';
file.clean = [clean_name '.wav']; 
file.noise = [noise_name '.wav'];
noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
file.noisy = [noisy_name '.wav'];      
addnoise_asl(file.clean, file.noise, file.noisy , snr);    
% 
% clean_name = 'clean';
% noise_name = '������';
% file.clean = [clean_name '.wav']; 
% file.noise = [noise_name '.wav'];
% noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
% file.noisy = [noisy_name '.wav'];      
% addnoise_asl(file.clean, file.noise, file.noisy , snr);
% 
% clean_name = 'clean';
% noise_name = '����';
% file.clean = [clean_name '.wav']; 
% file.noise = [noise_name '.wav'];
% noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
% file.noisy = [noisy_name '.wav'];      
% addnoise_asl(file.clean, file.noise, file.noisy , snr);
% 
% clean_name = 'clean';
% noise_name = '��·';
% file.clean = [clean_name '.wav']; 
% file.noise = [noise_name '.wav'];
% noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
% file.noisy = [noisy_name '.wav'];      
% addnoise_asl(file.clean, file.noise, file.noisy , snr);

% clean_name = 'clean';
% noise_name = '����';
% file.clean = [clean_name '.wav']; 
% file.noise = [noise_name '.wav'];
% noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
% file.noisy = [noisy_name '.wav'];      
% addnoise_asl(file.clean, file.noise, file.noisy , snr);
% 
% clean_name = 'clean';
% noise_name = '����';
% file.clean = [clean_name '.wav']; 
% file.noise = [noise_name '.wav'];
% noisy_name = ['noisy_snr' num2str(snr) '_' noise_name];
% file.noisy = [noisy_name '.wav'];      
% addnoise_asl(file.clean, file.noise, file.noisy , snr);