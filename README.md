# Unnamed project 

The Orbital Expansion Program (maybe? keep changeing the name), an open source 4x style managment game with "realistic" orbital dynamics.

## Quickstart

Compile and run the project, should work on any platform (tested on windows).
```
zig build run

zig build -Doptimize=ReleaseFast run
```

### Web with emscripten
**Build:** must install [emscripten](https://github.com/emscripten-core/emsdk) and activate (it adds to path).
```
../emsdk_path/emsdk activate

zig build -Dtarget=wasm32-emscripten --sysroot "$env:EMSDK\upstream\emscripten"
```
**Run:** also using emscripten which will start a server for the project files.
```
emrun .\zig-out\htmlout\index.html
```
Flags to add to the `emcc.zig` file, this is requiered for allocators to work.
```
"-sUSE_OFFSET_CONVERTER",
```

## The stack

Zig + raylib. Tried using raylib with C and it was a massive pain to compile. So zig is nice for it's cross compilation and easy single binary instalation. 

## Resources used

- [Zig language ref](https://ziglang.org/documentation/master/#Variables)
- [Zig build system tricks](https://ziggit.dev/t/build-system-tricks/3531)
- [N-body wikipedia](https://en.wikipedia.org/wiki/N-body_simulation)

### Back to school

- [Gravitation energy](https://physics.info/gravitation-energy/)

## TODO

Stoneshard in space, that's sort of the vibe I'm going for. At least right now. Slicing up this melon it should look something like this:

- [ ] An orbital system with some interesting features, maybe a recreatioin of the jovian system.
   - [ ] Comptime import jovian system parameters.
- [ ] A player controlled ship.
- [ ] UI to show some information and allows for switching certain fetures on/off.
- [ ] ... 


## Ephemeris DATA

The JPL is the ultimate source for precalculated ephemerides for [satellitesi (eg. moons of jupiter)](https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/satellites/), and this is very cool [planetary poisition from 13000 BCE to 17000 AD](https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/) 30k years of orbits calculated! And [docs on how to use the .spk files](https://naif.jpl.nasa.gov/naif/tutorials.html).

The principal tool in the cspice toolkit is [spkef_c](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/spklef_c.html) for reading the `.bsp` file. That documention has example code that shows pretty much what needs to be done. The there is some untested [chat gpt code](https://chatgpt.com/share/67152f22-76d0-8004-9fa2-5a4dacaf85c1), but it seems to be a bunch of bs.




### I'm distracted

Some 60 million years ago, the asteroid never hit. Proto humans evolved from dinasours, they conquered the whole system, some 15k years ago the fractured civilisation is at war. Over the next 30k years wage interplanitary war.


# TODO

MVU : look at using to for decoupling my UI to make it tesable.

TEA the elm architecture, more reading about MVU

write test, then fix code to work, when refactoring & adapting test to existing code. 

Burnstean : working with legacy code. "seams in code", cut the code then resow it together creating a seam to make an inpoint for testing.
