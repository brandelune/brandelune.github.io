(defun myPreviousDay (myDate)
  (- myDate 1))

(defun dailyIndex (myDate myTitle mySubtitle)
  (interactive (list
                (read-number "Date: " (string-to-number (format-time-string "%d")))
                (read-string "Title: " )
                (read-string "Sub-title: ")))
  (setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
  (setq baseCSSPath (format "../../../css/%s/" (format-time-string "%Y")))
  (setq baseCSSFile "adventuresintechland.css")
  (setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate))
  (setq baseCSSLink (concat baseCSSPath baseCSSFile))
  (setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
  (setq previousDay (myPreviousDay myDate))
  (setq previousDate (format "%s%s" (format-time-string "%m") previousDay))
  (setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay))
  (setq nextDay (+ myDate 1))
  (setq nextDate (format "%s%s" (format-time-string "%m") nextDay))
  (setq nextDayLink (format "../../%s/%s/index.html" (format-time-string "%m") nextDay))
  (setq todayDate (format "%s/%s/%s" (format-time-string "%Y") (format-time-string "%m") myDate))
  (setq todayPath (concat siteRoot todayDate "/"))
  (setq todayCSS (concat siteRoot "css/" (format-time-string "%Y") "/" dailyCSSFile))
  (setq todayIndex (concat todayPath "index.html"))
  (setq todayNavigation
	(format "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            <a href=\"%3$s\" hreflang=\"en\" rel=\"next\">%4$s</a>
        </p>"
		previousDayLink  ;;  1$
                previousDate     ;;  2$
                nextDayLink      ;;  3$
                nextDate         ;;  4$
))
  (setq todayTemplate
        (format "<html>
    <head>
        <title>%1$s</title>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%2$s\" class=\"baseCSS\"/>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%3$s\" class=\"dailyCSS\"/>
    </head>
    <body>
        %6$s

        <p><em>Adventures in Tech Land, Season 2<br />%4$s, day ...</em></p>
        <h1>%1$s</h1>
        <h2>%5$s</h2>   
        <p>We're not there yet...</p>

        %6$s
    </body>
</html>"
                myTitle          ;;  1$
                baseCSSLink      ;;  2$
                dailyCSSLink     ;;  3$
                todayDate        ;;  4$
                mySubtitle       ;;  5$

		todayNavigation  ;;  6$
                ))
  
  (write-region todayTemplate nil todayIndex nil nil nil t)
  (make-empty-file todayCSS)
  (find-file todayCSS)
  (find-file todayIndex))



(dailyIndex 2 "org export" "back to css")
