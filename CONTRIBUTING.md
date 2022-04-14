# Guidelines for contributing source code

This repository is part of a larger set of libraries designed for the
acquisition and real-time analysis of data transmitted from sensors and devices
that record physiological signals such as Electrocardiogram (ECG), 
Photoplethysmogram (PPG), Impedance Pneumograph (IP) and other physiological
parameters such as heart rate, peripheral oxygen saturation (SpO<sub>2</sub>), 
temperature and others. 

The goal of the development process is to gradually conform to the 
“BS EN 62304:2006 Medical device software - Software life-cycle processes” 
standard [1]. Because of performance requirements, much of the main 
infrastructure is developed in portable ANSI C/C++ programming language, 
C11/C++17 standard-compliant. We follow the coding guidelines described by the
following three documents:

- Motor Industry Software Reliability Association (MISRA) Guidelines for
the use of the C Language in Critical Systems [2].
- Motor Industry Software Reliability Association (MISRA) Guidelines for
the use of the C++ Language in Critical Systems [3].
- Joint strike fighter air vehicle C++ coding standards for the system 
development and demonstration program by Lockheed Martin Corporation [4].

For programming languages other than C/C++ (such as Swift, Python and Java),
we adjust the above coding guidelines so code can follow C++ format. For 
example, all words in an identifier (such as class, struct or variable name)
are separated by the ‘_’ character, we do NOT use CamelCase. Therefore, 
a valid name in Swift would be:

```swift
let data_stream = try await peripheral.notification_values(for: characteristic)
```

and not:

```swift
let dataStream = try await peripheral.notificationValues(for: characteristic)
```


## References

- **[1]** BSI Group. Medical device software - Software life-cycle processes. 
Number BS EN 62304:2006. British Standards Institution, 2008.
[BSI website](https://shop.bsigroup.com/products/bs-en-62304-health-software-software-life-cycle-processes-1/standard)

- **[2]** The Motor Industry Software Reliability Association (MISRA). 
MISRA-C:2012 Guidelines for the use of the C language in critical systems.
third edition, updated in February 2019.
[MISRA website](https://www.misra.org.uk/product/misra-c2012-third-edition-first-revision)

- **[3]** The Motor Industry Software Reliability Association (MISRA). 
MISRA C++:2008 Guidelines for the use of the C++ language in critical systems. 
first edition, 2008.
[MISRA website](https://www.misra.org.uk/product/misra-c2008)

- **[4]** Lockheed Martin Corporation. Joint strike fighter air vehicle
C++ coding standards for the system development and demonstration program. 
Doc No 2RDU00001 Rev C, first edition, 2005.
[PDF document](https://www.stroustrup.com/JSF-AV-rules.pdf)


