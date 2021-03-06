# Reusing Code Through "Linking"
### Warning: The extension of Rholang to allow for importing/exporting macros is only temporary! In a future release the Rholang compiler will include a proper package management system.

## Usage
```
$ scala link.scala <rholangSource> <libraryDirectory>
```
Where `<rholangSource>` is the file to be linked with packages (i.e. imports resolved) and `<libraryDirectory>` is a directory with all the Rholang sources with `export` declarations.

`link.scala` provides facility for "linking" Rholang source code. Linking is done  by trans-piling extended Rholang source into standard Rholang source. The extended Rholang includes two new keywords: `export` and `import`. These two keywords work very similarly to the `new` keyword in standard Rholang, but `export` has the restriction that only a single  name can be declared (i.e. `export x, y in { ... }` would be INVALID). Also note that `export` and `import` declarations can only appear at the "top level" of a file -- i.e. NOT inside `contract` definitions, bodies of `for` statements or `match` cases, etc. `export`s can use `import`s from other packages so long as there is not a loop of `import`s (e.g. if Y imports X then X cannot import Y or anything that depends on Y).

When `link.scala` is used on a Rholang source containing the `import` keyword, the import is mapped into a standard `new` statement, but with the code block following the `in` extended to include the code from the corresponding `export` declaration (which can, and should, reside in a separate file). This "linked" output can then be compiled and run as usual because it is standard Rholang.

### Example: 
Let's say X.rho contains
```
  export X in { contract X(input, return) = { return( 2 * input ) } }
```
and that Y.rho contains
```
  import X in { new Y in { contract Y(return) = { X(5, return) } } }
```
Then linking Y.rho would result in the file Y.rho.linked with the contents
```
   new X in {
     contract X(input, return) = { return( 2input ) } | 
     new Y in { contract Y(return) = { X(5, return) } }
   }
```