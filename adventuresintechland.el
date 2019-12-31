(defun my0Padding (myDigit)
  (if (< myDigit 10)
      (format "0%s" myDigit)
    myDigit))

(defun myPreviousDayString (myDate)
  (my0Padding (- (string-to-number myDate) 1)))

(defun myNextDayString (myDate)
  (my0Padding (+ (string-to-number myDate) 1)))

(defun myInsert (myText myMarker myFile)
  (save-current-buffer
    (set-buffer (find-file-noselect myFile))
    (goto-char (point-min))
    (if (not (search-forward myMarker nil t))
	(progn
	  (kill-buffer)
	  (user-error (format "%s was not found" myMarker)))
      ;; user-error seems to abort the rest of the progn, hence the need to put kill-buffer above
      (progn
	(goto-char (point-min))
	(goto-char (- (search-forward myMarker) (length myMarker)))
	(insert myText)
	(indent-region (point-min) (point-max))
	(save-buffer)
	(kill-buffer)))))

;;;;;; compute dates for edge cases

(defun dailyIndex (myDate myTitle mySubtitle)
  (interactive (list
                (read-string "Date: " (format-time-string "%d"))
                (read-string "Title: " )
                (read-string "Sub-title: ")))
  (setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
  (setq baseCSSPath (format "../../../css/%s/" (format-time-string "%Y"))) ;; 2019
  (setq baseCSSFile "adventuresintechland.css")
  (setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate)) ;; mmdd.css
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
    <head lang=\"en-us\">
    <title>%1$s</title>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%2$s\" class=\"baseCSS\"/>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%3$s\" class=\"dailyCSS\"/>
        <meta charset=\"UTF-8\" />
    </head>
    <body>
        %6$s

        <p><em>Adventures in Tech Land, Season 2<br />%4$s, day ...</em></p>
        <h1>%1$s <a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a></h1>
        <p></p>
        <h2>%5$s</h2>
        <p></p>

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
  
  (write-region "" nil todayCSS nil t nil t)
  (make-directory todayPath)
  (myInsert todayTemplate "" todayIndex)
  (find-file todayIndex))

;;;;;;;;;;;;;;


(defun myDailyRSSItem ()
  (let ((myTitle "a warm living room")
	(pageLink "https://brandelune.github.io/2019/12/24/index.html")
	(pubDate (format-time-string "%a, %d %b %Y %H:%m:%S UT" (current-time) t))
	(myDescription "I just got a gas heater in the living room. The house where I live now has no heating system, except for the gas cooker and the water heater. But as far as room heating is concerned, nothing. Until 2 days ago. Now it is considerably easier to stay at the table and work on my stuff. As I did last night, and tonight..."))
	(setq myText
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
    (myInsert
     myText
     "<!-- place new items above this line -->"
     "/Users/suzume/Documents/Code/brandelune.github.io/adventuresintechland.xml")))

(myDailyRSSItem)

