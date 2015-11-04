# encoding: utf-8
require './classes' # Carrega as classes do arquivo classes.rb
require './metodos' # Carrega os métodos do arquivo metodos.rb


puts 'Conversor de gramáticas em notação de Wirth para a forma de Autômatos de Pilha Estruturados equivalentes',
     'PCS 2508 - Linguagens e Compiladores - Profº João José Neto',
     'Adriano Dennanni - NUSP 8043308', ''


puts 'Digite o nome do arquivo na pasta "/gramaticas" contendo a gramática na Notação de Wirth:'

automato = analise_sintatica(analise_lexica(gets.chomp))

puts 'Deseja executar o autômato? (s/n)'
if gets.chomp == 's'
  puts 'Deseja ativar o modo verbose? (s/n)'
  verbose=gets.chomp
  if verbose == 's'
    verbose=true
  else
    verbose = false
  end
  puts 'Digite o nome do arquivo: '
  automato.run('programa.txt', verbose)

end