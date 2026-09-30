function results = run_tests()
%RUN_TESTS Run all AirWaveLab automated tests.

    root = fileparts(mfilename("fullpath"));
    addpath(fullfile(root, "src"));
    results = runtests(fullfile(root, "tests"));
    disp(results);
    assert(all([results.Passed]), "AirWaveLab:TestsFailed", ...
        "One or more AirWaveLab tests failed.");
end

