precedente_aplicavel(Tema, Tribunal, Tese) :-
    % Pega todos os precedentes desse tema
    findall(
        prec(Prioridade, Trib, Tese_),
        (
            precedente(_Id, Trib, Tema, Tese_, _Vinc),
            tribunal(Trib, prioridade(Prioridade), _)
        ),
        Precedentes
    ),
    % Ordena pela prioridade (maior primeiro)
    sort(1, @>=, Precedentes, [prec(_P, Tribunal, Tese)|_]).

% ============================================
% APLICA_PRECEDENTE
% ============================================
% Verifica se um precedente se aplica ao caso específico
% Olha se o tema do precedente faz sentido pro caso

aplica_precedente(Caso, insignificancia, Tribunal, Tese) :-
    % Verifica se pode aplicar insignificância
    valor_irrisorio(Caso),
    fatos_caso(Caso, violencia(nao)),
    precedente_aplicavel(insignificancia, Tribunal, Tese).

aplica_precedente(Caso, reincidencia_afasta_insignificancia, Tribunal, Tese) :-
    % Verifica se reincidência afasta a insignificância
    fatos_caso(Caso, reincidente(sim)),
    precedente_aplicavel(reincidencia_afasta_insignificancia, Tribunal, Tese).

aplica_precedente(Caso, furto_privilegiado, Tribunal, Tese) :-
    % Verifica se pode aplicar furto privilegiado
    caso(Caso, furto),
    fatos_caso(Caso, primario(sim)),
    pequeno_valor(Caso),
    fatos_caso(Caso, violencia(nao)),
    precedente_aplicavel(furto_privilegiado, Tribunal, Tese).

% ============================================
% HELPERS - VERIFICAÇÕES
% ============================================

% Valor irrisório: menos de 10% do salário mínimo
valor_irrisorio(Caso) :-
    fatos_caso(Caso, valor_bem(Valor)),
    salario_minimo(SM),
    Limite is SM * 0.1,
    Valor =< Limite.

% Pequeno valor: até 20% do salário mínimo (para privilegiado)
pequeno_valor(Caso) :-
    fatos_caso(Caso, valor_bem(Valor)),
    salario_minimo(SM),
    Limite is SM * 0.2,
    Valor =< Limite.
