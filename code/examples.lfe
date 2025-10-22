(c "./destructuring-bind.lfe")

(destructuring-bind (a b c &rest rest)
    (list 1 2 3 4 5 6)
  (io:format "~p and ~p and ~p and ~p~n" (list a b c rest)))
