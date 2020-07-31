function p = getBeatStructureParameters(mystruct, myfield, value)
% Return mystruct.myfield if it exists, otherwise return value
if  ~exist('value', 'var') && ~isfield(mystruct, myfield)
    error('Either value of mystruct.myfield must exist');
elseif exist('value', 'var') && ~isfield(mystruct, myfield) 
    p = value;
else
    p = mystruct.(myfield);
end