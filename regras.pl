% ============================================
% CLASSIFICACAO_JURIDICA
% ============================================
% Descobre qual o tipo de crime baseado nos fatos
% Roubo = furto + violência
% Furto = pegar coisa alheia sem violência

classificacao_juridica(Caso, roubo) :-
    caso(Caso, furto),
    fatos_caso(Caso, violencia(sim)),
    !. % Corta aqui, é roubo mesmo

classificacao_juridica(Caso, furto_qualificado) :-
    caso(Caso, furto),
    tem_qualificadora(Caso, _),
    !. % Corta aqui, é furto qualificado

classificacao_juridica(Caso, furto) :-
    caso(Caso, furto),
    !. % Furto simples

classificacao_juridica(Caso, Tipo) :-
    caso(Caso, Tipo). % Outros tipos

% ============================================
% TEM_QUALIFICADORA
% ============================================
% Verifica se o caso tem alguma qualificadora
% Qualificadoras tornam o crime mais grave

tem_qualificadora(Caso, Qual) :-
    fatos_caso(Caso, qualificadora(Qual)).

% ============================================
% REGRA_INSIGNIFICANCIA
% ============================================
% Princípio da insignificância - STF
% Requisitos:
% 1. Valor muito baixo (< 10% SM)
% 2. Sem violência
% 3. Sem qualificadoras
% 4. Sem exceções (tipo reincidência)

regra_insignificancia(Caso) :-
    % Valor tem que ser irrisório
    valor_irrisorio(Caso),
    
    % Sem violência
    fatos_caso(Caso, violencia(nao)),
    
    % Sem qualificadoras
    \+ tem_qualificadora(Caso, _),
    
    % Não pode ter exceções que impedem
    \+ excecao_insignificancia(Caso).

% ============================================
% EXCECAO_INSIGNIFICANCIA
% ============================================
% Exceções que impedem aplicar insignificância
% Mesmo com valor baixo, se é reincidente não rola

excecao_insignificancia(Caso) :-
    fatos_caso(Caso, reincidente(sim)).

% Pode ter mais exceções aqui tipo:
% - maus antecedentes
% - habitualidade delitiva
% etc...

% ============================================
% REGRA_FURTO_PRIVILEGIADO
% ============================================
% Furto privilegiado - art. 155, §2º CP
% Requisitos:
% 1. Ser primário
% 2. Valor pequeno (até 20% SM)
% 3. Sem violência
% 4. Ser furto (não roubo)

regra_furto_privilegiado(Caso) :-
    % Tem que ser furto
    caso(Caso, furto),
    
    % Primário (nunca foi condenado antes)
    fatos_caso(Caso, primario(sim)),
    
    % Valor pequeno
    pequeno_valor(Caso),
    
    % Sem violência
    fatos_caso(Caso, violencia(nao)).

% ============================================
% CAUSAS_CASO
% ============================================
% Pega todas as causas de redução de pena do caso
% Tipo: confissão, devolveu o bem, etc.

causas_caso(Caso, Causas) :-
    findall(Causa, causa_aplicavel(Caso, Causa), Causas).

% Cada causa de redução possível:
causa_aplicavel(Caso, confissao_espontanea) :-
    fatos_caso(Caso, confissao_espontanea(sim)).

causa_aplicavel(Caso, devolucao_bem) :-
    fatos_caso(Caso, devolucao_bem(sim)).

causa_aplicavel(Caso, furto_privilegiado) :-
    regra_furto_privilegiado(Caso).

% ============================================
% AUXILIAR
% ============================================

valor_irrisorio(Caso) :-
    fatos_caso(Caso, valor_bem(Valor)),
    salario_minimo(SM),
    Limite is SM * 0.1,
    Valor =< Limite.

pequeno_valor(Caso) :-
    fatos_caso(Caso, valor_bem(Valor)),
    salario_minimo(SM),
    Limite is SM * 0.2,
    Valor =< Limite.

% ============================================
% LIMITE_IRRISORIO
% ============================================
% Calcula o limite de insignificância (10% SM)

limite_irrisorio(Limite) :-
    salario_minimo(SM),
    Limite is SM * 0.1.