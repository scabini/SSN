function [ vector ] = getMeasures( data, parameters, z)
%UNTITLED Summary of this function goes here
%Retorna as medidas (measures) referentes a distribuição de entrada (data)
%   Detailed explanation goes here
measures = parameters.measures;
r=parameters.r;
% z=parameters.z;
% maxConect = [4, 12, 28, 48, 80, 112, 148, 196, 252, 316, 376, 440];
maxConect = [4 7 15 19 31 31 35 47 55 63 59 63];
maxConect = (maxConect*z + (z-1))+1; %o +1 é pra incluir tambem o 0, pois vertices podem ter de 0 à 14 conexoes

% format long;

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

if strcmp(measures, 'mean')==1
    vector =[media];
else
    if strcmp(measures, 'std')==1
        vector =[desvio];
    else
       if strcmp(measures, 'energy')==1
            vector =[energia];
       else    
           if strcmp(measures, 'entropy')==1
                vector =[entropia];
           else
               if strcmp(measures, 'all')==1%case = all -> usa todas as medidas estatisticas como feature
                    vector =[media, desvio, energia, entropia, skew, kurt];
               else
                   if strcmp(measures, 'three')==1
                    vector =[media, desvio, skew];
                   else
                       if strcmp(measures, 'four')==1
                        vector =[media, desvio, energia, entropia];
                       else
                           vector = [];
                       end
                   end
               end
           end
        end                    
    end
end   

%vector =[media, desvio];
%vector =[media, desvio, entropia];
%vector =[media];
%vector =[entropia, desvio, contraste, homogeneidade, energia];
%vector =[media, desvio, energia, entropia];
end