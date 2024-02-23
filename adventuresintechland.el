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
(defconst jc-tomorrow "<a href=\"../../../tomorrow.html\" hreflang=\"en\" rel=\"next\">tomorrow</a>")

(defconst jc-ghPagesURL "https://github.com/brandelune/brandelune.github.io/commits/gh-pages")
(defconst jc-siteRoot "https://github.com/brandelune/brandelune.github.io/")
(defconst jc-faviconURL "https://brandelune.github.io/favicon/")
(defconst jc-rssReferences "<a href=\"https://brandelune.github.io/adventuresintechland.xml\"><img src=\"https://www.mozilla.org/media/img/trademarks/feed-icon-28x28.e077f1f611f0.png\" width=\"15px\" height=\"15px\" alt=\"rss feed\" /></a>")
(defconst jc-baseCSSLink "../../adventuresintechland.css")
(defconst jc-dailyCSSLink "./adventuresintechland.css")

(defconst jc-todayNavigationContents "<p class=\"navigation\">
            <a href=\"%1$s\" hreflang=\"en\" rel=\"prev\">%2$s</a>
            <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%3$s\">gh-pages</a>
            <a href=\"../../../adventuresintechland.html\" hreflang=\"en\">todo</a>
            %4$s
        </p>")

(defconst jc-todayHeaderContents "<html>
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
    </head>")

(defconst jc-todayTemplateContents "%1$s
    <body>
        %2$s

        <p id=\"episode\"><em>Adventures in Tech Land. Season %7$s. Episode %8$s</em></p>
        <h1>%4$s %9$s</h1>
        <p id=\"title item\">%3$s, %10$sth day</p>
        <h2>%5$s</h2>
        <p id=\"first sub-title item\">%6$s</p>

        %2$s
    </body>
</html>")

(defconst jc-myRSSTemplate "<item>
<title>%1$s</title>
<link>https://brandelune.github.io/%2$s/index.html</link>
<guid>https://brandelune.github.io/%2$s/index.html</guid>
<pubDate>%3$s</pubDate>
<description>%4$s</description>
</item>
")

;;; variables
(defvar jc-lastdayList)
(defvar jc-lastdayLink)
(defvar jc-lastdayDate)

(defvar jc-todayList)
(defvar jc-todayHeader)
(defvar jc-todayTemplate)
(defvar jc-todayNavigation)
(defvar jc-todayPath)
(defvar jc-todayIndex)
(defvar jc-todayDate)

(defvar jc-seasonNumber)
(defvar jc-seasonEpisode)
(defvar jc-totalDays)

(defvar jc-newDayTracker)
(defvar monthMaxDay)


;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dailyIndex (today lastday title subtitle firstpar)
  "Create an html file for TODAY with LASTDAY TITLE SUBTITLE FIRSTPAR.
The contents has to be filled manually, later."

  ;; Create values for the new index, based on yesterday's values in dayTracker.txt.
  (save-current-buffer
    (set-buffer (find-file-noselect jc-dayTrackerPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (setq jc-lastdayDate (cl-fourth (decode-time (string-to-number (match-string 1))))
		  seasonNumber (match-string 2)
		  totalDays (string-to-number (match-string 3))
		  newTotalDays (+ 1 totalDays)
		  currentEpisode (string-to-number (match-string 4))
		  newSeasonEpisode (+ 1 currentEpisode))
	(kill-buffer))

  ;; Input data
  (interactive (list
                (read-number "Date: " (cl-fourth (decode-time (float-time))))
                (read-number "Previous date: " jc-lastdayDate)
                (read-string "Title: " )
                (read-string "Sub-title: ")
				(read-string "First paragraph: ")))

  ;; Create data for last day
  (setq jc-lastdayList (myDate lastday)
		jc-lastday (concat (my0Padding (cl-second jc-lastdayList)) (my0Padding (cl-third jc-lastdayList)))
		jc-lastdayLink (concat (file-name-as-directory "../../../")
							   (file-name-as-directory (number-to-string (cl-first jc-lastdayList)))
							   (file-name-as-directory (my0Padding (cl-second jc-lastdayList)))
							   (file-name-as-directory (my0Padding (cl-third jc-lastdayList)))
							   "index.html")
		jc-lastdayIndex (concat (file-name-as-directory jc-repositoryPath)
								(file-name-as-directory (number-to-string (cl-first jc-lastdayList)))
								(file-name-as-directory (my0Padding (cl-second jc-lastdayList)))
								(file-name-as-directory (my0Padding (cl-third jc-lastdayList)))
								"index.html"))

  ;; Create data for today
  (setq jc-todayList (myDate today)
		jc-todaySubPath (concat (file-name-as-directory (number-to-string (cl-first jc-todayList)))
							 (file-name-as-directory (my0Padding (cl-second jc-todayList)))
							 (file-name-as-directory (my0Padding (cl-third jc-todayList))))
		jc-todayPath (concat (file-name-as-directory jc-repositoryPath)
							 (file-name-as-directory jc-todaySubPath))
		jc-todayRelativeIndex (concat (file-name-as-directory "../../../")
									  (file-name-as-directory jc-todaySubPath)
									  "index.html")
		jc-todayIndex (concat (file-name-as-directory jc-todayPath)  "index.html")
		jc-todayDate  (concat (number-to-string (cl-first jc-todayList)) "/" (my0Padding (cl-second jc-todayList)) "/" (my0Padding (cl-third jc-todayList)))
		jc-todayLinkName (concat (my0Padding (cl-second jc-todayList)) (my0Padding (cl-third jc-todayList))))

  ;; Create navigation
  (setq jc-todayNavigation
		(format jc-todayNavigationContents
				jc-lastdayLink ;; 1$
                jc-lastday     ;; 2$
				jc-ghPagesURL  ;; 3$
				jc-tomorrow    ;; 4$
				))

  ;; Create <head> contents
  (setq jc-todayHeader
		(format jc-todayHeaderContents
                title	        ;; 1$
                jc-baseCSSLink  ;; 2$
                jc-dailyCSSLink ;; 3$
                jc-faviconURL   ;; 4$
				))

  ;; Create today's template
  (setq jc-todayTemplate
        (format jc-todayTemplateContents
                jc-todayHeader	   ;;  1$
				jc-todayNavigation ;;  2$
                jc-todayDate	   ;;  3$
                title		       ;;  4$
                subtitle	       ;;  5$
				firstpar           ;;  6$
				seasonNumber       ;;  7$
				jc-seasonEpisode   ;;  8$
				jc-rssReferences   ;;  9$
				jc-totalDays       ;; 10$
                ))
 
  (make-directory jc-todayPath t)
  (myInsert jc-todayTemplate "" jc-todayIndex)
  (myInsert "" "" jc-dailyCSSLink)
  (myDailyRSSItem title today firstpar)

  ;; TODO update the previous day page with the new "next day" value
  ;; (updateLastDayIndex)
  ;; TODO update the main index with the new "season/episode" data
  ;; (updateMainIndex)
  ;; TODO insert the daily content in the daily index


  ;; Update the dayTracker data
  (save-current-buffer
    (set-buffer (find-file-noselect jc-dayTrackerPath))
    (goto-char (point-min))
    (search-forward-regexp "\\([0-9]*\\.[0-9]*\\) \\([0-9]*\\) \\([0-9]*\\) \\([0-9]*\\)")
    (let* ((seasonNumber (match-string 2))
		   (jc-totalDays (+ 1 (string-to-number (match-string 3))))
		   (jc-seasonEpisode (+ 1 (string-to-number (match-string 4))))
		   (jc-newDayTracker (format "%s %s %s %s\n" (float-time) seasonNumber jc-totalDays jc-seasonEpisode)))
      (goto-char (point-min))
	  (insert jc-newDayTracker))
	(save-buffer)
	(kill-buffer))

  ;; update the previous page
  (setq jc-todayDayAnchor
		(concat "<a href=\"" jc-todayRelativeIndex "\" hreflang=\"en\" rel=\"next\">" jc-todayLinkName "</a>"))
  
  (myReplace
   jc-tomorrow
   jc-todayDayAnchor
   jc-lastdayIndex)

  ;; update the root index
  ;; rootIndexFilePath
  
  ;; open modified files for verification
  (find-file jc-todayIndex)
  (find-file rootIndexFilePath)
  (find-file jc-rssFile)
)

;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myDailyRSSItem (title date desc)
  "Insert the daily RSS feed with TITLE DATE and DESC."
;;;; TODO add default value for link
  (interactive (list
                (read-string "Title: ")
				(read-number "Date: " (cl-fourth (decode-time (float-time) t)))
				(read-string "Description: ")))
  
  (setq jc-myRSSTemplateContents	(format jc-myRSSTemplate
											title ;;  1$
											(cl-fifth (myDate  date)) ;;  2$
											(cl-fourth (myDate date)) ;;  3$
											desc ;;  4$
											))
  (myInsert
   jc-myRSSTemplateContents
   "<!-- place new items above this line -->"
   jc-rssFile)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun updateOldPages ()
  "Update the previous page and the general index."
  ;; TODO UpdatePreviousPage
  ;;    "tomorrow" link
  ;; how do I find the previous page ?
  ;; what kind of data do I have at this time ?


  ;; Update the general index

  (setq jc-lastDayAnchor
		(concat "<a href=\"" jc-lastdayLink "\" hreflang=\"en\" rel=\"prev\">last day</a>")
		jc-obsoleteAnchor
		(concat "<a href=\"./2024/02/19/index.html\" hreflang=\"en\" rel=\"prev\" id="update5">last day</a>")
		(search-forward "update5")
		(search-backward "<a href")
  	  
		<h2 id="update2">Logbook, 49 documented days</h2>
		<h3 id="update3">Season 4, 2 episode</h3>
		<ul id="update4">

  
))

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ManageDailyEntry ()
  "Create the current page, update the main index, the RSS feed, the previous page."
  )

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my0Padding (number)
  "Add a 0 string to one digit NUMBER.
This is used here to represent dates as in 01/01/2021"

  ;; string-pad "string" "length of padding" "thing to pad with" "pad from start if t"
  (string-pad (number-to-string number) 2 48 t))

  ;; old code
  ;; (if (< number 10)
  ;;     (format "0%s" number)
  ;;   (number-to-string number)))

  ;; (my0Padding 3) -> "03"
  ;; (my0Padding 10) -> "10"

  ;; TODO add option to "number-to-string" so that the padding can happen there
  ;;  // Defined in ~/Documents/Code/emacs/src/data.c

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun myDate (day)
  "Create a plausible (year month DAY) list.
Since I only enter a date for the current entry, I must compute the
previous day and the next days according to what's plausible. It is
expected that I enter a possible date."

;;;; TODO add error tests
;;;; (myDate 29) in February 2024, leap year, returns something like
;;;; (2024 2 29 "Sun, 29 Feb 2024 15:02:03 UT" "2024/2/29")

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
		 (monthMaxDay
		  (cond
			((member thisMonth '(1 3 5 7 8 10 12)) 31)
			((member thisMonth '(4 6 9 11)) 30)
			((and (= 2 thisMonth)
				  (= 0 (mod (cl-sixth (decode-time (float-time))) 4))) 29)
			(t 28)))
		 (myDay (if (> day monthMaxDay) monthMaxDay day))
		 (dateDifference (- (cl-fourth Today) (abs myDay)))
		 (myMonth (cond ((> 24 (abs dateDifference)) thisMonth)
						((natnump dateDifference) nextMonth)
						(t lastMonth)))
		 (myYear (cond ((= myMonth thisMonth) thisYear)
					   ((and (= myMonth nextMonth) (= myMonth 1)) nextYear)
					   (t lastYear)))
		 (rssDate (concat (format-time-string "%a, " (current-time) t)
						  (number-to-string myDay)
						  (format-time-string " %b %Y %H:%m:%S UT" (current-time) t)))
		 (linkDate (format "%1$s/%2$s/%3$s" myYear myMonth myDay)))
    (list myYear myMonth myDay rssDate linkDate)))

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun myInsert (myText myMarker myFile)
  "Insert MYTEXT at MYMARKER in MYFILE.
This is used to insert the RSS part of the feed for that day
at the end of the file, before the closing headers."
  (save-current-buffer
	;; Record which buffer is current; execute BODY; make that buffer current.
    (set-buffer (find-file-noselect myFile))
	;; Make buffer BUFFER-OR-NAME current for editing operations.
	;; Read file FILENAME into a buffer and return the buffer.
    (goto-char (point-min))
	;; Set point to POSITION, a number or marker.
	;; Return the minimum permissible value of point in the current buffer.
    (if (not (search-forward myMarker nil t))
		;; Search forward from point for STRING.
		(progn
		  (kill-buffer)
		  (user-error (format "%s was not found" myMarker)))
		;; user-error seems to abort the rest of the progn, hence the need to put kill-buffer above
		(progn
		  (goto-char (point-min))
		  (goto-char (- (search-forward myMarker) (length myMarker)))
		  (insert myText)
		  (indent-region (point-min) (point-max))
		  ;; not sure I want to indent if I use <pre> blocks in the inserted strings
		  (save-buffer)
		  (kill-buffer)))))

;;;;;;;;;;;;;;;;;;;;;;;;;
(defun myReplace (fromString toString myFile)
  "Replace fromString with toString in MYFILE."
  (save-current-buffer
	;; Record which buffer is current; execute BODY; make that buffer current.
    (set-buffer (find-file-noselect myFile))
	;; Make buffer BUFFER-OR-NAME current for editing operations.
	;; Read file FILENAME into a buffer and return the buffer.
    (goto-char (point-min))
	;; Set point to POSITION, a number or marker.
	;; Return the minimum permissible value of point in the current buffer.
    (if (not (search-forward fromString nil t))
		;; Search forward from point for STRING.
		(progn
		  (kill-buffer)
		  (user-error (format "%s was not found" fromString)))
		;; user-error seems to abort the rest of the progn, hence the need to put kill-buffer above
		(progn
		  (goto-char (point-min))
		  (replace-string fromString toString)
		  (save-buffer)
		  (kill-buffer)))))

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
