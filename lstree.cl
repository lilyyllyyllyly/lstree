(defun format-pad (text pad &rest args)
  (if (<= pad 0)
    (apply (function format) (cons t (cons text args))) ; if padding <= 0, just call format normally
    (apply (function format) (cons t (cons (format nil "~~~at~a" pad text) args))))) ; otherwise... i wont even attempt to explain

(defun dir-contents (&optional path padding max-depth follow-links depth)
  "lists contents of directory in the specified path"

  (setf depth (or depth 0)) ; if depth is nil, set it to 0
  (setf path  (or path #P"./")) ; if path is nil, set it to the current directory
  (if (and max-depth (> depth max-depth)) (return-from dir-contents)) ; if max-depth was passed, stop

  (let* ((contents-path (merge-pathnames path (pathname "*"))) ; = #P"/full/path/*"
         (files (directory contents-path :directories nil :follow-links follow-links)) ; list of files inside path
         (dirs  (directory contents-path :files nil :follow-links follow-links)))      ; list of directories inside path

    (dolist (file files)
      (format-pad "~a~%" (* depth padding) (enough-namestring (truename file) (truename path)))) ; print name of file

    (dolist (dir dirs)
      (format-pad "~a~%" (* depth padding) (enough-namestring (truename dir) (truename path))) ; print name of directory
      (dir-contents dir padding max-depth follow-links (+ depth 1))))) ; list directory contents

(defun print-help ()
  (format t "Usage: lstree [OPTION...] [DIRECTORY...]~%")
  (format t "List contents of DIRECTORY(s) recursively, with a tree view.~%~%")

  (format t "If no DIRECTORY is specified, lists contents of the current directory.~%~%")

  (format t "Long options do not use an equal sign (=). Unrecognized options are treated as paths.~%")
  (format t "  -h, --help~30tshow this help page~%")
  (format t "  -m, --max-depth DEPTH~30tdescend at most DEPTH directories~%")
  (format t "  -f, --follow-links~30tfollow symbolic or hard links and show their directory contents~%")
  (format t "  -p, --padding VALUE~30tseparate inner files/directories with VALUE spaces~%")
  )

(defun error-quit (err &rest args)
  (apply (function format) (cons t (cons (concatenate 'string "ERROR: " err) args)))
  (format t "try 'lstree --help' for more information.")
  (quit 1))

(defun main ()
  (let ((paths nil) (padding 2) (max-depth nil) (follow-links nil) (is-padding nil) (is-depth nil))
    (dolist (arg (cdr *command-line-argument-list*)) ; parsing arguments
      (cond
        (is-depth
          (let ((depth (or (parse-integer arg :junk-allowed t) ; try to parse arg as an integer
                           (error-quit "Provided max depth '~a' is not a valid integer~%" arg)))) ; if invalid error out
            (setf max-depth depth) ; setting max-depth to the provided depth value
            (setf is-depth nil))) ; dont treat next arg as a depth value again

        (is-padding
          (let ((new-pad (or (parse-integer arg :junk-allowed t) ; try to parse arg as an integer
                           (error-quit "Provided max depth '~a' is not a valid integer~%" arg)))) ; if invalid error out
            (setf padding new-pad) ; setting padding to the provided value
            (setf is-padding nil))) ; dont treat next arg as padding again
        
        ((or (string= arg "-h")
             (string= arg "--help"))
          (print-help) (return-from main))

        ((or (string= arg "-m")
             (string= arg "--max-depth"))
          (setf is-depth t)) ; treat next arg as depth value

        ((or (string= arg "-f")
             (string= arg "--folow-links"))
          (setf follow-links t))

        ((or (string= arg "-p")
             (string= arg "--padding"))
         (setf is-padding t)) ; treat next arg as padding

        (t ; if its not a valid option, treat it as a path
          (let* ((path (concatenate 'string arg "/")) ; adding '/' to the end in case the user types ".." instead of "../" etc.
                 (new-paths (cons path paths))) ; creating a new list with the new path included
            (setf paths new-paths))))) ; setting paths to the new list

      (if (not paths) (push nil paths)) ; adding nil to paths if none were specified, listing the current directory

      ; list contents of specified paths
      (dolist (path paths)
        (cond
          ((or (not path) (directory path)) ; if its a valid directory
            (if (second paths) (format t "~%~a:~%" (truename path))) ; if theres more than one path, specify which one is being listed
            (dir-contents path padding max-depth follow-links)) ; list contents

          (t (error-quit "Directory not found: '~a'~%" path)))))) ; otherwise, throw error

