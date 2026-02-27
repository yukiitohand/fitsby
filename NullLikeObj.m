classdef NullLikeObj < matlab.mixin.CustomDisplay
    % Dummy class to represent a null-like value.
    %
    % isempty(NullLikeObj()) returns true.


    properties
        
    end

    methods
        function obj = NullLikeObj()

        end

        function [tf] = isempty(obj)
            tf = true;
        end

        function [tf] = eq(x, y)
            clsname = "NullLikeObj";
            tf = isa(x, clsname) && isa(y, clsname);
        end

        function [tf] = ne(x, y)
            tf = ~eq(x, y);
        end
    end
end