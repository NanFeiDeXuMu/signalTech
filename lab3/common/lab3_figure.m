function fig = lab3_figure(cfg, name, height)
%LAB3_FIGURE Consistent canvas with English report labels.
if nargin < 3, height = 680; end
fig = figure('Name',name,'Color','w','Visible',cfg.figure_visible, ...
    'Position',[80,80,1100,height]);
set(fig, 'DefaultAxesFontSize',13, 'DefaultTextFontSize',13, ...
    'DefaultAxesFontName','Arial', 'DefaultTextFontName','Arial');
end
