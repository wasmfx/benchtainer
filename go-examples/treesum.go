package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type tree struct {
	val         int32
	left, right *tree
}

func makeTree(height int32, leafVal int32) tree {
	if height == 0 {
		return tree{leafVal, nil, nil}
	} else {
		children := makeTree(height-1, leafVal)
		return tree{0, &children, &children}
	}
}

// Traverse the tree and send all the leaf values on the channel.
func generator(c chan int32, t tree, arg0 int32, arg1 int32, arg2 int32) {
	if t.val != 0 {
		c <- t.val + arg0 + arg1 + arg2
	} else {
		if t.left != nil {
			generator(c, *t.left, arg0, arg1, arg2)
		}
		if t.right != nil {
			generator(c, *t.right, arg1, arg2, arg0)
		}
	}
}

func runGenerator(c chan int32, t tree) {
	generator(c, t, 0, 1, 2)
	close(c)
}

// Sum up the numbers sent on the given channel.
func summer(c chan int32) int32 {
	result := int32(0)
	for {
		p, more := <-c
		if !more {
			break
		}
		result += p
	}
	return result
}

func runsum(n int32) {
	t := makeTree(n, 1)
	result := int32(0)
	for i := 0; i < (1 << (24 - n)); i++ {
		c := make(chan int32)
		go runGenerator(c, t)
		result = summer(c)
	}
	fmt.Println("Result: ", result)
}

func main() {
	print("hi\n")
	first, err := strconv.Atoi(os.Args[1])
	if err != nil {
		panic("arg not parsed as int32")
	}
	last, err := strconv.Atoi(os.Args[2])
	if err != nil {
		panic("arg not parsed as int32")
	}

	for i := int32(first); i <= int32(last); i++ {
		start := time.Now()
		runsum(i)
		fmt.Println(i)
		fmt.Println("Time: ", time.Since(start))
	}
}

// ok:wq
