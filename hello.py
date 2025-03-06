from baml_client import b
from baml_client.types import Analysis
from baml_py import Image


def get_missing_params(analysis: Analysis) -> list[str]:
    valid_params = set(analysis.keyAssumptions)
    for formula in analysis.formulas:
        valid_params.add(formula.name)

    missing_params: list[str] = []
    for formula in analysis.formulas:
        for param in formula.parameters:
            if param not in valid_params:
                missing_params.append(param)
    # check if any formulas have the same name:
    return missing_params


def report_agent(image: Image):
    analysis = b.AnalyzeProforma(image)
    max_tries = 5

    missing_params = get_missing_params(analysis)

    while missing_params and max_tries > 0:
        max_tries -= 1
        print(f"Missing parameters: {missing_params}")
        new_formulas = b.GetMissingParams(missing_params, analysis)
        for formula in new_formulas:
            formula.formula.name = formula.name
            analysis.formulas.append(formula.formula)
        missing_params = get_missing_params(analysis)

    if missing_params:
        print(f"Still missing parameters: {missing_params}")
        print("Please provide the missing parameters with user input")

    return analysis

def run():
    result = report_agent(Image.from_url("https://i.imgur.com/9CYdOda.png"))
    print(result)

if __name__ == "__main__":
    run()

