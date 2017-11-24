# listenup

Basic port of the [Snowboy](https://github.com/Kitt-AI/snowboy) iOS example app to [fuse](https://www.fusetools.com) and android in particular.

## Why?

As with msgme, I like reference repos. This one in particular is far from best practices, but it does contain various forced examples of native interop, Observables, inclusion of native libraries, lots of EventEmitter, and of course, a keyword spotting capability.

## Pre-reqs

A working fuse development environment, and physical android device with an armv7 chipset.

## Build and Run

This one is nice and simple.

```
fuse preview --target=android
OR
fuse build --target=iOS -DCOCOAPODS --run
```

That'll fire it up loaded onto your connected android device. Once running, click the "listen" button, and as the instructions indicate, "Say Snowboy".


## Next Steps

- [x] Add iOS counterpart
- [x] Fix iOS Preview mode bug
- Clean up any UI oddities
- Add JS example of creating umdl via the REST API

