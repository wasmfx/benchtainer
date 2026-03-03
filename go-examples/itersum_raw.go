package main

// import "strconv"
// import "os"
import "time"
import "fmt"

func sum(n int) int {
  result := 0
  for i := 0; i < n; i++ {
    result += i
  }
  return result
}

// func main() {
//   n, err := strconv.Atoi(os.Args[1])
//   if err != nil {
//     panic("arg not parsed as int")
//   }		
//   fmt.Println(sum(n))
// }

func main() {
  for i := 0; i < 20; i++ {
    start := time.Now()
    fmt.Println(sum(i * 1000000))
    fmt.Println(i)
    fmt.Println("Time: ", time.Since(start));
  }
}
