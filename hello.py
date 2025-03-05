from baml_client import b
from baml_client.types import Analysis
from baml_py import Image


def fix_missing_params(analysis: Analysis):
    missing_params = []
    for formula in analysis.formulas:
        for param in formula.parameters:
            if param not in analysis.keyAssumptions:
                missing_params.append(param)
    
    if missing_params:
        formulas = b.GetMissingParams(missing_params, analysis)
        for param in missing_params:
            if param not in formulas:
                raise ValueError(f"Could not find formula for parameter {param}")
        analysis.formulas.extend(formulas.values())
    return analysis



def analyze(image: Image):
    analysis = b.AnalyzeProforma(image)
    analysis = fix_missing_params(analysis)



