# XCP (universal Measurement and calibration protocol)

[src](https://vector.com/portal/medien/solutions_for/xcp/XCP_ReferenceBook_V3.0_EN.pdf)


XCP is the protocol that succeds CCP (CAN Calibration Protocol), the conceptual idea of
the CC was to permit R/W access to internal ECU data over CAN. XCP was developed to 
implment this capability via different transmission media.

Read and write access to memory are available with the mechanisms of the XCP protocol.
The accesses are made in address-oriented way. Read access enables measurement from
RAM, and write access enables calibration of the parameters in the RAM.

XCP permits execution of the measurement synchronous to events in the ECU. This 
ensures that  the measured values correlate with one another. With every restart of 
a measurement, the signals to be measured can be freely selected. For write access,
the paramenters to be calibrated must be stored in RAM.
