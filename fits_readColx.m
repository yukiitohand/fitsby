function [coldata, nullval] = fits_readColx(fptr, colnum, varargin)
% [coldata, nullval] = fits_readColx(fptr, colnum)
%   Reads an entire column from an ASCII or binary table column. nullval is a
%   logical array specifying if a particular element of coldata should be
%   treated as undefined. It is the same size as coldata. If the data type of
%   the column is "A" (characters), then it will convert char array(s) to string
%   array(s).
%   
% [coldata, nullval] = fits_readColx(fptr, colnum, firstrow, numrows)
%   Reads a subsection of rows from an ASCII or binary table column.
%
%  Usage
%  -----
%  >> [coldata,nullval] = readCol(fptr,colnum)
%  >> [coldata,nullval] = readCol(fptr,colnum,firstrow,numrows)
%
%  INPUTS
%  ------
%  fptr: uint64
%    File pointer (output of fits.openFile or fits.openDiskFile
%  colnum: integer
%    Column number to read.
%
%  Optional Inputs
%  ---------------
%  firstrow: integer
%    First row number to start reading.
%  numrows: integer
%    Number of rows to read.

import matlab.io.*
[coldata, nullval] = fits.readCol(fptr, colnum, varargin{:});

[dtype,repeat,width] = fits.getColType(fptr,colnum);

if dtype == "TSTRING"
    coldata = string(coldata);
end


end