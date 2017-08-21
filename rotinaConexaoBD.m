clear all;
close all;
clc;

javaaddpath('C:\Users\Vinicius\Dropbox\Projeto Multidisciplinar\Algoritmo de Tomada de Decisão\mongo-java-driver-3.0.0-rc0.jar');
import com.mongodb.*;
import org.bson.types.ObjectId;

mongoClient = MongoClient(); % Estabelece a conexao
db = mongoClient.getDB('melhores_candidatos'); % Pega o esquema do banco a ser utilizado
events = db.getCollection('curriculos'); % Seleciona a tabela 'curriculos' do banco

ID = '590a66ccde3d881e25bd651f';

query = BasicDBObject('_id', ObjectId(ID));

cursor = events.find(query); % Este cursor aponta para o id da query, aí consigo pegar todas as informações do candidato com arquele id, aí é só resetar o cursor para a lista de ids que eu receber

cursor = events.find();

% Referencia: https://stackoverflow.com/questions/25606877/convert-data-from-mongodb-into-native-matlab-format-via-java-driver

n = 1;
while cursor.hasNext()
    event(n).id   = cursor.next().get('_id');
    event(n).id = char(event(n).id);
    event(n).ultAtu  = cursor.curr().get('ultima_atualizacao');
    event(n).ultAtu = char(event(n).ultAtu);
    event(n).des        = cursor.curr().get('desempregado');
    event(n).url      = cursor.curr().get('url');
    event(n).bairro      = cursor.curr().get('bairro');
    event(n).cidade        = cursor.curr().get('cidade');
    event(n).defic        = cursor.curr().get('deficiencia');
    event(n).sexo        = cursor.curr().get('sexo');
    event(n).idade        = cursor.curr().get('idade');
    event(n).dispviag        = cursor.curr().get('disponibilidade_viagem');
    event(n).estciv        = cursor.curr().get('estado_civil');
    event(n).est        = cursor.curr().get('estado');
    event(n).cnh        = cursor.curr().get('cnh');
    
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
    event(n).idiomas_nivel = nivel;
    event(n).idiomas_lingua = lingua;
    
    % event(389) e' interessante para teste
    % digite 'event(389)' na janela de comando
    
    % Note que formacao, experiencia e competencias sao do mesmo tipo que
    % idiomas. Entao tente fazer a mesma coisa
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
       inicio = [inicio,tempFormacao{i}.get('inicio')];
    end
    
    event(n).formacao_conclusao = conclusao;
    event(n).formacao_curso = curso;
    event(n).formacao_grau = grau;
    event(n).formacao_inicio = inicio;    

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
    
    event(n).experiencia_cargo = cargo;
    event(n).experiencia_duracao = duracao;
    event(n).experiencia_nivel = nivel;
    
    tempCompetencias = cursor.curr().get('competencias');
    tempCompetencias = tempCompetencias.toArray.cell;
    
    N3 = length(tempCompetencias);
    
    event(n).competencias_valores = cell(6,10);
    
    for i=1:N3
       tempValores = tempCompetencias{i}.get('valores');
       tempValores = tempValores.toArray.cell;
       
       N4 = length(tempValores);
    
       valores={};
       for j=1:N4
            valores = [valores,tempValores{j}]; 
       end
       event(n).competencias_valores(i,1:N4) = valores;       
    end

    tempObjetivos = cursor.curr().get('objetivos');
    
    tempSalario = tempObjetivos.get('salario');
    tempProfissional = tempObjetivos.get('profissional');
    tempNiveis = tempObjetivos.get('niveis');
    
    % Desmembrando o campo 'salario' de 'objetivos'
    event(n).objetivos_salario = tempSalario.get('min');
    
    % Desmembrando o campo 'profissional' de 'objetivos'
    tempProfissional = tempProfissional.toArray.cell;
    
    N5 = length(tempProfissional);
        
    event(n).objetivos_profissional_areas = cell(10,10);
    event(n).objetivos_profissional_cargo = cell(10,2);
    
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
        event(n).objetivos_profissional_areas(i,1:N6) = areas; 
        
        cargo = {};
        for j=1:N7
           cargo = [cargo,tempCargo{j}]; 
        end
        event(n).objetivos_profissional_cargo(i,1:N7) = cargo;
    end
    
    % Desmembrando o campo 'niveis' de 'objetivos'
    tempNiveis = tempNiveis.toArray.cell;
    
    N7 = length(tempNiveis);
    
    niveis = {};
    
    for i=1:N7
        niveis = [niveis,tempNiveis{i}];
    end
    event(n).objetivos_niveis = niveis;
    
    if(~isempty(event(n).cnh))
        event(n).cnh = char(event(n).cnh.toArray.cell);
    end
    
    n = n + 1;
end

cursor.close();