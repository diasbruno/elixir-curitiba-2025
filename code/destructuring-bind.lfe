(defun find-lambda-rest (ls)
  (lists:splitwith (lambda (a) (not (=:= '&rest a))) ls))

(defun make-let-bindings (bgs)
  (lists:foldl
   (lambda (binding acc)
     (let (((cons counter lb) acc))
       (cons (+ 1 counter)
             (lists:append lb `((,binding (lists:nth ,counter target)))))))
   (cons 1 '())
   bgs))

(defun rest-let-bindings (rest target count)
  (if (=:= rest '())
    '()
    `((,(lists:nth 2 rest)
       (lists:sublist target ,count ,(length target))))))

(defmacro destructuring-bind (bindings target body)
  "Place values from TARGET to the BINDINGS declared
 and execute the expression declare in BODY.

 Example:

 (destructuring-bind (a b c &rest rest)
     (list 1 2 3 4 5 6)
   (io:format \"~p and ~p and ~p and ~p~n\" (list a b c rest)))"
  (let* (;; split at &rest symbol (a b ... &rest rest) => #((a b ...) (&rest rest))
         ((tuple bgs rest) (find-lambda-rest bindings))
         ;; generate how many bindings we built
         ((cons count let-bindings) (make-let-bindings bgs))
         ;; check if &rest was declared
         (rest-let-binding (rest-let-bindings rest target count))
         ;; put it all together
         (let-bindings-rest
          (lists:append let-bindings rest-let-binding)))
    `(let* ((target ,target)
            ,@let-bindings-rest)
       ,body)))
