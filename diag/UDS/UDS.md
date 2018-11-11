# UDS: Unified diagnostic services ISO 14229

[1]: https://automotive.wiki/index.php/ISO_14229 "ISO_14229 wiki"

The ISO 14229 specifies data link independient requirements of diagnostic
services. It specifies generic services which allow the diagnostic tester to
stop or to resume non-diagnostic message transmisison on the data link.


## Terms and defiinitons

* **DTC: diagnostic trouble code**
    - Numerical common identifier for a fault condition identified by ODB system.
* **Diagnostic service**:
    - Information exchange initiated by a client in order to require diag
    information from a server adn/or to modify its behaviour for diag. 
    purposes.
* **client**:
    - Function that is part of the tester and that makes use of the 
    diagnostic services.

* **server**:
    - Function that is part of an electronic control unit that provides
    the diagnostic services.
* **tester**:
    - System that controls functions such as test, inspection, monitoring
    or diagnosis of an on-vehicle electronic control unit and which may
    be dedicated to a specific type of operator.
* **Functional unit**:
    - Set of functionally close or complementary diagnostic services.

* **Local server**:
* **Local client**:
* **remote server**:
* **remote client**:
* **permanent dtc**:
    - This type of DTCs are stored in NVRAM and not erasable by any test equipment 
    command or by disconnecting power to the on-board computer.

## Diag Jobs

### `0x10` Diagnostic Session Control
### `0x11` ECU reset
### `0x14` Clear Diagnostic Information
### `0x19` Read DTC Information
### `0x22` Read data by identifier
### `0x23` Read memory by address
### `0x27` Security Access
### `0x28` Communication Control
### `0x2A` Read data by periodic ID
### `0x2E` Write data by identifier
### `0x2F` Input Output Control by identifier
### `0x31` Routine Control
### `0x34` Request download
### `0x35` Request Upload
### `0x36` Transfer Data
### `0x37` Transfer Exit
### `0x3D` Write Memory by Address
### `0x3E` Tester Present
### `0x85` Control DTC Settings
 


## Negative response codes (NRC) for the services

The negative responses are divided in 3 ranges:
- `0x00`: Positive response parameter valuer for server internal implmenetation
- `0x01-0x7F`: Communication related negative responses.
- `0x80 - 0xFF`: Negative response codes for specific condtions that are not correct at the point in time the request is received by the server.
