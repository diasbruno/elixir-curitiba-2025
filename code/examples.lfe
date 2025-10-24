(include-lib "./destructuring-bind.lfe")
(include-lib "./with-pattern.lfe")
(include-lib"./defstate.lfe")

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

;; define a simple state machine

(deffsm order ((processing-order
                :allowed-transtions (packaging denied-order)
                :events ((order-confirmed (lambda (state event)
                                            (cons 'packaging '())))
                         (order-denied (lambda (state event)
                                         (cons 'denied-order (cdr event))))))
               (packaging
                :allowed-transtions (in-transit)
                :events ((packaging-done (lambda (state event)
                                           (cons 'in-transit '())))))
               (in-transit
                :allowed-transtions (delivered rejected)
                :events ((costumer-received (lambda (state event)
                                              (cons 'delivered '())))
                         (costumer-rejected (lambda (state event)
                                              (cons 'rejected '())))))))

;; get the api

(order-api)

;; get all the states of the fsm

(order-states)

;; get all the events from the fsm

(order-events)

;; simple execution

(let ((state (cons 'a 1))
      (events (list (cons 'b '()))))
  (=:= state
       (lists:foldl (lambda (event state)
                      (order state event))
                    state
                    events)))

(let ((state (cons 'processing-order 1))
      (events (list
               (cons 'order-confirmed '())
               (cons 'packaging-done '())
               (cons 'costumer-received '()))))
  (=:= (cons 'delivered '())
       (lists:foldl (lambda (event state)
                      (order state event))
                    state
                    events)))

(let ((state (cons 'processing-order 1))
      (events (list
               (cons 'order-denied 'out-of-stock))))
  (=:= (cons 'denied-order 'out-of-stock)
       (lists:foldl (lambda (event state)
                 (order state event))
               state
               events)))

(let ((state (cons 'processing-order 1))
      (events (list
               (cons 'order-confirmed `())
               (cons 'packaging-done `())
               (cons 'order-denied 'out-of-stock))))
  (=:= (cons 'in-transit '())
       (lists:foldl (lambda (event state)
                  (order state event))
                state
                events)))
