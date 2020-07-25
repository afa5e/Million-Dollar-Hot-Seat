open "queries.txt" for input as #file
rawQuestions$ = input$(#file, lof(#file))
close #file

dim questions$(40,5)

LoF = 5272 '''Q2 has a chunk that the code decides to consistently skip, to counteract this, another copy of the missing section was added to allow the program to recognise the start of the question.
for i = 0 to 39
  EoQ = instr(rawQuestions$, "#", 2)
  questions$(i, 1) = left$(rawQuestions$, EoQ-1)
  rawQuestions$ = right$(rawQuestions$, LoF-EoQ) '''5261
  LoF = LoF-EoQ
next

for i = 0 to 39
  EoQ = instr(questions$(i, 1),"?")
  EoA = instr(mid$(questions$(i, 1), EoQ + 2), ";")-1
  'Finds all chars between the end of the question (plus 2 to account for spacing and punctuation) and the end of the answer.
  questions$(i, 2) = mid$(questions$(i, 1), EoQ + 2, EoA)
  'Finds all chars between the positions of the first semicolon and the 2nd semicolon.
  questions$(i, 3) = left$(mid$(questions$(i, 1), EoA + EoQ + 3), instr(mid$(questions$(i, 1), EoA + EoQ + 3), ";") - 1)
  EoSecA = instr(mid$(questions$(i, 1), EoA + EoQ + 3), ";") - 1
  'Finds all chars between the positions of the 2nd semicolon and the third semicolon.
  questions$(i, 4) = left$(mid$(questions$(i, 1), EoA + EoQ + EoSecA + 4), instr(mid$(questions$(i, 1), EoA + EoQ + EoSecA + 4), ";") - 1)
  EoThrdA = instr(mid$(questions$(i, 1), EoA + EoQ + EoSecA + 4), ";") - 1
  'Finds all chars from the last semicolon and the end.
  questions$(i, 5) = mid$(questions$(i, 1), EoA + EoQ + EoSecA + EoThrdA + 5)
  questions$(i, 1) = left$(questions$(i, 1), EoQ)
<<<<<<< HEAD
  print questions$(i, 4)

=======
>>>>>>> 1504450fab5198ac7252b3b5102e959a86f883ec
next
