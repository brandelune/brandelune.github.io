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
;;;; so we'd have (setq baseCSSPath (format "../../../%s/css/" (format-time-string "%Y"))) ;; 2019
;;;; instead

;;;; CSS base file, necessary
(setq baseCSSFile "adventuresintechland.css")

;;;; if the CSS goes with the index, no need for that
(setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate)) ;; mmdd.css
;;;; we can use the baseCSSFile name

;;;; the [Directory name] in the manual suggests using:
;;;;      (concat (file-name-as-directory DIRFILE) RELFILE)
(concat (file-name-as-directory siteRoot) baseCSSFile)

(setq baseCSSLink (concat baseCSSPath baseCSSFile))
(setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
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
