echo "<!doctype html>
<html>
  <head>
    <title>Css index</title>
    <link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"./css/adventuresintechland1118.css\" />
    <meta charset=\"utf-8\" />
  </head>
  <body>
    <a href=\"../index.html\">..</a><br />
    <table>
      <thead>
        <tr><th>size (b)</th><th>creation date</th><th>name</th></tr>
      </thead>
      <tbody>" | cat > index.html ; ls -l 2018 | grep css | cut -d " " -f 8-12 | sort -t " " -k 2 | awk '{print "          <tr><td>" $1 "</td><td>" $2 " " $3 " " $4 "</td><td><a href=\"./2018/" $5 "\">" $5 "</a></td></tr>"}' | cat >> index.html ; echo "      </tbody>
    </table>
  </body>
</html>" | cat >> index.html
