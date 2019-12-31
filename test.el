;;;; now I need to compute dates
;;;; from _old.el
;;;; no edge case is considered, ugly stuff

;;;; siteRoot, necessary
(setq siteRoot (file-name-as-directory "/Users/suzume/Documents/Code/brandelune.github.io/"))

;;;; not sure what to do with that format-time-string, it looks like I use YYYY a lot
(setq myYear (format-time-string "%Y"))
(setq relativeCSSPath (file-name-as-directory (format "../../../%s/css/" myYear))) ;; 2019

;;;; CSS base file name, necessary
(setq baseCSSFilename ("adventuresintechland.css"))

;;;; the [Directory name] in the manual suggests using:
;;;;      (concat (file-name-as-directory DIRFILE) RELFILE)
(concat siteRoot baseCSSFile) ; -> already "file-name-as-directory"

;;;; I'll need to find what's the best way to create file paths safely
(setq path1 "/Users"
      path2 "suzume"
      path3 "Documents"
      path4 "Code"
      path5 "brandelune.github.io"
      cssfilename "stuff.css")

(concat (file-name-as-directory path1)
	(file-name-as-directory path2)
	(file-name-as-directory path3)
	(file-name-as-directory path4)
	(file-name-as-directory path5)
	cssfilename)
;;;; this works. good.
;;;; I can use that to store all sorts of partial paths for reuse

;;;; here I can use the above code for improvement
(setq yearBaseCSSLink (concat relativeCSSPath baseCSSFilename)) ;; "../../../css/2019/adventuresintechland.css"

;;;; same here, but I'll need to consider where to put the file in the end
(setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
;;;; maybe I need "baseDailyCSSPath" and "baseCSSFile" instead
(setq dailyCSSLink (concat
		    (file-name-as-directory baseDailyCSSPath)
		    baseCSSFile))
;;;; that's it for the CSS related paths, now everything becomes about day changes

;;;; myPreviousDayString is currently only subtracting 1 to myDate, and that doesn't work for 2 reasons:

;;;; 1) the previous days is often not current date -1
;;;; because I dont create html pages everyday

;;;; good, I've my ;;;; inserting command now...
;;;; ok, back to work

;;;; 2) in beginning of month/year the previous day is never current date -1

;;;; Hence, I need a way to ask for the previous day so that I am done with painful computations
;;;; also, there could be a way to detect the latest numbered folder in the tree and guess the day from that.

(defun foo (arg buff)
  "doc string"
  (interactive "P\nbbuffer: "))

;;;; The original code has lots of mechanisms that could be extracted from the funtion

(defun dailyIndex (myDate myLastDate myTitle mySubtitle)
  (interactive (list
                (read-string "Date: " (format-time-string "%d"))
		(read-string "Last date: " (format-time-string "%d"))
                (read-string "Title: " )
                (read-string "Sub-title: ")))
;;;; this part gets the input inside
;;;; could it be:
(defun dailyTest (myDate myYesterdate myTitle mySubtitle)
  (interactive "ntoday: 
nlast day: 
MTitle:
MSubtitle:")
  
  (setq siteRoot "/Users/suzume/Documents/Code/brandelune.github.io/")
  (setq baseCSSPath (format "../../../css/%s/" (format-time-string "%Y"))) ;; 2019
  (setq baseCSSFile "adventuresintechland.css")
  (setq dailyCSSFile (format "adventuresintechland%s%s.css" (format-time-string "%m") myDate)) ;; mmdd.css
  (setq baseCSSLink (concat baseCSSPath baseCSSFile))
  (setq dailyCSSLink (concat baseCSSPath dailyCSSFile))
;;;; this part creates a lot of paths, I discussed that above
  
  (setq previousDay (myPreviousDayString myDate))
;;;; this creates a string for the previous day and should really be a user input
  
  (setq previousDate (format "%s%s" (format-time-string "%m") previousDay)) ;; mmdd
;;;; this adds to the mess
  
  (setq previousDayLink (format "../../%s/%s/index.html" (format-time-string "%m") previousDay)) ;; mm/dd/index.html
;;;; this creates the link, which will eventually be a faulty link since the page might not exist
  
  (setq nextDay (myNextDayString myDate))
  (setq nextDate (format "%s%s" (format-time-string "%m") nextDay)) ;; mmdd
  (setq nextDayLink (format "../../%s/%s/index.html" (format-time-string "%m") nextDay)) ;; mm/dd/index.html
;;;; and the same happens for the next date, which is most probably not going to exist and it should not matter anyway
  
  (setq todayDate (format "%s/%s/%s" (format-time-string "%Y") (format-time-string "%m") myDate)) ;; yyyy/mm/dd
;;;; this date will be useful
  
  (setq todayPath (concat siteRoot todayDate "/"))
  (setq todayCSS (concat siteRoot "css/" (format-time-string "%Y") "/" dailyCSSFile)) ;; css/2019/advmmdd.css
  (setq todayIndex (concat todayPath "index.html"))
;;;; this is messed up paths creation
  
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
;;;; I should probably split that in a separate small function that creates the site navigation
  
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
;;;; here too, I should separate the head and body of the html

                myTitle          ;;  1$
                baseCSSLink      ;;  2$
                dailyCSSLink     ;;  3$
                todayDate        ;;  4$
                mySubtitle       ;;  5$

		todayNavigation  ;;  6$
                ))
  
  (write-region "" nil todayCSS nil t nil t)
  (make-directory todayPath)
  (write-region todayTemplate nil todayIndex nil t nil t))
;;;; and the output functions could be separate too.
