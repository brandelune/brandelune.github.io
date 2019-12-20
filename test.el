(write-region "stuff" nil "/Users/suzume/Documents/Code/brandelune.github.io/test.txt" nil t nil t)

(length myMarker)

(find-file-noselect "/Users/suzume/Documents/Code/brandelune.github.io/test2.xml")


(setq myTitle "myTitle"
      pageLink "pageLink"
      pubDate (format-time-string "%a, %d %b %Y %H:%m:%S UT" (current-time) t)
      myDescription "myDescription")

(defun genRSSItem ()
  (setq myRSSItem
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

(genRSSItem)

(setq myText myRSSItem
      myMarker "    <!-- place new items above this line -->"
      myFile "/Users/suzume/Documents/Code/brandelune.github.io/test.xml")

(defun myInsert (myText myMarker myFile)
  (save-current-buffer
    (set-buffer (find-file-noselect myFile))
    (goto-char (point-min))
    (goto-char (- (search-forward myMarker) (length myMarker)))
    (insert myText)
    (indent-region (point-min) (point-max))
    (save-buffer)
    (kill-buffer)))

(myInsert myText myMarker myFile)
