# Projeto SQL: Controle de Produção (TechMaricá)

O Que Foi Implementado

1. Estrutura do Banco
* **Tabelas:** Quatro tabelas principais ligadas por chaves (`Funcionarios`, `Maquinas`, `Produtos` e `Ordens`).
* **Dados:** O banco foi preenchido com dados realistas.

2. Consultas
* **Conexão de Dados:** Consultas complexas usando **JOINS** para ligar todas as tabelas.
* **Análise:** Uso de funções (`COUNT`, `DATEDIFF`) para gerar relatórios e métricas de produção.

3. Automação (VIEW, Procedure e Trigger)
* **VIEW:** Cria uma visão gerencial que junta todas as informações da produção.
* **Procedure:** Função para **registrar novas ordens** de produção de forma rápida e padronizada.
* **Trigger:** Automação que muda o status da ordem para **'FINALIZADA'** assim que a data de conclusão é inserida.
