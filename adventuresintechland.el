;;; adventuresintechland.el --- my personal CMS -*- lexical-binding: t -*-
;;; package --- Summary
;;; Commentary:
;; TODO
;; use defvar and defconst to declare things
;; the way this should work is
;; 1) I type the contents in a buffer
;; 2) I call the dailyIndex function
;; 3) it inserts the buffer contents into the index
;; 4) it creates the RSS item from the first paragraph (I need to itendify it)
;; 5) it updates the daytracker
;; 6) boom
;;
;; that way, I can focus back on html/css, write about that, including the web engineer thing
;; and that's more fun.

;;; Code:
(setq debug-on-error t)
;;;;;;;;;;;;;;;;;;;;;;;;;
;;; constants
(defconst jc-repositoryPath "/Users/suzume/Documents/Repositories/brandelune.github.io/")
(defconst jc-dayTrackerPath (concat jc-repositoryPath "dayTracker.txt"))
(defconst jc-rssFile (concat jc-repositoryPath "adventuresintechland.xml"))
(defconst jc-indexPath (concat jc-repositoryPath "index.html"))
(defconst jc-ghPagesURL "https://github.com/brandelune/brandelune.github.io/commits/gh-pages")
(defconst jc-siteRoot "https://github.com/brandelune/brandelune.github.io/")
(defconst jc-faviconURL "https://brandelune.github.io/favicon/")
(defconst jc-rssReferences "<a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a>")
(defconst jc-baseCSSLink "../../adventuresintechland.css")
(defconst jc-dailyCSSLink "./adventuresintechland.css")
;;; variables
(defvar jc-todayHeader)
(defvar jc-myPreviousDateList)
(defvar jc-todayNavigation)
(defvar jc-todayTemplate)
(defvar jc-myPreviousDateList)
(defvar jc-myTodayList)
(defvar jc-todayPath)
(defvar jc-todayIndex)
(defvar jc-newTracker)
(defvar jc-dayInSeason)
(defvar jc-previousDateLink)
(defvar jc-todayDate)
(defvar jc-totalDays)
(defvar jc-myText)
(defvar jc-timeStamp)
(defvar jc-seasonNumber)

