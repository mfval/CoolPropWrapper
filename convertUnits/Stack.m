classdef Stack < handle
    
    properties (Access = protected, Abstract = true)
        stack_default;
        stack;
    end
    
    methods
        
        function obj = Stack()
            obj.stack = obj.stack_default;
        end
        
        function num = size(obj)
            num = length(obj.stack);
        end
        
        function bool = empty(obj)
            bool = obj.size() == 0;
        end
        
        function push(obj, element)
            obj.stack(end+1) = element;
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
       
        function reset(obj)
            obj.stack = obj.stack_default;
        end
        
        function stack = content(obj)
            stack = obj.stack;
        end
        
    end
    
end