/*
recinto(codigo, nome, cidade, pais)
encontro(ano, fase, equipa1, equipa2, recinto) recinto REFERENCES recinto(codigo)
jogador(numero, nome, nickname, pais, genero, nasc, activ)
papel(codigo, descricao)
especialista(jogador, papel, tipo) jogador REFERENCES jogador(numero); papel REFERENCES papel(codigo)
joga(jogador, enc_ano, enc_fase,enc_numero, papel, pontos) jogador,papel REFERENCES especialista(jogador, papel); enc_ano,enc_fase,enc_numero REFERENCES encontro(ano,fase,numero)
*/

--1
/*
Nickname e país de todos os jogadores que já obtiveram pelo menos dez pontos 
em algum encontro realizado em Lisboa (LIS). O ano desses jogos também deverá 
ser apresentado; e os resultados ordenados de forma ascendente por ano, e 
descendente por país e nickname. Nota: pretende-se uma interrogação sem sub
interrogações: apenas com um SELECT.-
*/
SELECT jogador.nickname, jogador.pais, encontro.ano
FROM jogador, encontro, joga, recinto
WHERE jogador.numero = joga.jogador 
    AND encontro.ano = joga.enc_ano 
    AND encontro.fase = joga.enc_fase 
    AND encontro.numero = joga.enc_numero 
    AND joga.pontos >= 10 
    AND encontro.recinto = recinto.codigo
    AND recinto.cidade = 'LIS'
ORDER BY encontro.ano ASC, jogador.pais DESC, jogador.nickname DESC;
--2
/*
Número, nome, nickname, papel e país dos jogadores que são Senior em pelo 
menos um dos papeis: atirador e suporte, ou que tenham um nickname de 6 
caracteres, começado por ‘S’ e terminado por ‘r’ e tenham começado a jogar antes 
(*) do recente Torneio League of Legends realizado na Islândia (2021). Nota: 
pode usar construtores de conjuntos.
*/
SELECT jogador.numero, jogador.nome, jogador.nickname, papel.descricao, jogador.pais
FROM jogador, especialista, papel
WHERE jogador.numero = especialista.jogador 
    AND especialista.papel = papel.codigo 
    AND (especialista.tipo = 'senior' AND (papel.descricao = 'Atirador' OR papel.descricao = 'Suporte')
    OR (jogador.nickname LIKE 'S____r' AND jogador.activ < 2021));

--3
/*
Identificação dos encontros de semi-finais realizados em Paris (PAR) em que 
jogou, pelo menos, um jogador que iniciou actividade antes de 2021 e tem um 
nickname contendo ‘Purple’.
*/
SELECT encontro.*
FROM encontro, joga, jogador
WHERE encontro.fase = 'SF' 
    AND encontro.recinto = (SELECT codigo FROM recinto WHERE cidade = 'PAR')
    AND joga.jogador = jogador.numero 
    AND jogador.activ < 2021 
    AND jogador.nickname LIKE '%Purple%'
    AND encontro.ano = joga.enc_ano 
    AND encontro.fase = joga.enc_fase 
    AND encontro.numero = joga.enc_numero;

--4
/*
Nome, ano e país dos jogadores que nasceram antes do ano 2000, e que nunca 
participaram como atirador, em finais com equipas da Dinamarca (DK).
*/
SELECT jogador.nome, jogador.nasc, jogador.pais
FROM jogador
WHERE jogador.nasc < 2000 
    AND NOT EXISTS (
        SELECT 1 
        FROM joga, encontro 
        WHERE jogador.numero = joga.jogador 
            AND joga.papel = (SELECT codigo FROM papel WHERE descricao = 'Atirador')
            AND encontro.fase = 'FF' 
            AND (encontro.equipa1 = 'DK' OR encontro.equipa2 = 'DK')
            AND encontro.ano = joga.enc_ano 
            AND encontro.fase = joga.enc_fase 
            AND encontro.numero = joga.enc_numero
    );

--5
/*
Identificação dos encontros das fases finais (SF e FF) em que tenham participado 
jogadores islandeses (IS) junior em todos os papeis que existem. Nota: o resultado 
deve vir ordenado pelo ano de forma descendente, e pela fase e número do 
encontro de forma ascendente.
*/
SELECT encontro.*
FROM encontro, joga, jogador
WHERE (encontro.fase = 'SF' OR encontro.fase = 'FF') 
    AND jogador.pais = 'IS' 
    AND especialista.tipo = 'junior'
    AND joga.jogador = jogador.numero 
    AND joga.enc_ano = encontro.ano 
    AND joga.enc_fase = encontro.fase 
    AND joga.enc_numero = encontro.numero
ORDER BY encontro.ano DESC, encontro.fase ASC, encontro.numero ASC;

--6
/*
Número de encontros em que jogou cada jogador, em cada papel. Nota: os 
resultados devem ser ordenados, de forma ascendente, pelo nome e número do 
jogador, e de forma descendente pelo papel. 
*/
SELECT jogador.numero, papel.descricao, COUNT(*)
FROM jogador, joga, papel
WHERE jogador.numero = joga.jogador 
    AND joga.papel = papel.codigo
GROUP BY jogador.numero, papel.descricao
ORDER BY jogador.numero ASC, papel.descricao DESC;

--7
/*
Nome, número e país dos jogadores que participaram em mais finais (FF), em 
cada papel. Notas: em caso de empate, devem ser mostrados todos os jogadores 
em causa.
*/
SELECT jogador.nome, jogador.numero, jogador.pais
FROM jogador, joga, papel
WHERE jogador.numero = joga.jogador 
    AND joga.papel = papel.codigo 
    AND joga.enc_fase = 'FF'
GROUP BY jogador.nome, jogador.numero, jogador.pais
HAVING COUNT(*) = (
    SELECT MAX(contagem)
    FROM (
        SELECT COUNT(*) AS contagem
        FROM joga
        WHERE enc_fase = 'FF'
        GROUP BY jogador, papel
    ) AS maximo
);

--8
/*
Para cada ano de início de actividade, o número e nome do jogador que jogou em 
mais encontros. Apresentar também o número total de encontros em que jogou, e 
a maior e menor pontuação que obteve nesses encontros. Nota: em caso de empate 
do total de encontros, mostrar todos os jogadores em causa. 
*/
SELECT jogador.activ, jogador.numero, jogador.nome, COUNT(*) AS total_encontros, MAX(joga.pontos) AS max_pontos, MIN(joga.pontos) AS min_pontos
FROM jogador, joga
WHERE jogador.numero = joga.jogador
GROUP BY jogador.activ, jogador.numero, jogador.nome
HAVING COUNT(*) = (
    SELECT MAX(total)
    FROM (
        SELECT COUNT(*) AS total
        FROM jogador, joga
        WHERE jogador.numero = joga.jogador
        AND jogador.activ = jogador_activ.activ
        GROUP BY jogador.numero
    ) AS subquery
)
ORDER BY jogador.activ, jogador.numero;

--9
/*
Nickname, ano de nascimento e país dos jogadores que nasceram depois do mítico 
campeão de League of Legends, Faker (o coreano Lee Sang-hyeok, nasc: 1996), 
e que jogaram em menos de 4 encontros destes torneios de League of Legends, 
mesmo que não tenham jogado em nenhum. Pretende-se uma interrogação sem 
sub-interrogações: apenas com um SELECT. 
*/

SELECT nickname, nasc, pais
FROM jogador
LEFT JOIN joga ON jogador.numero = joga.jogador
GROUP BY nickname
HAVING nasc > 1996 AND COUNT(joga.jogador) < 4;