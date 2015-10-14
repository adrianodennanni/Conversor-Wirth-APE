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

  def is_inicial?
    @inicial
  end

  def set_como_aceitacao
    @aceitacao=true
  end

  def is_aceitacao?
    @aceitacao
  end

  def set_como_chamada_submaquina
    @chamada_submaquina=true
  end

  def is_chamada_submaquina?
    @chamada_submaquina
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

  def consumir(elemento)
    @proximos_estados[elemento] unless nil
  end


end

class Submaquina

  def initialize
    @primaria=false
  end

  def get_nome
    @nome
  end

  def set_nome(nome)
    @nome=nome
  end


  def set_estado_inicial(estado)
    @estado_inicial=estado
  end

  def get_estado_inicial
    @estado_inicial
  end

  def set_primaria(primaria) # Boolean
    @primaria=primaria
  end

  def is_primaria?
    @primaria
  end


end

class AutomatoDePilhaEstruturado

  def initialize()
    @submaquinas= {} # As submaquinas serão armazenados em um hash
    @nome_maquina_inicial=nil
    @estados_aceitacao=[]
    @pilha=[]
  end

  def add_submaquina(nome, submaquina)
    @submaquinas[nome] = submaquina
  end

  def get_submaquina(submaquina)
    @submaquinas[submaquina]
  end

  def set_submaquina_inicial(nome)
    @nome_maquina_inicial=nome
  end

  def get_submaquina_inicial
    @nome_maquina_inicial
  end

  def empilha(estado)
    @pilha << estado
  end

  def desempilha_e_retorna
    @pilha.pop
  end

  def add_estados_aceitacao(estado)
    @estados_aceitacao << estado
  end

  def get_estados_aceitacao
    @estados_aceitacao
  end


end

class Termo

  def initialize(nome,tipo)
    @nome=nome
    @tipo=tipo
  end

  def get_nome
    @nome
  end

  def get_tipo
    @tipo
  end

  def set_lado(lado)
    @lado=lado
  end

  def get_lado
    @lado
  end


end