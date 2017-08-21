function [w] = ahp(numeroCriteriosOrdenados)
%ahp Summary of this function goes here
%   Esta funcao calcula a importancia de cada criterio do problema,
%   retornando os pesos numericos (w) correspondentes aos mesmos que devem
%   ser utilizados na rotina relacionada ao algoritmo PROMETHEE II

% Pegando o numero de criterios ordenados pelo usuario
n = numeroCriteriosOrdenados;

% Cria uma matriz nxn para que possamos comparar os criterios entre si.
% Note que o criterio c1 tem a mesma importancia que o proprio criterio c1,
% portanto apresenta valor 1 para o AHP, por isso inicializo com uma matriz
% identidade
matrizAHP = eye(n,n);

% Preenchendo os valores da matriz de acordo com a importancia que cada
% criterio tem em relacao ao outro
peso = 2;

for i=1:n
   for j=(i+1):n
        if(matrizAHP(i,j) ~= 1)
            matrizAHP(i,j) = peso;
            peso = peso + 1;
            if(peso == 10)
                peso = 2;
            end
        end
   end
end

for i=1:n
   for j=i:-1:1
        if(matrizAHP(i,j) ~= 1)
            matrizAHP(i,j) = 1/matrizAHP(j,i);
        end
   end
end

% Calculando os valores das prioridades de cada criterio (w)
w = zeros(1,n);

matrizTemp = zeros(n,n);

vetorSomas = zeros(1,n);

for i=1:n
    vetorSomas(i) = sum(matrizAHP(:,i));
end

for i=1:n
    for j=1:n
       matrizTemp(i,j) = matrizAHP(i,j)/vetorSomas(j); 
    end
    w(i) = sum(matrizTemp(i,:))/n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo da consistencia do metodo %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Se o numero de criterios e' 2, considera-se o AHP sempre consistente e
% para um numero de criterios maior do que 10 este calculo nao se aplica e
% nao ha' outro na literatura
if((n > 2)&&(n <= 10))

    lambda_max = max(mean(matrizAHP,2));

    IC = (lambda_max - n)/(n - 1);

    ICA = [0 0 0.58 0.9 1.12 1.24 1.32 1.41 1.45 1.49];

    ICA = ICA(n);

    RC = IC/ICA;

    if(RC > 0.1)
        error('Erro: Abordagem de preenchimento da matriz do AHP ineficiente!')    
    end

end

end