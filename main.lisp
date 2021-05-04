(defconstant db-path "./cds.db")
(defvar *db* nil)

(defun wipe-db ()
  (setq *db* nil))

(defun save-db (filename)
  (with-open-file (out filename
                   :direction :output
                   :if-exists :supersede)
    (with-standard-io-syntax
      (print *db* out))))

(defun load-db (filename)
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))

(defun make-cd (title artist rating ripped)
  (list :title title :artist artist :rating rating :ripped ripped))

(defun add-record (cd)
  (push cd *db*))

(defun fprint-db ()
  (dolist (cd *db*)
	(format t "~{~a:~10t~a~%~}~%" cd)))

(defun prompt-read (prompt)
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun prompt-for-cd ()
  (make-cd
   (prompt-read "Title")
   (prompt-read "Artist")
   (or (parse-integer (prompt-read "Rating") :junk-allowed t) nil)
   (prompt-read "Ripped [y/n]")))

(defun prompt-for-cd-loop ()
  (loop (add-record (prompt-for-cd))
		(if (not (y-or-n-p "Another? [y/n]: "))
			(if (not (y-or-n-p "Save? [y/n]: "))
				(progn
				  (save-db db-path)
				  (return))))))

(progn
  (load-db db-path)
   (prompt-for-cd-loop))

