classdef FITS_KEYWORD_UNDEFINED < NullLikeObj
    % Dummy class to represent value UNDEFINED of keyword in the fits HDU 
    % header. This class corresponds to keyword defined such that
    %
    %   KEYWORD3=            / Undefined keyword.
    %
    % isempty(FITS_KEYWORD_UNDEFINED()) returns true.

    properties
        
    end

    methods
        function obj = FITS_KEYWORD_UNDEFINED()
        end

        function [tf] = eq(x, y)
            clsname = "FITS_KEYWORD_UNDEFINED";
            tfx = isa(x, clsname) || ((isstring(x) || ischar(x)) && x == "");
            tfy = isa(y, clsname) || ((isstring(y) || ischar(y)) && y == "");
            tf = tfx && tfy;
        end

        function [tf] = ne(x, y)
            tf = ~eq(x, y);
        end

    end
end
