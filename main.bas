open "queries.txt" for input as #file
rawQuestions$ = input$(#file, lof(#file))
close #file

dim questions$(40,5)

LoF = 5272 '''Q2 has a chunk that the code decides to consistently skip, to counteract this, another copy of the missing section was added to allow the program to recognise the start of the question.
for i = 0 to 39
  EoQ = instr(rawQuestions$, "#", 2)
  questions$(i, 1) = left$(rawQuestions$, EoQ-1)
  print left$(rawQuestions$, EoQ-1)
  rawQuestions$ = right$(rawQuestions$, LoF-EoQ) '''5261
  LoF = LoF-EoQ
next
