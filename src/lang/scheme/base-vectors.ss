;;; -*- Gerbil -*-
;;; (C) vyzo at hackzen.org
;;; R7RS (scheme base) library -- implementation details
package: scheme

(export #t)

;; vectors
(defrules defvector-copy ()
  ((_ id copy-e subvector-e length-e)
   (def* id
     ((vec)
      (copy-e vec))
     ((vec start)
      (subvector-e vec start (length-e vec)))
     ((vec start end)
      (subvector-e vec start end)))))

(defrules defvector-copy! ()
  ((_ id move-e length-e)
   (def* id
     ((dest dest-start src)
      (move-e src 0 (length-e src) dest dest-start))
     ((dest dest-start src src-start)
      (move-e src src-start (length-e src) dest dest-start))
     ((dest dest-start src src-start src-end)
      (move-e src src-start src-end dest dest-start)))))

(defrules defvector-for-each ()
  ((_ id length-e ref-e)
   (def* id
     ((proc vec)
      (let (len (length-e vec))
        (let lp ((x 0))
          (when (##fx< x len)
            (proc (ref-e vec x))
            (lp (##fx+ x 1))))))
     ((proc vec1 vec2)
      (let* ((len1 (length-e vec1))
             (len2 (length-e vec2))
             (len (##fxmin len1 len2)))
        (let lp ((x 0))
          (when (##fx< x len)
            (proc (ref-e vec1 x) (ref-e vec2 x))
            (lp (##fx+ x 1))))))
     ((proc . vecs)
      (let* ((lens (map length-e vecs))
             (len (apply fxmin lens)))
        (let lp ((x 0))
          (when (##fx< x len)
            (apply proc (map (cut ref-e <> x) vecs))
            (lp (##fx+ x 1)))))))))

(defrules defvector-map ()
  ((_ id make-e length-e ref-e set-e)
   (def* id
     ((proc vec)
      (let* ((len (length-e vec))
             (res (make-e len)))
        (let lp ((x 0))
          (if (##fx< x len)
            (let (val (proc (ref-e vec x)))
              (set-e res x val)
              (lp (##fx+ x 1)))
            res))))
     ((proc vec1 vec2)
      (let* ((len1 (length-e vec1))
             (len2 (length-e vec2))
             (len (##fxmin len1 len2))
             (res (make-e len)))
        (let lp ((x 0))
          (if (##fx< x len)
            (let (val (proc (ref-e vec1 x) (ref-e vec2 x)))
              (set-e res x val)
              (lp (##fx+ x 1)))
            res))))
     ((proc . vecs)
      (let* ((lens (map length-e vecs))
             (len (apply fxmin lens))
             (res (make-e len)))
        (let lp ((x 0))
          (if (##fx< x len)
            (let (val (apply proc (map (cut ref-e <> x) vecs)))
              (set-e res x val)
              (lp (##fx+ x 1)))
            res)))))))

(defrules defvector->vector ()
  ((_ id length-e ref-e make-e is? set-e)
   (def (id vec (start 0) (end (length-e vec)))
     (let* ((len (fx- end start))
            (res (make-e len)))
       (let lp ((x 0))
         (if (##fx< x len)
           (let (val (ref-e vec (##fx+ start x)))
             (unless (is? val)
               (error "Illegal argument" vec x val))
             (set-e res x val)
             (lp (##fx+ x 1)))
           res))))))

(defrules defvector->list ()
  ((_ id length-e ref-e)
   (def (id vec start end)
     (let (len (length-e vec))
       (let ((start (fxmax start 0))
             (end (fxmin end len)))
         (let lp ((i (##fx- end 1)) (r []))
           (if (##fx>= i start)
             (lp (##fx- i 1)
                 (cons (ref-e vec i) r))
             r)))))))

(defrules defvector-fill! ()
  ((_ id length-e set-e is?)
   (def (id vec val start end)
     (unless (is? val)
       (error "Illegal argument" vec val))
     (let (len (length-e vec))
       (let ((start (fxmax start 0))
             (end (fxmin end len)))
         (let lp ((i start))
           (when (##fx< i end)
             (set-e vec i val)
             (lp (##fx+ i 1)))))))))

(defvector-for-each vector-for-each vector-length ##vector-ref)
(defvector-map r7rs-vector-map make-vector vector-length ##vector-ref ##vector-set!)
(defvector-copy r7rs-vector-copy vector-copy subvector vector-length)
(defvector-copy! vector-copy! subvector-move! vector-length)
(defvector->list vector->list* vector-length ##vector-ref)
(defvector-fill! vector-fill!* vector-length ##vector-set! true)

;; strings
(defvector-for-each string-for-each string-length ##string-ref)
(defvector-map string-map make-string string-length ##string-ref ##string-set!)
(defvector-copy r7rs-string-copy string-copy substring string-length)
(defvector-copy! string-copy! substring-move! string-length)
(defvector->vector vector->string vector-length ##vector-ref make-string char? ##string-set!)
(defvector->vector string->vector string-length ##string-ref make-vector true ##vector-set!)
(defvector->list string->list* string-length ##string-ref)
(defvector-fill! string-fill!* string-length ##string-set! char?)

;; byte vectors
(defvector-copy bytevector-copy u8vector-copy subu8vector u8vector-length)
(defvector-copy! bytevector-copy! subu8vector-move! u8vector-length)
