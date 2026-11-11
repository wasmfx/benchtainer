import kotlinx.coroutines.*
import kotlin.random.*
import kotlin.math.*
import kotlin.time.measureTime

val VERBOSE = false;

suspend fun main() {
    println("Hello from Kotlin/Wasm")

    // println("\n--- Itersum 100_000_000 ---")
    // testItersum(100_000_000)

    // println("\n--- Treesum 25 ---")
    // testTreesum(25)

    println("\n--- Pi ---")
    pi()
}

fun sqr(x : Double) : Double {
    return x * x;
}

fun testItersum(size: Int) {
    val range = sequence {
        var i = 0
        while (true) {
            yield(i++)
        }
    }

    val durations : MutableList<Long> = mutableListOf();

    for (i in 0..10) {
        var sum = 0
        val duration = measureTime {
            sum = range.take(size).sum()
        }
        if (VERBOSE) {
            println("  Sum: $sum")
            println("  Duration: ${duration.inWholeMilliseconds}ms")
        } else print(".")
        if (i > 0)  // Discard the warmup measurement
            durations.add(duration.inWholeMilliseconds);
    }
    val mean : Long = durations.sum() / durations.size;
    println("Mean Duration: ${mean}ms")
    val stddev = sqrt(durations.map{ sqr((it - mean).toDouble()) }.sum());
    println("StdDev Duration: ${stddev.toLong()}ms")
}

class Node(val height: Int, val left: Node?, val right: Node?) {
}

fun buildTree(height: Int) : Node {
    if (height == 0) {
        return Node(1, null, null)
    }

    val child = buildTree(height - 1)

    return Node(height, child, child)
}

suspend fun testCoroutines() {
    val itemCount = 10

    val duration = measureTime {
        repeat(itemCount) { i ->
            delay(100)
            println("Sequential task $i completed")
        }
    }
    println("Duration: ${duration.inWholeMilliseconds}ms")
}

suspend fun SequenceScope<Int>.searchTree(t: Node) { //}: Sequence<Int> = sequence {
    if (t.left == null || t.right == null) {
        yield(t.height)
    } else {
        searchTree(t.left)
        searchTree(t.right)
    }
}

fun testTreesum(height: Int) {
    val tree = buildTree(height)

    val range = sequence {searchTree(tree)}

    val durations : MutableList<Long> = mutableListOf();

    for (i in 0..10) {
        var sum = 0
        val duration = measureTime {
            sum = range.sum()
        }

        if (VERBOSE) {
            println("  Sum: $sum")
            println("  Duration: ${duration.inWholeMilliseconds}ms")
        } else print(".")
        if (i > 0)  // Discard the warmup measurement
            durations.add(duration.inWholeMilliseconds);
    }
    val mean : Long = durations.sum() / durations.size;
    println("Mean Duration: ${mean}ms");
    val stddev = sqrt(durations.map{ sqr((it - mean).toDouble()) }.sum());
    println("StdDev Duration: ${stddev.toLong()}ms");
}

suspend fun pi() {
    val duration = measureTime {
        val threads = mutableListOf<Deferred<Unit>>()
        withContext(Dispatchers.Default) {
            for (i in 0 .. numTasks) {
                threads.add(MainScope().async {
                    val pi = monteCarloPi()
                    println("Estimated Pi: $pi")
                })
            }
            for (t in threads) {
                t.await()
            }
        }
    }
    println("Duration for pi (one trial): $duration")
}

val batches = 50
val batchSize = 20_000
val numTasks = 1000

suspend fun monteCarloPi() : Double {
    var inside = 0
    var total = 0
    for (i in 0 until batches) {
        for (j in 0 until batchSize) {
            val x = Random.nextFloat()
            val y = Random.nextFloat()
            if (x * x + y * y <= 1.0) {
                inside++
            }
            total++
        }
        delay(0)
    }
    return 4.0 * inside / total
}
