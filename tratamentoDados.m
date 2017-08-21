function [listaDeCandidatos] = tratamentoDados(listaIDs,criterios)
%tratamentoDados Summary of this function goes here
%   Pega os dados vindos da base de dados e faz o tratamento adequado para
%   formar a matriz numerica que sera' usada no PROMETHEE II
%
%   listaIds e' um array que contem os Ids dos candidatos que cumpriram os 
%   requisitos obrigatorios exigidos pelo empregador
%
%   criterios e' uma matriz Cx2 onde C e' o numero de criterios desejaveis
%   exigidos pelo empregador. Em uma coluna estao os nomes dos criterios e
%   na outra o valor que o empregador deseja que o candidato tenha
%   naquele criterio.

javaaddpath('C:\Users\Thais\Dropbox\Projeto Multidisciplinar\Algoritmo de Tomada de Decisão\mongo-java-driver-3.0.0-rc0.jar');
import com.mongodb.*;
import org.bson.types.ObjectId;

mongoClient = MongoClient(); % Estabelece a conexao
db = mongoClient.getDB('melhores_candidatos'); % Pega o esquema do banco a ser utilizado
cands = db.getCollection('curriculos'); % Seleciona a tabela 'curriculos' do banco

NId = length(listaIDs); % Numero de candidatos

n = 1;
while (n <= NId)
    
    query = BasicDBObject('_id', ObjectId(listaIDs{n}));

    cursor = cands.find(query);
    
    cand(n).id   = cursor.next().get('_id');
    cand(n).id = char(cand(n).id);
    cand(n).ultAtu  = cursor.curr().get('ultima_atualizacao');
    cand(n).ultAtu = char(cand(n).ultAtu);
    cand(n).des        = cursor.curr().get('desempregado');
    cand(n).url      = cursor.curr().get('url');
    cand(n).bairro      = cursor.curr().get('bairro');
    cand(n).cidade        = cursor.curr().get('cidade');
    cand(n).defic        = cursor.curr().get('deficiencia');
    cand(n).sexo        = cursor.curr().get('sexo');
    cand(n).idade        = cursor.curr().get('idade');
    cand(n).dispviag        = cursor.curr().get('disponibilidade_viagem');
    cand(n).estciv        = cursor.curr().get('estado_civil');
    cand(n).est        = cursor.curr().get('estado');
    cand(n).cnh        = cursor.curr().get('cnh');
    
    tempIdiomas = cursor.curr().get('idiomas');
    tempIdiomas = tempIdiomas.toArray.cell;
    
    % Tratando idiomas como um campo do tipo BasicDBObject
    N = length(tempIdiomas);
    nivel = {};
    lingua = {};
    for i=1:N
        nivel = [nivel,tempIdiomas{i}.get('nivel')];
        lingua = [lingua,tempIdiomas{i}.get('lingua')];
    end
    cand(n).idiomas_nivel = nivel;
    cand(n).idiomas_lingua = lingua;

    tempFormacao = cursor.curr().get('formacao');
    tempFormacao = tempFormacao.toArray.cell;
    
    N1 = length(tempFormacao);
    
    conclusao = {};
    curso = {};
    grau = {};
    inicio = {};
    for i = 1:N1
       conclusao = [conclusao,char(tempFormacao{i}.get('conclusao'))];
       curso = [curso,tempFormacao{i}.get('curso')];
       grau = [grau,tempFormacao{i}.get('grau')];
       inicio = [inicio,char(tempFormacao{i}.get('inicio'))];
    end
    
    cand(n).formacao_conclusao = conclusao;
    cand(n).formacao_curso = curso;
    cand(n).formacao_grau = grau;
    cand(n).formacao_inicio = inicio;    

    tempExperiencia = cursor.curr().get('experiencia');
    tempExperiencia = tempExperiencia.toArray.cell;
    
    N2 = length(tempExperiencia);
    
    cargo={};
    duracao=[];
    nivel={};
    
    for i=1:N2
        cargo = [cargo,tempExperiencia{i}.get('cargo')];
        duracao = [duracao tempExperiencia{i}.get('duracao')];
        nivel = [nivel,tempExperiencia{i}.get('nivel')];
    end
    
    cand(n).experiencia_cargo = cargo;
    cand(n).experiencia_duracao = duracao;
    cand(n).experiencia_nivel = nivel;
    
    tempCompetencias = cursor.curr().get('competencias');
    tempCompetencias = tempCompetencias.toArray.cell;
    
    N3 = length(tempCompetencias);
    
    cand(n).competencias_valores = cell(6,10);
    
    for i=1:N3
       tempValores = tempCompetencias{i}.get('valores');
       tempValores = tempValores.toArray.cell;
       
       N4 = length(tempValores);
    
       valores={};
       for j=1:N4
            valores = [valores,tempValores{j}]; 
       end
       cand(n).competencias_valores(i,1:N4) = valores;       
    end

    tempObjetivos = cursor.curr().get('objetivos');
    
    tempSalario = tempObjetivos.get('salario');
    tempProfissional = tempObjetivos.get('profissional');
    tempNiveis = tempObjetivos.get('niveis');
    
    % Desmembrando o campo 'salario' de 'objetivos'
    cand(n).objetivos_salario = tempSalario.get('min');
    
    % Desmembrando o campo 'profissional' de 'objetivos'
    tempProfissional = tempProfissional.toArray.cell;
    
    N5 = length(tempProfissional);
        
    cand(n).objetivos_profissional_areas = cell(10,10);
    cand(n).objetivos_profissional_cargo = cell(10,2);
    
    for i=1:N5
        tempCargo = tempProfissional{i}.get('cargo');
        tempCargo = tempCargo.toArray.cell;
        
        tempAreas = tempProfissional{i}.get('areas');
        tempAreas = tempAreas.toArray.cell;

        N6 = length(tempAreas);
        N7 = length(tempCargo);

        areas = {};
        for j=1:N6
            areas = [areas,tempAreas{j}]; 
        end
        cand(n).objetivos_profissional_areas(i,1:N6) = areas; 
        
        cargo = {};
        for j=1:N7
           cargo = [cargo,tempCargo{j}]; 
        end
        cand(n).objetivos_profissional_cargo(i,1:N7) = cargo;
    end
    
    % Desmembrando o campo 'niveis' de 'objetivos'
    tempNiveis = tempNiveis.toArray.cell;
    
    N7 = length(tempNiveis);
    
    niveis = {};
    
    for i=1:N7
        niveis = [niveis,tempNiveis{i}];
    end
    cand(n).objetivos_niveis = niveis;
    
    if(~isempty(cand(n).cnh))
        cand(n).cnh = char(cand(n).cnh.toArray.cell);
    end
    
    n = n + 1;

