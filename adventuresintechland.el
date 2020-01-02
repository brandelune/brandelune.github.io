(defun my0Padding (myDigit)
  "Adds a 0 to 1 digit numbers"
  ;; (my0Padding 10) -> "03"
  ;; (my0Padding 10) -> "10"  
  (if (< myDigit 10)
      (format "0%s" myDigit)
    myDigit))

(defun myPreviousDayString (myDate)
  "Substracts 1 to a string date and 0-pads if necessary"
  ;; (myPreviousDayString "9") -> "08"
  (my0Padding (- (string-to-number myDate) 1)))

(defun myNextDayString (myDate)
  "Adds 1 to a string date and 0-pads if necessary"
  ;; (myNextDayString "8") -> "09"
  (my0Padding (+ (string-to-number myDate) 1)))

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

;; edge cases:
;; the 1st of the month -> day before is *not* 1-1
;; the last day of the month -> day after is not n+1

;; a day has 60 * 60 * 24 seconds = (* 60 60 24) = 86400
(setq myYesterday (decode-time (- (float-time) 86400)));; (51 33 2 31 12 2019 2 nil 32400)
(setq myTomorrow (decode-time (+ (float-time) 86400)));; (17 33 2 2 1 2020 4 nil 32400)

;; let's assume, for now, that we use the current date as "today"
;; there are cases when we can use another day, for ex to prepare input
;; for the day after, or ton complete input for the day before
;; in that case, the input "myDate" will have to be converted into
;; an elisp timestamp and will have to be converted back to find
;; its myYesterday and myTomorrow

;; myDate is a max 2 digits number that is supposed to be "today" +/- 2~3 days
;; so how do we go to convert that into a time stamp ?
;; if the date has the same month as today (ie not edge case) then just use float-time

;; how do I check whether the date has the same month as today ?
;; or I can ask for a dd/mm string but that seems too much when most of the work happens
;; at most just a few days apart from today.
;; so, let's say today is the 31st of January, are there use cases when I want to create
;; a template for the 1st or 2nd of February and so call 1 or 2 as my date ?
;; also, I can be the 1st of February and enter 30th to complete a late entry
;; so, the date is 2/28 and I want a template for "3"
;; since I don't work that far back in time, the logic is that I want to prepare
;; something for march 3
;; so what I have here is possibly a difference of 27 between the 28th and the 1st
;; but no less than 25, for the 3rd for ex.
;; if I am on the 30th and the template is for the 1st, I have a difference
;; of 29, that may go down to 27 for a template on the 3rd
;; if I am on the 31st and the template is for the 1st, the difference is 30
;; and goes down to 28 for a template on the 3rd
;; so I end up with absolute values between 30 and 25 that indicate
;; a max of 3 days behind or ahead of the current date, in different months
;; 
;; so let's use that as the base; I would not create a template for a date that's
;; more than 3 days apart.
;; so I'm going to check |myDate-today| and if it is over 24 then that's an edge case
;; and I know the month is different

(setq myToday
      (fourth (decode-time (float-time)))
      myYesterday 31);; 1
;; let's say I complete yesterday's temmplate, which is 31

(if (< 24 (abs (- myToday myYesterday)))
    "different month"
  "same month")

;; now there is the case of months. edge cases are clearer: 12 and 1
;; so if a yesterday is in December then the difference is 11
;; if tomorrow is in January, then the difference also is 11
;; which leads to a change of year too
;; if there is a date edge case, I need to change the month

;; the following computes basic values that I'll use later, just to store them
(setq Today (decode-time (float-time))
      
      thisMonth (fifth Today)
      nextMonth (if (= 12 thisMonth)
		    1
		  (+ thisMonth 1))
      lastMonth (if (= 1 thisMonth)
		    12
		  (- thisMonth 1))

      thisYear (sixth Today)
      nextYear (+ thisYear 1)
      lastYear (- thisYear 1))

;; now I take the difference between today and my date

;; if the difference is < 24 I assume that we are in the same month (see above)
;; else, if the difference is positive (today is a big number) then we need next month
;; otherwise we need last month

;; similar for the year, if my month is the current month, no change of year
;; if my month is next month and is 1 then we need next year
;; otherwise we need last year

;; myDate is the input let's test 31 for yesterday (12/31) and 3 for 1/3

(setq myDate 1
      dateDifference (- (fourth Today) myDate)
      myMonth (cond ((> 24 (abs dateDifference)) thisMonth)
		    ((natnump dateDifference) nextMonth)
		    (t lastMonth))
      myYear (cond ((= myMonth thisMonth) thisYear)
		   ((and (= myMonth nextMonth) (= myMonth 1)) nextYear)
		   (t lastYear)))

;; ok, it seems to work fine
;; from a given 1-2 digit entry, that I assume is a day not further than a few days from today
;; I get a month and a year


;; ok, so how do I put that as a function of myDate...

(defun myDate (Date)
  "Lists a plausible (year month date) ;; TODO add error tests
the date should be comprised between 1 and (28 to 31)
(myDate 3) -> (2020 1 3)"
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

(defun myLink ()
  (let* ((Today (decode-time (float-time))))
    (format "https://brandelune.github.io/%s/%s/%s/index.html" (sixth Today) (my0Padding (fifth Today)) (my0Padding (fourth Today)))
    ))

(defun myDailyRSSItem (myTitle pageLink pubDate myDescription)
  (interactive (list
                (read-string "Title: ")
                (read-string "Link: " (myLink))
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



