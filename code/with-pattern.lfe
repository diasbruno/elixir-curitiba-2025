(defmacro with-sqlite-connection (connection-var connection-string body)
  `'(let ((,connection-var (sqlite:connection connection-string)))
      ,body
      (sqlite:disconnect ,connection-var)))

