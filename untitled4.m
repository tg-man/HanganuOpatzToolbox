

saveas(gcf, fullfile('Q:\Personal\Tony\Presentations\20231030_MeetingWithIleana\', 'fr_acc.fig'));
saveas(gcf, fullfile('Q:\Personal\Tony\Presentations\20231030_MeetingWithIleana\', 'fr_acc.svg'));


set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out');
set(gca, 'LineWidth', 2.8); 
title([]); 
title('MD', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial'); 

lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2.8;
end

ylabel('ERP (\muV)')
set(gca, 'XTick', [50 250 450])
xticklabels([-200 0 200]); 
xlim([0.4 2.6])

xticks([3 6 9])
xticklabels([0 3 6])
ylim([-0.9 -0.05])

xlabel('Time (s)')

ylim([-0.3 0.6])

xticklabels({['Dorsomedial' ...
    ' striatum'], ['Mediodorsal ' ...
    'thalamus']})

title('Anterior cingulate superfical layers \rightarrow dorsomedial striatum', 'FontWeight', 'bold')
set(gca, 'FontName', 'Arial', 'FontSize', 24, 'TickDir', 'out');

title('Dorsomedial striatum')
xlim([-50 125])
xticks([0 50])
