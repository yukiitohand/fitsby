classdef FITS_KEYWORD_EMPTY_STRING < NullLikeObj
    % Dummy class to represent the empty string value of keyword in the fits HDU 
    % header. This class corresponds to string value ' '. 
    % isempty(FITS_KEYWORD_EMPTY_STRING()) returns true.

    properties
        
    end

    methods
        function obj = FITS_KEYWORD_EMPTY_STRING()
        end

        function [tf] = eq(x, y)
            clsname = "FITS_KEYWORD_EMPTY_STRING";
            tfx = isa(x, clsname) || ((isstring(x) || ischar(x)) && ...
                                      ~isempty(regexp(x, "^'\s+'$", "ONCE")));
            tfy = isa(y, clsname) || ((isstring(y) || ischar(y)) && ...
                                      ~isempty(regexp(y, "^'\s+'$", "ONCE")));
            tf = tfx && tfy;
        end

        function [tf] = ne(x, y)
            tf = ~eq(x, y);
        end
    end
end
