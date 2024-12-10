DROP TABLE joga;
DROP TABLE especialista;
DROP TABLE papel;
DROP TABLE jogador;
DROP TABLE encontro; 
DROP TABLE recinto;

-- ----------------------------------------------------------------------

CREATE TABLE recinto ( 
  codigo      NUMERIC(3),
  nome        VARCHAR(30) NOT NULL,
  cidade      CHAR(3)     NOT NULL,        -- exo. LIS
  pais        CHAR(2)     NOT NULL,        -- exo. PT 
--
  CONSTRAINT pk_recinto
    PRIMARY KEY (codigo),
--
  CONSTRAINT ck_recinto_codigo
    CHECK (codigo > 0)
);


CREATE TABLE encontro (               	   -- de League of Legends
  ano         NUMERIC(4),                  -- ano da edição 
  fase        CHAR(2),	                 
  numero      NUMERIC(1),
  equipa1     CHAR(2)     NOT NULL,        -- identificadas pelo País
  equipa2     CHAR(2)     NOT NULL,
  recinto     NUMERIC(3)  NOT NULL,
--
  CONSTRAINT pk_encontro
    PRIMARY KEY (ano, fase, numero),
--
  CONSTRAINT ck_encontro_ano 	 
    CHECK (ano BETWEEN 1900 AND 2100),
--
  CONSTRAINT ck_encontro_fase
    CHECK (fase in ('OF','QF','SF','FF')), -- Oitavos de Final... Final
--
  CONSTRAINT fk_encontro_recinto
    FOREIGN KEY (recinto)
    REFERENCES recinto (codigo)
);


CREATE TABLE jogador (
  numero      NUMERIC(7),
  nome        VARCHAR(40) NOT NULL,
  nickname    VARCHAR(20) NOT NULL,        -- nickname unico
  pais        CHAR(2)     NOT NULL,        -- nacionalidade (exo. FR)
  genero      CHAR(1)     NOT NULL,
  nasc        NUMERIC(4)  NOT NULL,        -- ano de nascimento
  activ       NUMERIC(4)  NOT NULL,        -- ano de inicio de actividade
--
  CONSTRAINT pk_jogador
    PRIMARY KEY (numero),
--
  CONSTRAINT un_nickname
  	UNIQUE(nickname),
--
  CONSTRAINT ck_jogador_numero
    CHECK (numero > 0),
--
  CONSTRAINT ck_jogador_genero   
    CHECK (genero IN ('F','M')),     
--
  CONSTRAINT ck_jogador_nasc
    CHECK (nasc BETWEEN 1900 AND 2100), 
--
  CONSTRAINT ck_jogador_activ
    CHECK (activ BETWEEN 1900 AND 2100) 
);


CREATE TABLE papel (
  codigo      CHAR(9),                     -- exo. atirador, suporte ...
  descricao   VARCHAR(30) NOT NULL,
--
  CONSTRAINT pk_papel
    PRIMARY KEY (codigo),
--
  CONSTRAINT un_papel_descricao      
    UNIQUE (descricao)                     -- descricao unica
);


CREATE TABLE especialista (
  jogador     NUMERIC(7),
  papel       CHAR(9),                           
  tipo        CHAR(6),                     -- junior ou senior
--
  CONSTRAINT pk_especialista        
    PRIMARY KEY (jogador,papel),  
--
  CONSTRAINT ck_especialista
    CHECK (tipo in ('junior','senior')),     
--
  CONSTRAINT fk_especialista_jogador
    FOREIGN KEY (jogador)
    REFERENCES jogador (numero),
--
  CONSTRAINT fk_especialista_papel
    FOREIGN KEY (papel)
    REFERENCES papel (codigo)
);


CREATE TABLE joga (
  jogador       NUMERIC(7),
  enc_ano       NUMERIC(4),
  enc_fase  	CHAR(2),
  enc_numero  	NUMERIC(1),
  papel       	CHAR(9)    NOT NULL,       -- em que papel joga
  pontos        NUMERIC(3) NOT NULL,
--
  CONSTRAINT pk_joga
    PRIMARY KEY (jogador,enc_ano,enc_fase,enc_numero),
--
  CONSTRAINT ck_joga_pontos
    CHECK (pontos >= 0),
--
  CONSTRAINT fk_joga_jogador
    FOREIGN KEY (jogador,papel)
    REFERENCES especialista (jogador,papel),
--
  CONSTRAINT fk_joga_encontro
    FOREIGN KEY (enc_ano, enc_fase,enc_numero)
    REFERENCES encontro (ano,fase,numero)
);