#!/bin/sh

outputFile="index.html"

htmlHead="<!doctype html>
<html>
  <head lang="en-us">
    <title>Css index</title>
    <link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"./2018/adventuresintechland.css\" />
    <meta charset=\"utf-8\" />
  </head>
  <body>
    <a href=\"../index.html\">..</a><br />
    <table>
      <thead>
        <tr><th>size (b)</th><th>creation date</th><th>name</th></tr>
      </thead>
      <tbody>"

htmlTail="      </tbody>
    </table>
  </body>
</html>"

echo "$htmlHead" > $outputFile ; 

ls -l * | grep css | sort -k 9 | awk '{print "          <tr><td class="size">" $5 "</td>\
<td class="date">" $6 " " $7 " " $8 "</td>\
<td class="link"><a href=\"./2018/" $9 "\">" $9 "</a></td></tr>"}' | cat >> $outputFile ;

echo "$htmlTail" >> $outputFile
