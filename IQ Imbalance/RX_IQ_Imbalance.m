close all;

global FM;
FM = 10;  % Input signal with 100 Hz frequency 

global FS;
FS = 1000;               % Sampling frequency in Hz

t = linspace(0, 1, FS);  % Time vector from 0 to 1 second with 1000 points

A = cos(2 * pi * FM * t); % input Signal Real part
B = sin(2 * pi * FM * t); % input Signal Img part

Z = A + 1j * B; % Single Tone input signal ;

PlotInput (Z , "Z(t) Single Tone");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Gain_Imbalance = db2decimal (0.9) ; % 0.9 dB
Phase_Imbalance = deg2rad(0) ; % 0 rad 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ZI_Imbalance = A ;

ZQ_Imbalance = Gain_Imbalance * cos (Phase_Imbalance) * B - Gain_Imbalance * sin (Phase_Imbalance) * A;

Z_Imbalance = ZI_Imbalance + 1j *ZQ_Imbalance;
PlotInput (Z_Imbalance , "Z Imbalance (t) - Image");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%NumeratorG = sum (ZQ_Imbalance .* ZQ_Imbalance);
%DenumeratorG = sum (ZI_Imbalance .* ZI_Imbalance);

ISquare = abs (ZI_Imbalance).^2;
QSquare = abs (ZQ_Imbalance).^2;


Gain_Expected = sqrt (sum (QSquare)/sum (ISquare));
Phase_Expected = sum (ZI_Imbalance .* ZQ_Imbalance) / sqrt (sum (ISquare) *sum (QSquare)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MOne = [1 0; tan(Phase_Expected) ((Gain_Expected .* cos (Phase_Expected))^-1)];
MTwo = [ZI_Imbalance ; ZQ_Imbalance];

MResult = MOne * MTwo ;

ZI_CorrectedE = MResult (1, :) ;
ZQ_CorrectedE = MResult (2, :);

y = ZI_CorrectedE + 1j *ZQ_CorrectedE;

PlotInput (y , "Z(t) - Estimated");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MOne = [1 0; tan(Phase_Imbalance) ((Gain_Imbalance .* cos (Phase_Imbalance))^-1)];
MTwo = [ZI_Imbalance ; ZQ_Imbalance];

MResult = MOne * MTwo ;

ZI_Corrected = MResult (1, :) ;
ZQ_Corrected = MResult (2, :);

y = ZI_Corrected + 1j *ZQ_Corrected;

PlotInput (y , "Z(t) - Correct");


function decimal = db2decimal(db)
    decimal = 10^(db / 20);
end

function db = decimal2db(decimal)
    db = 20 * log10(decimal);
end

function rad = deg2rad(deg)
    rad = deg * (pi / 180);
end

function deg = rad2deg(rad)
    deg = rad * (180 / pi);
end

function PlotInput (y , T)
FS = 1000; 
Y = fft(y);

% Compute number of samples
n = length(y);

% Shift FFT output to center it and compute the two-sided frequency range
Y_shifted = fftshift(Y);
f = (-n/2:n/2-1)*(FS/n);   % Frequency range (two-sided)

% Compute the magnitude and normalize it
Y_mag = abs(Y_shifted)/n;

% Plot the frequency domain representation (two-sided)
figure;
plot(f, Y_mag);
xlabel('Frequency (Hz)');
ylabel('Magnitude (Normalized)');
ylim([0 1]);
title (T);
grid on;
end