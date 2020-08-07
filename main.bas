global questions$, names$, correct, chosenAnswer$, currentUserIndex, questionIndex, winner
call onFirstRun

sub readQuestionFile
  open "queries.txt" for input as #file
  rawQuestions$ = input$(#file, lof(#file))
  close #file

  dim questions$(40,6) '40 rows of questions: question|correct|answer|answer|answer|answered correctly or not (1, 0)
  dim names$(3, 2) '4 rows of user data: name|score|random float to sort against
  winner = 0

  LoF = 5272 'Q2 has a chunk that the code decides to consistently skip, to counteract this, another copy of the missing section was added to allow the program to recognise the start of the question.
  for i = 0 to 39
    EoQ = instr(rawQuestions$, "#", 2)
    questions$(i, 1) = left$(rawQuestions$, EoQ-1)
    rawQuestions$ = right$(rawQuestions$, LoF-EoQ) '5261
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
    questions$(i, 6) = "0"
  next
end sub

sub setup
  for i = 0 to 3
    input "Name: "; names$(i, 0)
    cls
    names$(i, 1) = "0"
    names$(i, 2) = str$(rnd(1))
  next
  currentUserIndex = int(rnd(1) * 4)
  sort names$(), 0, 3, 2
  print "Player order is: "; names$(0, 0);", "; names$(1, 0);", "; names$(2, 0);", "; names$(3, 0)
  timer 1000, mainLoop
  wait
end sub

sub onFirstRun
  call readQuestionFile
  call setup
end sub

sub mainLoop
    timer 0
    while winner = 0
      call querySub
      call checkAnswer
      print "Current user: '"; names$(currentUserIndex, 0); "' is now on "; names$(currentUserIndex, 1); " correct answer(s)."
      call swapPlayers
    wend
    print "A player has won."
    end
end sub

end
sub querySub
  questionIndex = int(rnd(1) * 40)
  while questions$(questionIndex, 6) = "1"
    questionIndex = int(rnd(1) * 40) ' Questions are only marked as completed once a player has CORRECTLY answered the question.
  wend
  print questions$(questionIndex, 1)
  for i = 1 to 5
    shuffledQuestions$(i, 1) = questions$(questionIndex, i)
    shuffledQuestions$(i, 2) = str$(rnd(1))
  next
  sort shuffledQuestions$(), 2, 5, 2
  print "A: ", shuffledQuestions$(2, 1)
  print "B: ", shuffledQuestions$(3, 1)
  print "C: ", shuffledQuestions$(4, 1)
  print "D: ", shuffledQuestions$(5, 1)
end sub

sub checkAnswer
  input "Answer: "; chosenAnswer$
  select case lower$(chosenAnswer$)
    case "a"
      chosenAnswer$ = shuffledQuestions$(2, 1)
    case "b"
      chosenAnswer$ = shuffledQuestions$(3, 1)
    case "c"
      chosenAnswer$ = shuffledQuestions$(4, 1)
    case "d"
      chosenAnswer$ = shuffledQuestions$(5, 1)
  end select
  print questions$(questionIndex, 2)
  if chosenAnswer$ = questions$(questionIndex, 2) then
    call incrementScore
    questions$(questionIndex, 6) = "1"
    correct = 1
  else
    correct = 0
  end if
end sub
sub incrementScore
  '''placeholder$ = str$(val(names$(currentUserIndex, 1)) + 1) May need to be used if the following line does not work.
  names$(currentUserIndex, 1) = str$(val(names$(currentUserIndex, 1)) + 1)
  print names$(currentUserIndex, 1)
  if names$(currentUserIndex, 1) = "20" then
    winner = 1
  end if
end sub

sub swapPlayers
  do
    currentUserIndex = (currentUserIndex + 1) mod 4
  loop while not(names$(currentUserIndex, 1) = "-1")
end sub
