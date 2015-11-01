# encoding: utf-8

# Cada estado é um objeto, para o programa manuseá-lo mais facilmente
class Estado

  def initialize(nome, submaquina_mae)
    @nome=nome
    @submaquina_mae = submaquina_mae
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

  def get_submaquina_mae
    @submaquina_mae
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
    @estados= {}
    @alfabeto= ['ε']
  end

  def get_nome
    @nome
  end

  def set_nome(nome)
    @nome=nome
  end

  def get_estado(nome)
    @estados[nome]
  end

  def set_estado(estado)
    @estados[estado.get_nome]=estado
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

  def get_alfabeto
    @alfabeto
  end

  def add_elemento_alfabeto(elemento)
    @alfabeto << elemento
  end


end

class AutomatoDePilhaEstruturado

  def initialize()
    @submaquinas= {} # As submaquinas serão armazenados em um hash
    @nome_maquina_inicial=nil
    @estados_aceitacao=[]
    @pilha=[]
    @alfabeto=['ε']
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

  def get_alfabeto
    @alfabeto
  end

  def add_elemento_alfabeto(elemento)
    @alfabeto << elemento
  end

  def add_estados_aceitacao(estado)
    @estados_aceitacao << estado
  end

  def get_estados_aceitacao
    @estados_aceitacao
  end


  def run(nome_do_arquivo, verbose)
    cadeia = File.read(File.dirname(__FILE__)+'/gramaticas/'+nome_do_arquivo.chomp, :encoding => 'utf-8').strip.split(' ')

    _estado=@submaquinas[@nome_maquina_inicial].get_estado(0)

    catch(:interrupcao) do
      while cadeia.size > 0 do

        unless @alfabeto.include? cadeia.first
          puts (_estado.get_nome.to_s+' --'+cadeia.first+'--> ?') if verbose
          puts "A cadeia não foi aceita pelo Autômato. O símbolo '#{cadeia.first}' não foi definido no Alfabeto do Autômato."
          throw(:interrupcao)
        end

        unless unless _estado.get_simbolos_validos.include? cadeia.first or _estado.is_chamada_submaquina?

                 if _estado.get_simbolos_validos.include? 'ε'
                   if verbose
                     print (_estado.get_nome.to_s+' --ε')
                   end
                   (_estado=_estado.consumir('ε'))
                   if verbose
                     puts ('--> '+_estado.get_nome.to_s)
                   end

                 else
                   puts (_estado.get_nome.to_s+' --'+cadeia.first+'--> ?')
                   puts "A cadeia não foi aceita pelo Autômato. O estado '#{_estado.get_nome}' não apresenta transições consumindo '#{cadeia.first}'."
                   throw(:interrupcao)
                 end
               end
        end

        if _estado.is_chamada_submaquina?

          # Verifica se há uma trasição normal antes de chamar uma submáquina
          if _estado.get_simbolos_validos.include? cadeia[0]
            print (_estado.get_nome.to_s+' --') if verbose
            elemento=cadeia.shift
            print elemento if verbose
            _estado=_estado.consumir(elemento)
            puts ('--> '+_estado.get_nome.to_s) if verbose


          else
            if verbose
              puts('O estado '+_estado.get_nome.to_s+' fez uma chamada para a máquina '+_estado.get_submaquina_chamada+
                       ', empilhado o estado '+_estado.get_estado_retorno.get_nome.to_s)
            end

            @pilha << _estado.get_estado_retorno
            _estado=@submaquinas[_estado.get_submaquina_chamada].get_estado_inicial
          end


        elsif _estado.is_aceitacao? and !@pilha.empty? and !_estado.get_submaquina_mae.is_primaria?
          # Retorno
          print('O estado '+_estado.get_nome.to_s+' realizou um retorno para o estado ') if verbose
          _estado=@pilha.pop
          puts(_estado.get_nome) if verbose


        else
          print (_estado.get_nome.to_s+' --') if verbose
          elemento=cadeia.shift
          print elemento if verbose
          _estado=_estado.consumir(elemento)
          puts ('--> '+_estado.get_nome.to_s) if verbose
        end
      end

      catch(:fim) do
        loop do
          if _estado.is_aceitacao?
            puts('A cadeia foi aceita pelo autômato.')
            throw(:fim)
          else
            if _estado.consumir('ε').nil?
              puts('O estado alcancado '+_estado.get_nome.to_s+' não é de aceitação. A cadeia foi recusada.')
              throw(:fim)
            else
              _estado=_estado.consumir('ε')
            end

          end
        end


      end

    end

  end


end

class Termo

  def initialize(nome, tipo)
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