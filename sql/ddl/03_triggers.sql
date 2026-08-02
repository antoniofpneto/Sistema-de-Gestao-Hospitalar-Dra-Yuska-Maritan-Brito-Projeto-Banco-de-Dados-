-- Script SQL responsável por criar as triggers da etapa 02, as funções executadas nos triggers estão no arquivo de stored_procedures

CREATE TRIGGER trg_check_sobreposicao_escala
BEFORE INSERT OR UPDATE ON ESCALA
FOR EACH ROW
EXECUTE FUNCTION trg_check_sobreposicao_escala_fn();

CREATE TRIGGER trg_audita_atendimento
AFTER INSERT OR UPDATE OR DELETE ON ATENDIMENTO
FOR EACH ROW
EXECUTE FUNCTION trg_audita_atendimento_fn();

CREATE TRIGGER trg_atualiza_media_procedimentos
AFTER INSERT OR UPDATE OR DELETE ON PROCEDIMENTO_REALIZADO
FOR EACH ROW
EXECUTE FUNCTION trg_atualiza_media_procedimentos_fn();