# Introduction to Elixir Concurrency

##### Outline

- Burrito Example
- Scheduling types
  - Preemptive
	- "Preemptive multitasking" means having a scheduler involved. The scheduler says, essentially, "you processes have to take turns. Each turn is N microseconds long. If you can finish your work in that much time, great. If not, I'll force you to pause and give someone else the CPU. You'll have to get back in line and continue when it's your turn again."
  - Non-preemptive
  - Co-operative
	- This means that each task must be polite, and say "I'm finished, now it's someone else's turn." This is nice if you're designing a single process, because you know it will never be interrupted unexpectedly.
- Erlang advantage


![]()

