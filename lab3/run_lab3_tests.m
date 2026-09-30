function results = run_lab3_tests(output_dir)
%RUN_LAB3_TESTS Deterministic numerical and WAV round-trip checks.
root=fileparts(mfilename('fullpath'));
if nargin<1, output_dir=fullfile(root,'output'); end
if ~isfolder(output_dir), mkdir(output_dir); end
results=runtests(fullfile(root,'tests'));
disp(results);
summary=table({results.Name}',[results.Passed]',[results.Failed]',[results.Incomplete]', ...
    'VariableNames',{'Test','Passed','Failed','Incomplete'});
writetable(summary,fullfile(output_dir,'test_results.csv'));
assert(all([results.Passed]),'Lab3:TestsFailed','Lab 3 validation failed.');
end
