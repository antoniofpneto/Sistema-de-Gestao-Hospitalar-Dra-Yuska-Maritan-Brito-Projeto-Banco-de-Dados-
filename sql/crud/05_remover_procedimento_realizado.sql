-- =========================================================================
-- 3.5 REMOVER UM PROCEDIMENTO REALIZADO
--     (apenas se ainda não houver faturamento associado)
-- =========================================================================
-- Usamos a flag "faturado" da tabela PROCEDIMENTO_REALIZADO como trava:
-- só é permitido excluir o registro se faturado = FALSE.

DELETE FROM PROCEDIMENTO_REALIZADO
WHERE id_atendimento = 5
  AND id_procedimento = 6
  AND faturado = FALSE;