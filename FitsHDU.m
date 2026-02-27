classdef FitsHDU < handle
    % FitsHDU HDU handler in the fits file.
    %   HDU is short for Header Data Unit. FitsHDU stores header info at
    %   property hdr as a struct, a cell array of it at property hdrcell, and
    %   raw texts in a string array at property hdrcards.
    %
    %   Property data stores data. Image data is an array and also stored at
    %   property img. Ascii and binary tables are MATLB table objects and also
    %   stored at property tbl.
    %
    % Syntax
    % ------
    % hdu = FitsHDU(file);
    % hdu = FitsHDU(file, hdunum);
    %
    % INPUTS
    % ------
    % file: string | char | uint64 (Fits File Pointer)
    %   A string/char array representing a file path or a file pointer opened by
    %   fits.openFile or fits.openDiskFile.
    %
    % hdunum: nonnegative integer
    %   HDU number to read. If file is a file pointer and not given or 0 is
    %   given, HDU number is set to the current HDU of the pointer. If file is a
    %   file path, then you must give a positive HDU number.
    %
    properties
        filepath   % Path to a file contains the HDU
        HDUnum     % HDU number
        name       % "PRIMARY" if so, otherwise EXTNAME of the HDU.
        hdr        % Header in a struct format
        hdrcell    % Header in a cell format
        hdrcards   % Raw header strings.
        data_type  % Data type of HDU ["IMAGE_HDU", "BINARY_TBL", "ASCII_TBL"]
        data       % Data of the HDU
        img        % Image data of the HDU for "IMAGE_HDU".
        tbl        % Table data of the HDU for "BINARY_TBL" and "ASCII_TBL"
    end

    methods
        function obj = FitsHDU(varargin)
            % Constructor of FitsHDU.
            %
            % Syntax
            % ------
            % hdu = FitsHDU(file);
            % hdu = FitsHDU(file, hdunum);
            %
            % INPUTS
            % ------
            % file: string | char | uint64 (Fits File Pointer)
            %   A string/char array representing a file path or a file pointer
            %   opened by fits.openFile or fits.openDiskFile.
            %
            % hdunum: nonnegative integer
            %   HDU number to read. If file is a file pointer and not given or 0
            %   is given, HDU number is set to the current HDU of the pointer.
            %   If file is a file path, then you must give a positive HDU
            %   number.
            %

            import matlab.io.*;

            % Validate input arguments
            % ------------------------
            p = inputParser;
            errmsg_file = ...
                "file must be a string/char array representing a file " + ...
                " path or a file pointer\nopened by fits.openFile or " + ...
                "fits.openDiskFile";
            addOptional(p, "file", uint64(0), ...
                @(x) assert(isstring(x) || ischar(x) || isa(x, "uint64"), ...
                            errmsg_file));

            addOptional(p, "hdunum", 0, ...
                @(x) assert(isinteger(x) || x >= 0, ...
                            "hdunum must be a nonnegative integer."));

            parse(p, varargin{:});
            
            file = p.Results.file;
            hdunum = p.Results.hdunum;
            
            if isnumeric(file) && file == 0
                obj.filepath = "";
                obj.HDUnum = hdunum;
            else
                % Interpret the input file.
                if isstring(file) || ischar(file)
                    file_is_path = true;
                    fpath = file;
                    if ~exist(fpath, "file")
                        error("%s does not exist.", fpath);
                    end
                    if hdunum == 0
                        error("Provide HDU number (positive integer) when" + ...
                             "file is a file path. ");
                    end
                    fptr = fits.openFile(fpath);
                    obj.filepath = fpath;
                else
                    file_is_path = false;
                    fptr = file;
                    obj.filepath = fits.fileName(fptr);
                end
                
                % Move the pointer to the specified HDU.
                if hdunum > 0
                    fits.movAbsHDU(fptr, hdunum);
                end

                % Set HDUnum
                obj.HDUnum = fits.getHDUnum(fptr);
                
                % Read and load the header of HDU.
                obj.readhdr(fptr);

                % Set name.
                if obj.HDUnum == 1
                    obj.name = "Primary";
                else
                    obj.name = obj.hdr.EXTNAME;
                end
                
                % Read and load the data of HDU.
                obj.data_type = string(fits.getHDUtype(fptr));
                switch obj.data_type
                    case "IMAGE_HDU"
                        obj.data = fits.readImg(fptr);
                        obj.img = obj.data;
                    case {"BINARY_TBL", "ASCII_TBL"}
                        obj.data = obj.readTbl(fptr);
                        obj.tbl = obj.data;
                    otherwise
                        error("Unrecognized data type %s.", obj.data_type);
                end
                
                % If you give filepath to input file, close the file pointer.
                if file_is_path
                    fits.closeFile(fptr);
                end
            end
        end

        function [] = readhdr(obj, fptr)
            % Read Header component of the HDU.
            % 
            % The struct format of the header is stored at property hdr, a cell
            % format one is at property hdrcell, and a raw hdr as a string array
            % is at property hdrcards.
            %
            % INPUTS
            % ------
            % fptr: uint64
            %   File pointer opened by fits.openFile or fits.openDiskFile. fptr
            %   must be pointed to the HDU to read.
            %
            % OUTPUTS
            % -------
            % None
            %
            import matlab.io.*;
            [obj.hdrcell, obj.hdrcards] = fitsHDUhdrread2cell(fptr);
            [obj.hdr] = fitsHDUhdrcell2struct(obj.hdrcell);
        end

        function [data] = readTbl(obj, fptr)
            % Read data of the HDU of data type "BINARY_TBL" or "ASCII_TBL"
            %
            % INPUTS
            % ------
            % fptr: uint64
            %   File pointer opened by fits.openFile or fits.openDiskFile. fptr
            %   must be pointed to the HDU to read.
            %
            % OUTPUTS
            % -------
            % data: table
            %   BINARY_TABLE or ASCII_TABLE data as a table object.
            % 
            import matlab.io.*;
            nCol = fits.getNumCols(fptr);
            tbldata = cell(1, nCol);
            for i=1:nCol
                tbldata{i} = fits_readColx(fptr, i);
            end
            data = table(tbldata{:});
            [~, cns] = fits.getColName(fptr, "*", false);
            data.Properties.VariableNames = cns;
        end
    end
end