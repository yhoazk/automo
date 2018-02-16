## vsomeip in 10 minutes

#### Table of contents
[SOME/IP Introduction](#intro)  
[SOME/IP On-Wire Format](#onwire)  
[SOME/IP Protocol](#protocol)  
[SOME/IP Service discovery](#sd)  
[vsomeip Short Overview](#vsomeip)  
[Preparation / Prerequisites](#prep)  
[First Application](#first)  
[Availability](#availability)  
[Request / Response](#request)  
[Subscribe / Notify](#subscribe)  
[Communication between two devices](#devices)  

<a name="intro"/>

#### SOME/IP Short Introduction

SOME/IP is an abbreviation for "Scalable service-Oriented middlewarE over IP". This middleware was designed for typical automotive use cases and for being compatible with AUTOSAR (at least on the wire-format level). A publicly accessible specification is available at http://some-ip.com/. In this wiki we do not want to deepen further into the reasons for another middleware specification, but want to give a rough overview about the basic structures of the SOME/IP specification and its open source implementation vsomeip without any claim of completeness.

Let's start with the three main parts of the SOME/IP specification:

- On-wire format
- Protocol
- Service Discovery

<a name="onwire"/>

##### SOME/IP On-Wire Format

In principle, SOME/IP communication consists of messages sent between devices or subscribers over IP. Consider the following picture:

![SOME/IP On-Wire Format](https://github.com/GENIVI/vsomeip/wiki/images/SOMEIPOnWireFormat.jpg)

There you see two devices (A and B); Device A sends a SOME/IP message to B and gets one message back. The underlying transport protocol can be TCP or UDP; for the message itself this makes no difference. Now we assume that on device B is running a service which offers a function that is called from device A by this message and the message back is the answer.

SOME/IP messages have two parts: header and payload. In the picture you see that the header consists mainly of identifiers:

- Service ID:	unique identifier for each service
- Method ID: 0-32767 for methods, 32768-65535 for events
- Length: length of payload in byte (covers also the next IDs, that means 8 additional bytes)
- Client ID: unique identifier for the calling client inside the ECU; has to be unique in the overall vehicle
- Session ID: identifier for session handling; has to be incremented for each call
- Protocol Version: 0x01
- Interface Version: major version of the service interface
- Message Type:
-- REQUEST (0x00) A request expecting a response (even void)
-- REQUEST_NO_RETURN (0x01) A fire&forget request
-- NOTIFICATION (0x02) A request of a notification/event callback expecting no response
-- RESPONSE (0x80) The response message
- Return Code:
-- E_OK (0x00) No error occurred
-- E_NOT_OK (0x01) An unspecified error occurred
-- E_WRONG_INTERFACE_VERSION (0x08) Interface version mismatch
-- E_MALFORMED_MESSAGE (0x09) Deserialization error, so that payload cannot be deseria-lized
-- E_WRONG_MESSAGE_TYPE (0x0A) An unexpected message type was received (e.g. RE-QUEST_NO_RETURN for a method defined as RE-QUEST)

We see that there are "REQUESTs" and "RESPONSEs" for normal function calls and notification messages for events to which the client has been subscribed. Errors are reported as normal responses or notifications but with an appropriate return code.

The payload contains the serialized data. The picture shows the serialization in the simple case that the transmitted data structure is a nested structure with only base data types. In this case it is easy: the struct elements are just flattened, that means that they are simply written one after the other into the payload.

<a name="protocol"/>

##### SOME/IP Protocol

In this section mainly 2 points are important and shall be described now:

- the so-called transport bindings (UDP and TCP)
- the basic communication patterns publish/subscribe and request/response.

As mentioned above the underlying transport protocol can be UDP or TCP. In the UDP case the SOME/IP messages are not fragmented; it can be that more than one message is in one UDP packet but one message cannot be longer than a UDP package can be (up to 1400 Bytes). Bigger messages must be transported via TCP. In this case all the robustness features of TCP are used. If a synchronization error in the TCP stream occurs, the SOME/IP specification allows so-call magic cookies in order to find again the beginning of the next message.

Please note that service interfaces must be instantiated and because there might be several instances of the same interface there must be an additional identifier for the instance defined (instance ID). However the instance ID is not part of the header of the SOME/IP message. The instance is identified via the port number of the transport protocol; that means that it is not possible that several instances of the same interface are offered on the same port.

Please take now a look at the following picture which shows the basic SOME/IP communication patterns:

![SOME/IP Protocol](https://github.com/GENIVI/vsomeip/wiki/images/SOMEIPProtocol.jpg)

In addition to the standard REQUEST/RESPONSE mechanism for remote procedure calls there is also the PUBLISH/SUBSCRIBE pattern for events. Note that events in the SOME/IP protocol are always grouped in an event group; therefore it is only possible to subscribe to event groups and not to the event itself. The SOME/IP specification also knows "fields"; in this case the setter/getter methods are following the REQUEST/RESPONSE pattern and notfication messages of changes are events. The subscription itself is done via the SOME/IP service discovery.

<a name="sd"/>

##### SOME/IP Service discovery

The SOME/IP Service Discovery is used to locate service instances and to detect if service instances are running as well as implementing the Publish/Subscribe handling. This is mainly done via so-called offer messages; that means that each device broadcasts (multicasts) messages which contain all the services which are offered by this device. SOME/IP SD messages are sent via UDP. If services are required by client applications but at the moment not offered, then also "find messages" can be sent. Other SOME/IP SD messages can be used for publishing or subscribing an eventgroup.

The following picture shows the general structure of a SOME/IP SD message.

![SOMEIP Service Discovery](https://github.com/GENIVI/vsomeip/wiki/images/SOMEIPServiceDiscovery.jpg)

This should be enough for the beginning. More details are discussed later in the examples or can be read in the specification.

<a name="vsomeip"/>

#### vsomeip Short Overview

Before we start to implement the introductory example, let's have a short look to the basic structure of the GENIVI implementation of SOME/IP which is called vsomeip.

![vsomeip Overview](https://github.com/GENIVI/vsomeip/wiki/images/vsomeipOverview.jpg)

As shown in the picture vsomeip covers not only the SOME/IP communication between devices (external communication) but also the internal inter process communication. Two devices communicate via so-called communication endpoints which determine the used transport protocol (TCP or UDP) and its parameters as the port number or other parameters. All these parameters are configuration parameters which can be set in a vsomeip configuration file (json file, see vsomeip user guide). The internal communication is done via local endpoints which are implemented by unix domain sockets using the Boost.Asio library. Since this internal communication is not routed via a central component (e.g. like the D-Bus daemon), it is very fast.

The central vsomeip routing manager gets messages only if they have to be sent to external devices and he distributes the messages coming from outside. There is only one routing manager per device; if nothing is configured the first running vsomeip application also starts the routing manager.

:exclamation: vsomeip does not implement the serialization of data structures! This is covered by the SOME/IP binding of CommonAPI. vsomeip just covers the SOME/IP protocol and the Service Discovery.

This was now a very, very short overview of SOME/IP and vsomeip. But for the first start it is enough; further details are explained directly in the examples.

<a name="prep"/>

#### Preparation / Prerequisites

As mentioned before vsomeip needs the Boost.Asio library, so make sure that you have installed BOOST on your system (at least version 1.55). When Boost has been successfuly installed, you can build vsomeip without further difficulty as usual:

```bash
$ cd vsomeip
<.>/vsomeip$ mkdir build
<.>/vsomeip$ cd build
<.>/vsomeip/build$ cmake ..
<.>/vsomeip/build$ make
```

This works, but in order to avoid some special problems afterwards I recommend to add at least one parameter to your CMake call:

```bash
<.>/vsomeip/build$ cmake -DENABLE_SIGNAL_HANDLING=1 ..
```

This parameter ensures that you can kill your vsomeip application without any problems (otherwise it might be that the shared memory segment /dev/shm/vsomeip is not be correctly removed when you stop the application with Ctrl-C).

<a name="first"/>

#### First Application

Create the first vsomeip application; let's call it `service-example`:

*service-example.cpp*
```cpp
#include <vsomeip/vsomeip.hpp>

std::shared_ptr< vsomeip::application > app;

int main() {

    app = vsomeip::runtime::get()->create_application("Hello");
    app->init();
    app->start();
}
```

It is very easy: you have to create first an application object and then to initialize and to start it.  The *init* method must be called first after creating a vsomeip application and executes the following steps to initialize it:

- Loading the configuration
- Determining routing configuration and initialization of the routing
- Installing signal handlers

The start method has to be called after *init* in order to start the message processing. The received messages are processed via sockets and registered callbacks are used to pass them to the user application.

READY :+1:

Now create a CMake file for building the application, it could look similar like this:

*CMakeLists.txt (Example)*
```cmake
cmake_minimum_required (VERSION 2.8)

set (CMAKE_CXX_FLAGS "-g -std=c++0x")

find_package (vsomeip 2.6.0 REQUIRED)
find_package( Boost 1.55 COMPONENTS system thread log REQUIRED )

include_directories (
    ${Boost_INCLUDE_DIR}
    ${VSOMEIP_INCLUDE_DIRS}
)

add_executable(service-example ../src/service-example.cpp)
target_link_libraries(service-example vsomeip ${Boost_LIBRARIES})
```
Go ahead as usual (create build directory, run CMake and build). Then start it (`service-example`). You should get the following output (or similar) on the console:

```bash
2017-03-20 10:38:20.885390 [info] Parsed vsomeip configuration in 0ms
2017-03-20 10:38:20.889637 [info] Default configuration module loaded.
2017-03-20 10:38:20.889797 [info] Initializing vsomeip application "World".
2017-03-20 10:38:20.890120 [info] SOME/IP client identifier configured. Using 0001 (was: 0000)
2017-03-20 10:38:20.890259 [info] No routing manager configured. Using auto-configuration.
2017-03-20 10:38:20.890367 [info] Instantiating routing manager [Host].
2017-03-20 10:38:20.890641 [info] init_routing_endpoint Routing endpoint at /tmp/vsomeip-0
2017-03-20 10:38:20.890894 [info] Client [1] is connecting to [0] at /tmp/vsomeip-0
2017-03-20 10:38:20.891039 [info] Service Discovery enabled. Trying to load module.
2017-03-20 10:38:20.891647 [info] Service Discovery module loaded.
2017-03-20 10:38:20.892045 [info] Application(World, 1001) is initialized (11, 100).
2017-03-20 10:38:20.892210 [info] Starting vsomeip application "World" using 2 threads
2017-03-20 10:38:20.892668 [info] Watchdog is disabled!
2017-03-20 10:38:20.893312 [info] Network interface "lo" is up and running.
2017-03-20 10:38:20.898471 [info] vSomeIP 2.6.2
2017-03-20 10:38:20.898708 [info] Sent READY to systemd watchdog
2017-03-20 10:38:20.898854 [info] SOME/IP routing ready.
```

Please note:

- These steps are the same for service and client; there is no difference. It is just a vsomeip application.
- Until now you do not need any configuraton file.

Let's discuss some points in detail.

- First you see the configuration that has been loaded; you have no configuration, therefore the default is used.
- You didn't configure a client ID for your application; therfore a vsomeip feature, the autoconfiguration, finds an appropriate client ID. The first number is `0x0001`.
- There is also no configuration for the routing manager; therefore the routing manager is automatically started with the first vsomeip application in the system and this is `service-example`. 
- By default is the Service Discovery enabled, no static routing. This would need some configuration parameters.
- The last `init()`output is `Application(World, 1) is initialized (11, 100)`. The two numbers at the end mean that the maximum numbers of dispatchers vsomeip uses is 11 if a callback blocks for more than 100ms. These parameters can be configured. 
- By default two threads are created for receiving SOME/IP messages; this allows vsomeip to handle long messages in parallel. 
- Then you see the current vsomeip version and the SOME/IP routing is ready. 

<a name="availability"/>

#### Availability

So far the application does not do too much work :smiley: And there is no difference between client and service. Now let's assume that our `service-example` is the service and we want to write a client that wants to use the service. In a first step we have to trigger the application to offer an instance of a service. This can be done by adding an *offer_service* command to our first example:

*service-example.cpp with offer*
```cpp
#include <vsomeip/vsomeip.hpp>

#define SAMPLE_SERVICE_ID 0x1234
#define SAMPLE_INSTANCE_ID 0x5678

std::shared_ptr< vsomeip::application > app;

int main() {

    app = vsomeip::runtime::get()->create_application("Hello");
    app->init();
    app->offer_service(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID);
    app->start();
}
```
In a next step we write an application that checks whether the running *"World"* application is available. Consider the following `client-example` code that creates an application with the name `Hello`:

*client-example.cpp*
```cpp
#include <iomanip>
#include <iostream>

#include <vsomeip/vsomeip.hpp>

#define SAMPLE_SERVICE_ID 0x1234
#define SAMPLE_INSTANCE_ID 0x5678

std::shared_ptr< vsomeip::application > app;

void on_availability(vsomeip::service_t _service, vsomeip::instance_t _instance, bool _is_available) {
    std::cout << "Service ["
            << std::setw(4) << std::setfill('0') << std::hex << _service << "." << _instance
            << "] is " << (_is_available ? "available." : "NOT available.")  << std::endl;
}

int main() {

    app = vsomeip::runtime::get()->create_application("Hello");
    app->init();
    app->register_availability_handler(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, on_availability);
    app->request_service(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID);
    app->start();
}
```

To keep it as simple as possible, we omitted all possible checks, for example whether the registration was successful. As client you have to tell vsomeip that you want to use the service and you need to register a callback in order to get a call when the service is available. The client output should now look similar to this:

```bash
Service [1234.5678] is NOT available.
2017-03-21 04:14:37.720313 [info] REQUEST(0002): [1234.5678:255.4294967295]
Service [1234.5678] is available.
```

The availability callback is called when the vsomeip event-loop is started by `app->start()`.

On service side there should be the following additional line:
```bash
2017-03-21 04:14:33.850964 [info] OFFER(0001): [1234.5678:0.0]
```
<a name="request"/>

#### Request / Response

Starting from a common vsomeip application we created a service which offers an instance of a service interface and a client which wants to use this interface. The next step is now to implement a function on service side which can be called by the client.

The service example must be prepared for receiving a message; this can be done by registering a message handler. Please have a look at the following code:

*service-example.cpp with offer and message handler*
```cpp
#include <iomanip>
#include <iostream>
#include <sstream>

#include <vsomeip/vsomeip.hpp>

#define SAMPLE_SERVICE_ID 0x1234
#define SAMPLE_INSTANCE_ID 0x5678
#define SAMPLE_METHOD_ID 0x0421

std::shared_ptr<vsomeip::application> app;

void on_message(const std::shared_ptr<vsomeip::message> &_request) {

    std::shared_ptr<vsomeip::payload> its_payload = _request->get_payload();
    vsomeip::length_t l = its_payload->get_length();

    // Get payload
    std::stringstream ss;
    for (vsomeip::length_t i=0; i<l; i++) {
       ss << std::setw(2) << std::setfill('0') << std::hex
          << (int)*(its_payload->get_data()+i) << " ";
    }

    std::cout << "SERVICE: Received message with Client/Session ["
        << std::setw(4) << std::setfill('0') << std::hex << _request->get_client() << "/"
        << std::setw(4) << std::setfill('0') << std::hex << _request->get_session() << "] "
        << ss.str() << std::endl;

    // Create response
    std::shared_ptr<vsomeip::message> its_response = vsomeip::runtime::get()->create_response(_request);
    its_payload = vsomeip::runtime::get()->create_payload();
    std::vector<vsomeip::byte_t> its_payload_data;
    for (int i=9; i>=0; i--) {
        its_payload_data.push_back(i % 256);
    }
    its_payload->set_data(its_payload_data);
    its_response->set_payload(its_payload);
    app->send(its_response, true);
}

int main() {

   app = vsomeip::runtime::get()->create_application("World");
   app->init();
   app->register_message_handler(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_METHOD_ID, on_message);
   app->offer_service(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID);
   app->start();
}
```

On client side it is a bit more complicated:

*client-example.cpp with message handler and send function*
```cpp
#include <iomanip>
#include <iostream>
#include <sstream>

#include <condition_variable>
#include <thread>

#include <vsomeip/vsomeip.hpp>

#define SAMPLE_SERVICE_ID 0x1234
#define SAMPLE_INSTANCE_ID 0x5678
#define SAMPLE_METHOD_ID 0x0421

std::shared_ptr< vsomeip::application > app;
std::mutex mutex;
std::condition_variable condition;

void run() {
  std::unique_lock<std::mutex> its_lock(mutex);
  condition.wait(its_lock);

  std::shared_ptr< vsomeip::message > request;
  request = vsomeip::runtime::get()->create_request();
  request->set_service(SAMPLE_SERVICE_ID);
  request->set_instance(SAMPLE_INSTANCE_ID);
  request->set_method(SAMPLE_METHOD_ID);

  std::shared_ptr< vsomeip::payload > its_payload = vsomeip::runtime::get()->create_payload();
  std::vector< vsomeip::byte_t > its_payload_data;
  for (vsomeip::byte_t i=0; i<10; i++) {
      its_payload_data.push_back(i % 256);
  }
  its_payload->set_data(its_payload_data);
  request->set_payload(its_payload);
  app->send(request, true);
}

void on_message(const std::shared_ptr<vsomeip::message> &_response) {

  std::shared_ptr<vsomeip::payload> its_payload = _response->get_payload();
  vsomeip::length_t l = its_payload->get_length();

  // Get payload
  std::stringstream ss;
  for (vsomeip::length_t i=0; i<l; i++) {
     ss << std::setw(2) << std::setfill('0') << std::hex
        << (int)*(its_payload->get_data()+i) << " ";
  }

  std::cout << "CLIENT: Received message with Client/Session ["
      << std::setw(4) << std::setfill('0') << std::hex << _response->get_client() << "/"
      << std::setw(4) << std::setfill('0') << std::hex << _response->get_session() << "] "
      << ss.str() << std::endl;
}

void on_availability(vsomeip::service_t _service, vsomeip::instance_t _instance, bool _is_available) {
    std::cout << "CLIENT: Service ["
            << std::setw(4) << std::setfill('0') << std::hex << _service << "." << _instance
            << "] is "
            << (_is_available ? "available." : "NOT available.")
            << std::endl;
    condition.notify_one();
}

int main() {

    app = vsomeip::runtime::get()->create_application("Hello");
    app->init();
    app->register_availability_handler(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, on_availability);
    app->request_service(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID);
    app->register_message_handler(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_METHOD_ID, on_message);
    std::thread sender(run);
    app->start();
}
```

Like on service side we need to register a message handler for receiving the response of our call. In principle it is very easy to create the send message (*request*). Just get the request object by calling `create_request()`, set service ID, instance ID and method ID and at the end write the payload with your serialized data. In the example here we write the values from 0 to 9 in the payload (`std::vector< vsomeip::byte_t >`). 

When we try to send our request from the client to the service then we run into a little problem. The application has to be started (`app->start()`) before we can send the message, because we need a running event-loop in order to process the message. But the method `app->start()` does not return because it has the running event-loop inside. Therefore we start a thread (`run`) and wait in this thread for the return of the availability callback before we call `app->send(request, true)`. 

Now you should get the output (I started the service first): 

```bash
2017-03-21 08:08:08.033710 [info] REQUEST(1002): [1234.5678:255.4294967295]
CLIENT: Service [1234.5678] is available.
2017-03-21 08:08:08.034182 [info] Client [1002] is connecting to [1001] at /tmp/vsomeip-1001
SERVICE: Received message with Client/Session [1002/0001] 00 01 02 03 04 05 06 07 08 09 
CLIENT: Received message with Client/Session [1002/0001] 09 08 07 06 05 04 03 02 01 00 
```
<a name="subscribe"/>

#### Subscribe / Notify

So far, we have created a service that implements a method and a client that calls this method. But that is not all that is possible :sunny:. The SOME/IP specification also describes an event handling. That means that application can send events to which subscribers can subscribe if they are interested. Together with the definition of setter and getter methods it is possible to implement services which provide attributes.

In order to make it not too complicated we remove in our example the implementation of the method call and implement the event handling. First let's have a look to the service.

Please add to your main function the following lines:

```cpp
const vsomeip::byte_t its_data[] = { 0x10 };
payload = vsomeip::runtime::get()->create_payload();
payload->set_data(its_data, sizeof(its_data));

std::set<vsomeip::eventgroup_t> its_groups;
its_groups.insert(SAMPLE_EVENTGROUP_ID);
app->offer_event(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_EVENT_ID, its_groups, true);
app->notify(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_EVENT_ID, payload);
```

:exclamation: Please note:

- You must offer the event in order to announce the existence of this event to the rest of the world.
- With the notify method you can send the event to anyone who has subscribed.
- Every event belongs to an event group! But it can also belong to several event groups.
- Events do not exist independently of the service; if the service has not been offered, then it is not available for the client and the client cannot subscribe.

On client side implement the following (for better understanding I omitted everything what has been discussed before):

```cpp
...

void run() {
  std::unique_lock<std::mutex> its_lock(mutex);
  condition.wait(its_lock);

  std::set<vsomeip::eventgroup_t> its_groups;
  its_groups.insert(SAMPLE_EVENTGROUP_ID);
  app->request_event(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_EVENT_ID, its_groups, true);
  app->subscribe(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, SAMPLE_EVENTGROUP_ID);

}

void on_message(const std::shared_ptr<vsomeip::message> &_response) {
    std::stringstream its_message;
    its_message << "CLIENT: received a notification for event ["
            << std::setw(4) << std::setfill('0') << std::hex
            << _response->get_service() << "."
            << std::setw(4) << std::setfill('0') << std::hex
            << _response->get_instance() << "."
            << std::setw(4) << std::setfill('0') << std::hex
            << _response->get_method() << "] to Client/Session ["
            << std::setw(4) << std::setfill('0') << std::hex
            << _response->get_client() << "/"
            << std::setw(4) << std::setfill('0') << std::hex
            << _response->get_session()
            << "] = ";
    std::shared_ptr<vsomeip::payload> its_payload = _response->get_payload();
    its_message << "(" << std::dec << its_payload->get_length() << ") ";
    for (uint32_t i = 0; i < its_payload->get_length(); ++i)
        its_message << std::hex << std::setw(2) << std::setfill('0')
            << (int) its_payload->get_data()[i] << " ";
    std::cout << its_message.str() << std::endl;
}

...

int main() {

    app = vsomeip::runtime::get()->create_application("Hello");
    app->init();
    app->register_availability_handler(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID, on_availability);
    app->request_service(SAMPLE_SERVICE_ID, SAMPLE_INSTANCE_ID);

    app->register_message_handler(vsomeip::ANY_SERVICE, vsomeip::ANY_INSTANCE, vsomeip::ANY_METHOD, on_message);

    std::thread sender(run);
    app->start();
}
```

You see that the implementation is without any difficulties:

- Again you need the eventgroup for the subscription to the event.
- You have to request the event before you can subscribe.
- For receiving the event just register a standard message handler; in this case you can use the very handy wild cards.

In the console you should now see the following lines:

```bash
2017-04-06 03:47:46.424942 [info] REGISTER EVENT(0001): [1234.5678.8778:is_provider=true]
2017-04-06 03:47:51.851654 [info] REGISTER EVENT(0002): [1234.5678.8778:is_provider=false]
...
2017-04-06 03:47:51.856821 [info] SUBSCRIBE(0002): [1234.5678.4465:ffff:0]
2017-04-06 03:47:51.861330 [info] SUBSCRIBE ACK(0001): [1234.5678.4465.ffff]
```

The numbers in the round brackets are again the client IDs; I started the service first, therfore the service has got from the autoconfiguration the number 1 and the client the number 2.

<a name="devices"/>

#### Communication between two devices

SOME/IP has not be invented for interprocess communication within one device (e.g. as D-Bus) but has been invented for the IP based communication between several devices. If you want to use the examples so far developed for the communication between two devices it is not necessary to change the C++ code; but you have to write vsomeip configuration files. Please look into the vsomeip user guide for details; here we just discuss the main points to get your system run.

I will first lose some introductory words about the vsoemip configuration generally. 

- The stack is configured by one or more files in json format (http://www.json.org/).
- The standard folder for the json files is `/etc/vsomeip`. 
- It is also possible to change this folder or to define a single configuration file by setting the environment variable `VSOMEIP_CONFIGURATION`.
- It is also possible to copy the configuration file to the folder which contains the executable application (local configuration).

For the following configuration example I assume that the service runs on a device with the address `172.17.0.2`and the client has the address `172.17.0.1`. 

First let's have a look to an example for the configuration of the service.

```json
{
    "unicast" : "172.17.0.2",
    "logging" :
    { 
        "level" : "debug",
        "console" : "true",
        "file" : { "enable" : "false", "path" : "/tmp/vsomeip.log" },
        "dlt" : "false"
    },
    "applications" : 
    [
        {
            "name" : "World",
            "id" : "0x1212"
        }
    ],
    "services" :
    [
        {
            "service" : "0x1234",
            "instance" : "0x5678",
            "unreliable" : "30509"
        }
    ],
    "routing" : "World",
    "service-discovery" :
    {
        "enable" : "true",
        "multicast" : "224.224.224.245",
        "port" : "30490",
        "protocol" : "udp",
        "initial_delay_min" : "10",
        "initial_delay_max" : "100",
        "repetitions_base_delay" : "200",
        "repetitions_max" : "3",
        "ttl" : "3",
        "cyclic_offer_delay" : "2000",
        "request_response_delay" : "1500"
    }
}
```

For the communication via IP the unicast address is mandatory. Let's discuss the other entries:

- *logging*:  These settings are optional; set "console"=true in order to see the log messages on the console.
- *applications*: You can define for each application (you created it by `create_application(<name>)`) a fixed client ID instead of having it determined by the autoconfiguration. This will help you later to identify your application in traces. **Here it is mandatory to set the client ID, because the client ID must be unique in your network.** If you don't set the clientID the autoconfiguration will calculate the clientID 1 on each device and the communication will not work. 
- *services*: For each service instance it must be defined under which port it can be reached. If the port is "unreliable" it is an UDP port, if it is "reliable", TCP will be the transport layer.
- *routing*: There is only one routing manager per device. This routing manager will be attached to the first vsomeip application which starts or to the application that is defined here.
- *service-discovery*: All these parameters only make sense if the service discovery is enabled. In this case the mandatory parameters are the multicast address which is used for sending the service discovery messages and port and protocol. The other parameters determine how often offer messages are sent, with whhich delay and so on. Please have a look to he user guide or teh SOME/IP specification.

:exclamation: Make sure that your device has been configured for receiving multicast messages (e.g. by `route add -nv  224.224.224.245 dev eth0` or similar; that depends on teh name of your ethernet device). 

Consider the following configuration of the client side:

```json
{
    "unicast" : "172.17.0.1",
    "logging" :
    {
        "level" : "debug",
        "console" : "true",
        "file" : { "enable" : "false", "path" : "/var/log/vsomeip.log" },
        "dlt" : "false"
    },
    "applications" : 
    [
        {
            "name" : "Hello",
            "id" : "0x1313"
        } 
    ],
    "routing" : "Hello",
    "service-discovery" :
    {
        "enable" : "true",
        "multicast" : "224.224.224.245",
        "port" : "30490",
        "protocol" : "udp",
        "initial_delay_min" : "10",
        "initial_delay_max" : "100",
        "repetitions_base_delay" : "200",
        "repetitions_max" : "3",
        "ttl" : "3",
        "cyclic_offer_delay" : "2000",
        "request_response_delay" : "1500"
    }
}
```

Since the client doesn't offer services, the "services" settings are not necessary.




