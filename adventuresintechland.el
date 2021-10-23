(setq debug-on-error t)
;;;;;;;;;;;;;;;;;;;;;;;;;

(setq repositoryPath "/Users/suzume/Documents/Repositories/brandelune.github.io/")
(setq dayTrackerPath (concat repositoryPath "dayTracker.txt"))
(setq rssFile (concat repositoryPath "adventuresintechland.xml"))
(setq indexPath (concat repositoryPath "index.html"))
(setq ghPagesURL "https://github.com/brandelune/brandelune.github.io/commits/gh-pages")
(setq siteRoot "https://github.com/brandelune/brandelune.github.io/")
(setq faviconURL "https://brandelune.github.io/favicon/")
(setq rssReferences "<a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a>")

(defun my0Padding (number)
  "Adds a 0 string to one digit numbers.
This is used here to represent dates as in 01/01/2021"

  ;; (my0Padding 3) -> "03"
  ;; (my0Padding 10) -> "10"  

;;;; TODO add option to "number-to-string" so that the padding can happen there
;;;;  // Defined in ~/Documents/Code/emacs/src/data.c

  ;;   DEFUN ("number-to-string", Fnumber_to_string, Snumber_to_string, 1, 1, 0,
  ;;        doc: /* Return the decimal representation of NUMBER as a string.
  ;; Uses a minus sign if negative.
  ;; NUMBER may be an integer or a floating point number.  */)
  ;;   (Lisp_Object number)
  ;; {
  ;;   char buffer[max (FLOAT_TO_STRING_BUFSIZE, INT_BUFSIZE_BOUND (EMACS_INT))];
  ;;   int len;

  ;;   CHECK_NUMBER (number);

  ;;   if (BIGNUMP (number))
  ;;     return bignum_to_string (number, 10);

  ;;   if (FLOATP (number))
  ;;     len = float_to_string (buffer, XFLOAT_DATA (number));
  ;;   else
  ;;     len = sprintf (buffer, "%"pI"d", XFIXNUM (number));

  ;;   return make_unibyte_string (buffer, len);
  ;; }

  (if (< number 10)
      (format "0%s" number)
    (number-to-string number)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myPreviousDayString (myDate)
  "Substracts 1 to a date string and 0-pads the result it if necessary.
myDate is a 1 or 2 digits strings that represents a calendar day.
This is used here to create the date string for the previous day."
  ;; (myPreviousDayString "9") -> "08"
  (my0Padding (- (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myNextDayString (myDate)
  "Adds 1 to a date string and 0-pads the result if necessary.
myDate is a 1 or 2 digits strings that represents a calendar day.
This is used here to create the date string for the next day."
  ;; (myNextDayString "8") -> "09"
  (my0Padding (+ (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myInsert (myText myMarker myFile)
  "Insert myText at myMarker in myFile.
This is used to insert the RSS part of the feed for that day
at the end of the file, before the closing headers."
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

(defun checkDayTracker ()
  "Check the day tracker values, increment.
This is not yet used but is prepared for automating the process
of creating the template for the day. The increment serves for the
following day."
  (save-current-buffer
    (set-buffer (find-file-noselect dayTrackerPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (setq timeStamp (match-string 1)
		  seasonNumber (match-string 2)
		  totalDays (match-string 3)
		  dayInSeason (match-string 4)
		  newMarker (format "%s %s %s %s\n" (float-time) seasonNumber totalDays dayInSeason))
;;    (goto-char (point-min))
;;    (insert newMarker)
;;    (save-buffer)
;;    (kill-buffer))
	(list seasonNumber totalDays dayInSeason)))	

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDate (Date)
  "Create a plausible (year month date) list.
I don't remember for which purpose, but according to the emacs-devel
thread that was born out of a related question, it looks like an estimate
of the date/month/year since I only enter a date for the current entry"
  ;; (myDate 24) -> (2021 10 24)
;;;; TODO add error tests
;;;; the date should be comprised between 1 and (28 to 31)"

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
		 (dateDifference (- (fourth Today) (abs Date)))
		 (myMonth (cond ((> 24 (abs dateDifference)) thisMonth)
						((natnump dateDifference) nextMonth)
						(t lastMonth)))
		 (myYear (cond ((= myMonth thisMonth) thisYear)
					   ((and (= myMonth nextMonth) (= myMonth 1)) nextYear)
					   (t lastYear))))
    (list myYear myMonth Date)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun dailyIndex (today myPreviousDate myTitle mySubtitle myFirstParagraph)
  "Creates an html file with navigation, body.
The contents has to be filled manually, later."
  (interactive (list
                (read-number "Date: " (fourth (decode-time (float-time))))
                (read-number "Previous date: " (- (third (myDate (fourth (decode-time (float-time))))) 1))
                (read-string "Title: " )
                (read-string "Sub-title: ")
				(read-string "First paragraph: ")))

  (setq myPreviousDateList (myDate myPreviousDate)
		previousDate (concat (my0Padding (second myPreviousDateList)) (my0Padding (third myPreviousDateList)))
		previousDateLink (concat (file-name-as-directory "../../../")
								 (file-name-as-directory (number-to-string (first myPreviousDateList)))
								 (file-name-as-directory (my0Padding (second myPreviousDateList)))
								 (file-name-as-directory (my0Padding (third myPreviousDateList)))
								 "index.html"))

  (setq myTodayList (myDate today)
		todayPath (concat (file-name-as-directory repositoryPath)
						  (file-name-as-directory (number-to-string (first myTodayList)))
						  (file-name-as-directory (my0Padding (second myTodayList)))
						  (file-name-as-directory (my0Padding (third myTodayList))))
		todayIndex (concat (file-name-as-directory todayPath)  "index.html")
		todayDate  (concat (number-to-string (first myTodayList)) "/" (my0Padding (second myTodayList)) "/" (my0Padding (third myTodayList))))

  (setq todayNavigation
		(format "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%3$s\">gh-pages</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            <a href=\"../../../tomorrow.html\" hreflang=\"en\" rel=\"next\">tomorrow</a>
        </p>"
				previousDateLink ;;  1$
                previousDate      ;;  2$
				ghPagesURL       ;; 3$
				))

  (setq baseCSSLink "../../adventuresintechland.css")
  (setq dailyCSSLink "./adventuresintechland.css")

  (setq todayHeader
		(format "<html>
    <head lang=\"en-us\">
        <title>%1$s</title>

	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
	<meta name=\"msapplication-TileColor\" content=\"#FFFFFF\" />
	<meta name=\"msapplication-TileImage\" content=\"%4$sfavicon-144.png\" />
	<meta name=\"msapplication-config\" content=\"%4$sbrowserconfig.xml\" />

	<link rel=\"shortcut icon\" href=\"%4$sfavicon.ico\" />
	<link rel=\"icon\" sizes=\"16x16 32x32 64x64\" href=\"%4$sfavicon.ico\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"196x196\" href=\"%4$sfavicon-192.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"160x160\" href=\"%4$sfavicon-160.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"96x96\" href=\"%4$sfavicon-96.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"64x64\" href=\"%4$sfavicon-64.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"%4$sfavicon-32.png\" />
	<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"%4$sfavicon-16.png\" />
	<link rel=\"apple-touch-icon\" href=\"%4$sfavicon-57.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"114x114\" href=\"%4$sfavicon-114.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"72x72\" href=\"%4$sfavicon-72.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"144x144\" href=\"%4$sfavicon-144.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"60x60\" href=\"%4$sfavicon-60.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"120x120\" href=\"%4$sfavicon-120.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"76x76\" href=\"%4$sfavicon-76.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"152x152\" href=\"%4$sfavicon-152.png\" />
	<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"%4$sfavicon-180.png\" />

        <link rel=\"stylesheet\" type=\"text/css\" href=\"%2$s\" class=\"baseCSS\"/>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"%3$s\" class=\"dailyCSS\"/>
        <meta charset=\"UTF-8\" />
    </head>"
                myTitle	     ;;  1$
                baseCSSLink  ;;  2$
                dailyCSSLink ;;  3$
                faviconURL   ;;  4$
				))

  (setq todayTemplate
        (format "%1$s
    <body>
        %2$s

        <p id=\"episode\"><em>Adventures in Tech Land, Season %7$s<br />%3$s, day %8$s</em></p>
        <h1>%4$s %9$s</h1>
        <p id=\"title item\"></p>
        <h2>%5$s</h2>
        <p id=\"first sub-title item\">%6$s</p>

        %2$s
    </body>
</html>"
                todayHeader	;;  1$
				todayNavigation	;;  2$
                todayDate	;;  3$
                myTitle		;;  4$
                mySubtitle	;;  5$
				myFirstParagraph ;; 6$
				(first checkDayTracker) ;; 7$
				(third checkDayTracker) ;; 8$
				rssReferences ;; 9$

                ))

  (make-directory todayPath t)
  (myInsert todayTemplate "" todayIndex)
  (myInsert "" "" dailyCSSLink)
  (find-file todayIndex))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun pageLink ()
  (format ))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDailyRSSItem (myTitle todayIndex pubDate myDescription)
  "inserts the daily RSS feed contents into the feed XML file"
;;;; TODO add default value for link
  (interactive (list
                (read-string "Title: ")
                (read-string "Link: ")
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
						todayIndex    ;;  2$
						pubDate       ;;  3$
						myDescription ;;  4$
						))
  (myInsert
   myText
   "<!-- place new items above this line -->"   
   rssFile)
  (find-file rssFile))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun updateDayTracker ()
  "Update the day tracker"

;;;; TODO updateDayTracker
;;;;    current season
;;;;    number of days in the current "season"
;;;;    total number of documented days
;;;;    link to "last day"
;;;;    index contents for the new day  -> ?

  (save-current-buffer
    (set-buffer (find-file-noselect indexPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (setq timeStamp (match-string 1)
		  seasonNumber (match-string 2)
		  totalDays (+ 1 (string-to-number (match-string 3)))
		  dayInSeason (+ 1 (string-to-number (match-string 4)))
		  newMarker (format "%s %s %s %s\n" (float-time) seasonNumber totalDays dayInSeason))
    (goto-char (point-min))
    (insert newMarker)
    (save-buffer)
    (kill-buffer)))


(defun UpdateRSSFeed ()
  "Update the RSS feed"

;;;; TODO UpdateRSSFeed
;;;;    title
;;;;    date
;;;;    link
;;;;    contents (first paragraph of current index ?)
  )

(defun UpdatePreviousPage ()
  "Update the previous page"

;;;; TODO UpdatePreviousPage
;;;;    "tomorrow" link

  )

(defun CreateCurrentPage ()
  "Create the page for the day"
  )

(defun ManageDailyEntry ()
  "Create the current page, update the main index, the RSS feed, the previous page"
  (checkMarker)
  
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
