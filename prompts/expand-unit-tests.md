Your task is to increase the test coverage for this repository. Please follow these steps meticulously:

**1. Coverage Analysis**
Analyze the codebase to identify critical logic that lacks automated testing. Prioritize:
* **Core Business Logic:** Complex calculations or state transitions.
* **Error Handling:** Catch blocks and failure scenarios that are rarely triggered.
* **Edge Cases:** Boundary conditions (e.g., empty lists, null values, max integers).

**2. Test Strategy**
Before writing code, outline your plan:
* **Target:** The specific classes or functions you will test.
* **Scenarios:** A list of "Happy Path" (success) and "Unhappy Path" (failure) cases you intend to cover.
* **Mocking Strategy:** Identify external dependencies (DB, APIs) that need to be mocked to ensure tests are fast and deterministic.

**3. Test Implementation**
Write the test cases using the repository's existing testing framework.
* Ensure tests are **atomic** (independent of each other).
* Use descriptive test names that explain the scenario (e.g., `should_return_error_when_user_not_found`).

**4. Verification**
* **Run the new tests** to ensure they pass.
* **Verify Failure:** Temporarily break the source code to ensure the test actually fails (avoids "false positives").
