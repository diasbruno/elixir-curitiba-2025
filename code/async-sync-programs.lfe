(defmacro async-call-process (to-process data)
  `(! ,to-process ,data))

(defmacro sync-call-process (to-process data receives)
  `(progn
     (! ,to-process (cons (self) ,data))
     (receive
       ,@receives)))

(defmacro with-process (process data receives)
  `(let ((,(car process) (spawn (lambda ()
                                  (receive
                                    ,@(cdr process))))))
     (sync-call-process p ,data ,receives)))
