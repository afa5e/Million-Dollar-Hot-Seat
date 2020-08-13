global questions$, names$, correct, chosenAnswer$, currentUserIndex, questionIndex, million, swapped$
call onFirstRun

sub readQuestionFile
  open "queries.txt" for input as #file
  rawQuestions$ = input$(#file, lof(#file))
  close #file

  dim questions$(40,6) '40 rows of questions: question|correct|answer|answer|answer|answered correctly or not (1, 0)
  dim names$(3, 3) '4 rows of user data: name|score|random float to sort against|swapped
  million = 0

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
    names$(i, 3) = "0"
  next
  currentUserIndex = int(rnd(1) * 4)
  sort names$(), 0, 3, 2
  timer 1000, mainLoop
  wait
end sub

sub onFirstRun
  call readQuestionFile
  call setup
end sub

sub mainLoop
  timer 0
  while million = 0
    [someoneFailedTheMillionDollarQuestion]
    cls
    print "Current player is "; names$(currentUserIndex, 0); " they are on "; names$(currentUserIndex, 1); " points."
    call querySub
    [reQuery]
    swapped$ = "0"
    call checkAnswer
    if val(names$(currentUserIndex, 1)) >=20 then
        call millionDollarQuestion
    end if
    if swapped$ = "1" then
      call reaskQuery
      goto [reQuery]
    end if
    cls
  wend
  call millionDollarQuestion
  end
end sub

end
sub querySub
  questionIndex = int(rnd(1) * 40)
  noQuestions = 0
  while questions$(questionIndex, 6) = "1"
    questionIndex = int(rnd(1) * 40)
    noQuestions = noQuestions + 1
    if noQuestions = 50 then
      noQuestions = 0
      for a = 0 to 39
        questions$(a, 6) = "0"
      next
    end if
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

sub reaskQuery
    print "Current player is "; names$(currentUserIndex, 0)
    print questions$(questionIndex, 1)
    print "A: ", shuffledQuestions$(2, 1)
    print "B: ", shuffledQuestions$(3, 1)
    print "C: ", shuffledQuestions$(4, 1)
    print "D: ", shuffledQuestions$(5, 1)
end sub

sub checkAnswer
  [reCheck]
  input "Answer: "; chosenAnswer$
  if lower$(chosenAnswer$) = "swap" then
    if val(names$(currentUserIndex, 3)) = 0 then
      names$(currentUserIndex, 3) = "1"
      call swapPlayers
      cls
      swapped$ = "1"
      goto [endSwapSub]
    else
      print "Swap is unavailable for the current user."
      timer 1500, [unswappableWait]
      wait
      [unswappableWait]
      timer 0
      cls
      call reaskQuery
      goto [reCheck]
    end if
  end if
  if lower$(chosenAnswer$) = "help" then
    print "For help, please view readme.md using github."
    timer 1500, [helped]
    wait
    [helped]
    timer 0
    cls
    call reaskQuery
    goto [reCheck]
  end if
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
  if chosenAnswer$ = questions$(questionIndex, 2) then
    call incrementScore
    if rnd(1) > 0.5 then
        questions$(questionIndex, 6) = "1" ' Questions are only marked as completed once a player has CORRECTLY answered the question.
    end if
    correct = 1
    print "Correct; "; names$(currentUserIndex, 0); " is now on "; names$(currentUserIndex, 1); " correct answer(s)."
    if val(names$(currentUserIndex, 1)) >= 20 then
      million = 1
      goto [endSwapSub]
    end if
    if val(names$(currentUserIndex, 1)) mod 5 = 0 then
      input "Would the current user like to withdraw their current winnings? Yes/No: "; giveUp$
      if lower$(giveUp$) = "yes" then
        print "You won $"; 2^val(names$(currentUserIndex, 1)); "."
        names$(currentUserIndex, 1) = "-1"
      end if
      call swapPlayers
    end if
    timer 1000, [waiting]
  else
    correct = 0
    print "Incorrect; "; names$(currentUserIndex, 0); " is now on "; names$(currentUserIndex, 1); " correct answer(s)."
    print "You have now lost."
    names$(currentUserIndex, 1) = "-1"
    call swapPlayers
    timer 1000, [waiting]
  end if
  wait
  [waiting]
  timer 0
  cls
  [endSwapSub]
end sub

sub incrementScore
  '''placeholder$ = str$(val(names$(currentUserIndex, 1)) + 1) May need to be used if the following line does not work.
  names$(currentUserIndex, 1) = str$(val(names$(currentUserIndex, 1)) + 1)
  if val(names$(currentUserIndex, 1)) >= 20 then
    million = 1
  end if
end sub

sub swapPlayers
  l = 0
  do
    currentUserIndex = (currentUserIndex + 1) mod 4
    l = l + 1
    if l > 5 then
      print "Everyone lost"
      end
    end if
  loop while names$(currentUserIndex, 1) = "-1"
end sub

sub millionDollarQuestion
  print "35010 copies of Liberty Basic Silver Edition Question:"
  print "Which of the following is not a valid price for a Liberty Basic installation tier?"
  print "a) $19.95"
  print "b) $29.95"
  print "c) $49.95"
  print "d) $00.00"
  input "Answer: "; millionAnswer$
  if lower$(millionAnswer$) = "a" then
    print "You won either 20992 copies of Liberty Basic Gold edition and still have $25.60 left; or 35010 copies of Liberty Basic Silver edition and still have $26.50 change."
    wait
    end
  end if
  names$(currentUserIndex, 1) = "-1"
  goto [someoneFailedTheMillionDollarQuestion]
end sub
