### Standard and extended tasks



Autosar basic tasks

A basic task can be activated, runs, and terminates when finished

extended tasks and events
An extended task preforms a blocking wait for the occurrence of certain 
events. During the wait for events, the OS will schedule the next ready task
Events are assinged to tasks.

Extended Tasks can activate Basic tasks tru IOC (Inter OS Application Communication)






Interrupts


Cat1: No access to OS services

Cat2: Access to OS service functions, but not all services/functions are
allowed. Not allowed: TerminateTask, WaitEvent, ClearEvent, Schedule, ChainTask



Compu methods

Defines how the conversion from a physical to inegral interpretation can
be done, and vice versa. Not actually represented in code
Compu methods are globally defined:
Categories:
    - Identical 
    linear
    scale-linear
    text table
    scale linear and Text tabke
    Bit fieldText Table
