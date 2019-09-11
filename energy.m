function [ energ ] = energy( data )
%calculates the statistical energy of a given 'data' histogram distribution

    if sum(data)==1 %normalization condition
        energ=sum(data.^2);
    else
        data = data/sum(data);
        energ=sum(data.^2);
    end   
end