(defun my0Padding (number)
  "Add a 0 string to one digit NUMBER.
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

(defun myInsert (myText myMarker myFile)
  "Insert MYTEXT at MYMARKER in MYFILE.
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
  "Create values for the new index, based on yesterday's values."
  (save-current-buffer
    (set-buffer (find-file-noselect jc-dayTrackerPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (let*((seasonNumber (match-string 2))
		  (jc-totalDays (+ 1 (string-to-number (match-string 3))))
		  (jc-dayInSeason (+ 1 (string-to-number (match-string 4)))))
	  (kill-buffer)
	  (list seasonNumber jc-totalDays jc-dayInSeason))))

(defun updateDayTracker ()
  "Update the dayTracker."
  (save-current-buffer
    (set-buffer (find-file-noselect jc-dayTrackerPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (let*((seasonNumber (match-string 2))
		  (jc-totalDays (+ 1 (string-to-number (match-string 3))))
		  (jc-dayInSeason (+ 1 (string-to-number (match-string 4))))
		  (jc-newTracker (format "%s %s %s %s\n" (float-time) seasonNumber jc-totalDays jc-dayInSeason)))
      (goto-char (point-min))
	  (insert jc-newTracker))
	(save-buffer)
	(kill-buffer)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDate (day)
  "Create a plausible (year month DAY) list.
Since I only enter a date for the current entry, I must compute the
previous day and the next days according to what's plausible. It is
expected that I enter a possible date.

  ;; (myDate 30) -> (2021 10 24)
;;;; TODO add error tests
;;;; the date should be comprised between 1 and (28 to 31)"

  (let* (
		 (Today (decode-time (float-time)))
		 (thisMonth (cl-fifth Today))
		 (nextMonth (if (= 12 thisMonth)
						1
					  (+ thisMonth 1)))
		 (lastMonth (if (= 1 thisMonth)
						12
					  (- thisMonth 1)))
		 (thisYear (cl-sixth Today))
		 (nextYear (+ thisYear 1))
		 (lastYear (- thisYear 1))
		 (dateDifference (- (cl-fourth Today) (abs day)))
		 (myMonth (cond ((> 24 (abs dateDifference)) thisMonth)
						((natnump dateDifference) nextMonth)
						(t lastMonth)))
		 (myYear (cond ((= myMonth thisMonth) thisYear)
					   ((and (= myMonth nextMonth) (= myMonth 1)) nextYear)
					   (t lastYear)))
		 (rssDate (format-time-string "%a, %d %b %Y %H:%m:%S UT" (current-time) t))
		 (linkDate (format "%1$s/%2$s/%3$s" myYear myMonth day)))
    (list myYear myMonth day rssDate linkDate)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun dailyIndex (today prevdate title subtitle firstpar)
  "Create an html file for TODAY with PREVDATE TITLE SUBTITLE FIRSTPAR.
The contents has to be filled manually, later."
  (interactive (list
                (read-number "Date: " (cl-fourth (decode-time (float-time))))
                (read-number "Previous date: " (- (cl-third (myDate (cl-fourth (decode-time (float-time))))) 1))
                (read-string "Title: " )
                (read-string "Sub-title: ")
				(read-string "First paragraph: ")))

  (setq jc-myPreviousDateList (myDate prevdate)
		prevdate (concat (my0Padding (cl-second jc-myPreviousDateList)) (my0Padding (cl-third jc-myPreviousDateList)))
		jc-previousDateLink (concat (file-name-as-directory "../../../")
									(file-name-as-directory (number-to-string (cl-first jc-myPreviousDateList)))
									(file-name-as-directory (my0Padding (cl-second jc-myPreviousDateList)))
									(file-name-as-directory (my0Padding (cl-third jc-myPreviousDateList)))
									"index.html"))

  (setq jc-myTodayList (myDate today)
		jc-todayPath (concat (file-name-as-directory jc-repositoryPath)
							 (file-name-as-directory (number-to-string (cl-first jc-myTodayList)))
							 (file-name-as-directory (my0Padding (cl-second jc-myTodayList)))
							 (file-name-as-directory (my0Padding (cl-third jc-myTodayList))))
		jc-todayIndex (concat (file-name-as-directory jc-todayPath)  "index.html")
		jc-todayDate  (concat (number-to-string (cl-first jc-myTodayList)) "/" (my0Padding (cl-second jc-myTodayList)) "/" (my0Padding (cl-third jc-myTodayList))))

  (setq jc-todayNavigation
		(format "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%3$s\">gh-pages</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            <a href=\"../../../tomorrow.html\" hreflang=\"en\" rel=\"next\">tomorrow</a>
        </p>"
				jc-previousDateLink ;;  1$
                prevdate      ;;  2$
				jc-ghPagesURL       ;; 3$
				))

  (setq jc-todayHeader
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
                title	     ;;  1$
                jc-baseCSSLink  ;;  2$
                jc-dailyCSSLink ;;  3$
                jc-faviconURL   ;;  4$
				))

  (setq jc-todayTemplate
        (format "%1$s
    <body>
        %2$s

        <p id=\"episode\"><em>Adventures in Tech Land. Season %7$s. Episode %8$s</em></p>
        <h1>%4$s %9$s</h1>
        <p id=\"title item\">%3$s, %10$sth day</p>
        <h2>%5$s</h2>
        <p id=\"first sub-title item\">%6$s</p>

        %2$s
    </body>
</html>"
                jc-todayHeader	;;  1$
				jc-todayNavigation	;;  2$
                jc-todayDate	;;  3$
                title		;;  4$
                subtitle	;;  5$
				firstpar ;; 6$
				(cl-first (checkDayTracker)) ;; 7$ season
				(cl-third (checkDayTracker)) ;; 8$ days in season
				jc-rssReferences ;; 9$
				(cl-second (checkDayTracker)) ;; 10$ total days
                ))

  (make-directory jc-todayPath t)
  (myInsert jc-todayTemplate "" jc-todayIndex)
  (myInsert "" "" jc-dailyCSSLink)
  (myDailyRSSItem title today firstpar)
  (updateDayTracker)
  (find-file jc-todayIndex))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDailyRSSItem (title date desc)
  "Insert the daily RSS feed with TITLE DATE and DESC."
;;;; TODO add default value for link
  (interactive (list
                (read-string "Title: ")
				(read-number "Date: " (cl-fourth (decode-time (float-time) t)))
				(read-string "Description: ")))
  
  (setq jc-myText	(format "<item>
<title>%1$s</title>
<link>https://brandelune.github.io/%2$s/index.html</link>
<guid>https://brandelune.github.io/%2$s/index.html</guid>
<pubDate>%3$s</pubDate>
<description>%4$s</description>
</item>
"
							title    ;;  1$
							(cl-fifth (myDate  date))  ;;  2$
							(cl-fourth (myDate date))   ;;  3$
							desc   ;;  4$
							))
  (myInsert
   jc-myText
   "<!-- place new items above this line -->"
   jc-rssFile)
  (find-file jc-rssFile))

;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;; (yet) Unused functions

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myPreviousDayString (myDate)
  "Substract 1 to MYDATE and 0-pads the result it if necessary.
myDate is a 1 or 2 digits strings that represents a calendar day.
This is used here to create the date string for the previous day."
  ;; (myPreviousDayString "9") -> "08"
  (my0Padding (- (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myNextDayString (myDate)
  "Add 1 to MYDATE and 0-pads the result if necessary.
myDate is a 1 or 2 digits strings that represents a calendar day.
This is used here to create the date string for the next day."
  ;; (myNextDayString "8") -> "09"
  (my0Padding (+ (string-to-number myDate) 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun pageLink ()
  "To be defined."
  ;;  (format )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun UpdateRSSFeed ()
  "Update the RSS feed."
;;;; TODO UpdateRSSFeed
;;;;    title
;;;;    date
;;;;    link
;;;;    contents (first paragraph of current index ?)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun UpdatePreviousPage ()
  "Update the previous page."
;;;; TODO UpdatePreviousPage
;;;;    "tomorrow" link
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun CreateCurrentPage ()
  "Create the page for the day."
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun ManageDailyEntry ()
  "Create the current page, update the main index, the RSS feed, the previous page."
  (checkDayTracker)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun narrowToEditZone ()
  "Narrow the index page to the area to edit."
;;;; search id = episode
;;;; goto beginning of line
;;;; set mark
;;;; search id = first sub-title item
;;;; goto to end of line
;;;; narrow-to-region
  )

;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'adventuresintechland)
;;; adventuresintechland.el ends here
