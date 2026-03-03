package main

import "strconv"
import "os"
import "fmt"
import "time"

type pair struct {
  v int
  stop bool
}

// Generate some numbers. (As it happens, the ones from 0..n.)
// Send them on the given channel.
func generator(c chan pair, n int) {
  for i := 0; i < n; i++ {
    c <- pair{i, false}
  }
  // Send a stop signal.
  c <- pair{0, true}
}

// Sum up the numbers sent on the given channcel.
func summer(c chan pair) int {
  result := 0
  for {
    p := <- c
    if p.stop {
      break
    }
    result += p.v
  }
  return result
}

func runsum(n int) {
  c := make(chan pair);
  go generator(c, n);
  summer(c);
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
