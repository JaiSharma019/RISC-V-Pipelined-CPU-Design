// POINTER CHASING BENCHMARK (Linked List Traversal)

// Define a Node containing data and a pointer (index) to the next node
struct Node {
    int value;
    int next_idx;
};

// Scrambled memory layout. 
// Using 'volatile' forces the hardware to physically read the RAM every time.
volatile struct Node pool[5] = {
    {10, 3},  // Node 0 -> points to Node 3
    {20, 4},  // Node 1 -> points to Node 4
    {30, 1},  // Node 2 -> points to Node 1 (THIS IS THE START NODE)
    {40, -1}, // Node 3 -> points to -1 (END OF LIST)
    {50, 0}   // Node 4 -> points to Node 0
};
// Expected Traversal: Node 2 -> 1 -> 4 -> 0 -> 3
// Expected Values: 30 + 20 + 50 + 10 + 40 = 150

// Force the 3 answers into the hardware Signature Region
__attribute__((section(".signature"))) int result[3] = {0, 0, 0};

int main() {
    int current_idx = 2; // Start at Node 2
    int sum = 0;
    int count = 0;
    int last_val = 0;

    // Traverse the list until we hit the null pointer (-1)
    while (current_idx != -1) {
        sum += pool[current_idx].value;
        last_val = pool[current_idx].value;
        current_idx = pool[current_idx].next_idx;
        count++;
    }

    // Write final metrics to 0x0800
    result[0] = sum;       // Expected: 150
    result[1] = count;     // Expected: 5
    result[2] = last_val;  // Expected: 40

    // Infinite trap
    while(1);
    return 0;
}