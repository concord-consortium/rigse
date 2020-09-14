# TypeScript Upgrade

## How to Build

Run `$ npm run build-library > typescript-errors.txt` to capture all the errors

## Done:

1. Add packages
2. Update webpack to use TypeScript loader
3. Start index.d.ts to type certain globals (like Portal)

## Todo:

1. Finish converting to importing jQuery (while still making it external)
2. Add imports for React (while still making it external)
3. Fix css module imports
4. Figure out how to update library.js so that PortalComponents is available for typechecking by callers
5. Convert all Component({...}) based components to React.Component classes
6. Resolve all errors in typescript-errors.txt
7. Change `noImplicitAny` to `true` in tsconfig.json and resolve errors
8. Rename all plain .js files to .ts and .js files with JSX to .tsx and update webpack config

