// httpserver -i 0.0.0.0 -p 8080 -d ./osconf/
package main

import (
  "flag"
  "fmt"
  "net/http"
  "log"
)

func main() {
    i := flag.String("i", "0.0.0.0", "ip address/host name")
    p := flag.String("p", "8080", "port number")
    d := flag.String("d", "./osconf", "http root dir")
    flag.Parse()
    fmt.Println(*i,*p,*d)
    http.Handle("/", http.FileServer(http.Dir(*d)))
    log.Fatal(http.ListenAndServe(*i+":"+*p, nil))
}
