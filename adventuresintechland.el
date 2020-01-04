
;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my0Padding (myDigit)
  "Concats a 0 string to 1 digit numbers"
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
  "Creates a plausible (year month date) as a list
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

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun dailyIndex (today myPreviousDate myTitle mySubtitle)
  "Creates an html file with navigation, body, to be filled manually"
  (interactive (list
                (read-number "Date: " (fourth (decode-time (float-time))))
                (read-number "Previous date: " (- (third (myDate (fourth (decode-time (float-time))))) 1))
                (read-string "Title: " )
                (read-string "Sub-title: ")))

  (setq myPreviousDateList (myDate myPreviousDate)
	previousDate (concat (my0Padding (second myPreviousDateList)) (my0Padding (third myPreviousDateList)))
	previousDateLink (concat (file-name-as-directory "../../../")
				 (file-name-as-directory (number-to-string (first myPreviousDateList)))
				 (file-name-as-directory (my0Padding (second myPreviousDateList)))
				 (file-name-as-directory (my0Padding (third myPreviousDateList)))
				 "index.html"))

  (setq myTodayList (myDate today)
	siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/"
	todayPath (concat (file-name-as-directory siteRoot)
			   (file-name-as-directory (number-to-string (first myTodayList)))
			   (file-name-as-directory (my0Padding (second myTodayList)))
			   (file-name-as-directory (my0Padding (third myTodayList))))
	todayIndex (concat (file-name-as-directory todayPath)  "index.html")
	todayDate  (concat (number-to-string (first myTodayList)) "/" (my0Padding (second myTodayList)) "/" (my0Padding (third myTodayList))))

  (setq todayNavigation
	(format "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"https://github.com/brandelune/brandelune.github.io/commits/gh-pages\">gh-pages</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            <a href=\"../../../tomorrow.html\" hreflang=\"en\" rel=\"next\">tomorrow</a>
        </p>"
		previousDateLink ;;  1$
                previousDate     ;;  2$
		))

  (setq baseCSSLink "../../adventuresintechland.css"
        dailyCSSLink (concat todayPath "adventuresintechland.css")
	)

  (setq todayHeader
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

        <p id="episode"><em>Adventures in Tech Land, Season 2<br />%3$s, day ...</em></p>
        <h1>%4$s <a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a></h1>
        <p id="title item"></p>
        <h2>%5$s</h2>
        <p id="first sub-title item"></p>

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
  "inserts the dayly RSS feed contents into the feed XML file"
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

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun UpdateMainIndex ()
  "Update the main index"

;;;; TODO
;;;;    number of days in the current "season"
;;;;    total number of documented days
;;;;    link to "last day"
;;;;    index contents for the new day

  )

(defun UpdateRSSFeed ()
  "Update the RSS feed"

;;;; TODO
;;;;    title
;;;;    date
;;;;    link
;;;;    contents (first paragraph of current index ?)
  )

(defun UpdatePreviousPage ()
  "Update the previous page"

;;;; TODO
;;;;    "tomorrow" link

  )

(defun CreateCurrentPage ()
  "Create the page for the day"
  )

(defun ManageDailyEntry ()
  "Create the current page, update the main index, the RSS feed, the previous page"
  )

(defun narrowToEditZone ()
  "Narrow the index page to the area to edit"
;;;; search id = episode
;;;; goto beginning of line
;;;; set mark
;;;; search id = first sub-title item
;;;; goto to end of line
;;;; narrow-to-region
  )
