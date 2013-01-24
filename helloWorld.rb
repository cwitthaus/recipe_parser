require 'underscore_win32ole'
word = WIN32OLE.new('word.application')
word.documents.open('~/Desktop/Broiled Onion Canapes.doc')
 
# select whole text
word.selection.wholestory
 
# read the selection
puts word.selection.text.chomp
 
# close document
word.activedocument.close( false ) # no save dialog, just close it
 
# quit word
word.quit