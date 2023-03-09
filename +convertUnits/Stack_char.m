classdef Stack_char < Stack
    
    properties (Access = protected)
        stack_default = '';
        stack;
    end
    
    methods
        
        function obj = Stack_char()
            obj = obj@Stack();
        end
        
        function num = size(obj)
            num = length(obj.stack);
        end
        
        function bool = empty(obj)
            bool = obj.size() == 0;
        end
        
        function push(obj, element)
            if ischar(element)
                for i = 1:length(element)
                    obj.stack(end+1) = element(i);
                end
            else
                error('%c is not an char', element);
            end
        end
        
        function element = pop(obj)
            if ~obj.empty()
                element = obj.stack(end);
                obj.stack = obj.stack(1:end-1);
            else
                element = -1;
            end
        end
        
        function element = peek(obj)
            if ~obj.empty()
                element = obj.stack(end);
            else
                element = -1;
            end
        end
        
        function element = top(obj)
            if ~obj.empty()
                element = obj.stack(1);
            else
                element = -1;
            end
        end
        
        function reset(obj, new)
            if nargin <= 1
                new = obj.stack_default;
            end
            obj.stack = new;
        end
        
        function stack = content(obj)
            stack = obj.stack;
        end
        
    end
    
end