end

cursor.close();

%%%%%%%%%%%%%%%%%%
% Fim da Parte 1 %
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parte 2: Fazendo a conversao dos dados em dados numericos %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Matriz de dados que sera entrada do PROMETHEE II
dados = zeros(NId,Ncrit);

for j=1:Ncrit
   if(strcmp(criterios{j,1},'ultima_atualizacao'))
       for i=1:NId 
            tamString = length(cand(i).ultAtu);
            string = [];
            string = [cand(i).ultAtu(tamString-3) cand(i).ultAtu(tamString-2) cand(i).ultAtu(tamString-1) cand(i).ultAtu(tamString)];
            % Pegando somente o ano e o mes que o candidato atualizou seu curriculo
            cand_ano = str2num(string);
            string_mes = [cand(i).ultAtu(5) cand(i).ultAtu(6) cand(i).ultAtu(7)];

            if(strcmp(string_mes,'Jan'))
                cand_mes = 1;
            elseif(strcmp(string_mes,'Feb'))
                cand_mes = 2;
            elseif(strcmp(string_mes,'Mar'))
                cand_mes = 3;    
            elseif(strcmp(string_mes,'Apr'))
                cand_mes = 4;
            elseif(strcmp(string_mes,'May'))
                cand_mes = 5;  
            elseif(strcmp(string_mes,'Jun'))
                cand_mes = 6;
            elseif(strcmp(string_mes,'Jul'))
                cand_mes = 7;            
            elseif(strcmp(string_mes,'Aug'))
                cand_mes = 8;
            elseif(strcmp(string_mes,'Sep'))
                cand_mes = 9;
            elseif(strcmp(string_mes,'Oct'))
                cand_mes = 10;
            elseif(strcmp(string_mes,'Nov'))
                cand_mes = 11;
            else
                cand_mes = 12;
            end

            melhores_anos = [];
            melhores_anos_ind = [];

            meses = [];
            meses_ind = [];

            if(cand_ano > criterios{j,2}(2))
                melhores_anos = [melhores_anos cand_ano];
                melhores_anos_ind = [melhores_anos_ind i];
            elseif(cand_ano == criterios{j,2}(2))
                if(cand_mes >= criterios{j,2}(1))
                    meses = [meses cand_mes];
                    meses_ind = [meses_ind i];
                else
                    dados(i,j) = 50;
                end
            else
                dados(i,j) = 0;
            end
       end
       
        [valores,indices] = sort(melhores_anos,'descend');
        [valores_meses,indices_meses] = sort(meses,'descend');
        
        melhores_anos_ind = melhores_anos_ind(indices);
        meses_ind = meses_ind(indices_meses);

        v = 100;

        for i=1:length(melhores_anos_ind)
           dados(melhores_anos_ind(i),j) = v;
           v = v - 1;
        end
        
        v = 90;
        
        for i=1:length(meses_ind)
           dados(meses_ind(i),j) = v;
           v = v - 1;
        end        
   elseif(strcmp(criterios{j,1},'desempregado'))
       for i=1:NId
            if(criterios{j,2} == cand(i).des)
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end
   elseif(strcmp(criterios{j,1},'bairro'))
       for i=1:NId
            if(strcmp(criterios{j,2},cand(i).bairro))
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end    
   elseif(strcmp(criterios{j,1},'cidade'))
       for i=1:NId
            if(strcmp(criterios{j,2},cand(i).cidade))
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end
   elseif(strcmp(criterios{j,1},'estado'))
       for i=1:NId
            if(strcmp(criterios{j,2},cand(i).est))
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end    
   elseif(strcmp(criterios{j,1},'deficiencia'))
       for i=1:NId
            if(criterios{j,2} == cand(i).defic)
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end
   elseif(strcmp(criterios{j,1},'sexo'))
       for i=1:NId
            if(strcmp(criterios{j,2},cand(i).sexo))
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end
   elseif(strcmp(criterios{j,1},'idade'))
       melhores_idades = [];
       melhores_idades_ind = [];
       
       for i=1:NId
            if((criterios{j,2}(1) <= cand(i).idade)&&(criterios{j,2}(2) >= cand(i).idade))
                melhores_idades = [melhores_idades cand(i).idade];
                melhores_idades_ind = [melhores_idades_ind i];
            else
                dados(i,j) = 1;
            end
       end
       
       [valores,indices] = sort(melhores_idades);
       
       melhores_idades_ind = melhores_idades_ind(indices);
       
       v = 100;
       
       for i=1:length(melhores_idades_ind)
           dados(melhores_idades_ind(i),j) = v;
           v = v - 1;
       end
   elseif(strcmp(criterios{j,1},'disponibilidade_viagem'))
       for i=1:NId
            if(criterios{j,2} == cand(i).dispviag)
                dados(i,j) = 100;
            else
                dados(i,j) = 0;
            end
       end    
   elseif(strcmp(criterios{j,1},'estado_civil'))
       for i=1:NId
            if(strcmp(criterios{j,2},'Solteiro') && (strcmp(cand(i).estciv,'Solteiro')))
                dados(i,j) = 100;
            elseif(strcmp(criterios{j,2},'Solteiro') && (strcmp(cand(i).estciv,'Divorciado')))
                dados(i,j) = 90;
            elseif(strcmp(criterios{j,2},'Solteiro') && (strcmp(cand(i).estciv,'Casado')))
                dados(i,j) = 10;
            elseif(strcmp(criterios{j,2},'Divorciado') && (strcmp(cand(i).estciv,'Solteiro')))
                dados(i,j) = 90;
            elseif(strcmp(criterios{j,2},'Divorciado') && (strcmp(cand(i).estciv,'Divorciado')))
                dados(i,j) = 100;
            elseif(strcmp(criterios{j,2},'Divorciado') && (strcmp(cand(i).estciv,'Casado')))
                dados(i,j) = 20;
            elseif(strcmp(criterios{j,2},'Casado') && (strcmp(cand(i).estciv,'Solteiro')))
                dados(i,j) = 10;
            elseif(strcmp(criterios{j,2},'Casado') && (strcmp(cand(i).estciv,'Divorciado')))
                dados(i,j) = 20;
            elseif(strcmp(criterios{j,2},'Casado') && (strcmp(cand(i).estciv,'Casado')))
                dados(i,j) = 100;                
            end
       end    
   elseif(strcmp(criterios{j,1},'cnh'))
        qtde_cnh = [];
        qtde_cnh_ind = [];
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).cnh)))
               qtde_cnh = [qtde_cnh length(cand(i).cnh)];
               qtde_cnh_ind = [qtde_cnh_ind i];
           else
               dados(i,j) = 0;
           end
        end
        
        [valores, indices] = sort(qtde_cnh,'descend');
        
        qtde_cnh_ind = qtde_cnh_ind(indices);
       
        v = 100;

        for i=1:length(qtde_cnh_ind)
           dados(qtde_cnh_ind(i),j) = v;
           v = v - 1;
        end        
   elseif(strcmp(criterios{j,1},'idiomas_lingua'))
        qtde_lingua = [];
        qtde_lingua_ind = [];
        niveis = find(strcmp(criterios,'idiomas_nivel'));
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).idiomas_lingua)))
               indexes = find(ismember(criterios{j,2},cand(i).idiomas_lingua));
               if(all(ismember(criterios{niveis,2},cand(i).idiomas_nivel(indexes))))
                   qtde_lingua = [qtde_lingua length(cand(i).idiomas_lingua)];
                   qtde_lingua_ind = [qtde_lingua_ind i];
               else
                   dados(i,[j,niveis])= 0;
               end
           else
               dados(i,[j,niveis]) = 0;
           end
        end
        
        [valores, indices] = sort(qtde_lingua,'descend');
        
        qtde_lingua_ind = qtde_lingua_ind(indices);
       
        v = 100;

        for i=1:length(qtde_lingua_ind)
           dados(qtde_lingua_ind(i),[j,niveis]) = v;
           v = v - 1;
        end
        
        j = j + 1;     
   elseif(strcmp(criterios{j,1},'formacao_curso'))
        qtde_curso = [];
        qtde_curso_ind = [];
        
        anos_ini = [];
        anos_ini_ind = [];
        
        anos_con = [];
        anos_con_ind = [];
        
        graus = find(strcmp(criterios,'formacao_grau'));
        inicios = find(strcmp(criterios,'formacao_inicio'));
        conclusoes = find(strcmp(criterios,'formacao_conclusao'));
        
        objcar = find(strcmp(criterios,'objetivos_cargo'));

        flag = 0;

        if(strcmp(criterios{objcar,2},'Estagiario'))
            flag = 1;
        end
        
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).formacao_curso)))
               indexes = find(ismember(cand(i).formacao_curso,criterios{j,2}));
               
               indexes = indexes(1);
               
               cand_ano_ini = char(cand(i).formacao_inicio(indexes));
               cand_ano_con = char(cand(i).formacao_conclusao(indexes));
               ano_crit_ini = char(criterios{inicios,2});
               ano_crit_con = char(criterios{conclusoes,2});
               
               if(all(ismember('o momento',ano_crit_con)))
                    ano_crit_con = char(datetime('today'));
               end
               
               tamString = length(cand_ano_ini);
               tamString2 = length(cand_ano_con);
               tamString3 = length(ano_crit_ini);
               tamString4 = length(ano_crit_con);
               
               cand_ano_ini = [cand_ano_ini(tamString-3) cand_ano_ini(tamString-2) cand_ano_ini(tamString-1) cand_ano_ini(tamString)];
               cand_ano_con = [cand_ano_con(tamString2-3) cand_ano_con(tamString2-2) cand_ano_con(tamString2-1) cand_ano_con(tamString2)];
               cand_ano_ini = [ano_crit_ini(tamString3-3) ano_crit_ini(tamString3-2) ano_crit_ini(tamString3-1) ano_crit_ini(tamString3)];
               cand_ano_con = [ano_crit_con(tamString4-3) ano_crit_con(tamString4-2) ano_crit_con(tamString4-1) ano_crit_con(tamString4)];
               
               cand_ano_ini = str2num(cand_ano_ini);
               cand_ano_con = str2num(cand_ano_con);
               ano_crit_ini = str2num(ano_crit_ini);
               ano_crit_con = str2num(ano_crit_con);
               
               if(cand_ano_ini <= ano_crit_ini)
               if(flag)
                   if(cand_ano_con >= ano_crit_con)
                       if(all(ismember(criterios{graus,2},cand(i).formacao_grau(indexes))))
                           qtde_curso = [qtde_curso length(cand(i).formacao_curso)];
                           qtde_curso_ind = [qtde_curso_ind i];
                           
                           anos_ini = [anos_ini cand_ano_ini];
                           anos_ini_ind = [anos_ini_ind i];
                           anos_con = [anos_con cand_ano_con];
                           anos_con_ind = [anos_con_ind i];
                       end
                   end
               else
                   if(cand_ano_con <= ano_crit_con)
                       if(all(ismember(criterios{graus,2},cand(i).formacao_grau(indexes))))
                           qtde_curso = [qtde_curso length(cand(i).formacao_curso)];
                           qtde_curso_ind = [qtde_curso_ind i];

                           anos_ini = [anos_ini cand_ano_ini];
                           anos_ini_ind = [anos_ini_ind i];
                           anos_con = [anos_con cand_ano_con];
                           anos_con_ind = [anos_con_ind i];
                       end
                   end                   
               end
               else
                    dados(i,[j,graus,conclusoes,inicios]) = 0;
               end
           else
               dados(i,[j,graus,conclusoes,inicios]) = 0;
           end
        end
        
        [valores, indices] = sort(qtde_curso,'descend');
        
        [v1, i1] = sort(anos_ini);
        
        if(flag)
            [v2, i2] = sort(anos_con,'descend');
        else
            [v2, i2] = sort(anos_con);
        end
        
        qtde_curso_ind = qtde_curso_ind(indices);
        anos_ini_ind = anos_ini_ind(i1);
        anos_con_ind = anos_con_ind(i2);
       
        v = 100;

        for i=1:length(qtde_curso_ind)
           dados(qtde_curso_ind(i),[j,graus]) = v;
           v = v - 1;
        end 
        
        v = 100;

        for i=1:length(anos_ini_ind)
           dados(anos_ini_ind(i),inicios) = v;
           v = v - 1;
        end

        v = 100;

        for i=1:length(anos_con_ind)
           dados(anos_con_ind(i),conclusoes) = v;
           v = v - 1;
        end
        
        j = j + 3;
   elseif(strcmp(criterios{j,1},'experiencia_cargo'))
        qtde_cargo = [];
        qtde_cargo_ind = [];
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).experiencia_cargo)))
               qtde_cargo = [qtde_cargo length(cand(i).experiencia_cargo)];
               qtde_cargo_ind = [qtde_cargo_ind i];
           else
               dados(i,j) = 0;
           end
        end
        
        [valores, indices] = sort(qtde_cargo,'descend');
        
        qtde_cargo_ind = qtde_cargo_ind(indices);
       
        v = 100;

        for i=1:length(qtde_cargo_ind)
           dados(qtde_cargo_ind(i),j) = v;
           v = v - 1;
        end           
   elseif(strcmp(criterios{j,1},'experiencia_duracao'))
        expduracao = [];
        expduracao_ind = [];
        for i=1:NId
           if(criterios{j,2} <= cand(i).experiencia_duracao)
               expduracao = [expduracao cand(i).experiencia_duracao];
               expduracao_ind = [expduracao_ind i];
           else
               dados(i,j) = 0;
           end
        end
        
        [valores, indices] = sort(expduracao,'descend');
        
        expduracao_ind = expduracao_ind(indices);
       
        v = 100;

        for i=1:length(expduracao_ind)
           dados(expduracao_ind(i),j) = v;
           v = v - 1;
        end            
   elseif(strcmp(criterios{j,1},'experiencia_nivel'))
        qtde_expnivel = [];
        qtde_expnivel_ind = [];
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).experiencia_nivel)))
               qtde_expnivel = [qtde_expnivel length(cand(i).experiencia_nivel)];
               qtde_expnivel_ind = [qtde_expnivel_ind i];
           else
               dados(i,j) = 0;
           end
        end
        
        [valores, indices] = sort(qtde_expnivel,'descend');
        
        qtde_expnivel_ind = qtde_expnivel_ind(indices);
       
        v = 100;

        for i=1:length(qtde_expnivel_ind)
           dados(qtde_expnivel_ind(i),j) = v;
           v = v - 1;
        end           
   elseif(strcmp(criterios{j,1},'competencias'))
        qtde_comp = [];
        qtde_comp_ind = [];
        
        for i=1:NId
            
           [linhasValores,colunasValores] = size(cand(i).competencias_valores);
           
           for l=1:linhasValores
               
               inds = find(cellfun(@isempty,cand(i).competencias_valores(l,:)));
               
               if(length(inds) > 0)
                    inds = inds(1)-1;
               else
                    inds = find(~cellfun(@isempty,cand(i).competencias_valores(l,:)));
                    inds=inds(end);
               end
               
               if(all(ismember(criterios{j,2},cand(i).competencias_valores(l,1:inds))))
                   qtde_comp = [qtde_comp length(cand(i).competencias_valores)];
                   qtde_comp_ind = [qtde_comp_ind i];
               else
                   dados(i,j) = 0;
               end
           end
        end
        
        [valores, indices] = sort(qtde_comp,'descend');
        
        qtde_comp_ind = qtde_comp_ind(indices);
       
        v = 100;

        for i=1:length(qtde_comp_ind)
           dados(qtde_comp_ind(i),j) = v;
           v = v - 1;
        end           
   elseif(strcmp(criterios{j,1},'salario'))
       melhores_salarios = [];
       melhores_salarios_ind = [];
       
       for i=1:NId
            if((criterios{j,2} >= cand(i).objetivos_salario))
                melhores_salarios = [melhores_salarios cand(i).objetivos_salario];
                melhores_salarios_ind = [melhores_salarios_ind i];
            else
                dados(i,j) = 0;
            end
       end
       
       [valores,indices] = sort(melhores_salarios);
       
       melhores_salarios_ind = melhores_salarios_ind(indices);
       
       v = 100;
       
       for i=1:length(melhores_salarios_ind)
           dados(melhores_salarios_ind(i),j) = v;
           v = v - 1;
       end           
   elseif(strcmp(criterios{j,1},'objetivos_areas'))
        for i=1:NId
            
           [linhasValores,colunasValores] = size(cand(i).objetivos_profissional_areas);
           
           for l=1:linhasValores
               
               inds = find(cellfun(@isempty,cand(i).objetivos_profissional_areas(l,:)));
               
               if(length(inds) > 0)
                    inds = inds(1)-1;
               else
                    inds = find(~cellfun(@isempty,cand(i).objetivos_profissional_areas(l,:)));
                    inds=inds(end);
               end
                           
               if(all(ismember(criterios{j,2},cand(i).objetivos_profissional_areas(l,1:inds))))
                   dados(i,j) = 100;
               else
                   dados(i,j) = 0;
               end
           end
        end           
   elseif(strcmp(criterios{j,1},'objetivos_cargo'))
        for i=1:NId
            
           [linhasValores,colunasValores] = size(cand(i).objetivos_profissional_cargo);
           
           for l=1:linhasValores
               
               inds = find(cellfun(@isempty,cand(i).objetivos_profissional_cargo(l,:)));
               
               if(length(inds) > 0)
                    inds = inds(1)-1;
               else
                    inds = find(~cellfun(@isempty,cand(i).objetivos_profissional_cargo(l,:)));
                    inds=inds(end);
               end
                           
               if(all(ismember(criterios{j,2},cand(i).objetivos_profissional_cargo(1:inds))))
                   dados(i,j) = 100;
               else
                   dados(i,j) = 0;
               end
           end
        end           
   elseif(strcmp(criterios{j,1},'objetivos_niveis'))
        for i=1:NId
           if(all(ismember(criterios{j,2},cand(i).objetivos_niveis)))
               dados(i,j) = 100;
           else
               dados(i,j) = 0;
           end
        end
   end
   
end

%%%%%%%%%%%%%%%%%%
% Fim da Parte 2 %
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parte 3: Executando o AHP e o PROMETHEE II e retornando o resultado %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = ahp(Ncrit);

listaDeCandidatos = tomadaDeDecisao(dados,w,listaIDs);

end