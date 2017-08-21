function [ listaCandidatos ] = tomadaDeDecisao(dados, w, listaIDs)
%tomadaDeDecisao Summary of this function goes here
%   Esta funcao implementa o algoritmo PROMETHEE II que ranqueia as
%   alternativas de um problema de tomada de decisao baseado em um conjunto
%   de criterios.

% As linhas da matriz "dados" sao as alternativas, cada linha representa 
% cada candidato a determinada vaga.
% As colunas representam os criterios, que sao os campos escolhidos como 
% desejaveis pelo empregador no preenchimento da tela "Buscar Curriculos"

% Os dados da matriz em si correspondem aos valores que cada candidato 
% adquiriu em cada criterio

% Note que a matriz "dados" e' o retorno da funcao que vai calcular o valor
% que cada alternativa tera' em cada criterio. Ex: O candidato 1 tem 4 anos
% de experiencia e o empregador quer 2 anos de experiencia no minimo. Entao
% o candidato 1 tem, no criterio experiencia, o valor 2, e por aí vai.
% Dessa forma que e' preenchida a matriz "dados"

% A variavel "w" contem os pesos de cada criterio calculados atraves do
% metodo AHP e que serao usados como entrada

% Numero de alternativas
[n,c] = size(dados);

Pj = zeros(c,n,n);

for j=1:c
    for i=1:n
       for k=1:n
            Pj(j,i,k) = funG(dados(i,j) - dados(k,j)); % Todos os criterios
            % sao de maximizacao
       end
    end
end

% Relacao de preferencia
P = zeros(n,n);

for i=1:n
    for k=1:n
        soma = 0;
        for j=1:c
           soma = soma + w(j)*Pj(j,i,k); 
        end
        P(i,k) = soma/sum(w);
    end
end

%Fluxo liquido de preferencia 
fi = zeros(1,n);
for i=1:n
    soma1 = 0;
    soma2 = 0;
    for k=1:n
        soma1 = soma1 + P(i,k);
        soma2 = soma2 + P(k,i);
    end
    fi(i) = soma1 - soma2;
end

% Fazendo o ranking das solucoes
[ranking_fis,indices] = sort(fi,'descend');

% IDs dos candidatos ordenados do melhor para o pior
listaCandidatos = listaIDs(indices);

end