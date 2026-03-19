# End-to-End Data Pipeline: Da Assiduidade à Previsibilidade Financeira em Clínica de Terapia Ocupacional Pediátrica  

<p align="center">
  <img src="https://img.shields.io/badge/Status-Completed-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Python-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/SQL-red?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/SQLite-lightblue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/ETL-orange?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Data%20Pipeline-grey?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Dimensional%20Modeling-purple?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Power%20BI-yellow?style=for-the-badge"/>
</p>  

>[!NOTE] 
>Esse projeto foi desenvolvido a partir de dados reais de um consultório de Terapia Ocupacional Pediátrica.  
>Por questões de segurança e privacidade, todos os dados foram **anonimizados**.

## Problema de Negócio

O consultório de Terapia Ocupacional operava com um modelo de atendimento que vinculava diretamente a receita à presença do paciente, com **cobrança realizada por sessão**. Na prática, esse modelo gerava um incentivo indireto ao **absenteísmo:** como não havia custo ao faltar, parte dos pacientes não mantinha a regularidade necessária.

Com o tempo, esse comportamento passou a gerar **dois impactos** críticos:
- **Impacto Terapêutico:** Faltas recorrentes interrompiam a continuidade do tratamento, reduzindo a eficácia das intervenções e prejudicando o desenvolvimento clínico dos pacientes.
- **Impacto Operacional:** O faturamento tornava-se altamente volátil e imprevisível. Horários reservados e não utilizados geravam ociosidade na agenda e dificultavam o planejamento financeiro do consultório.  

Apesar desses efeitos serem percebidos na rotina, **não havia visibilidade sobre a real dimensão do problema**. Os dados de agenda, sessões e faturamento estavam dispersos em planilhas isoladas e controles manuais, o que impossibilitava responder perguntas essenciais, como:
- Qual é a taxa real de faltas por paciente?
- Existem padrões sazonais ou comportamentais de faltas?
- Quanto o absenteísmo impacta financeiramente o faturamento mensal?
- Como a frequência das sessões influencia a estabilidade da receita?  

Dessa forma, surgiu a hipótese de migrar para um **modelo de mensalidade recorrente**, onde as famílias pagariam por um pacote fixo de atendimentos. A expectativa era reduzir o absenteísmo e trazer previsibilidade financeira.

Embora análises exploratórias em Excel dessem **indícios positivos**, era necessário **estruturar os dados de forma robusta e consistente**, permitindo transformar uma percepção operacional em evidência quantitativa, validar a eficácia do modelo recorrente e acompanhar os principais indicadores de forma contínua e confiável.

## Objetivo do Projeto

O objetivo central deste projeto foi **estruturar e centralizar** as informações operacionais e financeiras do consultório, criando uma **infraestrutura de dados** confiável para validar a **transição** do modelo de pagamento por sessão para o modelo de mensalidade recorrente.

Para viabilizar uma análise orientada a dados, foi construído um pipeline end-to-end com foco em:

- **Consolidação de Histórico:** integração de dados de atendimentos e faturamento anteriormente dispersos;
- **Modelagem Dimensional:** implementação de uma arquitetura **Star Schema** para análise de assiduidade e performance;
- **Geração de Evidências:** criação de indicadores consistentes para mensurar o impacto da mudança no absenteísmo e na previsibilidade de receita.

Com isso, o projeto permite transformar uma hipótese operacional em evidência quantitativa, apoiando decisões que aumentam a continuidade do tratamento e previsibilidade financeira.

## Estratégia da Solução

### Visão Analítica

A construção da solução partiu da necessidade de validar uma hipótese observada na prática: a correlação entre o modelo de cobrança por sessão e as taxas de absenteísmo e a estabilidade da receita.

A estratégia foi estruturada na comparação de cenários "antes e depois", permitindo avaliar os efeitos da transição para o modelo de mensalidade a partir de duas perspectivas:

- **Comportamental:** análise dos padrões de assiduidade e frequência real dos pacientes;
- **Financeira:** impacto direto das faltas na receita e na previsibilidade do faturamento futuro.

Para mensurar o sucesso, foram definidos indicadores-chave (KPIs), como:

**- Taxa de Faltas;**  
**- Crescimento da receita;**  
**- Variância de Receita;**  

Essa estrutura analítica permitiu transformar uma percepção operacional em um problema mensurável, auditável e orientado a dados.

### Implementação Técnica

O plano de desenvolvimento focou em transformar registros manuais e descentralizados em uma arquitetura de dados robusta e automatizada, estabelecendo uma Fonte Única de Verdade (SSOT) baseada nos princípios de Analytics Engineering.

A execução foi dividida em quatro pilares:

#### 1. Automação da Ingestão e Limpeza (Python)
Extração e tratamento automatizado dos dados brutos para garantir reprodutibilidade, eliminando inconsistências manuais e duplicidades.

#### 2. Modelagem Dimensional e Governança (SQL/SQLite)
Estruturação em modelo Star Schema para garantir performance em análises complexas.

#### 3. Implementação de Data Quality Gates
Camada de validação com 14 testes que garantem integridade referencial e aderência às regras de negócio antes da disponibilização dos dados, mitigando riscos de decisões baseadas em informações inconsistentes.

#### 4. Dataviz e Storytelling (Power BI)
Construção de um dashboard executivo focado em evidenciar o impacto da transição do modelo de negócio, tanto na saúde financeira da clínica quanto na adesão ao tratamento dos pacientes.