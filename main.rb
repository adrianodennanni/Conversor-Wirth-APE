# encoding: utf-8
require './classes' # Carrega as classes do arquivo classes.rb
require './metodos' # Carrega os métodos do arquivo metodos.rb


puts 'Conversor de gramáticas em notação de Wirth para a forma de Autômatos de Pilha Estruturados equivalentes',
     'PCS 2508 - Linguagens e Compiladores - Profº João José Neto',
     'Adriano Dennanni - NUSP 8043308', ''


puts 'Digite o nome do arquivo na pasta "/gramaticas" contendo a gramática na Notação de Wirth:'

analise_sintatica(analise_lexica('g1.txt')) #gets.chomp))
