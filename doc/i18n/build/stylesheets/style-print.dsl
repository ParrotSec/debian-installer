<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY dbstyle SYSTEM "/usr/share/sgml/docbook/stylesheet/dsssl/modular/print/docbook.dsl" CDATA DSSSL>
]>
<style-sheet>
<style-specification use="docbook">
<style-specification-body>

(define %section-autolabel% 
  ;; Are sections enumerated?
   #t )

(define %paper-type%
  ;; Name of paper type
    "A4"
    ;;  "USletter"
    )
(define %hyphenation%
  ;; Allow automatic hyphenation?
    #t)

(define %default-quadding%
    'justify)

(define bop-footnotes
  ;; Make "bottom-of-page" footnotes?
  #t)

(define %admon-graphics%
  ;; Use graphics in admonitions?
  ;; Also removes black box around warnings
  #f)

(define ($peril$)
  (let* ((title     (select-elements 
		     (children (current-node)) (normalize "title")))
	 (has-title (not (node-list-empty? title)))
	 (adm-title (if has-title 
			(make sequence
			  (with-mode title-sosofo-mode
			    (process-node-list (node-list-first title))))
			(literal
			 (gentext-element-name 
			  (current-node)))))
	 (hs (HSIZE 2)))
  (if %admon-graphics%
      ($graphical-admonition$)
      (make display-group
	space-before: %block-sep%
	space-after: %block-sep%
	font-family-name: %admon-font-family%
	font-size: (- %bf-size% 1pt)
	font-weight: 'medium
	font-posture: 'upright
	line-spacing: (* (- %bf-size% 1pt) %line-spacing-factor%)
	  (make paragraph
	    space-before: %para-sep%
	    space-after: %para-sep%
	    start-indent: (+ (inherited-start-indent) (* 2 (ILSTEP)) 1em)
	    end-indent: (+ (inherited-end-indent) 1em)
	    font-family-name: %title-font-family%
	    font-weight: 'bold
	    font-size: hs
	    line-spacing: (* hs %line-spacing-factor%)
	    quadding: 'center
	    keep-with-next?: #t
	    adm-title)
	  (process-children)))))


</style-specification-body>
</style-specification>
<external-specification id="docbook" document="dbstyle">
</style-sheet>
