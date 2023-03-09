classdef Stack_cell < Stack
    
    properties (Access = protected)
        stack_default = {};
        stack;
    end
    
    methods
        
        function obj = Stack_cell()
            obj = obj@Stack();
        end
        
        function num = size(obj)
            num = length(obj.stack);
        end
        
        function bool = empty(obj)
            bool = obj.size() == 0;
        end
        
        function push(obj, element)
            if iscell(element)
                obj.stack(end+1) = element;
            else
                error('Element is not a cell');
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
        
    end
    
end