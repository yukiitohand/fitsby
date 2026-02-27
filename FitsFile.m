classdef FitsFile < dynamicprops
    % FitsFile fits file handler 
    %   Read and load all the HDUs in the FitsFile. HDUs are loaded at property
    %   HDU as an array of FitsHDU objects. Primary HDU is accessible at
    %   property Primary and extension HDUs are all accessible by the properties
    %   of their EXTNAMEs with white spaces replaced with "_". So there are two
    %   ways to access an HDU: property HDU with the HDU number or property of
    %   the white-space replaced EXTNAME (or property Primary for the primary
    %   HDU.
    %
    % Syntax
    % ------
    % fitsfile = FitsFile(filename);
    % fitsfile = FitsFile(filename, dirpath);
    %
    % Without dirpath, filename is considered as the file path to the file.
    %
    % INPUTS
    % ------
    % filename: string | char
    %   Name of the file or file path.
    %
    % dirpath: string | char
    %   Directory of the file exist.
    %

    properties
        filepath  % File path to the fits file
        dirpath   % Directory path to the fits file
        filename  % Name of the fits file
        numHDUs   % Number of HDUs in the fits file.
        HDU       % Array of FitsHDU objects
        Primary   % FitsHDU object of the primary HDU.
    end

    methods
        function obj = FitsFile(varargin)
            % Constructor of class FitsFile
            %
            % Syntax
            % ------
            % fitsfile = FitsFile(filename);
            % fitsfile = FitsFile(filename, dirpath);
            % 
            % Without dirpath, filename is considered as the file path to the
            % file.
            %
            % INPUTS
            % ------
            % filename: string | char
            %   Name of the file or file path.
            %
            % dirpath: string | char
            %   Directory of the file exist.

            import matlab.io.*;
            p = inputParser;
            errmsgv = " must be a string/char array representing a file";
            addOptional(p, "filename", "", ...
                @(x) assert(isstring(x) || ischar(x), "filename" + errmsgv));

            addOptional(p, "dirpath", "", ...
                @(x) assert(isstring(x) || ischar(x), "dirpath" + errmsgv));
            
            parse(p, varargin{:});
            obj.filename = string(p.Results.filename);
            obj.dirpath = string(p.Results.dirpath);

            obj.filepath = fullfile(obj.dirpath, obj.filename);

            if exist(obj.filepath, "file")
               obj.read();
            end
        end

        function [] = read(obj)
            % method: read()
            %
            % Read HDUs in the fits file and store them at property HDU as an
            % array of FitsHDU in a order of HDU numbers, and dynamic properties
            % using their EXTNAMEs (with white spaces replaced with "_").
            %
            % INPUTS
            % ------
            % None
            %
            % OUTPUTS
            % -------
            % None
            %
            import matlab.io.*;
            fptr = fits.openFile(obj.filepath);
    
            obj.numHDUs = fits.getNumHDUs(fptr);
            for i=1:obj.numHDUs
                obj.HDU = [obj.HDU FitsHDU(fptr, i)];
            end
            obj.Primary = obj.HDU(1);

            for i=2:obj.numHDUs
                fldname = strrep(obj.HDU(i).name, " ", "_");
                if ~isprop(obj, fldname)
                    obj.addprop(fldname);
                end
                obj.(fldname) = obj.HDU(i);
            end

            fits.closeFile(fptr);

        end
    end
end