package main

import (
  "net/http"
  "log"
)

func main() {
    http.Handle("/", http.FileServer(http.Dir("./osconf/")))
    log.Fatal(http.ListenAndServe(":8080", nil))
}
