function confplot(x, y, color, options)
%CONFPLOT Summary of this function goes here
%   Detailed explanation goes here
arguments
    x
    y
    color {validatecolor} = 'black'
    options.LineStyle = '.-'
    options.dim = 1
    options.Smooth = 0;
    options.Upper = []
    options.Lower = []
end
if ~isrow(x)
    x = x';
end

mean_y = mean(y, options.dim);
std_y = std(y, 0, options.dim);
fig = gca; % current figure handle
plot(x, mean_y, options.LineStyle, "Color", color, "Parent", fig);
upper = mean_y + std_y;
lower = mean_y - std_y;
if ~isempty(options.Upper)
    upper = min(options.Upper, upper);
end
if ~isempty(options.Lower)
    lower = max(options.Lower, lower);
end
if options.Smooth > 0
    upper = smoothdata(upper, 'movmean', options.Smooth);
    lower = smoothdata(lower, 'movmean', options.Smooth);
end

patch([x flip(x)], [upper flip(lower)], color, ...
"EdgeColor", "none", "FaceAlpha", 0.1, "Parent", fig, 'HandleVisibility', 'off');
end

