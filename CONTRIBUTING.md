# Guidelines for contributing code

Please read this document before submitting pull requests or contributing code.

This repository is part of a larger set of libraries for collecting data from
sensors and other devices to analyse physiological parameters in real-time. The 
goal of the development process is to conform to the “BS EN 62304:2006 Medical 
device software Software life-cycle processes” standard [1].

Because of performance requirements, much of the main infraestructure is 
developed in portable ANSI C/C++ programming language, C11/C++17 
standard-compliant. We follow the code guidelines described by the three 
following documents:

- 2004 Motor Industry Software Reliability Association (MISRA) Guidelines for
the use of the C Language in Critical Systems [2].
- 2008 Motor Industry Software Reliability Association (MISRA) Guidelines for
the use of the C++ Language in Critical Systems [3].
- Joint strike fighter air vehicle c++ coding standards for the system 
development and demonstration program by Lockheed Martin Corporation, 2005 [4].

For programming languages other than C/C++ (such as Swift, Python and Java),
we adjust the above coding guidelines so code can follow C++ format. For 
example, all words in an identifier (such as class, struct or variable names)
are separated by the ‘_’ character. Therefore, a valid name in Swift is:

```swift
let data_stream = try await peripheral.notification_values(for: characteristic)
```

and not

```swift
let dataStream = try await peripheral.notificationValues(for: characteristic)
```


## References

[1] BSI Group. Medical device software Software life-cycle processes. 
Number BS EN 62304:2006. British Standards Institution, 2008.

[2] The Motor Industry Software Reliability Association. MISRA-C:2004 Guidelines
 for the use of the C language in critical systems. MIRA, second edition, 2004.

[3] The Motor Industry Software Reliability Association. MISRA C++:2008 
Guidelines for the use of the C++ language in critical systems. MIRA, 
first edition, 2008.

[4] Lockheed Martin Corporation. Joint strike fighter air vehicle c++ coding 
standards for the system development and demonstration program. Number 
Document No. 2RDU00001 Rev C. Lockheed Martin, first edition, 2005.
