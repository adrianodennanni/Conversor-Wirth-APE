# encoding: utf-8

# Cada estado é um objeto, para o programa manuseá-lo mais facilmente
class Estado

  def initialize(nome)
    @nome=nome
    @inicial=false
    @aceitacao=false
    @chamada_submaquina=false
    @proximos_estados={} # Hash
    @simbolos_validos=[] # Array
  end

  def set_como_inicial
    @inicial=true
  end

  def set_como_aceitacao
    @aceitacao=true
  end

  def set_como_chamada_submaquina
    @chamada_submaquina=true
  end

  def set_proximo_estado(elemento, estado)
    @proximos_estados[elemento]=estado
    @simbolos_validos << elemento
  end

  def get_nome
    @nome
  end

  def get_simbolos_validos
    @simbolos_validos
  end

  def is_chamada_submaquina?
    @chamada_submaquina
  end

  def is_inicial?
    @inicial
  end

  def is_aceitacao?
    @aceitacao
  end

  def consumir(elemento)
    @proximos_estados[elemento] unless nil
  end

  def set_submaquina_chamada(submaquina)
    @submaquina_chamada=submaquina
  end

  def get_submaquina_chamada
    @submaquina_chamada unless nil
  end

  def set_estado_retorno(estado)
    @estado_retorno=estado
  end

  def get_estado_retorno
    @estado_retorno unless nil
  end

end