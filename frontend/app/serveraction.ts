"use server";

import { b } from "../baml_client";
import type { Analysis } from "../baml_client/types";
import { Image } from "@boundaryml/baml";

async function fixMissingParams(analysis: Analysis): Promise<Analysis> {
    const missingParams: string[] = [];
    for (const formula of analysis.formulas) {
        for (const param of formula.parameters) {
            if (!(param in analysis.keyAssumptions)) {
                missingParams.push(param);
            }
        }
    }

    if (missingParams.length > 0) {
        const formulas = await b.GetMissingParams(missingParams, analysis);
        for (const param of missingParams) {
            if (!formulas.find((f) => f.name !== param)) {
                throw new Error(`Could not find formula for parameter ${param}`);
            }
        }
        analysis.formulas.push(...formulas);
    }
    return analysis;
}

export async function analyzeImage(image: Image): Promise<Analysis> {
    let analysis = await b.AnalyzeProforma(image);
    analysis = await fixMissingParams(analysis);

    console.log(analysis);
    return analysis;
}
