function [ vector ] = getMeasures( data, parameters, z)
%Returns the 6 statistics of CN measures (data)

r=parameters.r;

% maxConect = [4, 12, 28, 48, 80, 112, 148, 196, 252, 316, 376, 440];
maxConect = [4 7 15 19 31 31 35 47 55 63 59 63];
maxConect = (maxConect*z + (z-1))+1; %o +1 é pra incluir tambem o 0, pois vertices podem ter de 0 à 14 conexoes

media = mean(data); %dados brutos
desvio = std(data); %dados brutos

if floor(data(:))==data(:) %verificando se todos os elementos de data são inteiros. se sim, é o vetor de grau
%     disp(['max k: ', num2str(max(data)), '  norm: ', num2str(maxConect(r)), '   z:', num2str(z)]);
    data = hist(data, maxConect(r));
else %se todos nao forem inteiros, é o vetor das forças, entao hist é calculado com binagem de Freedman-Diaconis    
%     disp(['max str: ', num2str(max(data)), '  norm: ', num2str(maxConect(r)), '   z:', num2str(z)]);
    data = hist(data, maxConect(r)*10);
end

data = data/sum(data);

energia = energy(data); %histograma
entropia= wentropy(data,'shannon'); %histograma

skew = skewness(data);
kurt = kurtosis(data);

vector =[media, desvio, energia, entropia, skew, kurt];
            
end
