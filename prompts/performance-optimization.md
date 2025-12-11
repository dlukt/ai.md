Your task is to optimize the performance of a specific bottleneck in this repository. Please follow these steps meticulously:

**1. Bottleneck Identification**
Analyze the codebase to find inefficient operations. Look for:
* **Algorithmic Complexity:** $O(n^2)$ or worse loops on large datasets.
* **I/O Blocking:** Synchronous database or API calls that should be asynchronous.
* **Memory Leaks:** Objects explicitly retained longer than necessary.

**2. Benchmarking Plan**
Before optimizing, establish a baseline:
* **The Metric:** Define what you are measuring (e.g., "Execution time in ms," "Memory usage in MB").
* **The Baseline:** Estimate or measure current performance.
* **The Goal:** Define the expected improvement (e.g., "Reduce execution time by 50%").

**3. Optimization Implementation**
Implement the performance fix.
* Focus strictly on the identified bottleneck.
* Explain the algorithmic change in comments if the new logic is complex.

**4. Comparative Verification**
* **Run tests** to ensure functionality remains correct.
* **Demonstrate Improvement:** Provide a comparison of the "Before" vs. "After" metrics to prove the optimization worked.
