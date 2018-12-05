;; code pour créer mes squelettes de HTML

;; The function takes a date d and returns a (d m y) list where (d m y) is the closest day to today
;; For ex, today is 2018/12/3
;; d=1 -> (1 12 2018)
;; d=30 -> (30 11 2018)
;; d=15 -> (15 12 2018)
;; I use the function in a template for a blog that I write one page a day.
;; When I launch the template for a given day, it creates links for the previous day and the next day
;; I used the "closest" assumption because I'm either writing the blog late, or outputing future days templates for preparation.


(defun getMyDate (myDay)
  (interactive)
  (if (or (> 1 myDay) (< 32 myDay))
      (setq ((myDay (nth 3 (decode-time))))
	    myDay))

  (let* ((decoded-now (decode-time (float-time)))
	 (myDateLastMonth (copy-sequence decoded-now))
	 (myDateThisMonth (copy-sequence decoded-now))
	 (myDateNextMonth (copy-sequence decoded-now))
	 (encoded-now (encode-time decoded-now 'integer))))
  
  ;; need to create "last month", "next month", "last year", "next year"
  ;; 1 day is 84600 seconds
  ;; 1 month is approximately 2,592,000 seconds
  ;; 1 year is approximately 31,536,000 seconds
  (let ((yesterDay (nth 3 (decode-time (- (float-time) 84600)))) ;; not used in the function
	(toMorrow (nth 3 (decode-time (+ (float-time) 84600)))) ;; not used in the function
	(lastMonth (nth 4 (decode-time (- (float-time) 2592000))))
	(thisMonth (nth 4 (decode-time))) ;; not used in the function
	(nextMonth (nth 4 (decode-time (+ (float-time) 2592000))))
	(lastYear (nth 5 (decode-time (- (float-time) 31536000))))
	(thisYear (nth 5 (decode-time))) ;; not used in the function
	(nextYear (nth 5 (decode-time (+ (float-time) 31536000)))))

    ;; create the data for last month
    (setf (nth 3 myDateLastMonth) myDay)
    (setf (nth 4 myDateLastMonth) lastMonth)
    (if (= lastMonth 12)
	(setf (nth 5 myDateLastMonth) lastYear))
    
    ;; create the data for this month
    (setf (nth 3 myDateThisMonth) myDay)

    ;; create the data for next month
    (setf (nth 3 myDateNextMonth) myDay)
    (setf (nth 4 myDateNextMonth) nextMonth)
    (if (= nextMonth 12)
	(setf (nth 5 myDateNextMonth) nextYear)))

  ;; compare the dates to find the closest
  (let (( a (abs (- now (encode-time myDateLastMonth 'integer))))
	(b (abs (- now (encode-time myDateThisMonth 'integer))))
	(c (abs (- (encode-time myDateNextMonth 'integer)))))

    (if (and (< a b) (< b c))
	(setq myMonth (nth 4 myDateLastMonth)
	      myYear (nth 5 myDateLastMonth))
      (if (and (< b a) (< b c))
	  (setq myMonth (nth 4 myDateThisMonth)
		myYear (nth 5 myDateThisMonth))
	(setq myMonth (nth 4 myDateNextMonth)
	      myYear (nth 5 myDateNextMonth))))
    ;; et voilà
    (setq (list myDay myMonth myYear))))

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
  (setq previousDay (- myDate 1))
  (setq previousDate (format "%s%s" (format-time-string "%m") previousDay))
  (setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay))
  (setq nextDay (+ myDate 1))
  (setq nextDate (format "%s%s" (format-time-string "%m") nextDay))
  (setq nextDayLink (format "../../%s/%s/index.html" (format-time-string "%m") nextDay))
  (setq todayDate (format "%s/%s/%s" (format-time-string "%Y") (format-time-string "%m") myDate))
  (setq todayPath (concat siteRoot todayDate "/"))
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
	<p class=\"navigation\">
	    <a href=\"%4$s\" hreflang=\"en\" rel=\"prev\">%5$s</a>
	    <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%6$s\" hreflang=\"en\" rel=\"next\">%7$s</a>
	</p>
	<p>%8$s, ...th day in a row</p>
	<h1>%1$s</h1>
        <p></p>
	<h2>%9$s</h2>
        <ul>
            <li></li>
            <li></li>
        </ul>
	<p class=\"navigation\">
	    <a href=\"%4$s\" hreflang=\"en\" rel=\"prev\">%5$s</a>
	    <a href=\"../../../index.html\" hreflang=\"en\">index</a>
	    <a href=\"%6$s\" hreflang=\"en\" rel=\"next\">%7$s</a>
	</p>
    </body>
</html>"
		myTitle          ;;  1$
		baseCSSLink      ;;  2$
		dailyCSSLink     ;;  3$
		previousDayLink  ;;  4$
		previousDate     ;;  5$
		nextDayLink      ;;  6$
		nextDate         ;;  7$
		todayDate        ;;  8$
		mySubtitle       ;;  9$
		myTitle          ;;  1$
		))
  
  (write-region todayTemplate nil todayIndex nil nil nil t)
  (make-empty-file todayCSS)
  (find-file todayCSS)
  (find-file todayIndex))


