# chez-scheme-js
Chez Scheme on the web

## Browser

`chez-scheme-js` uses `SharedArrayBuffer`, which requires the COOP and COEP security
headers to be set and for there to be a secure context (either localhost or https).

```http
Cross-Origin-Opener-Policy: same-origin
// And one of:
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Embedder-Policy: credentialless
```

## Node.js

Node.js is currently unsupported. There is no technical reason it couldn't be,
but figuring out a build system that will support both Node.js and browsers takes some work.
PRs to do this will be accepted.

## Usage

```js
import Scheme from 'chez-scheme-js';

const scheme = new Scheme({
    error: err => console.error(err),
});

console.log(await scheme.init());
// Petite Chez Scheme Version 9.9.9-pre-release.14
// Copyright 1984-2022 Cisco Systems, Inc.
console.log(await scheme.runExpression(`
    (cdr '(1 2 3))

    (define (add-one n) (+ n 1))
    (add-one 2)
`));
// ["(2 3)", "3"]
console.log(await scheme.runExpression('(add-one 5)'));
// ["6"]
```

## Development

Run `npm i` to install dependencies.

This project uses Racket's modified Chez Scheme, which has support for compilation to WASM via Emscripten.
The binaries for it are not checked in, and you will need to compile them yourself.

### Compiling Chez Scheme

You will need `gcc`, `make`, `sh`, and similar programs. If you are using Windows, I recommend using WSL.
You will also need to [install Emscripten](https://emscripten.org/docs/getting_started/downloads.html).

Once you have everything installed, run `npm run build-chez`.
This will generate a custom WebAssembly build of Chez Scheme and copy the relevant artifacts into `src/chez`.

### Building

This project uses Webpack, and it can be compiled with `npm run build` or watched with `npm run watch`.

#### Publishing

First verify the package has all necessary files with `npm pack`. Then run `npm publish` when ready.

### Testing

Currently there are no automated tests. There is a playground in the `demo` directory which can be run with `npm run dev`.
