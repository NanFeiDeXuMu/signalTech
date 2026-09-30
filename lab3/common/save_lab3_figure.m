function save_lab3_figure(fig, cfg, filename)
%SAVE_LAB3_FIGURE Export an explicit figure and release it in batch mode.
folder = fullfile(cfg.output_dir, 'figures');
if ~isfolder(folder), mkdir(folder); end
exportgraphics(fig, fullfile(folder, filename), 'Resolution',180);
if strcmp(cfg.figure_visible, 'off'), close(fig); end
end
