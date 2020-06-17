open "queries.txt" for input as #file
rawQuestions$ = input$(#file, lof(#file))
close #file

dim questions$(40,5)

nextQuestionPosition = 0
for i = 0 to 9
  EOQ = instr(rawQuestions$, "\n", nextQuestionPosition) - EOQ
  print mid$(rawQuestions$,nextQuestionPosition, EOQ)
  nextQuestionPosition = EOQ + 3
  '''questions$(i, 1) = mid$(rawQuestions$,nextQuestionPosition, EOQ)
next

print questions$
