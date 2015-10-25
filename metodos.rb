# encoding: utf-8
require './classes'

def analise_lexica(nome_do_arquivo)

  arquivo = File.read(File.dirname(__FILE__)+'/gramaticas/'+nome_do_arquivo.chomp, :encoding => 'utf-8').strip

  # Este bloco lê o arquivo de entrada e o subdivide em um vetor de vetores. Cada vetor representa
  # uma regra de formação da gramática

  gramatica = [[]]
  regra=0
  wirth = [[]]
  term_buffer = ''
  term_aberto = false

  # Lista de todos os caracteres que são válidos como nomes de Terminais e N-Terminais
  caracteres_validos_para_nomes = 'a'.upto('z').to_a + 0.upto(9).to_a + 'A'.upto('Z').to_a + %w(- _ ")


  arquivo.split(//).each do |char| # Separa letra a letra
    gramatica[regra] << char if char != "\n" # Adiciona ao vetor a letra se não for CRLF
    if char == '.' # Se for ponto, vai para a proxima regra
      regra += 1
      gramatica.push([])
    end
  end
  gramatica.pop

  gramatica.each_with_index do |regra_n, indice_regra|

    regra_n.each_with_index do |char, j|
      case char
        when '='
          wirth[indice_regra] << Termo.new(char, 'definicao')

        when '.'
          wirth[indice_regra] << Termo.new(char, 'fim_de_regra')

        when '('
          termo = Termo.new(char, 'parenteses')
          termo.set_lado('abre')
          wirth[indice_regra] << termo

        when ')'
          termo = Termo.new(char, 'parenteses')
          termo.set_lado(:'fecha')
          wirth[indice_regra] << termo

        when '['
          termo = Termo.new(char, 'colchetes')
          termo.set_lado('abre')
          wirth[indice_regra] << termo

        when ']'
          termo = Termo.new(char, 'colchetes')
          termo.set_lado('fecha')
          wirth[indice_regra] << termo

        when '{'
          termo = Termo.new(char, 'chaves')
          termo.set_lado('abre')
          wirth[indice_regra] << termo

        when '}'
          termo = Termo.new(char, 'chaves')
          termo.set_lado('fecha')
          wirth[indice_regra] << termo

        when '|'
          wirth[indice_regra] << Termo.new(char, 'separador')

        when ' '
          # Espaço, não deve fazer nada

        else # Caso não seja nenhum dos caracteres acima

                  if caracteres_validos_para_nomes.include? char # Se não for um dos casos acima, é tratado aqui, como T ou NT

                    if char == '"' # Abre aspas
              if term_aberto # Fecha aspas
                term_aberto = false
                term_buffer << char
                termo = Termo.new(term_buffer, 'terminal')
                wirth[indice_regra] << termo
                term_buffer = ''

              else
                term_aberto = true
                term_buffer << char
              end

            else # Não é aspas
              term_buffer << char if term_aberto

              unless term_aberto
                term_aberto = true
                term_buffer << char
              end

              unless caracteres_validos_para_nomes.include? regra_n[j+1]
                termo = Termo.new(term_buffer, 'nao_terminal')
                wirth[indice_regra] << termo
                term_buffer = ''
                term_aberto = false
              end
            end
          end
      end
    end
    wirth << []
  end
  puts 'Análise léxica concluída'
  wirth.pop
  wirth # Retorna os tokens
end

def analise_sintatica(regras)


  automato = AutomatoDePilhaEstruturado.new # Criação do autômato

  regras.each_with_index do |regra, n_regra|

    submaquina = Submaquina.new # Para cada regra temos uma submáquina

    # Esta parte do código se refere ao algoritmo apresentado na aula 3, disponível em https://goo.gl/RwYL4H

    # Esta pilha armazenas as aberturas de parenteses/chaves/colchetes/barras verticais para controle de estados
    pilha=[]
    estado = 0
    contador = 2


    # Neste bloco são postos valores nulos entre os tokens para escrever seus estados
    regra.each_with_index do |token, n_token|

      if n_token == 0 # Se o token for o primeiro, significa que é o nome da submáquina
        submaquina.set_nome(token.get_nome)
      elsif token.get_tipo == 'definicao' # Se for '=', não faça nada, só pule
      end


      # Nesta parte o algoritmo é aplicado

      if n_token > 1

        case token.get_tipo

          when 'terminal'

          when 'nao_terminal'
          when 'parenteses'
          when 'parenteses'
          when 'colchetes'
          when 'chaves'
          when 'fim_de_regra'

        end

      end
    end
    # Agora a submáquina é inserida dentro do autômato
    if n_regra == 0 # Se for a primeira regra, significa que é a primeira submáquina, a raiz.
      submaquina.set_primaria(true)
      automato.set_submaquina_inicial(submaquina.get_nome)
    end
    automato.add_submaquina(submaquina.get_nome, submaquina)
  end
end

