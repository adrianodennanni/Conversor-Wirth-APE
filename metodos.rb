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
    n_estado = 1
    contador = 2


    # Neste bloco são postos valores nulos entre os tokens para escrever seus estados
    regra.each_with_index do |token, n_token|

      if n_token == 0 # Se o token for o primeiro, significa que é o nome da submáquina
        submaquina.set_nome(token.get_nome)
      elsif token.get_tipo == 'definicao' # Se for '=', crie os estados inicial e final
        # Estado Inicial
        estado = Estado.new(0)
        estado.set_como_inicial
        submaquina.set_estado(estado)

        # Estado Final
        estado = Estado.new(1)
        estado.set_como_aceitacao
        submaquina.set_estado(estado)

        # Coloca na pilha esse par
        pilha << [submaquina.get_estado(0), submaquina.get_estado(1)]

        # Define como estado anterior o Estado 0
        @estado_anterior = submaquina.get_estado(0)
      end


      # Nesta parte o algoritmo é aplicado

      if n_token > 1

        case token.get_tipo

          when 'terminal'
            # Soma mais 1 aos contadores
            n_estado+=1
            contador+=1

            # Verifica se já existe um próximo estado. Se não existe, cria ele
            if submaquina.get_estado(n_estado).nil?
              submaquina.set_estado(Estado.new(n_estado))
            end
            @estado_anterior.set_proximo_estado(token.get_nome, submaquina.get_estado(n_estado))
            @estado_anterior=submaquina.get_estado(n_estado)

          when 'nao_terminal'
          when 'parenteses'
                      # No caso de abrir parenteses
                      if token.get_lado == 'abre'
                        # Soma mais 1 aos contadores
                        contador +=1
                        n_estado+=1

                        # Nesta situação somente empilha os estados relativos ao início e fim do parenteses
                        if submaquina.get_estado(n_estado).nil?
                          submaquina.set_estado(Estado.new(n_estado))
                        end
                        pilha << [@estado_anterior, submaquina.get_estado(n_estado)]

                        # No caso de fechar parenteses
                      else
                        @estado_anterior.set_proximo_estado('ε', pilha[-1][1])
                        @estado_anterior=submaquina.get_estado(pilha[-1][1].get_nome)
                        pilha.pop


                      end

          when 'colchetes'
            if token.get_lado == 'abre'
              # Soma mais 1 aos contadores
              contador +=1
              n_estado+=1

              # Nesta situação somente empilha os estados relativos ao início e fim do parenteses
              if submaquina.get_estado(n_estado).nil?
                submaquina.set_estado(Estado.new(n_estado))
              end
              pilha << [@estado_anterior, submaquina.get_estado(n_estado)]
              @estado_anterior.set_proximo_estado('ε', submaquina.get_estado(n_estado))

            else
              @estado_anterior.set_proximo_estado('ε', pilha[-1][1])
              @estado_anterior=submaquina.get_estado(pilha[-1][1].get_nome)
              pilha.pop

            end

          when 'chaves'
            if token.get_lado == 'abre'
              # Soma mais 1 aos contadores
              contador +=1
              n_estado+=1

              # Cria o próximo estado caso não exista
              if submaquina.get_estado(n_estado).nil?
                submaquina.set_estado(Estado.new(n_estado))
              end

              # Gera a transição
              @estado_anterior.set_proximo_estado('ε', submaquina.get_estado(n_estado))

              # Empilha
              pilha << [submaquina.get_estado(n_estado), submaquina.get_estado(n_estado)]

              # Atualiza o estado anterior
              @estado_anterior=submaquina.get_estado(n_estado)

            else
              @estado_anterior.set_proximo_estado('ε', pilha[-1][1])
              @estado_anterior=submaquina.get_estado(pilha[-1][1].get_nome)
              pilha.pop
            end

          when 'separador'
            @estado_anterior.set_proximo_estado('ε', pilha[-1][1])
            @estado_anterior=submaquina.get_estado(pilha[-1][0].get_nome)

          when 'fim_de_regra'
            @estado_anterior.set_proximo_estado('ε', pilha[-1][1])
            @estado_anterior=submaquina.get_estado(pilha[-1][1].get_nome)
            pilha.pop

          else
            puts 'Algo ocorreu de errado durante a leitura'
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

