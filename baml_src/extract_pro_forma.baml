class ProformaMetrics {
  // Time Period
  period string @description("The time period of these metrics")
  // Financial Metrics
  effectiveGrossRevenue float @description("Total revenue after vacancy and credit losses")
  operatingExpenses float @description("Total operating expenses")
  netOperatingIncome float? @description("NOI - Revenue minus operating expenses")
  capitalExpenditures float? @description("Expected capital expenditures")
  cashFlowFromOperations float? @description("Operating cash flow after capex")

  // Valuation Metrics
  capRate float? @description("Capitalization rate used for valuation")
  propertyValue float? @description("Total property valuation")
  valuePerUnit float? @description("Property value per unit")
  yieldOnCost float? @description("Unlevered yield on total development cost")

  // Development Metrics
  totalProjectCost float? @description("Total cost of development")
  developmentSpread float? @description("Spread between cap rate and yield on cost in basis points")
}

class CostOfRevenue {
  support float
  hostingAndDelivery float
  total float
}

class GrossProfit {
  amount float
  margin float
}

class Expenses {
  engineering float
  generalAndAdmin float
  salesAndMarketing float
  total float
}

class CashFlow {
  operating float
  investing float
  financing float
  netChange float
}

class FinancialMetrics {
  arr float @description("Annual Recurring Revenue")
  revenue float @description("Monthly Revenue")
  costOfRevenue CostOfRevenue
  grossProfit GrossProfit
  expenses Expenses
  netIncome float
  cashFlow CashFlow
  bankBalance float
}

class Deltas {
  arr float
  revenue float
  netIncome float
  bankBalance float
}

class MonthlyComparison {
  month string @description("Month and year")
  target FinancialMetrics?
  actual FinancialMetrics
  deltas Deltas
}


class Analysis {
    keyAssumptions map<string, float | string>
    metric_type "proforma" | "monthly"
    proformaMetrics ProformaMetrics[]?
    monthlyMetrics MonthlyComparison[]?
    formulas Formula[] @description("Formulas used to calculate the metrics from assumptions")
}

class Formula {
    name string @description(#"
      like a function name
    "#)
    purpose string
    parameters string[] @description(#"
      usually keys in keyAssumptions
    "#)
    expression string
}

function AnalyzeProforma(data: image) -> Analysis {
//   client "openai/gpt-4o-mini"
  client CustomSonnet
  prompt #"
    
    Extract all the relavent data for proforma metrics.

    {{ ctx.output_format }}

    {{ _.role("user") }}
    {{ data }}
  "#
}

test TestName {
  functions [AnalyzeProforma]
  args {
    data { 
        file "../data/self-storage-dev-model.png"
    }
  }
}


test PLSheet {
  functions [AnalyzeProforma]
  args {
    data { 
        file "../data/pl-sheet.png"
    }
  }
}




function GetMissingParams(params: string[], analysis: Analysis) -> Formula[] {
  client CustomSonnet
  prompt #"
    Given a list of parameters, describe the formulas are missing.
    {{ analysis }}

    {{ ctx.output_format }}
    {{ _.role("user") }}
    Missing formulas for:
    {% for p in params %}
    - {{ p }}
    {% endfor %}
  "#
}

test TestName {
  functions [GetMissingParams]
  args {
    params ["totalRents"]
    analysis {
  "keyAssumptions" {
    "totalUnits" 425
    "netRentableArea" 84500
    "landArea" 5
    "numberOfBuildings" 12
    "height" "1.0-Story"
    "growthRate" 0.03
    "expenseGrowth" 0
    "effectiveRentPSF" 0.8
    "effectiveRentPerUnit" 138
    "generalVacancy" 0.1
    "operatingExpenseRatio" 0.2578
    "breakevenOccupancy" 0.7437
    "constructionDebtPercentage" 0.6
  }
  "proformaMetrics" [
    {
      "period" "Untrended"
      "effectiveGrossRevenue" 783426
      "operatingExpenses" 201931
      "netOperatingIncome" 581496
      "capitalExpenditures" 16900
      "cashFlowFromOperations" 564596
      "capRate" 0.065
      "propertyValue" 8946088
      "valuePerUnit" 21050
      "yieldOnCost" 0.0828
      "totalProjectCost" 7021116
      "developmentSpread" 178.2
        }
        {
      "period" "Trended"
      "effectiveGrossRevenue" 807472
      "operatingExpenses" 209617
      "netOperatingIncome" 597855
      "capitalExpenditures" 17581
      "cashFlowFromOperations" 580274
      "capRate" 0.065
      "propertyValue" 9197771
      "valuePerUnit" 21642
      "yieldOnCost" 0.0852
      "totalProjectCost" 7021116
      "developmentSpread" 201.5
        }
        {
      "period" "Sale"
      "effectiveGrossRevenue" 831696
      "operatingExpenses" 215905
      "netOperatingIncome" 615791
      "capitalExpenditures" 18109
      "cashFlowFromOperations" 597682
      "capRate" 0.065
      "propertyValue" 9473704
      "valuePerUnit" 22291
      "yieldOnCost" 0.0877
      "totalProjectCost" 7021116
      "developmentSpread" 227.1
        }
      ]
      "formulas" [
        {
      "name" "effectiveGrossRevenue"
      "purpose" "Calculate effective revenue after vacancy"
      "parameters" [
        "totalRents"
        "vacancyRate"
      ]
      "expression" "totalRents * (1 - vacancyRate)"
        }
        {
      "name" "netOperatingIncome"
      "purpose" "Calculate NOI"
      "parameters" [
        "effectiveGrossRevenue"
        "operatingExpenseRatio"
      ]
      "expression" "effectiveGrossRevenue * (1 - operatingExpenseRatio)"
        }
        {
      "name" "propertyValue"
      "purpose" "Calculate property value"
      "parameters" [
        "netOperatingIncome"
        "capRate"
      ]
      "expression" "netOperatingIncome / capRate"
        }
      ]
    }
  }
}
