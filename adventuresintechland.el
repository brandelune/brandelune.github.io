(defun my0Padding (myDigit)
  "Adds a 0 to 1 digit numbers"
  ;; (my0Padding 3) -> "03"
  ;; (my0Padding 10) -> "10"  
  (if (< myDigit 10)
      (format "0%s" myDigit)
    (number-to-string myDigit)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myPreviousDayString (myDate)
  "Substracts 1 to a string date and 0-pads if necessary"
  ;; (myPreviousDayString "9") -> "08"
  (my0Padding (- (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myNextDayString (myDate)
  "Adds 1 to a string date and 0-pads if necessary"
  ;; (myNextDayString "8") -> "09"
  (my0Padding (+ (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myInsert (myText myMarker myFile)
  "Inserts myText at myMarker in myFile"
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

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDate (Date)
  "Lists a plausible (year month date)
TODO add error tests
the date should be comprised between 1 and (28 to 31)"
;; (myDate 3) -> (2020 1 3)
  (let* (
	(Today (decode-time (float-time)))
    (thisMonth (fifth Today))
     (nextMonth (if (= 12 thisMonth)
		    1
		  (+ thisMonth 1)))
      (lastMonth (if (= 1 thisMonth)
		    12
		  (- thisMonth 1)))
      (thisYear (sixth Today))
      (nextYear (+ thisYear 1))
      (lastYear (- thisYear 1))
      (dateDifference (- (fourth Today) Date))
      (myMonth (cond ((> 24 (abs dateDifference)) thisMonth)
		    ((natnump dateDifference) nextMonth)
		    (t lastMonth)))
      (myYear (cond ((= myMonth thisMonth) thisYear)
		   ((and (= myMonth nextMonth) (= myMonth 1)) nextYear)
		   (t lastYear))))
    (list myYear myMonth Date)))
  


;;;;;; compute dates for edge cases

(defun dailyIndex (myDate myTitle mySubtitle)
  (interactive (list
                (read-string "Date: " (format-time-string "%d"))
                (read-string "Title: " )
                (read-string "Sub-title: ")))
  (setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
  (setq baseCSSLink "../../../adventuresintechland.css")
  (setq dailyCSSLink "./adventuresintechland.css")
  (setq previousDay (myPreviousDayString myDate))
  (setq previousDate (format "%s%s" (format-time-string "%m") previousDay)) ;; mmdd
  (setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay)) ;; mm/dd/index.html
  (setq nextDayLink (format "../%s/tomorrow.html" (format-time-string "%Y"))) ;; 2020/tomorrow.html
  (setq todayDate (format "%s/%s/%s" (format-time-string "%Y") (format-time-string "%m") myDate)) ;; yyyy/mm/dd
  (setq todayPath (concat siteRoot todayDate "/"))
  (setq todayCSS (concat siteRoot "css/" (format-time-string "%Y") "/" dailyCSSFile)) ;; css/2019/advmmdd.css
  (setq todayIndex (concat todayPath "index.html"))
  (setq todayNavigation
	(format "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            <a href=\"%3$s\" hreflang=\"en\" rel=\"next\">tomorrow</a>
        </p>"
		previousDayLink  ;;  1$
                previousDate     ;;  2$
                nextDayLink      ;;  3$
))
  (setq todayTemplate
        (format "<html>
    <head lang=\"en-us\">
    <title>%1$s</title>
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
	<meta name=\"msapplication-TileColor\" content=\"#FFFFFF\" />
	<meta name=\"msapplication-TileImage\" content=\"https://brandelune.github.io/favicon/favicon-144.png\" />
	<meta name=\"msapplication-config\" content=\"https://brandelune.github.io/favicon/browserconfig.xml\" />

	<link rel=\"shortcut icon\" href=\"https://brandelune.github.io/favicon/favicon.ico\" />
	<link rel=\"icon\" sizes=\"16x16 32x32 64x64\" href=\"https://brandelune.github.io/favicon/favicon.ico\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"196x196\" href=\"https://brandelune.github.io/favicon/favicon-192.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"160x160\" href=\"https://brandelune.github.io/favicon/favicon-160.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"96x96\" href=\"https://brandelune.github.io/favicon/favicon-96.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"64x64\" href=\"https://brandelune.github.io/favicon/favicon-64.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"https://brandelune.github.io/favicon/favicon-32.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"https://brandelune.github.io/favicon/favicon-16.png\" />
	<link rel=\"apple-touch-icon\" href=\"https://brandelune.github.io/favicon/favicon-57.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"114x114\" href=\"https://brandelune.github.io/favicon/favicon-114.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"72x72\" href=\"https://brandelune.github.io/favicon/favicon-72.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"144x144\" href=\"https://brandelune.github.io/favicon/favicon-144.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"60x60\" href=\"https://brandelune.github.io/favicon/favicon-60.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"120x120\" href=\"https://brandelune.github.io/favicon/favicon-120.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"76x76\" href=\"https://brandelune.github.io/favicon/favicon-76.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"152x152\" href=\"https://brandelune.github.io/favicon/favicon-152.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"https://brandelune.github.io/favicon/favicon-180.png\" />

        <link rel=\"stylesheet\" type=\"text/css\" href=\"%2$s\" class=\"baseCSS\"/>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%3$s\" class=\"dailyCSS\"/>
        <meta charset=\"UTF-8\" />
    </head>"
                myTitle	     ;;  1$
                baseCSSLink  ;;  2$
                dailyCSSLink ;;  3$
		))

  (setq todayTemplate
        (format "%1$s
    <body>
        %2$s

        <p><em>Adventures in Tech Land, Season 2<br />%3$s, day ...</em></p>
        <h1>%4$s <a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a></h1>
        <p></p>
        <h2>%5$s</h2>
        <p></p>

        %2$s
    </body>
</html>"
                todayHeader	;;  1$
		todayNavigation	;;  2$
                todayDate	;;  3$
                myTitle		;;  4$
                mySubtitle	;;  5$

                ))

  (make-directory todayPath)
  (myInsert todayTemplate "" todayIndex)
  (myInsert "" "" dailyCSSLink)
  (find-file todayIndex))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDailyRSSItem (myTitle pageLink pubDate myDescription)
  (interactive (list
                (read-string "Title: ")
                (read-string "Link: " pageLink)
		(read-string "Date: " (format-time-string "%a, %d %b %Y %H:%m:%S UT" (current-time) t))
		(read-string "Description: ")))
  (setq myText	(format "<item>
<title>%1$s</title>
<link>%2$s</link>
<guid>%2$s</guid>
<pubDate>%3$s</pubDate>
<description>%4$s</description>
</item>
"
	 myTitle       ;;  1$
	 pageLink      ;;  2$
	 pubDate       ;;  3$
	 myDescription ;;  4$
	 ))
  (myInsert
   myText
   "<!-- place new items above this line -->"
   "/Users/suzume/Documents/Code/brandelune.github.io/adventuresintechland.xml"))



