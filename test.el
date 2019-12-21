(write-region "stuff" nil "/Users/suzume/Documents/Code/brandelune.github.io/test.txt" nil t nil t)

(length myMarker)

(find-file-noselect "/Users/suzume/Documents/Code/brandelune.github.io/test2.xml")

;;;; generating my RSS item

(setq myTitle "myTitle"
      pageLink "pageLink"
      pubDate (format-time-string "%a, %d %b %Y %H:%m:%S UT" (current-time) t)
      myDescription "myDescription")

(defun genRSSItem ()
  (setq myRSSItem
	(format
	 "<item>
<title>%1$s</title>
<link>%2$s</link>
<guid>%2$s</guid>
<pubDate>%3$s</pubDate>
<description>%4$s</description>
</item>
"
	 myTitle          ;;  1$
	 pageLink         ;;  2$
	 pubDate          ;;  3$
	 myDescription    ;;  4$
	 )))

(genRSSItem)

;;;; and then using the item in my insertion function

(setq myText myRSSItem
      myMarker "    <!-- place new items above this line -->"
      myFile "/Users/suzume/Documents/Code/brandelune.github.io/test.xml")

(defun myInsert (myText myMarker myFile)
  (save-current-buffer
    (set-buffer (find-file-noselect myFile))
    (goto-char (point-min))
    (goto-char (- (search-forward myMarker) (length myMarker)))
    (insert myText)
    (indent-region (point-min) (point-max))
    (save-buffer)
    (kill-buffer)))

(myInsert myText myMarker myFile)

;;;; now I need to compute dates
;;;; from _old.el
;;;; no edge case is considered, ugly stuff

;;;; siteRoot, necessary
(setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")

;;;; not sure what to do with that format-time-string, it looks like I use YYYY a lot
(setq baseCSSPath (format "../../../css/%s/" (format-time-string "%Y"))) ;; 2019
;;;; maybe the CSS should be inside the base year and not in a separate tree
;;;; and each day css should be with the corresponding index file
;;;; so we'd have
(setq baseCSSPath (format "../../../%s/css/" (format-time-string "%Y"))) ;; 2019
;;;; instead
;;;; also, see below
(setq baseCSSPath (file-name-as-directory
		   (format "../../../%s/css/" (format-time-string "%Y"))))
;;;; this should be cleaner and safer
;;;; TODO create a command that adds a line break and pads the new line with the same nb of ;;; as the line above

;;;; CSS base file, necessary
(setq baseCSSFile "adventuresintechland.css")

;;;; if the CSS goes with the index.html file each day, no need for that
(setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate)) ;; mmdd.css
;;;; we can use the baseCSSFile name

;;;; the [Directory name] in the manual suggests using:
;;;;      (concat (file-name-as-directory DIRFILE) RELFILE)
(concat (file-name-as-directory siteRoot) baseCSSFile)
;;;; I'll need to find what's the best way to create file paths safely
(setq path1 "/Users"
      path2 "suzume"
      path3 "Documents"
      path4 "Code"
      path5 "brandelune.github.io"
      cssfilename "stuff.css")

(concat (file-name-as-directory path1)
	(file-name-as-directory path2)
	(file-name-as-directory path3)
	(file-name-as-directory path4)
	(file-name-as-directory path5)
	cssfilename)
;;;; this works. good.
;;;; I can use that to store all sorts of partial paths for reuse

;;;; here I can use the above code for improvement
(setq baseCSSLink (concat
		   (file-name-as-directory baseCSSPath)
		   baseCSSFile))

;;;; same here, but I'll need to consider where to put the file in the end
(setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
;;;; maybe I need "baseDailyCSSPath" and "baseCSSFile" instead
(setq dailyCSSLink (concat
		    (file-name-as-directory baseDailyCSSPath)
		    baseCSSFile))
;;;; that's it for the CSS related paths, now everything becomes about day changes

;;;; myPreviousDayString is currently only subtracting 1 to myDate, and that doesn't work for 2 reasons:
;;;; 1) the previous days is often not current date -1
;;;; because I dont create html pages everyday

(define-key emacs-lisp-mode-map (kbd "<C-return>")
  (lambda ()
    (interactive)
    (insert "
;;;; ")))
;;;; good, I've my ;;;; inserting command now...
;;;; ok, back to work
;;;; 2) in beginning of month/year the previous day is never current date -1
;;;; I need a way to ask for the previous day so that I am down with painful computations
;;;; also, there could be a way to detect the latest numbered folder in the tree and guess the day from that.

;;;; 
(setq previousDay (myPreviousDayString myDate))
(setq previousDate (format "%s%s" (format-time-string "%m") previousDay)) ;; mmdd
(setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay)) ;; mm/dd/index.html
(setq nextDay (myNextDayString myDate))
(setq nextDate (format "%s%s" (format-time-string "%m") nextDay)) ;; mmdd
(setq nextDayLink (format "../../%s/%s/index.html" (format-time-string "%m") nextDay)) ;; mm/dd/index.html
(setq todayDate (format "%s/%s/%s" (format-time-string "%Y") (format-time-string "%m") myDate)) ;; yyyy/mm/dd
(setq todayPath (concat siteRoot todayDate "/"))
(setq todayCSS (concat siteRoot "css/" (format-time-string "%Y") "/" dailyCSSFile)) ;; css/2019/advmmdd.css
(setq todayIndex (concat todayPath "index.html"))
