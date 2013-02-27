This project demonstrates a loss of data that can occur in NSHTTPCookieStorage ([rdar://13293418](http://openradar.appspot.com/radar?id=2776403)).

Problem description
===================

The content of a NSHTTPCookieStorage instance is synchronized to the disk periodically. However, if an app crashes before the cookies are synchronized, the unsaved cookies are lost.

Actually…
=========

While coding this demo project, I realized that the data loss doesn't occur when the app crashes, exit() or abort().

Only a **SIGKILL** (like when the debugger exits) trigger this issue.

As it doesn't occur in normal conditions (but only when debugging), I closed the Radar.
We just have to add to the common knowledge that NSHTTPCookieStorage is not immune to SIGKILL.
