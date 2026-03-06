package main

import "strconv"
import "os"
import "fmt"
import "time"

func consumer(c chan int) {
  x := 0
  for {
    x = <- c
  }
  fmt.Println("consumer says", x)
}

func runsum(n int) {
  // The second parameter is a channel depth. Sending blocks the thread exactly when that depth is
  // full, and no sooner. If it blocks it will trigger a deadlock detector that recognizes there is
  // no consumer. So to test raw sends, we use a large channel depth.
  c := make(chan int, n+1)
  // You can also test send+receive together using this consumer; in that case set the depth to n-1.
  // go consumer(c)
  start := time.Now()
  for i := 0; i < n; i++ {
    c <- i
    if i % 1000000 == 0 {
      fmt.Println(time.Since(start))
    }
  }
}

func main() {
  first, err := strconv.Atoi(os.Args[1])
  if err != nil { panic("arg not parsed as int") }
  last, err := strconv.Atoi(os.Args[2])
  if err != nil { panic("arg not parsed as int") }
  
  for i := first; i <= last; i++ {
    start := time.Now()
    runsum(i * 1000000)
    fmt.Println(i)
    fmt.Println("Time: ", time.Since(start));
  }
}
