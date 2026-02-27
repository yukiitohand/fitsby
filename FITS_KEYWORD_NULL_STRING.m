classdef FITS_KEYWORD_NULL_STRING < NullLikeObj
    % Dummy class to represent the null string value of keyword in the fits HDU 
    % header. This class corresponds to string value ''. 
    % isempty(FITS_KEYWORD_NULL_STRING()) returns true.


    properties
        
    end

    methods
        function obj = FITS_KEYWORD_NULL_STRING()
        end

        function [tf] = eq(x, y)
            clsname = "FITS_KEYWORD_NULL_STRING";
            tfx = isa(x, clsname) || ((isstring(x) || ischar(x)) && x=="''");
            tfy = isa(y, clsname) || ((isstring(y) || ischar(y)) && y=="''");
            tf = tfx && tfy;
        end

        function [tf] = ne(x, y)
            tf = ~eq(x, y);
        end
    end
end
