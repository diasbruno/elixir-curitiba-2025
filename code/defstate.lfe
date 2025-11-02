(defun getf (ls place)
  (if (=:= (car ls) place)
    (cadr ls)
    (getf (cddr ls) place)))

(defun capture-transitions (transitions)
  (lists:foldl
   (lambda (handler acc)
     (let ((handler-name (car handler))
           ((tuple evs exps) acc))
       (tuple
        (cons (car handler) evs)
        (lists:append exps (list `(',(car handler)
                                   (funcall ,(cadr handler) state event)))))))
   (tuple (list) (list))
   (getf transitions ':events)))

(defmacro deffsm (name transitions)
  (let (((tuple evs exps)
         (lists:foldl (lambda (transition acc)
                        (let* (((tuple evs exps) acc)
                               ((tuple state-evs state-exps)
                                (capture-transitions (cdr transition))))
                          (tuple
                           (cons (tuple (car transition) state-evs) evs)
                           (lists:append
                            exps
                            `((',(car transition)
                               (case (car event)
                                 ,@state-exps
                                 (else (progn
                                        (io:format "[error] unhandled event ~p at state ~p~n expected events are: ~p~n"
                                                   (list event state '(,@state-evs)))
                                        state)))))))))
                      (tuple (list) (list))
                      transitions))
        (api-fn-name (list_to_atom (lists:append (atom_to_list name) "-api")))
        (states-fn-name (list_to_atom (lists:append (atom_to_list name) "-states")))
        (events-fn-name (list_to_atom (lists:append (atom_to_list name) "-events"))))

    `(progn
       (defun ,events-fn-name ()
         ',evs)
       (defun ,api-fn-name ()
         ',(lists:foldl (lambda (item acc)
                          (let (((tuple state es) item))
                            (lists:append acc es)))
                        '()
                        evs))

       (defun ,states-fn-name ()
         ',(lists:foldl (lambda (item acc)
                          (let (((tuple state es) item))
                            (cons state acc)))
                        '()
                        evs))

       (defun ,name (state event)
         (case (car state)
           ,@exps
           (else (progn
                (io:format "[error] unknown state ~p~n possible states are: ~p~n"
                           (list state (,states-fn-name)))
                state)))))))
