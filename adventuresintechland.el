;; code pour créer mes squelettes de HTML

;; The function takes a date d and returns a (d m y) list where (d m y) is the closest day to today
;; For ex, today is 2018/12/3
;; d=1 -> (1 12 2018)
;; d=30 -> (30 11 2018)
;; d=15 -> (15 12 2018)
;; I use the function in a template for a blog that I write one page a day.
;; When I launch the template for a given day, it creates links for the previous day and the next day
;; I used the "closest" assumption because I'm either writing the blog late, or outputing future days templates for preparation.

(defun getMyDates (myDay)
  ;; if the number is not between 1 and 31, the value defaults to today's date
  (if (or (> 1 myDay) (< 32 myDay))
      (setq myDay (nth 3 (decode-time))))

  (let* ((now (decode-time (float-time)))
         (myDatelastMonth (copy-sequence now))
         (myDatethisMonth (copy-sequence now))
         (myDatenextMonth (copy-sequence now))
         (now (encode-time now 'integer))

         ;; need to create "last month", "next month", "last year", "next year"
         ;; 1 day is 84600 seconds
         ;; 1 month is approximately 2,592,000 seconds
         ;; 1 year is approximately 31,536,000 seconds

         (yesterDay (nth 3 (decode-time (- (float-time) 84600))))
         (toMorrow (nth 3 (decode-time (+ (float-time) 84600))))
         (lastMonth (nth 4 (decode-time (- (float-time) 2592000))))
         (thisMonth (nth 4 (decode-time)))
         (nextMonth (nth 4 (decode-time (+ (float-time) 2592000))))
         (lastYear (nth 5 (decode-time (- (float-time) 31536000))))
         (thisYear (nth 5 (decode-time)))
         (nextYear (nth 5 (decode-time (+ (float-time) 31536000)))))

    ;; create the data for last month
    (setf (nth 3 myDatelastMonth) myDay)
    (setf (nth 4 myDatelastMonth) lastMonth)
    (if (= lastMonth 12)
        (setf (nth 5 myDatelastMonth) lastYear))

    ;; create the data for this month
    (setf (nth 3 myDatethisMonth) myDay)

    ;; create the data for next month
    (setf (nth 3 myDatenextMonth) myDay)
    (setf (nth 4 myDatenextMonth) nextMonth)
    (if (= nextMonth 12)
        (setf (nth 5 myDatenextMonth) nextYear))

  ;; compare the dates to find the closest
  (let ((toLastMonth (abs (- now (encode-time myDatelastMonth 'integer))))
        (toThisMonth (abs (- now (encode-time myDatethisMonth 'integer))))
        (toNextMonth (abs (- (encode-time myDatenextMonth 'integer)))))

    (if (and (< toLastMonth toThisMonth)
             (< toThisMonth toNextMonth))
        (setq myMonth (nth 4 myDatelastMonth)
              myYear (nth 5 myDatelastMonth))
      (if (and (<= toThisMonth toLastMonth)
               (< toThisMonth toNextMonth))
          (setq myMonth (nth 4 myDatethisMonth)
                myYear (nth 5 myDatethisMonth))
        (setq myMonth (nth 4 myDatenextMonth)
              myYear (nth 5 myDatenextMonth)))))
  ;; et voilà
  (encode-time (list 0 0 12 myDay myMonth myYear nil nil 32400) 'integer)))


(defun dailyTemplate (myDay myTitle mySubtitle)
  (interactive (list
                (read-number "Date: " (string-to-number (format-time-string "%d")))
		(read-string "Title: " )
		(read-string "Sub-title: ")))

  (let* ((myToday (getMyDates myDay))
	 (myTomorrow (+ myToday 84600))
	 (myYesterday (- myToday 84600))
	 (siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
	 (baseCSSPath (format "../../../css/%s/"
			      (format-time-string "%Y" myToday)))
	 (baseCSSFile "adventuresintechland.css")
	 (dailyCSSFile (format "adventuresintechland%s%s.css"
			       (format-time-string "%m" myToday)
			       (format-time-string "%d" myToday)))
	 (baseCSSLink (concat baseCSSPath baseCSSFile))
	 (dailyCSSLink (concat baseCSSPath dailyCSSFile))
	 
	 (previousDay (format-time-string "%d" myYesterday))
	 (previousDate (format "%s%s"
			       (format-time-string "%m" myYesterday)
			       previousDay))
	 (previousDayLink (format "../../%s/%s/index.html"
				  (format-time-string "%m" myYesterday)
				  previousDay))

	 (nextDay (format-time-string "%d" myTomorrow))
	 (nextDate (format "%s%s"
			   (format-time-string "%m" myTomorrow)
			   nextDay))
	 (nextDayLink (format "../../%s/%s/index.html"
			      (format-time-string "%m" myTomorrow)
			      nextDay))

	 (todayDate (format "%s/%s/%s"
			    (format-time-string "%Y" myToday)
			    (format-time-string "%m" myToday)
			    (format-time-string "%d" myToday)))
	 (todayPath (concat siteRoot todayDate "/"))
	 (todayCSS (concat siteRoot "css/" (format-time-string "%Y" myToday) "/" dailyCSSFile))
	 (todayIndex (concat todayPath "index.html"))

	 (todayTemplate
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
		  )))
  
    (write-region todayTemplate nil todayIndex nil t nil t)
    (make-empty-file todayCSS)
    (find-file todayIndex)))
