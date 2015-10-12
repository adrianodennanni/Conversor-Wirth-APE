# encoding: utf-8
require './classes'

def analise_lexica(nome_do_arquivo)

  nome_do_arquivo='g1.txt' ### EXCLUIR
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
          wirth[indice_regra] << Termo.new(char, :definicao)

        when '.'
          wirth[indice_regra] << Termo.new(char, :fim_de_regra)

        when '('
          termo = Termo.new(char, :parenteses)
          termo.set_lado(:abre)
          wirth[indice_regra] << termo

        when ')'
          termo = Termo.new(char, :parenteses)
          termo.set_lado(:fecha)
          wirth[indice_regra] << termo

        when '['
          termo = Termo.new(char, :colchetes)
          termo.set_lado(:abre)
          wirth[indice_regra] << termo

        when ']'
          termo = Termo.new(char, :colchetes)
          termo.set_lado(:fecha)
          wirth[indice_regra] << termo

        when '{'
          termo = Termo.new(char, :chaves)
          termo.set_lado(:abre)
          wirth[indice_regra] << termo

        when '}'
          termo = Termo.new(char, :chaves)
          termo.set_lado(:fecha)
          wirth[indice_regra] << termo

        when ' '
          # Espaço, não deve fazer nada

        else

          if caracteres_validos_para_nomes.include? char  # Se não for um dos casos acima, é tratado aqui, como T ou NT

            if char == '"'  # Abre aspas
              if term_aberto # Fecha aspas
                term_aberto = false
                term_buffer << char
                termo = Termo.new(term_buffer, :terminal)
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
                termo = Termo.new(term_buffer, :nao_terminal)
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
  wirth.pop

end

