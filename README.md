# ⚖️ Sistema de Apoio à Decisão Penal — README

Este repositório contém um sistema baseado em **lógica e regras** voltado para auxiliar na análise penal, permitindo avaliar decisões a partir de fatos, circunstâncias e enquadramentos legais. O projeto utiliza um conjunto de **regras estruturadas**, interpretações e inferências automáticas para gerar respostas explicativas e transparentes.

O objetivo é oferecer um mecanismo simples de consulta, onde o usuário informa um conjunto de dados ou características de um caso, e o sistema retorna conclusões justificadas.

---

## 📁 1. Estrutura do Repositório

```
Apoio-Decisao-Penal/
│
├── /Tema
    ├── saida_esperada.txt
    ├── enunciado.md
├── decisao.pl
├── dosimetria.pl
├── entrada.txt
├── explicacao.pl
├── precedentes.pl
├── principal.pl
├── regras.pl
├── saida.txt
├── README.md
```

---

## ▶️ 2. Como executar o sistema

### ✔️ Execução

Você pode excutar tanto na sua IDE preferida fazendo o git clone e executando o arquivo principal.pl

```bash
swipl -s principal.pl
```

Como tambem pode ir pelo SWI Prolog (app)
e consultar o arquivo prinicpal.pl

```bash
?- consult('principal.pl').
```

Você poderá:

* Escolher um arquivo de entrada
* Rodar o motor de inferência
* Visualizar explicações das regras ativadas

---

## 🧩 3. Como usar arquivos de entrada e saída

### 🔹 **Arquivo de entrada**

Um arquivo de entrada contém as características do caso, por exemplo:

```json
{
  "agente": "réu primário",
  "acao": "furto",
  "valor": 300,
  "violencia": false,
  "circunstancias": ["arrependimento posterior"]
}
```

### 🔹 **Arquivo de saída (gerado)**

O sistema gera um explicando:

* Qual regra foi ativada
* Qual resultado foi inferido
* Justificativas

Exemplo:

```json
{
  "classificacao": "furto simples",
  "pena_base": "1 a 4 anos",
  "atenuantes": ["réu primário", "arrependimento posterior"],
  "explicacao": "O sistema identificou que não houve violência e o valor é baixo, enquadrando o caso como furto simples..."
}
```

---

## 🧠 4. Como as regras foram construídas

As regras seguem uma estrutura lógica inspirada em sistemas especialistas:

### ✔️ Exemplo de regra

```python
if acao == "furto" and violencia is False and valor < 500:
    classificacao = "furto de pequeno valor"
    explicacao.append("Valor inferior a 500 reais e sem violência")
```

**Tipos de regras incluídas:**

* Classificação do crime
* Circunstâncias agravantes/atenuantes
* Seleção de pena base
* Explicações textuais geradas dinamicamente

Cada regra contém:

* Condições lógicas
* Conclusões
* Texto explicativo que o sistema adiciona como justificativa

---

## ⚙️ 5. Funcionamento do sistema

O sistema é composto por:

### 🔧 **1. Motor de Inferência**

Responsável por:

* Ler os dados de entrada
* Verificar quais regras se aplicam
* Executar todas as conclusões válidas
* Registrar explicações e justificativas

### 📘 **2. Interpretador de Regras**

* Lê a base de regras
* Organiza em grupos (classificação, pena, circunstâncias)

### 📤 **3. Módulo de Geração de Explicações**

* Consolida todas as regras acionadas
* Formata respostas explicadas

---

## 🔍 6. Exemplos de consultas e resultados esperados

### 🧪 **Consulta 1** — Furto simples sem violência

Entrada:

```json
{
  "acao": "furto",
  "valor": 300,
  "violencia": false,
  "agente": "primário"
}
```

Resultado esperado:

```json
{
  "classificacao": "furto simples",
  "pena_base": "1 a 4 anos",
  "explicacao": "O crime não envolve violência e o valor é considerado baixo..."
}
```

### 🧪 **Consulta 2** — Roubo com violência

Entrada:

```json
{
  "acao": "roubo",
  "violencia": true,
  "arma": true
}
```

Resultado esperado:

```json
{
  "classificacao": "roubo majorado",
  "pena_base": "4 a 10 anos",
  "agravantes": ["uso de arma"],
  "explicacao": "Foi identificada violência e uso de arma, enquadrando o caso como roubo majorado..."
}
```

### 🧪 **Consulta 3** — Atenuante por confissão

Entrada:

```json
{
  "acao": "estelionato",
  "confissao": true
}
```

Resultado esperado:

```json
{
  "classificacao": "estelionato",
  "atenuantes": ["confissão espontânea"],
  "explicacao": "A confissão espontânea foi reconhecida como atenuante conforme as regras..."
}
```

---

## 📚 7. Objetivo do Projeto

Criar um sistema simples, interpretável e transparente para:

* Auxiliar no estudo de sistemas especialistas
* Demonstrar raciocínio baseado em regras no contexto penal
* Gerar explicações claras e rastreáveis

---

## ✨ 8. Autora

**Giovanna Paiva Alves**
**Matheus Sanchez Duda**

Contribuições e melhorias são super bem‑vindas! 😊
