This is a general purpose Flexible Image Transport System (FITS) reader for MATLAB based on MATLAB low-level fits functions in ``matlab.io.*`` library.
MATLAB high-level fits reader ``fitsread`` and ``fitsinfo`` does not support extensions well and does not properly read multiline header components.

This toolbox provides a more natural interface to read fits files.

Usage
-----
You just need class ``FitsFile`` to read and load all the header data units (HDU) in a reasonable structure.
You do not need to know the structure of fits files, just HDUs are read and loaded in order as found in the file.

``` matlab
>> fits_data = FitsFile("a.fits");
```
All the HDUs will be loaded to property ``HDU`` in order of the HDUs defined in the file. *i*th HDU can be accessed by
``` matlab
>> fits_data.HDU(i)
```
If you want to access an HDU by EXTNAME, then you can use an aliased property with EXTNAME_ 
``` matlab
>> fits_data.(EXTNAME_)
```
where EXTNAME_ is the name EXTNAME of the extension in which white spaces are replaced with underscores.

