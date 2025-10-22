(c "./destructuring-bind.lfe")
(c "./with-pattern.lfe")

;; destructuring bind example

(destructuring-bind (a b c &rest rest)
                    (list 1 2 3 4 5 6)
                    (progn
                      (io:format "~p and ~p and ~p and ~p~n" (list a b c rest))))

;; with pattern

(with-sqlite-connection conn
                        ":memory:"
                        (progn
                          (print conn)))
