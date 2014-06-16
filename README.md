# XHRBulkTransferDemo for iOS

## What is this?

An experiment on bulk data transfer from native codo to JavaScript in WebView using XmlHttpRequest.

## Features

 * In-app minimum http server only works for this demonstration.
 * Multiple requests and responses through 1 TCP connection(persistent connection).

## Problem

 * XHR responses accumrates increasingly and are not released. Finally, this causes the app crashes.

## Result

 * Make chunk size larger, data throughput increases.
 * About 160 Mbps recorded at 1MB chunk on 1G iPad mini.
 * Because of the problem, this way is not useful.
