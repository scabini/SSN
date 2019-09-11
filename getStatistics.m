function [vector] = getStatistics(data, parameters)

    r=parameters.r;
    z=parameters.z;
    maxConect = [4, 12, 28, 48, 80, 112, 148, 196, 252, 316];   
    maxConect = (maxConect*z + (z-1))+1; %o +1 é pra incluir tambem o 0, pois vertices podem ter de 0 à 14 conexoes


    media = mean(data); %dados brutos
    desvio = std(data); %dados brutos

    if floor(data(:))==data(:) %verificando se todos os elementos de data são inteiros. se sim, é o vetor de grau
        data = hist(data, maxConect(r));
        data = data/sum(data);
    else %se todos nao forem inteiros, é o vetor das forças, entao hist é calculado com bins = 5 vezes o grau maximo    
        data = hist(data, maxConect(r));
        data = data/sum(data);
    end

    energia = energy(data); %histograma
    entropia= wentropy(data,'shannon'); %histograma

    skew = skewness(data);
    kurt = kurtosis(data);
    vector =[media, desvio, energia, entropia, skew, kurt];

end

