--- src/hayat.lisp.orig	2019-10-21 03:38:59 UTC
+++ src/hayat.lisp
@@ -2205,6 +2205,25 @@
       (or (alike1 (exp-pt (get-datum (datum-var (car l)))) (exp-pt (car l)))
 	  (return () ))))
 
+;; Patch borrowed from SageMath: 0001-taylor2-Avoid-blowing-the-stack-when-diff-expand-isn
+;;
+;; SUBTREE-SEARCH
+;;
+;; Search for subtrees, ST, of TREE that contain an element equal to BRANCH
+;; under TEST as an immediate child and return them as a list.
+;;
+;; Examples:
+;;   (SUBTREE-SEARCH 2 '(1 2 3)) => '((1 2 3))
+;;   (SUBTREE-SEARCH 2 '(1 2 2 3)) => '((1 2 2 3))
+;;   (SUBTREE-SEARCH 2 '(1 (2) 3)) => '((2))
+;;   (SUBTREE-SEARCH 4 '(1 (2) 3)) => NIL
+;;   (SUBTREE-SEARCH 2 '(1 (2) 3 (2))) => '((2) (2))
+
+(defun subtree-search (branch tree &optional (test 'equalp))
+  (unless (atom tree)
+    (if (find branch tree :test test) (list tree)
+        (mapcan (lambda (child) (subtree-search branch child test)) tree))))
+
 (defun taylor2  (e)
  (let ((last-exp e))	    ;; lexp-non0 should be bound here when needed
   (cond ((assolike e tlist) (var-expand e 1 () ))
@@ -2248,9 +2267,32 @@
 		 ((null l) t)
 		 (or (free e (car l)) (return ()))))
 	 (newsym e))
-	(t (let ((exact-poly () ))	; Taylor series aren't exact
-	      (taylor2 (diff-expand e tlist)))))))
+	(t
+         ;; When all else fails, call diff-expand to try to expand e around the
+         ;; point as a Taylor series by taking repeated derivatives. This might
+         ;; fail, unfortunately: If a required derivative doesn't exist, then
+         ;; DIFF-EXPAND will return a form of the form "f'(x)" with the
+         ;; variable, rather than the expansion point in it.
+         ;;
+         ;; Sometimes this works - in particular, if there is a genuine pole at
+         ;; the point, we end up passing a sum of terms like x^(-k) to a
+         ;; recursive invocation and all is good. Unfortunately, it can also
+         ;; fail. For example, if e is abs(sin(x)) and we try to expand to first
+         ;; order, the expression "1/1*(cos(x)*sin(x)/abs(sin(x)))*x^1+0" is
+         ;; returned. If we call taylor2 on that, we will end up recursing and
+         ;; blowing the stack. To avoid doing so, error out if EXPANSION
+         ;; contains E as a subtree. However, don't error if it occurs as an
+         ;; argument to %DERIVATIVE (in which case, we might well be fine). This
+         ;; happens from things like taylor(log(f(x)), x, x0, 1).
 
+         (let* ((exact-poly nil) ; (Taylor series aren't exact)
+                (expansion (diff-expand e tlist)))
+           (when (find-if (lambda (subtree)
+                            (not (eq ($op subtree) '%derivative)))
+                          (subtree-search e expansion))
+             (exp-pt-err))
+           (taylor2 expansion))))))
+
 (defun compatvarlist (a b c d)
    (cond ((null a) t)
 	 ((or (null b) (null c) (null d)) () )
@@ -3024,7 +3066,21 @@
        (and (or (member '$inf pt-list :test #'eq) (member '$minf pt-list :test #'eq))
 	    (unfam-sing-err)))
 
-(defun diff-expand (exp l)		;l is tlist
+;; DIFF-EXPAND
+;;
+;; Expand EXP in the variables as specified in L, which is a list of tlists. If
+;; L is a singleton, this just works by the classic Taylor expansion:
+;;
+;;    f(x) = f(c) + f'(c) + f''(c)/2 + ... + f^(k)(c)/k!
+;;
+;; If L specifies multiple expansions, DIFF-EXPAND works recursively by
+;; expanding one variable at a time. The derivatives are computed using SDIFF.
+;;
+;; In some cases, f'(c) or some higher derivative might be an expression of the
+;; form 1/0. Instead of returning an error, DIFF-EXPAND uses f'(x)
+;; instead. (Note: This seems bogus to me (RJS), but I'm just describing how
+;; EVAL-DERIV works)
+(defun diff-expand (exp l)
   (check-inf-sing (mapcar (function caddr) l))
   (cond ((not l) exp)
 	(t
