%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%      Uncoded BPSK over freq. selective multipath fading channel       %
%                       in presence of AWGN                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;

M=2; %M-ary QAM

datasize=1024; %Total number of bits
m=log2(M);     %nuber of bits per symbol

Es=1;% Energy of symbols  for BPSK modulation

SNR=0:35;
SNRd=10.^(SNR./10);

frame=10;   % Number of Frames



%==== ITU Pedestrian channel  B ====
h=zeros(1,43);
p=[-3.92 -4.82 -8.82 -11.92 -11.72 -27.82];
c=sqrt(10.^(p./10));
ind=[1 3 10 15 27 43];
h(ind)=c;
KK=length(h);     


% ==  Initializing   ========
BER=zeros(1,length(SNRd));

% ==========   TRANSMITTER   ==========================
for loop=1:length(SNRd);% loop of SNR
    SNR(loop)
    
    BERtotal=0;
    
    for symboleloop=1:frame % Symbole Loop
% ----- Data Generation on the Transmitter
        msg=randi(1,datasize,M);

% ----- QAM modulation 
        mod=modem.pskmod('M',2,'symbolOrder','gray');
        ytr=modulate(mod,msg);
       
       

% ============  CHANNEL  ===============================
% ----- Multipath Fading  
        U=conv(h,ytr) ; % convolution of modulated signal with the channel
        ZZ=length(U);
% -----  AWGN 
        Noise= sqrt((Es/2)/(log2(M)*SNRd(loop)))*(randn(1,ZZ)+1j*randn(1,ZZ));
% -----  Received signal
        yrc=U+Noise;

       
% ==========   RECEIVER     =================================
% ----- Discard last Nch-1 received values resulting from convolution
        yrc(end-KK+2:end) = [];
% ----- QAM demodulation 
        demod=modem.pskdemod('M',2,'SymbolOrder','gray');
        Y=demodulate(demod,yrc);
%======================================================================================================        
        [BERs_Selectiv  ratio]=biterr(msg,Y);  
        BERtotal=BERtotal+BERs_Selectiv;

    end % Symbole loop
    BER(loop)=BERtotal/( frame*datasize*m );%  BER for  OFDM

end % end of SNR loop===================================================

% Draw BER graph
figure(3)
pb=0.5*erfc(sqrt(SNRd));
semilogy(SNR,pb,'b--');
hold on
semilogy(SNR,BER,'ro-'); 

grid; title('Uncoded 16QAM over freq. selective multipath fading channel');
legend( ' 16QAM'  )
xlabel('SNR-dB'); ylabel ('BER')

figure(1)

subplot(221)
plot(ytr,'bo'),grid
ylabel('Q Channel')
xlabel('I Channel')
title('16QAM Constellation ')

% IQ constellation at equalizer output.
subplot(222)
plot(yrc,'bo'),grid
ylabel('Q Channel')
xlabel('I Channel')
title('transmitted signal constellation')


subplot(223)
plot( Y,'ro'),grid
ylabel('Q Channel')
xlabel('I Channel')
title('recieved signal constellation') 


