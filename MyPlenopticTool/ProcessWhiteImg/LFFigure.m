function h = LFFigure(h, varargin)
% LFFIGURE (originally sfigure) Create figure window (minus annoying focus-theft).
%
% Usage is identical to figure.
%
% Daniel Eaton, 2005
%
% See also figure

if nargin>=1 
	if ishandle(h)
		set(0, 'CurrentFigure', h);
	else
		h = figure(h, varargin{:});
	end
else
	h = figure;
end
