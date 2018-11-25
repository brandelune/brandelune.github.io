;; code pour créer mes squelettes de HTML

(defun dailyIndex (myDate)
  (interactive (list
                (read-number "Date: " (string-to-number (format-time-string "%d")))))
  (setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
  (setq baseCSSPath (format "../../../css/%s/" (format-time-string "%Y")))
  (setq baseCSSFile "adventuresintechland.css")
  (setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate))
  (setq baseCSSLink (concat baseCSSPath baseCSSFile))
  (setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
  (setq previousDay (- myDate 1))
  (setq previousDate (format "%s%s" (format-time-string "%m") previousDay))
  (setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay))
  (setq nextDay (+ myDate 1))
  (setq nextDate (format "%s%s" (format-time-string "%m") nextDay))
  (setq nextDayLink (format "../../%s/%s/index.html" (format-time-string "%m") nextDay))
  (setq todayDate (format "%s/%s/%s/" (format-time-string "%Y") (format-time-string "%m") myDate))
  (setq todayPath (concat siteRoot todayDate))
  (setq todayCSS (concat siteRoot "css/" (format-time-string "%Y") "/" dailyCSSFile))
  (setq todayIndex (concat todayPath "index.html"))

  (setq todayTemplate
	(format "<html>
    <head>
	<title>%1$s</title>
	<link rel=\"stylesheet\" type=\"text/css\" href=\"%2$s\" class=\"baseCSS\"/>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%3$s\" class=\"dailyCSS\"/>
    </head>
    <body>
	We're not there yet...
	<p class=\"navigation\">
	    <a href=\"%4$s\" hreflang=\"en\" rel=\"prev\">%5$s</a>
	    <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%6$s\" hreflang=\"en\" rel=\"next\">%7$s</a>
	</p> 
	<p>%8$s, %9$s day in a row</p>
	<h1>%1$s</h1>
	<h2>%10$s</h2>	

	<p class=\"navigation\">
	    <a href=\"%4$s\" hreflang=\"en\" rel=\"prev\">%5$s</a>
	    <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%6$s\" hreflang=\"en\" rel=\"next\">%7$s</a>
	</p>
    </body>
</html>"
		"titre"          ;;  1$
		baseCSSLink      ;;  2$
		dailyCSSLink     ;;  3$
		previousDayLink  ;;  4$
		previousDate     ;;  5$
		nextDayLink      ;;  6$
		nextDate         ;;  7$
		todayDate        ;;  8$
		"..."            ;;  9$
		"titre"          ;;  1$
		"sous-titre"     ;; 10$
		))
  (write-region todayTemplate nil todayIndex)
  (make-empty-file todayCSS)
  (find-file todayIndex)
  (find-file todayCSS))
