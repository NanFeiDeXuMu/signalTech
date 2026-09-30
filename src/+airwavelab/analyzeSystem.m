function report = analyzeSystem(apply, firstInput, secondInput)
%ANALYZESYSTEM Run finite-record empirical system-property checks.

    validateattributes(apply, {'function_handle'}, {'scalar'});
    validateattributes(firstInput, {'numeric'}, ...
        {'vector', 'real', 'finite', 'nonempty'});
    validateattributes(secondInput, {'numeric'}, ...
        {'vector', 'real', 'finite', 'numel', numel(firstInput)});
    firstInput = firstInput(:);
    secondInput = secondInput(:);

    tolerance = 1e-10;
    a = 0.7;
    b = -1.1;
    lhs = applyChecked(apply, a*firstInput + b*secondInput);
    rhs = a*applyChecked(apply, firstInput) + b*applyChecked(apply, secondInput);
    linearityError = relativeError(lhs, rhs);

    shift = max(1, min(7, floor(numel(firstInput)/8)));
    shiftedInput = shiftRight(firstInput, shift);
    shiftedOutput = shiftRight(applyChecked(apply, firstInput), shift);
    outputFromShiftedInput = applyChecked(apply, shiftedInput);
    interior = shift+2:max(shift+2, numel(firstInput)-shift);
    timeInvarianceError = relativeError( ...
        outputFromShiftedInput(interior), shiftedOutput(interior));

    probeIndex = max(1, floor(numel(firstInput)/2));
    futureVariant = firstInput;
    if probeIndex < numel(firstInput)
        perturbation = reshape( ...
            linspace(0.1, 0.9, numel(firstInput)-probeIndex), [], 1);
        futureVariant(probeIndex+1:end) = ...
            futureVariant(probeIndex+1:end) + perturbation;
    end
    originalOutput = applyChecked(apply, firstInput);
    futureOutput = applyChecked(apply, futureVariant);
    futureDependenceError = relativeError( ...
        originalOutput(1:probeIndex), futureOutput(1:probeIndex));

    report = struct( ...
        "linearityError", linearityError, ...
        "timeInvarianceError", timeInvarianceError, ...
        "futureDependenceError", futureDependenceError, ...
        "appearsLinear", linearityError < tolerance, ...
        "appearsTimeInvariant", timeInvarianceError < tolerance, ...
        "appearsCausal", futureDependenceError < tolerance, ...
        "inputPeak", max(abs(firstInput)), ...
        "outputPeak", max(abs(originalOutput)), ...
        "finiteOutput", all(isfinite(originalOutput)));
end

function output = applyChecked(apply, input)
    output = apply(input);
    output = output(:);
    assert(numel(output) == numel(input), "AirWaveLab:SystemSizeChanged", ...
        "Systems used by analyzeSystem must preserve sample count.");
end

function output = shiftRight(input, shift)
    output = [zeros(shift, 1); input(1:end-shift)];
end

function value = relativeError(left, right)
    value = norm(left-right) / max(1, norm(right));
end
